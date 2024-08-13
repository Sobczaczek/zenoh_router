# Stage 1: Build Stage
FROM rust:alpine AS builder

RUN apk add --no-cache \
    build-base \
    cmake \
    musl-dev

# Copy the local zenoh directory with changes
COPY ./zenoh /zenoh

# Set workdit to /zenoh
WORKDIR /zenoh

# Build Zenoh in release mode
RUN cargo build --release \
    && cp target/release/zenohd /usr/local/bin/zenohd

# Stage 2: Run Stage
FROM alpine:latest

RUN apk add --no-cache \
    libgcc \
    libstdc++

# Copy the built binary from the builder stage
COPY --from=builder /zenoh/target/release/zenohd /usr/local/bin/zenohd

# Create the /zenoh directory
RUN mkdir -p /zenoh
RUN mkdir -p /zenoh/target/
RUN mkdir -p /zenoh/target/release

# Copy the built debug artifacts from the builder stage (plugins)
COPY --from=builder /zenoh/target/release/libzenoh_plugin_rest.so /zenoh/target/release/libzenoh_plugin_rest.so

# Copy the configuration file
COPY ./CUSTOM_CONFIG.json5 /zenoh/CUSTOM_CONFIG.json5

# Expose the default Zenoh and REST API ports
EXPOSE 7447
EXPOSE 8000

# Start Zenoh daemon with a  configuration file
CMD ["zenohd", "-c", "zenoh/CUSTOM_CONFIG.json5"]
