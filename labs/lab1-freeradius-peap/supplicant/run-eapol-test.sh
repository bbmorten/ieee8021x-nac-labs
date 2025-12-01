#!/bin/sh
set -e

RADIUS_SERVER="${RADIUS_SERVER:-radius}"
RADIUS_PORT="${RADIUS_PORT:-1812}"
RADIUS_SECRET="${RADIUS_SECRET:-testing123}"
CONFIG_FILE="${CONFIG_FILE:-/etc/wpa_supplicant/eapol_test_peap.conf}"

# Resolve hostname to IP address (eapol_test requires IP, not hostname)
if echo "${RADIUS_SERVER}" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$'; then
    RADIUS_IP="${RADIUS_SERVER}"
else
    RADIUS_IP=$(getent hosts "${RADIUS_SERVER}" | awk '{print $1}' | head -n1)
    if [ -z "${RADIUS_IP}" ]; then
        echo "ERROR: Cannot resolve hostname '${RADIUS_SERVER}'"
        exit 1
    fi
fi

echo "============================================"
echo "EAPOL Test - RADIUS Authentication Client"
echo "============================================"
echo "Server: ${RADIUS_SERVER} (${RADIUS_IP}):${RADIUS_PORT}"
echo "Config: ${CONFIG_FILE}"
echo "============================================"
echo ""

eapol_test -c "${CONFIG_FILE}" \
           -a "${RADIUS_IP}" \
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