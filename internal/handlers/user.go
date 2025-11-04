package handlers

import (
	"fmt"
	"net/http"
	"strings"
	"time"

	"github.com/bikashb-meesho/golang-app/internal/models"
	"github.com/bikashb-meesho/golang-lib/httputil"
	"github.com/bikashb-meesho/golang-lib/logger"
	"github.com/bikashb-meesho/golang-lib/validator"
	"go.uber.org/zap"
)

// UserHandler handles user-related HTTP requests
type UserHandler struct {
	log *logger.Logger
	// In a real application, you would inject a repository here
	users map[string]*models.User // In-memory storage for demo
}

// NewUserHandler creates a new user handler
func NewUserHandler(log *logger.Logger) *UserHandler {
	return &UserHandler{
		log:   log,
		users: make(map[string]*models.User),
	}
}

// CreateUser handles POST /api/users
func (h *UserHandler) CreateUser(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		httputil.WriteError(w, http.StatusMethodNotAllowed, "method_not_allowed", "Method not allowed")
		return
	}

	// Get logger with request context
	log := h.log.WithContext(r.Context())

	// Parse request body
	var req models.CreateUserRequest
	if err := httputil.ReadJSON(r, &req, 1<<20); err != nil {
		log.Warn("Invalid request body", zap.Error(err))
		httputil.WriteError(w, http.StatusBadRequest, "invalid_request", err.Error())
		return
	}

	// Validate request using the validator package from our library
	v := validator.New()
	v.Required("name", req.Name)
	v.MinLength("name", req.Name, 2)
	v.MaxLength("name", req.Name, 100)

	v.Required("email", req.Email)
	v.Email("email", req.Email)

	v.Range("age", req.Age, 1, 150)

	allowedRoles := []string{"admin", "user", "guest"}
	v.OneOf("role", req.Role, allowedRoles)

	if !v.IsValid() {
		log.Warn("Validation failed", zap.String("errors", v.ErrorMessages()))
		httputil.WriteError(w, http.StatusBadRequest, "validation_failed", v.ErrorMessages())
		return
	}

	// Create user
	user := &models.User{
		ID:        generateID(),
		Name:      req.Name,
		Email:     req.Email,
		Age:       req.Age,
		Role:      req.Role,
		CreatedAt: time.Now(),
	}

	// Store user (in-memory for demo)
	h.users[user.ID] = user

	log.Info("User created successfully",
		zap.String("user_id", user.ID),
		zap.String("email", user.Email),
	)

	// Return success response
	httputil.WriteSuccess(w, user)
}

// GetUser handles GET /api/users/{id}
func (h *UserHandler) GetUser(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		httputil.WriteError(w, http.StatusMethodNotAllowed, "method_not_allowed", "Method not allowed")
		return
	}

	log := h.log.WithContext(r.Context())

	// Extract user ID from path
	path := strings.TrimPrefix(r.URL.Path, "/api/users/")
	userID := strings.Split(path, "/")[0]

	if userID == "" {
		httputil.WriteError(w, http.StatusBadRequest, "invalid_request", "User ID is required")
		return
	}

	// Retrieve user
	user, exists := h.users[userID]
	if !exists {
		log.Warn("User not found", zap.String("user_id", userID))
		httputil.WriteError(w, http.StatusNotFound, "user_not_found", "User not found")
		return
	}

	log.Info("User retrieved successfully", zap.String("user_id", userID))

	httputil.WriteSuccess(w, user)
}

// generateID generates a simple ID (in real app, use UUID)
func generateID() string {
	return fmt.Sprintf("user_%d", time.Now().UnixNano())
}
