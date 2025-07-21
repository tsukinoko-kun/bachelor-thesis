package gstreamer

import (
	"log"
	"os/exec"
	"sync"
)

type GStreamer struct {
	cmd  *exec.Cmd
	lock sync.Mutex
}

func NewGStreamer() *GStreamer {
	return &GStreamer{}
}

func (g *GStreamer) Start() error {
	g.lock.Lock()
	defer g.lock.Unlock()
	if g.cmd != nil && g.cmd.Process != nil {
		return nil // Already running
	}
	// Build the gst-launch-1.0 command
	g.cmd = exec.Command(
		"gst-launch-1.0",
		"-v",
		"videotestsrc",
		"!", "video/x-raw,format=I420",
		"!", "x264enc", "tune=zerolatency", "byte-stream=true", "key-int-max=30", "bitrate=512", "speed-preset=ultrafast",
		"!", "video/x-h264,profile=baseline",
		"!", "rtph264pay", "config-interval=1", "pt=96",
		"!", "udpsink", "host=127.0.0.1", "port=5004",
	)
	g.cmd.Stdout = log.Writer()
	g.cmd.Stderr = log.Writer()
	if err := g.cmd.Start(); err != nil {
		g.cmd = nil
		return err
	}
	log.Println("GStreamer pipeline started")
	return nil
}

func (g *GStreamer) Stop() error {
	g.lock.Lock()
	defer g.lock.Unlock()
	if g.cmd == nil || g.cmd.Process == nil {
		return nil // Not running
	}
	err := g.cmd.Process.Kill()
	if err != nil {
		return err
	}
	_, waitErr := g.cmd.Process.Wait()
	g.cmd = nil
	log.Println("GStreamer pipeline stopped")
	return waitErr
}
