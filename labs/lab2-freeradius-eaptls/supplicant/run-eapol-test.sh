#!/bin/sh
set -e

RADIUS_SERVER="${RADIUS_SERVER:-radius-tls}"
RADIUS_PORT="${RADIUS_PORT:-1812}"
RADIUS_SECRET="${RADIUS_SECRET:-tlssecret}"
CONFIG_FILE="${CONFIG_FILE:-/etc/wpa_supplicant/eapol_test_tls.conf}"
CAPTURE="${CAPTURE:-false}"
CAPTURE_FILE="${CAPTURE_FILE:-/captures/eaptls-auth-$(date +%Y%m%d-%H%M%S).pcap}"

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
echo "EAPOL Test - EAP-TLS Authentication Client"
echo "============================================"
echo "Server: ${RADIUS_SERVER} (${RADIUS_IP}):${RADIUS_PORT}"
echo "Config: ${CONFIG_FILE}"
if [ "${CAPTURE}" = "true" ]; then
    echo "Capture: ${CAPTURE_FILE}"
fi
echo "============================================"
echo ""

# Start tcpdump in background if capture is enabled
if [ "${CAPTURE}" = "true" ]; then
    echo "[*] Starting packet capture..."
    tcpdump -i any -w "${CAPTURE_FILE}" "host ${RADIUS_IP} and udp port ${RADIUS_PORT}" &
    TCPDUMP_PID=$!
    # Give tcpdump time to start
    sleep 1
fi

eapol_test -c "${CONFIG_FILE}" \
           -a "${RADIUS_IP}" \
           -p "${RADIUS_PORT}" \
           -s "${RADIUS_SECRET}" \
           -t 10 -r 3

exit_code=$?

# Stop tcpdump if it was started
if [ "${CAPTURE}" = "true" ] && [ -n "${TCPDUMP_PID}" ]; then
    sleep 1  # Allow final packets to be captured
    kill "${TCPDUMP_PID}" 2>/dev/null || true
    wait "${TCPDUMP_PID}" 2>/dev/null || true
    echo ""
    echo "[*] Packet capture saved to: ${CAPTURE_FILE}"
fi

echo ""
if [ $exit_code -eq 0 ]; then
    echo "✓ Authentication SUCCESS"
else
    echo "✗ Authentication FAILED (exit code: $exit_code)"
fi

exit $exit_code
