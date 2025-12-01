# 802.1X / NAC Lab Overview

These labs implement a small but realistic slice of a NAC system:

- A **RADIUS server** (FreeRADIUS)
- A **supplicant** (Linux host using `eapol_test`)
- **EAP over RADIUS** with username/password (PEAP/MSCHAPv2)

Instead of a physical switch or wireless controller, we directly test
EAP/RADIUS with `eapol_test`. This is a standard way to validate your RADIUS
and EAP configuration before integrating with switches and controllers.

Once you understand the flow here, you can apply the same logic on:

- Cisco ISE / Aruba ClearPass / NPS / FreeRADIUS on bare metal
- Wired 802.1X ports on switches
- Wireless WPA2‑Enterprise / WPA3‑Enterprise SSIDs
