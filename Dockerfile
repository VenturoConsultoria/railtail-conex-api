FROM golang:1.23.4 AS builder

WORKDIR /app

COPY go.mod go.sum ./

RUN go mod download

COPY . ./

RUN CGO_ENABLED=0 go build -o railtail -ldflags="-w -s" ./.

FROM debian:bookworm-slim

WORKDIR /app

# Instalar Tailscale
RUN apt-get update && apt-get install -y curl && \
    curl -fsSL https://tailscale.com/install.sh | sh && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

COPY --from=builder /app/railtail /usr/local/bin/railtail

ENTRYPOINT ["/usr/local/bin/railtail"]
