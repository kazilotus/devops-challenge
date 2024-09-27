# Build stage
FROM golang:1.22.5-alpine AS builder
WORKDIR /app
COPY go.mod ./
RUN go mod download
COPY . .
ENV CGO_ENABLED=0 GOOS=linux GOARCH=amd64
RUN go build -o /app/getBirdImage ./main.go

# Final stage
FROM alpine:latest
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
WORKDIR /app
COPY --from=builder /app/getBirdImage /app/getBirdImage
RUN chown -R appuser:appgroup /app
USER appuser
EXPOSE 4200
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:4200/ || exit 1
CMD ["/app/getBirdImage"]
