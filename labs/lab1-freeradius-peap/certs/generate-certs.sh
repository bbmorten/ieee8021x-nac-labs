#!/usr/bin/env bash
set -euo pipefail

# Very small helper script to generate a demo CA, server, and client certificate
# for an EAP-TLS style lab. This is NOT wired into the Docker configs by
# default, but it gives you a starting point.

OPENSSL_CONF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$OPENSSL_CONF_DIR"

CA_KEY="ca.key"
CA_CRT="ca.crt"
SERVER_KEY="server.key"
SERVER_CSR="server.csr"
SERVER_CRT="server.crt"
CLIENT_KEY="client.key"
CLIENT_CSR="client.csr"
CLIENT_CRT="client.crt"

DAYS=3650

echo "[*] Generating CA key and certificate..."
openssl genrsa -out "$CA_KEY" 4096
openssl req -x509 -new -nodes -key "$CA_KEY" -sha256 -days "$DAYS" -out "$CA_CRT" -subj "/C=TR/O=NAC-LAB/OU=CA/CN=nac-lab-ca"

echo "[*] Generating server key and CSR..."
openssl genrsa -out "$SERVER_KEY" 4096
openssl req -new -key "$SERVER_KEY" -out "$SERVER_CSR" -subj "/C=TR/O=NAC-LAB/OU=RADIUS/CN=radius.local"

echo "[*] Signing server certificate..."
openssl x509 -req -in "$SERVER_CSR" -CA "$CA_CRT" -CAkey "$CA_KEY" -CAcreateserial -out "$SERVER_CRT" -days "$DAYS" -sha256

echo "[*] Generating client key and CSR..."
openssl genrsa -out "$CLIENT_KEY" 4096
openssl req -new -key "$CLIENT_KEY" -out "$CLIENT_CSR" -subj "/C=TR/O=NAC-LAB/OU=CLIENT/CN=client01"

echo "[*] Signing client certificate..."
openssl x509 -req -in "$CLIENT_CSR" -CA "$CA_CRT" -CAkey "$CA_KEY" -CAcreateserial -out "$CLIENT_CRT" -days "$DAYS" -sha256

echo ""
echo "Done. Generated files:"
ls -1 *.key *.crt
echo ""
echo "Next steps (manual wiring):"
echo "  - Copy ${CA_CRT}, ${SERVER_KEY}, ${SERVER_CRT} into the FreeRADIUS container cert directory."
echo "  - Configure the 'tls' section in the FreeRADIUS eap module to use them."
echo "  - Copy ${CA_CRT}, ${CLIENT_KEY}, ${CLIENT_CRT} into the supplicant container and point your"
echo "    EAP-TLS config to them."
