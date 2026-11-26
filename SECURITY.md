# Security Policy

## Supported versions

`ops-bro` is a docs-and-script skill repo with a single `main` line. Security fixes land on `main` and are noted in release notes / commit messages.

## Reporting a vulnerability

Please **do not** open a public issue. Use GitHub's **private vulnerability reporting**:

1. Go to the **Security** tab of `levmichael3/ops-bro`.
2. Click **Report a vulnerability**.

Include steps to reproduce, impact, and any suggested fix. We'll acknowledge within 72 hours.

## Scope notes

- `install.sh` only copies `SKILL.md` into local agent config directories. It uses no `sudo`, makes no network calls, and stores no credentials.
- This repo must never contain secrets, tokens, or private infrastructure details. Examples use fictional hostnames, IDs, and namespaces.
