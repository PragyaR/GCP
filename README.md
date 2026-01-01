# GCP SRE Platform Demo – Cloud Run, Terraform, SLOs & Burn Rate Alerting

This repository demonstrates a **production-grade SRE setup on Google Cloud Platform**, focused on **reliability engineering**, **error budgets**, and **alerting based on SLO burn rate** rather than raw metrics.

It is designed as a **hands-on demo** suitable for:

* SRE interviews
* Reliability discussions
* IaC + Observability walkthroughs

---

## 🧱 Architecture Overview

**Core components:**

* **Cloud Run** – Serverless container runtime (zero idle cost)
* **Terraform** – Infrastructure as Code (source of truth)
* **Cloud Monitoring** – Native metrics, SLOs, alerting
* **GitHub Actions (OIDC)** – CI/CD without static secrets

```
Client Load
   ↓
Cloud Run (Flask API)
   ↓
Cloud Monitoring
   ├─ Availability SLO (99.9%)
   ├─ High Error Rate Alert
   └─ SLO Burn Rate Alert
```

---

## 🎯 Design Goals (SRE Principles)

* No click-ops (everything declarative)
* Alerts tied to **user impact**, not raw errors
* Error budgets drive alerting behavior
* Support controlled failure injection
* Low alert noise, high signal

---

## 🚀 Application Behavior

The demo API intentionally simulates failures to demonstrate observability and alerting.

### Behavior

* Returns `200 OK` most of the time
* Randomly returns `500` based on `ERROR_RATE`
* Emits structured logs for each request

---

## 🔥 Failure Injection (Chaos Testing)

You can dynamically change the error rate **without redeploying**:

```bash
gcloud run services update demo-api \
  --region us-central1 \
  --update-env-vars ERROR_RATE=0.5
```

This simulates a severe partial outage (~50% failures).

Terraform remains the **source of truth** and will detect/revert drift if applied again.

---

## 📊 Observability & Reliability

### Availability SLO

* **Target**: 99.9% success rate
* **Window**: 30 days
* **Signal**: Cloud Run request metrics
* **SLI**: Ratio of 2xx responses to total requests

---

### Alert 1: High Error Rate

Triggers when:

* 5xx error ratio > **1%**
* Sustained for **2 minutes**

Purpose:

> Detect immediate service instability.

---

### Alert 2: SLO Burn Rate (Fast Burn)

Triggers when:

* Error budget is consumed **>2× faster** than allowed
* Evaluated over a 60s window
* Sustained for 120s

Purpose:

> Detect long-term reliability risk before the SLO is breached.

This alert answers:

> *“If this continues, how fast will we exhaust our error budget?”*

---

## 🧪 Demo Scenario

1. Deploy container via CI/CD 
2. Deploy infrastructure with Terraform
3. Inject failures:

   ```bash
   ERROR_RATE=0.5
   ```
4. Generate load:

   ```powershell
   .\simulate-load.ps1 `
     -ServiceUrl https://<cloud-run-url> `
     -Requests 1000 `
     -DelayMs 100
   ```
5. Observe:

   * High error-rate alert fires
   * SLO burn-rate alert fires
   * SLO compliance degrades   

6. Restore system:

   ```bash
   ERROR_RATE=0.02
   ```

---

## 📈 Example Outcome

After a 1000-request test:

* 502 successes
* 498 failures

Observed:

* Error rate ≈ **2.1%**
* Burn rate ≈ **20.8**

Result:

* High error-rate alert triggered because the 5xx ratio exceeded 1% for over two minutes.
* SLO burn-rate alert triggered because we exceeded the allowed error budget by over 20× for more than two minutes, meaning we’d exhaust the monthly budget in about a day. 

This demonstrates **correct, expected SRE behavior**.

---

## 🔐 CI/CD & Security

* GitHub Actions uses **Workload Identity Federation**
* No long-lived service account keys
* Terraform deployments use Application Default Credentials for login
* Drift detection enforced via IaC

---

## 🧠 Key SRE Takeaways

* Alerts are **SLO-aligned**, not metric-driven
* Error budgets govern operational response
* Failure injection is safe and reversible
* Terraform is the system of record
* Observability focuses on **user impact**

---

## 📌 Why this matters

This repo demonstrates how real SRE teams:

* Avoid alert fatigue
* Measure reliability objectively
* Detect issues early using burn rates
* Balance velocity with stability