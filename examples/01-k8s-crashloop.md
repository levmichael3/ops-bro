# Example 1: Kubernetes `CrashLoopBackOff` + `/ops-bro`

## User

> Pod `checkout-worker-7d9f8b6c4-x2k9p` is stuck in `CrashLoopBackOff` right after deploy. Logs cut off mid-startup.

## `ops-bro` (Default Pinpoint Mode)

The container is likely hitting either a premature `livenessProbe` failure during cold start or an `OOMKilled` (`Exit Code 137`) event before flushing stdout.

Check the termination reason and probe events immediately:

```bash
kubectl describe pod checkout-worker-7d9f8b6c4-x2k9p -n prod
kubectl logs checkout-worker-7d9f8b6c4-x2k9p -n prod --previous
```

- If `Last State` shows `Reason: OOMKilled` (`Exit Code: 137`), raise `spec.containers[].resources.limits.memory` in your Deployment manifest.
- If `Events` shows `Liveness probe failed`, add a `startupProbe` or increase `initialDelaySeconds` so the kubelet stops killing the Pod mid-boot.

---

## User: `/ops-bro`

## `ops-bro` (Plain-Language Translation)

Your `checkout-worker-7d9f8b6c4-x2k9p` pod is dying during startup before it even finishes printing its logs, so Kubernetes keeps restarting it over and over (`CrashLoopBackOff`). There are two usual suspects: either it ran out of RAM (`OOMKilled` / `Exit Code 137`), or Kubernetes asked "are you alive yet?" too early (`Liveness probe failed`) and killed it while it was still booting up.

Run `kubectl describe pod checkout-worker-7d9f8b6c4-x2k9p -n prod` and `kubectl logs checkout-worker-7d9f8b6c4-x2k9p -n prod --previous` to see which one happened. If it ran out of RAM, bump `spec.containers[].resources.limits.memory`. If it just boots slowly, add a `startupProbe` or raise `initialDelaySeconds` so Kubernetes gives it more time.
