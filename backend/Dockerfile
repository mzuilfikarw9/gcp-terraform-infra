# 1. Update to Go 1.23 (Matches your local Go version)
FROM golang:1.23-alpine AS builder

WORKDIR /app

# Copy dependency files first (Standard Docker caching practice)
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy the rest of the source code
COPY . .

# Build the binary
RUN go build -o main .

# --- Final Stage ---
FROM alpine:latest
WORKDIR /root/

# Copy the binary from the builder stage
COPY --from=builder /app/main .

EXPOSE 8080

# Run the binary (Production mode)
CMD ["./main"]