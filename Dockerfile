# Build image
FROM swift:5.10-jammy as builder

# Install build dependencies
RUN apt-get update && apt-get install -y \
    libssl-dev \
    libcurl4-openssl-dev \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY . .

# Build for release
RUN swift build -c release --static-swift-stdlib

# Runtime image
FROM ubuntu:22.04

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    libssl3 \
    libcurl4 \
    libatomic1 \
    ca-certificates \
    zlib1g \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user
RUN groupadd -r vapor && useradd -r -g vapor vapor

WORKDIR /app

# Copy the compiled executable from builder stage
COPY --from=builder /app/.build/release/clinic_api_server /app/clinic_api_server

# Change ownership to vapor user
RUN chown -R vapor:vapor /app
USER vapor

# Environment variables (will be overridden by docker-compose or runtime)
ENV VAPOR_ENV=production
ENV HOSTNAME=0.0.0.0
ENV PORT=8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/api/v1/health || exit 1

# Expose port
EXPOSE 8080

# Run the application
CMD ["./clinic_api_server", "serve", "--hostname", "0.0.0.0", "--port", "8080"]