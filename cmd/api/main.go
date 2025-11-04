package main

import (
	"context"
	"fmt"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/bikashb-meesho/golang-app/internal/config"
	"github.com/bikashb-meesho/golang-app/internal/handlers"
	"github.com/bikashb-meesho/golang-lib/httputil"
	"github.com/bikashb-meesho/golang-lib/logger"
	"go.uber.org/zap"
)

func main() {
	// Load configuration
	cfg := config.Load()

	// Initialize logger
	log, err := logger.New(logger.Config{
		Level:       cfg.LogLevel,
		Environment: cfg.Environment,
		Service:     "user-api",
	})
	if err != nil {
		fmt.Fprintf(os.Stderr, "Failed to initialize logger: %v\n", err)
		os.Exit(1)
	}
	defer log.Sync()

	log.Info("Starting application",
		zap.String("environment", cfg.Environment),
		zap.String("port", cfg.Port),
	)

	// Initialize handlers
	userHandler := handlers.NewUserHandler(log)

	// Setup routes
	mux := http.NewServeMux()
	mux.HandleFunc("/health", healthHandler(log))
	mux.HandleFunc("/api/users", userHandler.CreateUser)
	mux.HandleFunc("/api/users/", userHandler.GetUser)

	// Apply middleware
	handler := httputil.Recover(
		httputil.RequestID(
			httputil.CORS([]string{"http://localhost:3000"})(
				mux,
			),
		),
	)

	// Create server
	srv := &http.Server{
		Addr:         ":" + cfg.Port,
		Handler:      handler,
		ReadTimeout:  15 * time.Second,
		WriteTimeout: 15 * time.Second,
		IdleTimeout:  60 * time.Second,
	}

	// Start server in goroutine
	go func() {
		log.Info("Server listening", zap.String("address", srv.Addr))
		if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatal("Server failed to start", zap.Error(err))
		}
	}()

	// Wait for interrupt signal
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit

	log.Info("Shutting down server...")

	// Graceful shutdown with timeout
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	if err := srv.Shutdown(ctx); err != nil {
		log.Error("Server forced to shutdown", zap.Error(err))
		os.Exit(1)
	}

	log.Info("Server stopped gracefully")
}

func healthHandler(log *logger.Logger) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		httputil.WriteSuccess(w, map[string]string{
			"status": "healthy",
			"time":   time.Now().Format(time.RFC3339),
		})
	}
}
