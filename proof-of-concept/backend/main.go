package main

import (
	"backend/internal/broadcaster"
	"backend/internal/gstreamer"
	"backend/internal/server"
	"context"
	"log"
	"os"
	"os/signal"
	"syscall"
)

func main() {
	// Start a single GStreamer pipeline for the life of the server
	g := gstreamer.NewGStreamer()
	if err := g.Start(); err != nil {
		log.Fatalf("Failed to start GStreamer: %v", err)
	}
	defer g.Stop()

	// Start a single broadcaster for the life of the server
	b, err := broadcaster.NewBroadcaster(5004)
	if err != nil {
		log.Fatalf("Failed to start broadcaster: %v", err)
	}
	defer b.Stop()

	// Start the HTTP server, passing it the broadcaster
	s, err := server.Start(":8080", b)
	if err != nil {
		log.Fatal(err)
	}
	defer s.Stop(context.Background())

	c := make(chan os.Signal, 1)
	signal.Notify(
		c,
		os.Interrupt,
		syscall.SIGTERM,
		syscall.SIGINT,
		syscall.SIGQUIT,
		syscall.SIGHUP,
	)
	<-c

	log.Println("Shutting down server...")
	// os.Exit is not needed, the deferred calls will handle cleanup
}
