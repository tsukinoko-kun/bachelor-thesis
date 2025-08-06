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
	"strings"
	"time"

	"github.com/go-vgo/robotgo"
	"github.com/gorilla/websocket"
	"github.com/pion/webrtc/v3"
)

type InputEvent struct {
	Type      string         `json:"type"`
	Data      map[string]any `json:"data"`
	Timestamp int64          `json:"timestamp"`
}

func handleInputEvent(data []byte) {
	var event InputEvent
	if err := json.Unmarshal(data, &event); err != nil {
		log.Printf("Failed to unmarshal input event: %v", err)
		return
	}

	log.Printf("Received input event: %s with data: %v", event.Type, event.Data)

	switch event.Type {
	case "mouse_move":
		handleMouseMove(event.Data)
	case "mouse_click":
		handleMouseClick(event.Data)
	case "mouse_release":
		handleMouseRelease(event.Data)
	case "key_press":
		handleKeyPress(event.Data)
	case "key_release":
		handleKeyRelease(event.Data)
	default:
		log.Printf("Unknown input event type: %s", event.Type)
	}
}

func handleMouseMove(data map[string]any) {
	deltaX, _ := data["deltaX"].(float64)
	deltaY, _ := data["deltaY"].(float64)
	log.Printf("Mouse move: deltaX=%.2f, deltaY=%.2f", deltaX, deltaY)

	// Get current mouse position
	currentX, currentY := robotgo.Location()
	log.Printf("Current mouse position: (%d, %d)", currentX, currentY)

	// Apply relative movement
	newX := currentX + int(deltaX)
	newY := currentY + int(deltaY)
	log.Printf("Moving mouse to: (%d, %d)", newX, newY)

	// Move mouse to new position
	robotgo.Move(newX, newY)

	// Verify the move worked
	verifyX, verifyY := robotgo.Location()
	log.Printf("Mouse position after move: (%d, %d)", verifyX, verifyY)
}
func handleMouseClick(data map[string]any) {
	button, _ := data["button"].(float64)
	x, _ := data["x"].(float64)
	y, _ := data["y"].(float64)
	log.Printf("Mouse click: button=%d, x=%.3f, y=%.3f", int(button), x, y)

	// Convert button number to robotgo button string
	var buttonStr string
	switch int(button) {
	case 0:
		buttonStr = "left"
	case 1:
		buttonStr = "center"
	case 2:
		buttonStr = "right"
	default:
		buttonStr = "left"
	}

	// Execute mouse down (press only)
	log.Printf("Executing mouse down: %s", buttonStr)
	robotgo.Toggle(buttonStr, "down")
}
func handleMouseRelease(data map[string]any) {
	button, _ := data["button"].(float64)
	x, _ := data["x"].(float64)
	y, _ := data["y"].(float64)
	log.Printf("Mouse release: button=%d, x=%.3f, y=%.3f", int(button), x, y)

	// Convert button number to robotgo button string
	var buttonStr string
	switch int(button) {
	case 0:
		buttonStr = "left"
	case 1:
		buttonStr = "center"
	case 2:
		buttonStr = "right"
	default:
		buttonStr = "left"
	}

	// Execute mouse release (up only)
	log.Printf("Executing mouse up: %s", buttonStr)
	robotgo.Toggle(buttonStr, "up")
}
func handleKeyPress(data map[string]any) {
	key, _ := data["key"].(string)
	code, _ := data["code"].(string)
	ctrlKey, _ := data["ctrlKey"].(bool)
	shiftKey, _ := data["shiftKey"].(bool)
	altKey, _ := data["altKey"].(bool)
	metaKey, _ := data["metaKey"].(bool)

	log.Printf("Key press: key=%s, code=%s, ctrl=%t, shift=%t, alt=%t, meta=%t",
		key, code, ctrlKey, shiftKey, altKey, metaKey)

	// Check if this is a modifier key itself
	isModifierKey := key == "Shift" || key == "Control" || key == "Alt" || key == "Meta" ||
		key == "ShiftLeft" || key == "ShiftRight" ||
		key == "ControlLeft" || key == "ControlRight" ||
		key == "AltLeft" || key == "AltRight" ||
		key == "MetaLeft" || key == "MetaRight"

	// Convert JavaScript key to robotgo key
	robotKey := convertJSKeyToRobotKey(key, code)
	log.Printf("Converted key '%s' to robotgo key '%s', isModifier: %t", key, robotKey, isModifierKey)

	// Execute key press
	log.Printf("Executing key press...")
	if isModifierKey {
		// For modifier keys, just press the key itself (no additional modifiers)
		log.Printf("Pressing modifier key: %s", robotKey)
		robotgo.KeyToggle(robotKey, "down")
	} else {
		// For regular keys, ignore modifier state since modifiers are sent separately
		log.Printf("Pressing regular key: %s (ignoring modifier state)", robotKey)
		robotgo.KeyTap(robotKey)
	}
	log.Printf("Key press execution completed")
}

func handleKeyRelease(data map[string]any) {
	key, _ := data["key"].(string)
	code, _ := data["code"].(string)
	log.Printf("Key release: key=%s, code=%s", key, code)

	// Check if this is a modifier key itself
	isModifierKey := key == "Shift" || key == "Control" || key == "Alt" || key == "Meta" ||
		key == "ShiftLeft" || key == "ShiftRight" ||
		key == "ControlLeft" || key == "ControlRight" ||
		key == "AltLeft" || key == "AltRight" ||
		key == "MetaLeft" || key == "MetaRight"

	if isModifierKey {
		// For modifier keys, we need to release them
		robotKey := convertJSKeyToRobotKey(key, code)
		log.Printf("Releasing modifier key: %s", robotKey)
		robotgo.KeyToggle(robotKey, "up")
	}
	// For regular keys, robotgo.KeyTap handles the full press+release cycle
	// so we don't need to do anything for key release
}

func convertJSKeyToRobotKey(key, code string) string {
	// Handle modifier keys first
	switch key {
	case "Shift", "ShiftLeft", "ShiftRight":
		return "shift"
	case "Control", "ControlLeft", "ControlRight":
		return "ctrl"
	case "Alt", "AltLeft", "AltRight":
		return "alt"
	case "Meta", "MetaLeft", "MetaRight":
		return "cmd"
	}

	// Handle special keys
	switch key {
	case "Enter":
		return "enter"
	case "Escape":
		return "esc"
	case "Backspace":
		return "backspace"
	case "Tab":
		return "tab"
	case "Delete":
		return "delete"
	case "ArrowUp":
		return "up"
	case "ArrowDown":
		return "down"
	case "ArrowLeft":
		return "left"
	case "ArrowRight":
		return "right"
	case "Home":
		return "home"
	case "End":
		return "end"
	case "PageUp":
		return "pageup"
	case "PageDown":
		return "pagedown"
	case "Insert":
		return "insert"
	case "CapsLock":
		return "capslock"
	case "NumLock":
		return "numlock"
	case "ScrollLock":
		return "scrolllock"
	case "PrintScreen":
		return "printscreen"
	case "Pause":
		return "pause"
	case " ":
		return "space"
	}

	// Handle function keys
	if len(key) >= 2 && key[0] == 'F' {
		switch key {
		case "F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10", "F11", "F12":
			return strings.ToLower(key)
		}
	}

	// Handle regular characters - robotgo expects lowercase
	if len(key) == 1 {
		return strings.ToLower(key)
	}

	// Fallback to the key as-is, converted to lowercase
	return strings.ToLower(key)
}

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
		_ = conn.WriteJSON(map[string]any{
			"candidate": c.ToJSON(),
		})
	})

	peerConnection.OnConnectionStateChange(func(s webrtc.PeerConnectionState) {
		log.Printf("Peer Connection State has changed to %s\n", s.String())
		if s == webrtc.PeerConnectionStateFailed {
			log.Println("Peer Connection has failed")
		}
	})

	// Create data channel for input events
	dataChannel, err := peerConnection.CreateDataChannel("input", nil)
	if err != nil {
		log.Println(errors.Join(errors.New("Failed to create data channel"), err))
		return
	}

	dataChannel.OnOpen(func() {
		log.Println("Input data channel opened")
	})

	dataChannel.OnMessage(func(msg webrtc.DataChannelMessage) {
		handleInputEvent(msg.Data)
	})

	dataChannel.OnClose(func() {
		log.Println("Input data channel closed")
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
		var signal map[string]any
		if err := json.Unmarshal(msg, &signal); err != nil {
			log.Println(
				errors.Join(errors.New("Failed to unmarshal signal"), err),
			)
			continue
		}
		if sdp, ok := signal["sdp"].(map[string]any); ok {
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
				_ = conn.WriteJSON(map[string]any{"sdp": answer})
			}
		} else if candidate, ok := signal["candidate"].(map[string]any); ok {
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
		} else if inputEventData, ok := signal["inputEvent"].(map[string]any); ok {
			// Handle input events received via WebSocket fallback
			b, _ := json.Marshal(inputEventData)
			handleInputEvent(b)
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
