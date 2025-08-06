package gstreamer

import (
	"fmt"
	"log"
	"sync"

	"github.com/go-gst/go-gst/gst"
	"github.com/go-gst/go-gst/gst/app"
)

func init() {
	gst.Init(nil)
}

type DataHandler interface {
	HandleRTPPacket(data []byte) error
}

type GStreamer struct {
	pipeline    *gst.Pipeline
	appsink     *app.Sink
	dataHandler DataHandler
	lock        sync.Mutex
}

func NewGStreamer(handler DataHandler) *GStreamer {
	return &GStreamer{
		dataHandler: handler,
	}
}

func (g *GStreamer) Start() error {
	g.lock.Lock()
	defer g.lock.Unlock()
	if g.pipeline != nil {
		return nil // Already running
	}

	pipeline, err := gst.NewPipelineFromString(getPipelineStr())
	if err != nil {
		return fmt.Errorf("failed to create pipeline: %w", err)
	}
	g.pipeline = pipeline

	// Get the appsink element from the pipeline
	appsinkElement, err := g.pipeline.GetElementByName("rtpsink")
	if err != nil {
		return fmt.Errorf("failed to get appsink element 'rtpsink' from pipeline: %w", err)
	}

	// Convert to appsink
	g.appsink = app.SinkFromElement(appsinkElement)
	if g.appsink == nil {
		return fmt.Errorf("failed to convert element to appsink")
	}

	// Set up the callback to receive RTP packets
	g.appsink.SetCallbacks(&app.SinkCallbacks{
		NewSampleFunc: func(sink *app.Sink) gst.FlowReturn {
			sample := sink.PullSample()
			if sample == nil {
				return gst.FlowEOS
			}

			buffer := sample.GetBuffer()
			if buffer == nil {
				return gst.FlowError
			}

			// Map the buffer to get the RTP packet data
			mapInfo := buffer.Map(gst.MapRead)
			defer buffer.Unmap()

			// Copy the data since the buffer will be unmapped
			data := make([]byte, len(mapInfo.Bytes()))
			copy(data, mapInfo.Bytes())

			// Send the RTP packet to the data handler
			if err := g.dataHandler.HandleRTPPacket(data); err != nil {
				log.Printf("Failed to handle RTP packet: %v", err)
				return gst.FlowError
			}

			return gst.FlowOK
		},
	})

	err = g.pipeline.SetState(gst.StatePlaying)
	if err != nil {
		g.pipeline = nil
		return fmt.Errorf("failed to set pipeline to playing state: %w", err)
	}
	log.Println("GStreamer pipeline started with appsink")
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
