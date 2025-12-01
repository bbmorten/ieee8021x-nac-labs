# CLAUDE.md - Project Guide for Claude Code

## Project Overview

This is an **IEEE 802.1X NAC (Network Access Control) learning lab** repository. It provides hands-on Docker-based labs for understanding 802.1X authentication, EAP protocols, and RADIUS server configuration.

## Repository Structure

```
ieee8021x-nac-labs/
├── docs/                    # Documentation and theory
│   ├── 01_overview.md       # NAC concepts overview
│   ├── 02_eap_radius.md     # EAP and RADIUS protocol details
│   ├── 03_lab1_freeradius_peap.md   # Lab 1 walkthrough
│   └── 04_lab2_freeradius_eaptls.md # Lab 2 walkthrough
├── labs/
│   ├── lab1-freeradius-peap/   # PEAP/MSCHAPv2 lab
│   │   ├── docker-compose.yml
│   │   ├── freeradius/         # RADIUS server config
│   │   ├── supplicant/         # Linux supplicant with eapol_test
│   │   └── certs/              # Certificate generation scripts
│   └── lab2-freeradius-eaptls/ # EAP-TLS lab (certificate-based auth)
│       ├── docker-compose.yml
│       ├── freeradius/         # RADIUS server config + certs
│       ├── supplicant/         # Linux supplicant with eapol_test
│       └── certs/              # Certificate generation scripts
└── README.md
```

## Key Components

- **FreeRADIUS**: Open-source RADIUS server for AAA (Authentication, Authorization, Accounting)
- **eapol_test**: Linux tool for testing EAP authentication against RADIUS servers (built from wpa_supplicant source)
- **Docker Compose**: Orchestrates the lab environments

## Common Commands

### Starting a Lab
```bash
# Lab 1 - PEAP/MSCHAPv2
cd labs/lab1-freeradius-peap
docker compose up -d --build

# Lab 2 - EAP-TLS
cd labs/lab2-freeradius-eaptls
docker compose up -d --build
```

### Running Authentication Tests
```bash
# Lab 1 - PEAP/MSCHAPv2
docker compose exec supplicant run-eapol-test.sh

# Lab 2 - EAP-TLS
docker compose exec supplicant-tls run-eapol-test.sh
```

### Capturing Traffic (pcap)

```bash
# Lab 1 - with packet capture
docker compose exec supplicant env CAPTURE=true run-eapol-test.sh

# Lab 2 - with packet capture
docker compose exec supplicant-tls env CAPTURE=true run-eapol-test.sh
```

Captures are saved to `./captures/` directory in pcap format.

### Viewing RADIUS Logs
```bash
# Lab 1
docker compose logs -f radius

# Lab 2
docker compose logs -f radius-tls
```

### Stopping a Lab
```bash
docker compose down
```

### Regenerating Certificates (Lab 2)

Lab 2 generates certificates automatically at container startup. To regenerate:
```bash
docker compose down -v   # Remove volume with old certs
docker compose up -d --build
```

## Lab Details

### Lab 1: PEAP/MSCHAPv2
- Username/password authentication
- Server certificate for TLS tunnel
- Inner authentication via MSCHAPv2
- Config files: `freeradius/users`, `freeradius/clients.conf`
- Test user: `testuser` / `P@ssw0rd`

### Lab 2: EAP-TLS
- Certificate-based mutual authentication
- Requires CA, server cert, and client cert
- Certificates generated at runtime and shared via Docker volume
- More secure than PEAP, commonly used in enterprise environments
- Config files: `freeradius/eap`, `freeradius/clients.conf`
- Test identity: `client01` (certificate CN)

## Configuration Files

### Lab 1

- `freeradius/clients.conf` - NAS/authenticator client definitions (secret: `testing123`)
- `freeradius/users` - User database
- `supplicant/eapol_test_peap.conf` - Supplicant PEAP configuration

### Lab 2

- `freeradius/clients.conf` - NAS/authenticator client definitions (secret: `tlssecret`)
- `freeradius/eap` - EAP-TLS module configuration
- `freeradius/start.sh` - Startup script for cert generation
- `supplicant/eapol_test_tls.conf` - Supplicant EAP-TLS configuration

## Architecture Notes

### eapol_test

Both labs build `eapol_test` from wpa_supplicant source code because the Debian `wpasupplicant` package does not include this testing tool. The build process:
1. Downloads wpa_supplicant source
2. Enables `CONFIG_EAPOL_TEST=y` in build config
3. Compiles only the `eapol_test` binary

### Certificate Sharing (Lab 2)

Lab 2 uses a Docker volume to share certificates between containers:
- RADIUS server generates CA, server cert, and client cert at startup
- Certificates are stored in `/shared-certs` volume
- Supplicant reads client cert and CA from the shared volume
- This ensures both containers trust the same CA

## Troubleshooting Tips

1. **Certificate issues (Lab 2)**: Remove volume and rebuild: `docker compose down -v && docker compose up -d --build`
2. **Connection refused**: Ensure containers are running with `docker compose ps`
3. **Auth failures**: Check RADIUS debug logs for detailed error messages
4. **Shared secret mismatch**: Verify `clients.conf` matches supplicant config
5. **Hostname resolution**: `eapol_test` requires IP addresses; the run scripts handle DNS resolution automatically
6. **DH parameter generation**: Lab 2 first startup may take ~30 seconds for DH parameter generation
