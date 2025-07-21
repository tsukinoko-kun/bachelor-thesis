package gstreamer

import (
	"log"
	"sync"

	"github.com/go-gst/go-gst/gst"
)

func init() {
	gst.Init(nil)
}

type GStreamer struct {
	pipeline *gst.Pipeline
	lock     sync.Mutex
}

func NewGStreamer() *GStreamer {
	return &GStreamer{}
}

func (g *GStreamer) Start() error {
	g.lock.Lock()
	defer g.lock.Unlock()
	if g.pipeline != nil {
		return nil // Already running
	}

	pipelineStr := "avfvideosrc capture-screen=true ! video/x-raw,framerate=10/1 ! videoscale ! videoconvert ! queue ! x264enc tune=zerolatency byte-stream=true key-int-max=10 insert-vui=true bitrate=2048 speed-preset=ultrafast ! video/x-h264,profile=baseline ! queue ! rtph264pay config-interval=1 pt=96 ! udpsink host=127.0.0.1 port=5004"

	pipeline, err := gst.NewPipelineFromString(pipelineStr)
	if err != nil {
		return err
	}
	g.pipeline = pipeline

	err = g.pipeline.SetState(gst.StatePlaying)
	if err != nil {
		g.pipeline = nil
		return err
	}
	log.Println("GStreamer pipeline started (go-gst)")
	return nil
}

func (g *GStreamer) Stop() error {
	g.lock.Lock()
	defer g.lock.Unlock()
	if g.pipeline == nil {
		return nil // Not running
	}
	err := g.pipeline.SetState(gst.StateNull)
	if err != nil {
		return err
	}
	g.pipeline = nil
	log.Println("GStreamer pipeline stopped (go-gst)")
	return nil
}
