FROM debian:bullseye-slim

ENV DEBIAN_FRONTEND=noninteractive

# Install build dependencies and runtime packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      build-essential \
      pkg-config \
      libnl-3-dev \
      libnl-genl-3-dev \
      libnl-route-3-dev \
      libssl-dev \
      libdbus-1-dev \
      wget \
      ca-certificates \
      freeradius-utils \
      iputils-ping && \
    rm -rf /var/lib/apt/lists/*

# Download and build eapol_test from wpa_supplicant source
ARG WPA_SUPPLICANT_VERSION=2.11
RUN cd /tmp && \
    wget -q https://w1.fi/releases/wpa_supplicant-${WPA_SUPPLICANT_VERSION}.tar.gz && \
    tar xzf wpa_supplicant-${WPA_SUPPLICANT_VERSION}.tar.gz && \
    cd wpa_supplicant-${WPA_SUPPLICANT_VERSION}/wpa_supplicant && \
    # Create build configuration
    cp defconfig .config && \
    sed -i 's/#CONFIG_EAPOL_TEST=y/CONFIG_EAPOL_TEST=y/' .config && \
    # Build eapol_test
    make eapol_test -j$(nproc) && \
    cp eapol_test /usr/local/bin/ && \
    # Cleanup build artifacts
    cd / && rm -rf /tmp/wpa_supplicant-*

# Remove build dependencies to reduce image size
RUN apt-get update && \
    apt-get purge -y --auto-remove \
      build-essential \
      pkg-config \
      libnl-3-dev \
      libnl-genl-3-dev \
      libnl-route-3-dev \
      libssl-dev \
      libdbus-1-dev \
      wget && \
    apt-get install -y --no-install-recommends \
      libnl-3-200 \
      libnl-genl-3-200 \
      libnl-route-3-200 \
      libssl1.1 \
      libdbus-1-3 && \
    rm -rf /var/lib/apt/lists/*

# Copy configs
COPY eapol_test_peap.conf /etc/wpa_supplicant/eapol_test_peap.conf
COPY run-eapol-test.sh /usr/local/bin/run-eapol-test.sh

RUN chmod +x /usr/local/bin/run-eapol-test.sh

CMD ["tail", "-f", "/dev/null"]
