# Build Stage
FROM golang:1.24-alpine AS builder
WORKDIR /app

# Copy go mod files first (better caching)
COPY go.mod go.sum ./
RUN go mod download  # ← This layer is cached unless go.mod/go.sum changes

# Copy source code
COPY . .

# Build the application
RUN go build -o main main.go

# Download migrate tool
RUN apk add --no-cache curl
RUN curl -L https://github.com/golang-migrate/migrate/releases/download/v4.19.1/migrate.linux-amd64.tar.gz | tar xvz

# Run Stage  
FROM alpine:3.20
WORKDIR /app

# Install runtime dependencies
RUN apk add --no-cache ca-certificates

# Copy binaries and files 
COPY --from=builder /app/main .
COPY --from=builder /app/migrate ./migrate
COPY app.env .
COPY start.sh .
COPY wait-for.sh .
COPY db/migration ./migration

# Fix line endings and make executable
RUN chmod +x /app/start.sh /app/wait-for.sh

EXPOSE 8080
CMD ["/app/main"]
ENTRYPOINT ["/app/start.sh"]