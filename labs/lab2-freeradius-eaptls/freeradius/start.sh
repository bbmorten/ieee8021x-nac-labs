#!/bin/bash
set -e

CERT_DIR="/etc/freeradius/3.0/certs"
SHARED_CERT_DIR="/shared-certs"

# Check if certificates already exist in shared volume
if [ ! -f "${SHARED_CERT_DIR}/ca.crt" ]; then
    echo "[*] Generating certificates..."
    cd /opt/certs
    ./generate-certs.sh

    echo "[*] Copying certificates to shared volume..."
    cp ca.crt ca.key server.crt server.key client.crt client.key dh "${SHARED_CERT_DIR}/"
fi

# Copy certificates to FreeRADIUS directory
echo "[*] Setting up FreeRADIUS certificates..."
mkdir -p "${CERT_DIR}"
cp "${SHARED_CERT_DIR}/ca.crt" "${CERT_DIR}/"
cp "${SHARED_CERT_DIR}/server.crt" "${CERT_DIR}/"
cp "${SHARED_CERT_DIR}/server.key" "${CERT_DIR}/"
cp "${SHARED_CERT_DIR}/dh" "${CERT_DIR}/"

# Set proper permissions for FreeRADIUS
chown -R freerad:freerad "${CERT_DIR}"
chmod 640 "${CERT_DIR}"/*.key
chmod 644 "${CERT_DIR}"/*.crt "${CERT_DIR}/dh"

echo "[*] Starting FreeRADIUS..."
exec freeradius -f -l stdout -X
