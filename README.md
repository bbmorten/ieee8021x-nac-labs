# IEEE 802.1X NAC Labs – FreeRADIUS + Docker

This repository contains hands‑on labs for learning IEEE 802.1X and NAC concepts
using **FreeRADIUS** in Docker and a Linux supplicant container.

> ⚠️ These labs are for learning and testing only. Do **not** use these sample
> configs in production.

---

## Labs Included

| Lab | Description | Authentication |
|-----|-------------|----------------|
| `lab1-freeradius-peap` | PEAP/MSCHAPv2 with username/password | Easier to get started |
| `lab2-freeradius-eaptls` | Full EAP-TLS with CA, server, and client certs | More secure, enterprise-grade |

---

## Repository Layout

```text
ieee8021x-nac-labs/
├── docs/
│   ├── 01_overview.md           # NAC concepts overview
│   ├── 02_eap_radius.md         # EAP and RADIUS protocol details
│   ├── 03_lab1_freeradius_peap.md
│   └── 04_lab2_freeradius_eaptls.md
├── labs/
│   ├── lab1-freeradius-peap/    # PEAP/MSCHAPv2 lab
│   │   ├── docker-compose.yml
│   │   ├── freeradius/
│   │   ├── supplicant/
│   │   └── certs/
│   └── lab2-freeradius-eaptls/  # EAP-TLS lab
│       ├── docker-compose.yml
│       ├── freeradius/
│       ├── supplicant/
│       └── certs/
├── README.md
└── LICENSE
```

---

## Prerequisites

- Docker + Docker Compose
- Linux or macOS shell (Windows WSL2 works too)

---

## Quickstart: Lab 1 (PEAP/MSCHAPv2)

### 1. Go to the lab directory

```bash
cd labs/lab1-freeradius-peap
```

### 2. Bring up the lab

```bash
docker compose up -d --build
```

This starts:

- `radius` – FreeRADIUS server
- `supplicant` – Linux container with `eapol_test`

### 3. Run an EAP‑PEAP/MSCHAPv2 authentication

```bash
docker compose exec supplicant run-eapol-test.sh
```

You should see `✓ Authentication SUCCESS` at the end.

### 4. Watch RADIUS debug logs

```bash
docker compose logs -f radius
```

### 5. Stop the lab

```bash
docker compose down
```

---

## Quickstart: Lab 2 (EAP-TLS)

```bash
cd labs/lab2-freeradius-eaptls
docker compose up -d --build
```

This starts:

- `radius-tls` – FreeRADIUS server configured for EAP-TLS
- `supplicant-tls` – Linux container with `eapol_test` and client certificate

Note: First startup may take ~30 seconds for DH parameter generation.

Run an EAP-TLS authentication:

```bash
docker compose exec supplicant-tls run-eapol-test.sh
```

You should see `✓ Authentication SUCCESS` at the end.

Watch RADIUS debug logs:

```bash
docker compose logs -f radius-tls
```

Stop the lab:

```bash
docker compose down
```

### Regenerating Certificates

Lab 2 generates certificates automatically at startup. To regenerate:

```bash
docker compose down -v   # Remove volume with old certs
docker compose up -d --build
```

---

## Test Credentials

| Lab | Identity | Secret |
|-----|----------|--------|
| Lab 1 | `testuser` | `P@ssw0rd` |
| Lab 2 | `client01` | (certificate-based) |

RADIUS shared secrets:

- Lab 1: `testing123`
- Lab 2: `tlssecret`

---

## Documentation

- [01_overview.md](docs/01_overview.md) – NAC concepts overview
- [02_eap_radius.md](docs/02_eap_radius.md) – EAP and RADIUS protocol details
- [03_lab1_freeradius_peap.md](docs/03_lab1_freeradius_peap.md) – Lab 1 walkthrough
- [04_lab2_freeradius_eaptls.md](docs/04_lab2_freeradius_eaptls.md) – Lab 2 walkthrough

---

## Architecture Notes

### eapol_test

Both labs build `eapol_test` from wpa_supplicant source code because the Debian
`wpasupplicant` package does not include this testing tool.

### Certificate Sharing (Lab 2)

Lab 2 uses a Docker volume to share certificates between containers:

- RADIUS server generates CA, server cert, and client cert at startup
- Certificates are stored in a shared volume
- Supplicant reads client cert and CA from the shared volume
- This ensures both containers trust the same CA

---

## Troubleshooting

1. **Certificate issues (Lab 2)**: Remove volume and rebuild:

   ```bash
   docker compose down -v && docker compose up -d --build
   ```

2. **Connection refused**: Ensure containers are running:

   ```bash
   docker compose ps
   ```

3. **Auth failures**: Check RADIUS debug logs for detailed error messages

4. **Shared secret mismatch**: Verify `clients.conf` matches supplicant config
