# Use the official Rust image as base (updated to 1.83 for Solana compatibility)
FROM rust:1.83-slim AS builder

# Install system dependencies
RUN apt-get update && apt-get install -y \
    pkg-config \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Create app directory
WORKDIR /app

# Copy Cargo files for dependency caching
COPY Cargo.toml Cargo.lock ./

# Create a dummy main.rs to build dependencies first (for better Docker layer caching)
RUN mkdir src && echo "fn main() {}" > src/main.rs && cargo build --release && rm -rf src

# Copy source code
COPY src ./src

# Touch main.rs to ensure it's newer than the dummy version
RUN touch src/main.rs

# Build the application
RUN cargo build --release

# Runtime stage
FROM debian:bookworm-slim

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    ca-certificates \
    libssl3 \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user
RUN useradd -r -s /bin/false appuser

# Copy the binary from builder stage
COPY --from=builder /app/target/release/sol-fn /usr/local/bin/sol-fn

# Change to non-root user
USER appuser

# Expose port (will be overridden by cloud platforms)
EXPOSE 10000

# Set environment variables
ENV PORT=10000
ENV RUST_LOG=info

# Run the application
CMD ["sol-fn"]
