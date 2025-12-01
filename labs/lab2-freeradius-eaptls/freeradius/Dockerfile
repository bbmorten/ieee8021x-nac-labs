FROM debian:bookworm-slim

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
      freeradius \
      freeradius-utils \
      openssl && \
    rm -rf /var/lib/apt/lists/*

# Copy lab cert scripts and config
COPY certs /opt/certs
COPY clients.conf /etc/freeradius/3.0/clients.conf
COPY eap /etc/freeradius/3.0/mods-available/eap

# Copy startup script
COPY start.sh /opt/start.sh
RUN chmod +x /opt/start.sh /opt/certs/generate-certs.sh

EXPOSE 1812/udp 1813/udp

CMD ["/opt/start.sh"]
