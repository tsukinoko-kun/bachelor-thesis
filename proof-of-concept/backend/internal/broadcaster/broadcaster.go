package broadcaster

import (
	"errors"
	"io"
	"log"
	"sync"

	"github.com/pion/webrtc/v3"
)

// Broadcaster manages a single RTP stream and fans it out to multiple
// peer connections. It implements the DataHandler interface to receive
// RTP packets directly from GStreamer via appsink.
type Broadcaster struct {
	// Map of all connected tracks
	tracks map[string]*webrtc.TrackLocalStaticRTP
	// Mutex to protect the tracks map
	lock sync.RWMutex
}

// NewBroadcaster creates a new Broadcaster.
func NewBroadcaster() (*Broadcaster, error) {
	b := &Broadcaster{
		tracks: make(map[string]*webrtc.TrackLocalStaticRTP),
	}

	log.Println("Broadcaster created for direct RTP packet handling")
	return b, nil
}

// HandleRTPPacket implements the DataHandler interface.
// This method receives RTP packets directly from GStreamer's appsink.
func (b *Broadcaster) HandleRTPPacket(data []byte) error {
	b.lock.RLock()
	defer b.lock.RUnlock()

	if len(b.tracks) == 0 {
		// No tracks to send to, but this is not an error
		return nil
	}

	// Broadcast the RTP packet to all registered tracks
	for _, track := range b.tracks {
		if _, writeErr := track.Write(data); writeErr != nil {
			if !errors.Is(writeErr, io.ErrClosedPipe) {
				log.Printf("Failed to write RTP packet to track %s: %v", track.ID(), writeErr)
			}
		}
	}

	return nil
}

// AddTrack adds a new track to the broadcaster.
func (b *Broadcaster) AddTrack(track *webrtc.TrackLocalStaticRTP) {
	b.lock.Lock()
	defer b.lock.Unlock()
	b.tracks[track.ID()] = track
	log.Printf("Added track %s to broadcaster", track.ID())
}

// RemoveTrack removes a track from the broadcaster.
func (b *Broadcaster) RemoveTrack(track *webrtc.TrackLocalStaticRTP) {
	b.lock.Lock()
	defer b.lock.Unlock()
	delete(b.tracks, track.ID())
	log.Printf("Removed track %s from broadcaster", track.ID())
}

// Stop is a no-op now since we don't have UDP connections to close.
func (b *Broadcaster) Stop() {
	log.Println("Broadcaster stopped")
}
