# IEEE 802.1X NAC Labs – FreeRADIUS + Docker

This repository contains hands‑on labs for learning IEEE 802.1X and NAC concepts
using **FreeRADIUS** in Docker and a Linux supplicant container.

The first lab focuses on **EAP over RADIUS** using **PEAP (EAP‑MSCHAPv2)**, which
is easier to get running quickly. A skeleton for certificate generation is also
included so you can extend the lab to **EAP‑TLS**.

> ⚠️ These labs are for learning and testing only. Do **not** use these sample
> configs in production.

---

## Repository Layout

```text
ieee8021x-nac-labs/
  README.md
  LICENSE
  .gitignore
  docs/
    01_overview.md
    02_eap_radius.md
    03_lab1_freeradius_peap.md
  labs/
    lab1-freeradius-peap/
      docker-compose.yml
      freeradius/
        Dockerfile
        clients.conf
        users
      supplicant/
        Dockerfile
        eapol_test_peap.conf
        run-eapol-test.sh
      certs/
        generate-certs.sh
        openssl.cnf
```

---

## Quickstart

Prereqs:

- Docker + Docker Compose
- Linux or macOS shell (Windows WSL2 is fine)

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

You should see output similar to:

- `SUCCESS` when auth passes
- Detailed EAP/RADIUS exchange in the logs

### 4. Watch RADIUS debug logs

```bash
docker compose logs -f radius
```

---

## Next Steps

- Read `docs/03_lab1_freeradius_peap.md` for a step‑by‑step walk‑through.
- Inspect `labs/lab1-freeradius-peap/freeradius/*` for RADIUS config.
- Inspect `labs/lab1-freeradius-peap/supplicant/*` for supplicant config.
- Use `certs/generate-certs.sh` as a starting point for an EAP‑TLS lab.

You can push this repo directly to GitHub:

```bash
git init
git add .
git commit -m "Add IEEE 802.1X / NAC FreeRADIUS Docker lab"
git remote add origin git@github.com:<your-user>/ieee8021x-nac-labs.git
git push -u origin main
```


---

## Labs Included

- `lab1-freeradius-peap` – PEAP/MSCHAPv2 with FreeRADIUS + Docker
- `lab2-freeradius-eaptls` – Full EAP-TLS lab with its own CA, server, and client certs

