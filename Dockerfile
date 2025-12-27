# ========= Build stage =========
FROM golang:1.22-alpine AS builder

WORKDIR /app

# Pre-copy mod files to leverage Docker layer caching
COPY go.mod ./
RUN go mod download

# Copy full source
COPY . .

# Build the API binary
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
    go build -o just-cloud ./cmd/api

# ========= Runtime stage =========
# Distroless base is small and secure, works on any cloud.
FROM gcr.io/distroless/base-debian12

WORKDIR /app

COPY --from=builder /app/just-cloud /app/just-cloud

# Default envs; can be overridden by platform
ENV PORT=8080
ENV SERVICE_NAME="just-cloud"

EXPOSE 8080

USER nonroot:nonroot

ENTRYPOINT ["/app/just-cloud"]