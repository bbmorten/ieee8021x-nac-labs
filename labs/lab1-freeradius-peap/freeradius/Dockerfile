FROM debian:bookworm-slim

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
      freeradius \
      freeradius-utils && \
    rm -rf /var/lib/apt/lists/*

# Copy simplified clients and users configuration.
COPY clients.conf /etc/freeradius/3.0/clients.conf
COPY users /etc/freeradius/3.0/users

EXPOSE 1812/udp 1813/udp

CMD ["freeradius", "-f", "-l", "stdout", "-X"]
