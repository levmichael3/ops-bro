# Contributing to ops-bro

Thanks for helping make `ops-bro` sharper. The most valuable contribution is a **new operational example** — a real incident pattern, failure mode, or runbook that teaches the skill how to talk like a Principal SRE.

Every contribution also grows your [GitAnimals](https://www.gitanimals.org/) pets: 30 commits adopt a new pet, and each contribution levels them up. Connect your GitHub account on [gitanimals.org](https://www.gitanimals.org/) to start your farm.

---

## How to add a new operational example

Examples live in `examples/` and are numbered sequentially:

```text
examples/01-k8s-crashloop.md
examples/02-iac-state-lock.md
examples/03-clean-runbook.md
examples/04-your-new-pattern.md   <-- yours
```

### 1. Pick a real pattern

Good topics: `ImagePullBackOff` loops, PVC `Pending` binds, Terraform drift after manual console edits, Helm release stuck in `pending-install`, ingress `504` storms, OOMKilled sidecars, expired cert-manager certs, GitOps sync loops, flaky canary analysis, error-budget burn alerts.

Bad topics: anything tied to a single cloud vendor's proprietary console, marketing comparisons, or hypothetical errors you haven't seen in the wild.

### 2. Follow the file format

Every example file **must** contain all three parts:

```markdown
# Example N: Short Title with `exact terms`

### User

> <the raw user prompt, incident report, or error — keep it realistic>

### `ops-bro` (Default Pinpoint Mode | Clean Artifact Mode)

<the pinpoint SRE answer: BLUF first, exact commands/flags/paths verbatim,
safety warnings before destructive ops>

---

### User

> `/ops-bro` (+ optional pasted text)

### `ops-bro` (Plain-Language Translation)

<the same answer re-explained like a sharp teammate over coffee —
every command, flag, path, port, and exit code 100% verbatim>
```

**Rules for the pinpoint section:**

- **BLUF first.** Root cause, impact, or action in sentence one. No throat-clearing.
- **Facts survive verbatim.** Never round thresholds, rename resources, or paraphrase flags.
- **Safety first.** Any `destroy`, `kubectl delete`, `force-unlock`, or force-push gets a dry-run / `plan` step and a warning.
- **Vendor-agnostic.** Prefer Kubernetes APIs, OCI, declarative HCL, GitOps, OpenTelemetry, POSIX tools. Name a vendor only when the user did.

**Rules for the `/ops-bro` translation:**

- Re-explain, don't re-answer. No new tools, no new diagnosis.
- Take the space clarity needs — simpler, not necessarily shorter.
- Flatten tables and jargon into conversational sentences.
- Keep the user's language.

### 3. Link it in the README

Add one bullet under the `## Examples` section (use plain path here, not a link — the file doesn't exist yet):

```markdown
- `examples/04-your-new-pattern.md` — One-line description of the pattern.
```

### 4. Run the checks locally

```bash
# install.sh must stay ShellCheck-clean
shellcheck install.sh

# SKILL.md frontmatter must stay valid
python3 -c "
import re
t = open('SKILL.md').read()
m = re.match(r'^---\n(.*?)\n---\n', t, re.DOTALL)
assert m and 'name: ops-bro' in m.group(1), 'frontmatter broken'
print('frontmatter OK')
"

# Markdown should be tidy (if you have markdownlint-cli2)
npx markdownlint-cli2 "README.md" "CONTRIBUTING.md" "SKILL.md" "examples/**/*.md"
```

CI ([`.github/workflows/ci.yml`](.github/workflows/ci.yml)) runs the same checks via ShellCheck, a frontmatter validator, and `DavidAnson/markdownlint-cli2-action@v19` on every push to `main` and every PR.

---

## Other contributions

- **SKILL.md wording:** keep it tight. One idea per bullet, exact vocabulary, no new vendor lock-in. Small PRs preferred.
- **`install.sh`:** must stay POSIX-friendly `bash`, `set -euo pipefail`, and ShellCheck-clean. Test on at least one agent (Claude Code, Cursor, OpenCode, Codex, Hermes).
- **README:** keep the Why/Install/Examples/Credits skeleton. Don't add vendor-specific setup.

---

## Pull request checklist

- [ ] Example filename is next sequential number (`NN-slug.md`).
- [ ] File has User prompt → pinpoint answer → `/ops-bro` → plain translation.
- [ ] All commands, flags, paths, ports, exit codes identical in both modes.
- [ ] README `## Examples` bullet added.
- [ ] `shellcheck install.sh` passes (if touched).
- [ ] No proprietary vendor lock-in introduced.

---

## GitAnimals 🐾

This repo celebrates contributors with [GitAnimals](https://www.gitanimals.org/) pets:

1. Go to [gitanimals.org](https://www.gitanimals.org/) and connect your GitHub account.
2. Contribute — every merged commit feeds your pets.
3. At 30 commits you adopt a new pet; rarer pets have lower drop rates.
4. Show your farm on your profile or repo with:

```markdown
[![GitAnimals Farm](https://render.gitanimals.org/farms/<your-username>)](https://www.gitanimals.org/en-US/farm/<your-username>)
```

> The `<your-username>` placeholder is intentional — contributors replace it with their own farm name. Marksman may flag it; that's expected.

Team up with friends through guilds, decorate your farm, and climb the weekly leaderboard — all powered by the commits you're already making.
