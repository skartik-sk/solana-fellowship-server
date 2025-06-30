# Use the official Rust image as base (updated version)
FROM rust:1.80-slim as builder

# Install system dependencies
RUN apt-get update && apt-get install -y \
    pkg-config \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Create app directory
WORKDIR /app

# Copy Cargo files
COPY Cargo.toml ./

# Copy source code
COPY src ./src

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
