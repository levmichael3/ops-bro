# Example 3: Generating a Zero-Bloat Runbook

## User

> Write a short, clean runbook for high 5xx error rates on our ingress gateway.

## `ops-bro` (Clean Artifact Mode)

## Runbook: Ingress Gateway Elevated 5xx Rate

## 1. Symptom & Blast Radius

- **Alert:** `IngressHigh5xxRate` (> 2% HTTP `502`/`503`/`504` responses over 5 minutes).
- **Impact:** External client requests are failing at the edge before or during upstream routing.

## 2. Immediate Mitigation

1. **Check recent rollouts:** If errors spiked within 15 minutes of a deployment, roll back the offending upstream `Deployment` immediately:

   ```bash
   kubectl rollout undo deployment/<service-name> -n <namespace>
   ```

2. **Shed load / scale edge:** If ingress controller CPU/memory is saturated, scale replicas horizontally:

   ```bash
   kubectl scale deployment/ingress-gateway -n ingress --replicas=<N>
   ```

## 3. Diagnostic Commands

- **Isolate failing upstream routes (`502` vs `504`):**

  ```bash
  kubectl logs -l app=ingress-gateway -n ingress --since=10m | grep -E " (502|503|504) "
  ```

- **Verify upstream `Endpoints` exist and Pods are `Ready`:**

  ```bash
  kubectl get endpoints <service-name> -n <namespace>
  ```

- **Check saturation on gateway Pods:**

  ```bash
  kubectl top pods -n ingress
  ```

## 4. Root Cause & Prevention

- **`502 Bad Gateway`:** Upstream process crashed or closed connections abruptly; verify `readinessProbe` grace periods and `preStop` lifecycle hooks (`sleep 5`) so traffic drains before Pod termination.
- **`504 Gateway Timeout`:** Upstream latency exceeded proxy timeout; inspect distributed traces for database lock contention or downstream backpressure, and tune circuit-breaker thresholds.
