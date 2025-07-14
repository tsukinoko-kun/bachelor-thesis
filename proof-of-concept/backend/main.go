package main

import (
	"backend/internal/server"
	"context"
	"log"
	"os"
	"os/signal"
	"syscall"
)

func main() {
	s, err := server.Start(":8080")
	if err != nil {
		log.Fatal(err)
	}
	defer s.Stop(context.Background())

	c := make(chan os.Signal, 1)
	signal.Notify(c, os.Interrupt, syscall.SIGTERM, syscall.SIGINT, syscall.SIGQUIT, syscall.SIGHUP)
	<-c

	log.Println("Shutting down server...")
	os.Exit(0)
}
