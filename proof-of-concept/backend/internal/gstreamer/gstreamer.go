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

	pipeline, err := gst.NewPipelineFromString(getPipelineStr())
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
