# Example 2: Pasting a Raw IaC State Lock Error into `/ops-bro`

## User

> `/ops-bro`
>
> ```text
> Error: Error acquiring the state lock
>
> Error message: ConditionalCheckFailedException: The conditional request failed
> Lock Info:
>   ID:        9f4b2c1a-88e1-4d3b-a7c0-112233445566
>   Path:      prod/network/terraform.tfstate
>   Operation: OperationTypeApply
>   Who:       ci-runner@build-node-04
>   Created:   2026-11-26 09:42:11.104821 +0000 UTC
> ```

## `ops-bro` (Plain-Language Translation)

Your IaC tool refused to run because another process (`ci-runner@build-node-04`) locked the state file `prod/network/terraform.tfstate` at `09:42:11 UTC` while running an `OperationTypeApply`. State locks exist so two people or pipelines don't overwrite your infrastructure state at the exact same time and corrupt it.

First, check if that CI job on `build-node-04` is still actively running. If it crashed or timed out and left a stale lock behind, clear it manually by running `force-unlock 9f4b2c1a-88e1-4d3b-a7c0-112233445566` (using `terraform` or `tofu`), then re-run your `plan`. Never force-unlock while an apply is actually in flight.
