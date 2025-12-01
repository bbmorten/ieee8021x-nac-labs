# EAP and RADIUS in this Lab

## EAP Method

The lab uses:

- **Outer method:** PEAP (Protected EAP)
- **Inner method:** MSCHAPv2 (username/password)

The authentication identity will be:

- Username: `testuser`
- Password: `P@ssw0rd`

These are configured in `freeradius/users`.

## RADIUS Client

The RADIUS client is logically the "NAS" (switch/WLC). In this lab, we cheat
slightly: `eapol_test` talks directly to the RADIUS server, but we still need
a RADIUS client definition with a shared secret:

- `clients.conf` – defines a generic client with IP `0.0.0.0/0`
- Shared secret: `testing123`

This matches the secret used in the `eapol_test_peap.conf` file.

You can think of `eapol_test` as emulating the 802.1X side of a switch.
