
# root@46802004a3c3:/usr/local/bin# radtest testuser P@ssw0rd radius 0 testing123
# Sent Access-Request Id 227 from 0.0.0.0:39227 to 172.22.0.2:1812 length 78
#         User-Name = "testuser"
#         User-Password = "P@ssw0rd"
#         NAS-IP-Address = 172.22.0.3
#         NAS-Port = 0
#         Message-Authenticator = 0x00
#         Cleartext-Password = "P@ssw0rd"
# Received Access-Accept Id 227 from 172.22.0.2:1812 to 172.22.0.3:39227 length 20



#!/bin/sh
set -e

RADIUS_SERVER="${RADIUS_SERVER:-radius}"
RADIUS_PORT="${RADIUS_PORT:-1812}"
RADIUS_SECRET="${RADIUS_SECRET:-testing123}"
CONFIG_FILE="${CONFIG_FILE:-/etc/wpa_supplicant/eapol_test_peap.conf}"

echo "============================================"
echo "EAPOL Test - RADIUS Authentication Client"
echo "============================================"
echo "Server: ${RADIUS_SERVER}:${RADIUS_PORT}"
echo "Config: ${CONFIG_FILE}"
echo "============================================"
echo ""

eapol_test -c "${CONFIG_FILE}" \
           -a "${RADIUS_SERVER}" \
           -p "${RADIUS_PORT}" \
           -s "${RADIUS_SECRET}" \
           -t 10 -r 3

exit_code=$?

echo ""
if [ $exit_code -eq 0 ]; then
    echo "✓ Authentication SUCCESS"
else
    echo "✗ Authentication FAILED (exit code: $exit_code)"
fi

exit $exit_code