# 🤙 ops-bro

**Pinpoint, vendor-agnostic DevOps & SRE speak — plus `/ops-bro` to translate dense logs, errors, and jargon into plain language without losing a single flag.**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Format: Agent Skill](https://img.shields.io/badge/Format-Agent_Skill-blue.svg)](SKILL.md)
[![Works with](https://img.shields.io/badge/Works_with-Claude_Cursor_OpenCode_Codex-lightgrey.svg)](#compatibility--installation)
[![CI](https://github.com/levmichael3/ops-bro/actions/workflows/ci.yml/badge.svg)](https://github.com/levmichael3/ops-bro/actions/workflows/ci.yml)

> Replace `levmichael3` in the badge URLs and install commands below with your actual GitHub username or org.

---

## Why ops-bro?

AI agents usually fail DevOps in one of two ways: they either drown you in corporate fluff ("In today's dynamic cloud-native ecosystem...") or dump a wall of raw telemetry and acronyms at 3 AM when production is on fire.

`ops-bro` is a single-file Agent Skill ([`SKILL.md`](SKILL.md)) that gives your AI coding partner three sharp modes:

1. **Pinpoint DevOps & SRE Speak (Default):** Leads with the bottom line, uses exact vendor-agnostic operational vocabulary (Kubernetes, declarative IaC, CI/CD, GitOps, OpenTelemetry), and flags destructive actions before you run them.
2. **Clean Artifact Mode:** Automatically formats runbooks, postmortems (RCAs), and Architecture Decision Records (ADRs) into scannable, zero-bloat docs that both engineers and stakeholders can read.
3. **`/ops-bro` Plain-Language Mode:** Inspired by [`luchasarie/bro-skill`](https://github.com/luchasarie/bro-skill).
   Type `/ops-bro` after a dense reply — or paste a raw stack trace, state-lock error, or RFC after `/ops-bro` — to get it explained like a sharp teammate over coffee, while keeping every command, path, port, and exit code **100% verbatim**.

**What it is:** a portable skill + slash-command pair. No dependencies, no API keys, no cloud lock-in.
**What it isn't:** a SaaS product, a monitoring agent, or a replacement for reading your alerts.

---

## Compatibility & Installation

Supported platforms include Claude Code, Cursor, OpenCode, OpenAI Codex, and Hermes Agent, with corresponding skill paths and invocation commands detailed below.

| Tool             | Skill location                               | Slash command / invocation                           |
| :--------------- | :------------------------------------------- | :--------------------------------------------------- |
| **Claude Code**  | `~/.claude/skills/ops-bro/SKILL.md`          | `/ops-bro` (`~/.claude/commands/ops-bro.md`)         |
| **Cursor**       | `~/.cursor/skills/ops-bro/SKILL.md`          | `/ops-bro`                                           |
| **OpenCode**     | `~/.config/opencode/skills/ops-bro/SKILL.md` | `/ops-bro` (`~/.config/opencode/command/ops-bro.md`) |
| **OpenAI Codex** | `~/.codex/skills/ops-bro/SKILL.md`           | `$ops-bro` or via `/skills`                          |
| **Hermes Agent** | `~/.hermes/skills/ops-bro/SKILL.md`          | Auto-loaded skill                                    |

> **Note:** OpenCode uses the singular `command/` directory (not `commands/`). The installer handles this for you.

### Quick Install

**One-liner** — detects which AI coding tools are installed and drops `ops-bro` into each:

```bash
curl -fsSL https://raw.githubusercontent.com/levmichael3/ops-bro/main/install.sh | bash
```

**From a clone:**

```bash
git clone https://github.com/levmichael3/ops-bro.git
cd ops-bro
chmod +x install.sh
./install.sh
```

Restart your agent session after installing, then type `/ops-bro` anytime.

---

## Examples

Refer to the included examples and MIT LICENSE for further reference:

- [`examples/01-k8s-crashloop.md`](examples/01-k8s-crashloop.md) — Kubernetes `CrashLoopBackOff` diagnosis, then `/ops-bro` plain-language translation.
- [`examples/02-iac-state-lock.md`](examples/02-iac-state-lock.md) — Pasting a raw declarative IaC state-lock error into `/ops-bro`.
- [`examples/03-clean-runbook.md`](examples/03-clean-runbook.md) — Zero-bloat ingress-gateway 5xx runbook via Clean Artifact Mode.

### Example: Kubernetes `CrashLoopBackOff` + `/ops-bro`

**User:**

> Pod `checkout-worker-7d9f8b6c4-x2k9p` is stuck in `CrashLoopBackOff` right after deploy. Logs cut off mid-startup.

**`ops-bro` (Default Pinpoint Mode):**

> The container is likely hitting either a premature `livenessProbe` failure during cold start or an `OOMKilled` (`Exit Code 137`) event before flushing stdout.
>
> Check the termination reason and probe events immediately:
>
> ```bash
> kubectl describe pod checkout-worker-7d9f8b6c4-x2k9p -n prod
> kubectl logs checkout-worker-7d9f8b6c4-x2k9p -n prod --previous
> ```
>
> - If `Last State` shows `Reason: OOMKilled` (`Exit Code: 137`), raise `spec.containers[].resources.limits.memory` in your Deployment manifest.
> - If `Events` shows `Liveness probe failed`, add a `startupProbe` or increase `initialDelaySeconds` so the kubelet stops killing the Pod mid-boot.

**User:**

> `/ops-bro`

**`ops-bro` (Plain-Language Translation):**

> Your `checkout-worker-7d9f8b6c4-x2k9p` pod is dying during startup before it even finishes printing its logs, so Kubernetes keeps restarting it over and over (`CrashLoopBackOff`). There are two usual suspects: either it ran out of RAM (`OOMKilled` / `Exit Code 137`), or Kubernetes asked "are you alive yet?" too early (`Liveness probe failed`) and killed it while it was still booting up.
>
> Run `kubectl describe pod checkout-worker-7d9f8b6c4-x2k9p -n prod` and `kubectl logs checkout-worker-7d9f8b6c4-x2k9p -n prod --previous` to see which one happened. If it ran out of RAM, bump `spec.containers[].resources.limits.memory`. If it just boots slowly, add a `startupProbe` or raise `initialDelaySeconds` so Kubernetes gives it more time.

---

## Core rules baked in

- **Bottom Line Up Front (BLUF):** Root cause or action in sentence one. Zero throat-clearing.
- **Vendor-agnostic:** Built around open primitives (Kubernetes, OCI, declarative HCL/IaC, GitOps, OpenTelemetry) rather than proprietary cloud lock-in.
- **Facts survive verbatim:** Commands, flags, paths, ports, and exit codes are never altered or paraphrased.
- **Safety first:** Destructive actions (`destroy`, `kubectl delete`, force-pushes) always include dry-run flags first.
- **Same language:** Responds in whatever language you prompt in.

---

## Continuous integration

The repository includes [`.github/workflows/ci.yml`](.github/workflows/ci.yml) configured to trigger on pushes to `main` and pull requests. It runs:

- **ShellCheck** via `ludeeus/action-shellcheck@master` on `install.sh`.
- **Frontmatter & structure validation** via an inline Python script that verifies `SKILL.md` starts with valid YAML frontmatter containing the required keys (`name: ops-bro`, `description:`).
- **Markdown linting** via `DavidAnson/markdownlint-cli2-action@v19` across root and example Markdown files.

---

## Contributing

Want to add a new runbook, incident pattern, or IaC failure mode? See [CONTRIBUTING.md](CONTRIBUTING.md) for example format, naming (`NN-slug.md`), and the `/ops-bro` translation requirement.

---

## GitAnimals

Every contribution grows a pet! This repo supports [GitAnimals](https://www.gitanimals.org/) — 30 commits adopt a new pet, and contributions level it up.

[![GitAnimals Farm](https://render.gitanimals.org/farms/levmichael3)](https://www.gitanimals.org/en-US/farm/levmichael3)

> After forking, [connect your GitHub account on gitanimals.org](https://www.gitanimals.org/), then replace `ops-bro` in the image URL above with your own farm name to show your pets here.

---

## Credits & License

Inspired by [`luchasarie/bro-skill`](https://github.com/luchasarie/bro-skill). Released under the [MIT License](LICENSE).
