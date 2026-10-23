package main

import (
	"context"
	"log"
	"moby.local/family/internal/api"
	"moby.local/family/internal/grpcapi"
	"net"
	"net/http"
	"os"
	"os/signal"
	"path/filepath"
	"syscall"
	"time"
)

func main() {
	syscall.Umask(0077)
	addr := os.Getenv("MOBY_ADDR")
	if addr == "" {
		addr = "127.0.0.1:8080"
	}
	path := os.Getenv("MOBY_DATABASE")
	if path == "" {
		path = "data/family.sqlite"
	}
	if e := os.MkdirAll(filepath.Dir(path), 0700); e != nil {
		log.Fatal("cannot create database directory")
	}
	service, e := api.New(api.Config{DatabasePath: path, BootstrapSecret: os.Getenv("MOBY_BOOTSTRAP_SECRET"), BusinessDate: os.Getenv("MOBY_BUSINESS_DATE")})
	if e != nil {
		log.Fatal("cannot initialize backend: check database and configuration")
	}
	defer service.Close()
	if e := os.Chmod(path, 0600); e != nil {
		log.Fatal("cannot secure database")
	}
	server := &http.Server{Addr: addr, Handler: service, ReadHeaderTimeout: 5 * time.Second, ReadTimeout: 15 * time.Second, IdleTimeout: 60 * time.Second, MaxHeaderBytes: 8192}
	grpcAddr := os.Getenv("MOBY_GRPC_ADDR")
	if grpcAddr == "" {
		grpcAddr = "127.0.0.1:9090"
	}
	grpcListener, e := net.Listen("tcp", grpcAddr)
	if e != nil {
		log.Fatal("cannot bind private gRPC listener")
	}
	defer grpcListener.Close()
	rpcServer := grpcapi.NewServer(service, grpcapi.Options{})
	go func() {
		if e := rpcServer.Serve(grpcListener); e != nil {
			log.Print("gRPC listener stopped")
		}
	}()
	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stop()
	go service.RunScheduler(ctx)
	shutdownDone := make(chan struct{})
	go func() {
		defer close(shutdownDone)
		<-ctx.Done()
		c, cancel := context.WithTimeout(context.Background(), 5*time.Second)
		defer cancel()
		_ = server.Shutdown(c)
		done := make(chan struct{})
		go func() { rpcServer.GracefulStop(); close(done) }()
		select {
		case <-done:
		case <-c.Done():
			rpcServer.Stop()
		}
	}()
	log.Print("synthetic Moby backend starting")
	if e := server.ListenAndServe(); e != nil && e != http.ErrServerClosed {
		log.Fatal("HTTP server stopped unexpectedly")
	}
	<-shutdownDone
}
