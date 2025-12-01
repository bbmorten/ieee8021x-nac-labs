# Lab 1 – FreeRADIUS + Docker + PEAP/MSCHAPv2

## Goal

Bring up a FreeRADIUS server in Docker and authenticate a test user using
EAP‑PEAP (MSCHAPv2) from a supplicant container.

---

## 1. Start the Lab

```bash
cd labs/lab1-freeradius-peap
docker compose up -d --build
```

Services:

- `radius` – FreeRADIUS with a simple config
- `supplicant` – Has `eapol_test` installed

---

## 2. Run a Test Authentication

```bash
docker compose exec supplicant run-eapol-test.sh
```

Expected at the end of the output:

- `SUCCESS` – the authentication worked

If you see `FAILURE` or timeouts, inspect RADIUS logs.

---

## 3. Watch FreeRADIUS Debug Logs

```bash
docker compose logs -f radius
```

Look for lines like:

- `(0) Received Access-Request`
- `(0) Login OK: [testuser]`
- `(0) Sent Access-Accept`

This shows the full EAP conversation and RADIUS decision.

---

## 4. Explore Configuration

### 4.1 Users

`labs/lab1-freeradius-peap/freeradius/users`:

```text
testuser Cleartext-Password := "P@ssw0rd"
```

This defines a local user in FreeRADIUS.

### 4.2 Clients

`labs/lab1-freeradius-peap/freeradius/clients.conf`:

```text
client supplicant {
    ipaddr = 0.0.0.0/0
    secret = testing123
    nas_type = other
}
```

This allows any IP to act as a RADIUS client using the shared secret
`testing123`. In a real network you would lock this down.

### 4.3 EAP Configuration

The Dockerfile uses the default `eap` module config shipped with FreeRADIUS,
which already has PEAP/MSCHAPv2 enabled.

---

## 5. Exercises

1. **Change the Password**  
   - Modify `users` and update the password.  
   - Rebuild the `radius` container or restart it.  
   - Test again with the new password.

2. **Break the Secret**  
   - Change the secret in `clients.conf` but not in the supplicant.  
   - Observe the error in FreeRADIUS logs.  
   - Fix it and test again.

3. **Add a Second User**  
   - Add another username/password pair.  
   - Clone `eapol_test_peap.conf` to another file and test the new user.

4. **Prepare for EAP‑TLS**  
   - Inspect `certs/generate-certs.sh` and think how to wire it into:
     - FreeRADIUS `eap` TLS section
     - Supplicant config

From here, you can extend the lab into:

- **EAP‑TLS** with client certificates
- Integration with real switches / APs as RADIUS clients
- VLAN/ACL assignment with RADIUS attributes
