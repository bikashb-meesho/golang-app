# Golang App - User Management API

A sample REST API application demonstrating the use of reusable components from [golang-lib](https://github.com/bikashb-meesho/golang-lib).

## 🎯 Features

- **User Management**: Create and retrieve users via REST API
- **Structured Logging**: Uses the logger package from golang-lib
- **Input Validation**: Validates requests using the validator package
- **HTTP Utilities**: Leverages httputil for consistent API responses
- **Graceful Shutdown**: Handles SIGINT/SIGTERM signals properly
- **Middleware**: Request ID tracking, panic recovery, CORS support

## 🏗️ Architecture

```
golang-app/
├── cmd/
│   └── api/
│       └── main.go          # Application entry point
├── internal/
│   ├── config/
│   │   └── config.go        # Configuration management
│   ├── handlers/
│   │   └── user.go          # HTTP handlers
│   └── models/
│       └── user.go          # Domain models
├── go.mod
└── README.md
```

## 🚀 Getting Started

### Prerequisites

- Go 1.23 or higher
- Access to the [golang-lib](https://github.com/bikashb-meesho/golang-lib) repository

### Installation

1. Clone the repository:
```bash
git clone https://github.com/bikashb-meesho/golang-app.git
cd golang-app
```

2. For local development with the library, update `go.mod`:
```go
replace github.com/bikashb-meesho/golang-lib => ../golang-lib
```

3. Download dependencies:
```bash
go mod download
```

### Running the Application

```bash
# Run with default settings
go run cmd/api/main.go

# Run with custom configuration
PORT=8080 ENVIRONMENT=production LOG_LEVEL=debug go run cmd/api/main.go
```

The server will start on `http://localhost:8080` (or the port you specified).

## 📡 API Endpoints

### Health Check
```bash
GET /health
```

**Response:**
```json
{
  "success": true,
  "data": {
    "status": "healthy",
    "time": "2025-11-04T10:30:00Z"
  }
}
```

### Create User
```bash
POST /api/users
Content-Type: application/json

{
  "name": "John Doe",
  "email": "john@example.com",
  "age": 30,
  "role": "user"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "user_1234567890",
    "name": "John Doe",
    "email": "john@example.com",
    "age": 30,
    "role": "user",
    "created_at": "2025-11-04T10:30:00Z"
  }
}
```

### Get User
```bash
GET /api/users/{id}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "user_1234567890",
    "name": "John Doe",
    "email": "john@example.com",
    "age": 30,
    "role": "user",
    "created_at": "2025-11-04T10:30:00Z"
  }
}
```

## 🧪 Testing the API

Using curl:

```bash
# Health check
curl http://localhost:8080/health

# Create a user
curl -X POST http://localhost:8080/api/users \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Jane Smith",
    "email": "jane@example.com",
    "age": 28,
    "role": "admin"
  }'

# Get a user (replace {id} with actual user ID from create response)
curl http://localhost:8080/api/users/{id}
```

## 🔧 Configuration

The application is configured via environment variables:

| Variable    | Default       | Description                          |
|-------------|---------------|--------------------------------------|
| PORT        | 8080          | Port for the HTTP server             |
| ENVIRONMENT | development   | Environment (development/production) |
| LOG_LEVEL   | info          | Log level (debug/info/warn/error)    |

## 📦 Dependencies

This application uses the following library from golang-lib:

- **logger**: Structured logging with Zap
- **validator**: Input validation
- **httputil**: HTTP utilities and middleware

## 🌐 GitHub Setup

### Creating the Repository

1. Create a new GitHub repository named `golang-app`

2. Initialize git in this directory:
```bash
cd golang-app
git init
git add .
git commit -m "Initial commit: Add user management API"
```

3. Add remote and push:
```bash
git remote add origin https://github.com/bikashb-meesho/golang-app.git
git branch -M main
git push -u origin main
```

### Using with Published Library

Once you've published the `golang-lib` repository:

1. Remove the `replace` directive from `go.mod`
2. Run `go get github.com/bikashb-meesho/golang-lib@v1.0.0`
3. Run `go mod tidy`

## 🚢 Deployment

### Building for Production

```bash
# Build binary
go build -o bin/api cmd/api/main.go

# Run binary
./bin/api
```

### Docker Deployment

Create a `Dockerfile`:

```dockerfile
FROM golang:1.23-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o /api cmd/api/main.go

FROM alpine:latest
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=builder /api .
EXPOSE 8080
CMD ["./api"]
```

Build and run:
```bash
docker build -t golang-app .
docker run -p 8080:8080 -e ENVIRONMENT=production golang-app
```

## 📝 Development Workflow

1. Make changes to the library in `../golang-lib`
2. Test the app with the local library using the `replace` directive
3. Once satisfied, tag and push the library changes
4. Update the app's `go.mod` to use the new library version
5. Deploy the app

## 📄 License

MIT License

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

