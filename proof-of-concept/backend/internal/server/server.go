package server

import (
	"context"
	"fmt"
	"log"
	"net"
	"net/http"
)

type Server struct {
	mux    *http.ServeMux
	server *http.Server
}

func Start(addr string) (*Server, error) {
	ln, err := net.Listen("tcp", addr)
	if err != nil {
		return nil, err
	}
	fmt.Println("Listening on", ln.(*net.TCPListener).Addr())

	mux := http.NewServeMux()

	s := &Server{
		mux: mux,
		server: &http.Server{
			Addr:    addr,
			Handler: mux,
		},
	}

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
