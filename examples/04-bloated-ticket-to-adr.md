# Example 4: Over-Engineered Ticket to Crisp ADR + `/ops-bro`

## User

> Please turn this Jira ticket into an ADR:
>
> ```text
> [PLAT-2847] Strategic Initiative: Holistically Synergize Next-Gen
> Distributed Resilience Paradigm for Checkout Persistence Layer to
> Proactively Leverage Best-in-Breed Ecosystem Capabilities
>
> Description:
> As a synergy stakeholder, we must operationalize a holistic,
> hyper-converged, AI-driven persistence resilience mesh that
> incentivizes paradigm-shifting throughput synergies across the
> checkout value stream. Let's ideate on leveraging bleeding-edge
> next-gen disruptors to actualize 360-degree robustness for our
> mission-critical persistence journey.
>
> Acceptance Criteria:
> 1. Synergize resilient outcomes across all verticals.
> 2. Leverage holistic best practices with zero disruption.
> 3. Actualize scalable paradigm with best-in-breed tooling.
>
> Hidden signal (from comments):
> - checkout-api P95 latency is 2.8s during peak, SLO is 500ms.
> - Postgres reports max_connections=100, active connections hover at 98.
> - checkout-api Deployment runs 12 replicas, each holding 8 idle connections.
> - Ingress shows spikes of HTTP 504 during checkout bursts.
> ```

## `ops-bro` (Clean Artifact Mode)

Checkout P95 of `2.8s` (SLO: `500ms`) is caused by Postgres connection exhaustion (`98/100` of `max_connections`), not missing features. Twelve `checkout-api` replicas holding `8` connections each saturate the database, so bursts queue and the ingress returns `504`.

## ADR-0042: Add Transaction-Mode Connection Pooling in Front of Checkout Database

### Status

Accepted on `2026-11-26`. Owners: Checkout + Platform.

### Context

- `checkout-api` (`12` replicas x `8` connections = `96` baseline) leaves almost no headroom against Postgres `max_connections=100`.
- Peak traffic queues for a free connection; client-visible symptom is P95 `2.8s` and ingress `504` over the `500ms` SLO.
- Ticket `PLAT-2847` asks for a "resilience mesh" but names no mechanism, metric, or rollback.

### Decision

Deploy a transaction-mode connection pooler as a dedicated `Deployment` (`pooler-checkout`, `3` replicas for HA) between `checkout-api` and Postgres:

- Cap each `checkout-api` Pod at `4` pooled connections via `DATABASE_URL` + `pool_size=4`.
- Cap the pooler at `60` server-side connections total, leaving `40` headroom under `max_connections=100` for migrations and admin.
- Gate rollout on existing SLO: P95 `checkout-api` latency < `500ms` over `30m`, zero `504` spikes during peak replay.

### Alternatives Considered

- Raise `max_connections` to `200`: rejected. Memory per connection grows, and `12` replicas would still race to the new ceiling without backpressure.
- Per-Pod vertical scaling: rejected. More CPU/RAM does not add database connections; it makes the stampede faster.
- Full "resilience mesh" rewrite: rejected. No defined problem, no SLO, no rollback plan.

### Consequences

- Positive: connection queueing moves into the pooler where it is observable (`pool_wait_ms`, `pool_checkout_p95`) and tunable without touching the database.
- Positive: rollback is a single `DATABASE_URL` revert to direct Postgres.
- Watch: set alerts on `pool_wait_ms > 100ms` over `5m` and `pooler Ready < 3` so saturation pages before clients see `504` again.

---

## User: `/ops-bro`

## `ops-bro` (Plain-Language Translation)

Ticket `PLAT-2847` is ten paragraphs of buzzwords hiding a simple plumbing problem. Your checkout database only allows `max_connections=100` simultaneous connections, and your `12` copies of `checkout-api` each hold `8` open — that's `96` spoken for before a single real customer shows up. When a burst arrives there is nowhere to sit, so requests wait in line until the front door gives up and returns `504`, which is why P95 is `2.8s` against a `500ms` promise.

The fix in `ADR-0042` is a waiting room. You put a small pooler (`pooler-checkout`, `3` copies so one can die safely) between the API and Postgres, tell each API Pod it only gets `pool_size=4`, and tell the pooler it may only open `60` real database connections total. That leaves `40` spare for admin work and stops the stampede. If the waiting room itself fills up you will see `pool_wait_ms > 100ms`, and if that lasts `5m` you get paged — long before customers see another `504`.
