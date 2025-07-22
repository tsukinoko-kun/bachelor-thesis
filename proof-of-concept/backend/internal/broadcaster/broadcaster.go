package broadcaster

import (
	"errors"
	"io"
	"log"
	"net"
	"sync"

	"github.com/pion/webrtc/v3"
)

// Broadcaster manages a single RTP stream and fans it out to multiple
// peer connections.
type Broadcaster struct {
	// UDP connection that GStreamer is pushing RTP packets to
	conn *net.UDPConn
	// Map of all connected tracks
	tracks map[string]*webrtc.TrackLocalStaticRTP
	// Mutex to protect the tracks map
	lock sync.RWMutex
}

// NewBroadcaster creates a new Broadcaster and starts listening on the
// given UDP port.
func NewBroadcaster(port int) (*Broadcaster, error) {
	addr := &net.UDPAddr{IP: net.ParseIP("127.0.0.1"), Port: port}
	conn, err := net.ListenUDP("udp", addr)
	if err != nil {
		return nil, err
	}
	log.Println("Listening for RTP packets on", addr)

	b := &Broadcaster{
		conn:   conn,
		tracks: make(map[string]*webrtc.TrackLocalStaticRTP),
	}

	// Start the goroutine to read from UDP and broadcast
	go b.run()

	return b, nil
}

// AddTrack adds a new track to the broadcaster.
func (b *Broadcaster) AddTrack(track *webrtc.TrackLocalStaticRTP) {
	b.lock.Lock()
	defer b.lock.Unlock()
	b.tracks[track.ID()] = track
}

// RemoveTrack removes a track from the broadcaster.
func (b *Broadcaster) RemoveTrack(track *webrtc.TrackLocalStaticRTP) {
	b.lock.Lock()
	defer b.lock.Unlock()
	delete(b.tracks, track.ID())
}

// run reads RTP packets from the UDP connection and broadcasts them to all
// registered tracks.
func (b *Broadcaster) run() {
	defer b.conn.Close()
	buf := make([]byte, 1500)
	for {
		n, _, err := b.conn.ReadFrom(buf)
		if err != nil {
			log.Println("Broadcaster UDP read error, stopping:", err)
			return
		}

		b.lock.RLock()
		for _, track := range b.tracks {
			if _, writeErr := track.Write(buf[:n]); writeErr != nil {
				if !errors.Is(
					writeErr,
					io.ErrClosedPipe,
				) {
					log.Println(
						"Failed to write RTP packet to track:",
						writeErr,
					)
				}
			}
		}
		b.lock.RUnlock()
	}
}

// Stop closes the UDP connection, which will stop the run() goroutine.
func (b *Broadcaster) Stop() {
	b.conn.Close()
}
