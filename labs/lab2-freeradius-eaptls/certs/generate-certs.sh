#!/usr/bin/env bash
set -euo pipefail

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
DH_FILE="dh"

DAYS=3650

echo "[*] Generating CA key and certificate..."
openssl genrsa -out "$CA_KEY" 4096
openssl req -x509 -new -nodes -key "$CA_KEY" -sha256 -days "$DAYS" -out "$CA_CRT" -subj "/C=TR/O=NAC-LAB-TLS/OU=CA/CN=nac-lab-ca"

echo "[*] Generating server key and CSR..."
openssl genrsa -out "$SERVER_KEY" 4096
openssl req -new -key "$SERVER_KEY" -out "$SERVER_CSR" -subj "/C=TR/O=NAC-LAB-TLS/OU=RADIUS/CN=radius-tls.local"

echo "[*] Signing server certificate..."
openssl x509 -req -in "$SERVER_CSR" -CA "$CA_CRT" -CAkey "$CA_KEY" -CAcreateserial -out "$SERVER_CRT" -days "$DAYS" -sha256

echo "[*] Generating client key and CSR..."
openssl genrsa -out "$CLIENT_KEY" 4096
openssl req -new -key "$CLIENT_KEY" -out "$CLIENT_CSR" -subj "/C=TR/O=NAC-LAB-TLS/OU=CLIENT/CN=client01"

echo "[*] Signing client certificate..."
openssl x509 -req -in "$CLIENT_CSR" -CA "$CA_CRT" -CAkey "$CA_KEY" -CAcreateserial -out "$CLIENT_CRT" -days "$DAYS" -sha256

echo "[*] Generating Diffie–Hellman parameters (this may take a while)..."
openssl dhparam -out "$DH_FILE" 2048

echo ""
echo "Done. Generated files:"
ls -1 *.key *.crt "$DH_FILE"
