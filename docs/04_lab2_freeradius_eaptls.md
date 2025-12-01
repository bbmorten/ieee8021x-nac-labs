# Lab 2 – FreeRADIUS + Docker + EAP-TLS

This lab extends the PEAP/MSCHAPv2 lab into **certificate-based EAP-TLS**.

We will:

- Spin up a second FreeRADIUS instance with EAP-TLS enabled
- Generate a small lab CA, server cert, and client cert
- Authenticate with **EAP-TLS** from a supplicant container using `eapol_test`

> ⚠️ All keys/certs generated here are for lab use only. Never reuse in
> production.

---

## 1. Start the Lab

```bash
cd labs/lab2-freeradius-eaptls
docker compose up -d --build
```

Services:

- `radius-tls` – FreeRADIUS with EAP-TLS enabled
- `supplicant-tls` – Has `eapol_test` and client certificates

During the Docker build, both containers run `certs/generate-certs.sh` to
create:

- A private CA
- A server certificate (for RADIUS)
- A client certificate (for the supplicant)

---

## 2. Run an EAP-TLS Authentication

```bash
docker compose exec supplicant-tls run-eapol-test.sh
```

Expected result:

- `SUCCESS` at the end of `eapol_test` output
- RADIUS logs showing EAP-TLS and `Access-Accept`

---

## 3. Inspect Certificates

Inside the RADIUS container:

```bash
docker compose exec radius-tls ls -l /etc/freeradius/3.0/certs
```

You should see:

- `ca.crt`
- `server.crt`
- `server.key`
- `client.crt` (not used by the server)
- `client.key` (not used by the server)
- `dh` (Diffie–Hellman params)

Inside the supplicant container:

```bash
docker compose exec supplicant-tls ls -l /etc/certs
```

You should see:

- `ca.crt`
- `client.crt`
- `client.key`

---

## 4. Explore EAP-TLS Configuration

### 4.1 RADIUS EAP Module

`labs/lab2-freeradius-eaptls/freeradius/eap` is copied into
`/etc/freeradius/3.0/mods-available/eap` and defines:

- Default EAP type = `tls`
- TLS config pointing at our generated certs

### 4.2 Supplicant Config

`labs/lab2-freeradius-eaptls/supplicant/eapol_test_tls.conf`:

```text
network={
    key_mgmt=IEEE8021X
    eap=TLS
    identity="client01"
    ca_cert="/etc/certs/ca.crt"
    client_cert="/etc/certs/client.crt"
    private_key="/etc/certs/client.key"
}
```

This tells `eapol_test` to:

- Use EAP-TLS
- Present the client certificate to the RADIUS server
- Validate the server using the same CA

---

## 5. Exercises

1. **Break Trust by Changing CA**  
   - Edit `generate-certs.sh` to change subject or CA CN.  
   - Rebuild only one side (RADIUS or supplicant).  
   - Observe EAP-TLS failure and check logs.

2. **Client Revocation (Conceptual)**  
   - Think about how you would revoke `client01` in a real PKI:  
     - CRL / OCSP  
     - Removing the cert mapping in your NAC policy

3. **Multiple Clients**  
   - Extend `generate-certs.sh` to produce multiple client certs
     (e.g., `client02`).  
   - Add a second EAP-TLS profile and test.

Once you’re comfortable with this TLS lab, you can map these concepts directly
to enterprise NAC platforms (ISE, ClearPass, NPS) and to real wired/wireless
802.1X deployments.
