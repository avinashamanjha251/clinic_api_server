# Build image
FROM swift:5.10-jammy as builder

RUN apt-get update && apt-get install -y \
    libssl-dev \
    libcurl4-openssl-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY . .
# Compile for release
RUN swift build -c release --static-swift-stdlib

# Production image
FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    libssl3 \
    libcurl4 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
# Copy the compiled executable from the builder
COPY --from=builder /app/.build/release/clinic_api_server /app/clinic_api_server
# Copy any necessary environment or public folders (if applicable)
COPY .env .
# COPY Public/ Public/

EXPOSE 8080
CMD ["./clinic_api_server", "serve", "--hostname", "0.0.0.0", "--port", "8080"]
