package server

import (
	"backend/internal/broadcaster"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"log"
	"net"
	"net/http"
	"os"
	"time"

	"github.com/gorilla/websocket"
	"github.com/pion/webrtc/v3"
)

type Server struct {
	mux         *http.ServeMux
	server      *http.Server
	broadcaster *broadcaster.Broadcaster
}

func (s *Server) wsHandler(w http.ResponseWriter, r *http.Request) {
	log.Println("/ws handler called")
	upgrader := websocket.Upgrader{
		CheckOrigin: func(r *http.Request) bool { return true },
	}
	conn, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Println(errors.Join(errors.New("WebSocket upgrade error"), err))
		return
	}
	defer func() {
		log.Println("WebSocket connection closed")
		conn.Close()
	}()
	log.Println("WebSocket connection established")

	// GStreamer is no longer started or stopped here

	peerConnection, err := webrtc.NewPeerConnection(webrtc.Configuration{})
	if err != nil {
		log.Println(
			errors.Join(errors.New("Failed to create PeerConnection"), err),
		)
		return
	}
	defer peerConnection.Close()

	// Create and add the RTP track BEFORE negotiation
	rtpTrack, err := webrtc.NewTrackLocalStaticRTP(
		webrtc.RTPCodecCapability{
			MimeType:  webrtc.MimeTypeH264,
			ClockRate: 90000,
		},
		"video",
		"gstreamer",
	)
	if err != nil {
		log.Println(errors.Join(errors.New("Failed to create RTP track"), err))
		return
	}
	rtpSender, err := peerConnection.AddTrack(rtpTrack)
	if err != nil {
		log.Println(errors.Join(errors.New("Failed to add RTP track"), err))
		return
	}
	// Read RTCP packets to keep the sender alive
	go func() {
		rtcpBuf := make([]byte, 1500)
		for {
			if _, _, rtcpErr := rtpSender.Read(rtcpBuf); rtcpErr != nil {
				return
			}
		}
	}()

	// Add the track to the central broadcaster
	s.broadcaster.AddTrack(rtpTrack)
	// When the handler exits, remove the track
	defer s.broadcaster.RemoveTrack(rtpTrack)

	// The UDP listening goroutine is now removed from here

	peerConnection.OnICECandidate(func(c *webrtc.ICECandidate) {
		if c == nil {
			return
		}
		log.Println("Sending ICE candidate")
		_ = conn.WriteJSON(map[string]interface{}{
			"candidate": c.ToJSON(),
		})
	})

	peerConnection.OnConnectionStateChange(func(s webrtc.PeerConnectionState) {
		log.Printf("Peer Connection State has changed to %s\n", s.String())
		if s == webrtc.PeerConnectionStateFailed {
			log.Println("Peer Connection has failed")
		}
	})

	for {
		_, msg, err := conn.ReadMessage()
		if err != nil {
			if websocket.IsUnexpectedCloseError(
				err,
				websocket.CloseGoingAway,
				websocket.CloseAbnormalClosure,
			) {
				log.Println("WebSocket read error:", err)
			}
			return
		}
		log.Println("Received signaling message:", string(msg))
		var signal map[string]interface{}
		if err := json.Unmarshal(msg, &signal); err != nil {
			log.Println(
				errors.Join(errors.New("Failed to unmarshal signal"), err),
			)
			continue
		}
		if sdp, ok := signal["sdp"].(map[string]interface{}); ok {
			typeStr, _ := sdp["type"].(string)
			sdpStr, _ := sdp["sdp"].(string)
			log.Println("Received SDP:", typeStr)
			desc := webrtc.SessionDescription{
				Type: webrtc.NewSDPType(typeStr),
				SDP:  sdpStr,
			}
			if desc.Type == webrtc.SDPTypeOffer {
				log.Println("Remote SDP offer:\n", desc.SDP)
				if err := peerConnection.SetRemoteDescription(desc); err != nil {
					log.Println(
						errors.Join(
							errors.New("Failed to set remote offer"),
							err,
						),
					)
					continue
				}
				answer, err := peerConnection.CreateAnswer(nil)
				if err != nil {
					log.Println(
						errors.Join(errors.New("Failed to create answer"), err),
					)
					continue
				}
				log.Println("Local SDP answer:\n", answer.SDP)
				if err := peerConnection.SetLocalDescription(answer); err != nil {
					log.Println(
						errors.Join(
							errors.New("Failed to set local answer"),
							err,
						),
					)
					continue
				}
				log.Println("Sending SDP answer")
				_ = conn.WriteJSON(map[string]interface{}{"sdp": answer})
			}
		} else if candidate, ok := signal["candidate"].(map[string]interface{}); ok {
			cand := webrtc.ICECandidateInit{}
			b, _ := json.Marshal(candidate)
			_ = json.Unmarshal(b, &cand)
			log.Println("Received ICE candidate")
			if err := peerConnection.AddICECandidate(cand); err != nil {
				log.Println(
					errors.Join(
						errors.New("Failed to add ICE candidate"),
						err,
					),
				)
			}
		}
	}
}

func videoHandler(w http.ResponseWriter, r *http.Request) {
	log.Println("/video handler called")
	file, err := os.Open("example_video.mp4")
	if err != nil {
		log.Println(errors.Join(errors.New("Failed to open video file"), err))
		w.WriteHeader(http.StatusInternalServerError)
		return
	}
	defer file.Close()

	buf := make([]byte, 1024*1024) // 1MB chunks
	for {
		n, err := file.Read(buf)
		if n > 0 {
			_, writeErr := w.Write(buf[:n])
			if writeErr != nil {
				log.Println(errors.Join(errors.New("Failed to write video chunk"), writeErr))
				return
			}
			w.(http.Flusher).Flush()
			log.Println("Sent video chunk of size", n)
			time.Sleep(100 * time.Millisecond) // Simulate live streaming
		}
		if err != nil {
			if err != io.EOF {
				log.Println(errors.Join(errors.New("Error reading video file"), err))
			}
			break
		}
	}
	log.Println("Finished /video streaming")
}

func staticHandler() http.Handler {
	log.Println("/static/ handler registered")
	return http.StripPrefix("/static/", http.FileServer(http.Dir("frontend/public")))
}

func Start(addr string, b *broadcaster.Broadcaster) (*Server, error) {
	ln, err := net.Listen("tcp", addr)
	if err != nil {
		return nil, err
	}
	fmt.Println("Listening on", ln.(*net.TCPListener).Addr())

	s := &Server{
		mux:         http.NewServeMux(),
		broadcaster: b,
	}
	s.server = &http.Server{
		Addr:    addr,
		Handler: s.mux,
	}

	s.mux.HandleFunc("/ws", s.wsHandler)
	s.mux.HandleFunc("/video", videoHandler)
	s.mux.Handle("/static/", staticHandler())
	log.Println("Handlers registered: /ws, /video, /static/")

	go func() {
		if err := s.server.Serve(ln); err != nil && err != http.ErrServerClosed {
			log.Println("Error serving:", err)
		}
	}()

	return s, nil
}

func (s *Server) Stop(ctx context.Context) {
	if err := s.server.Shutdown(ctx); err != nil {
		log.Println("Error shutting down server:", err)
	}
}
