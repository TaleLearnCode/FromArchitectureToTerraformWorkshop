# Lab 5: Watch a change flow through

**Time:** 15 minutes in the workshop (12 hands-on and a 3-minute debrief), 20 to 30 minutes on your own · Part of the [lab guide](../lab-guide.md)

| | |
|---|---|
| **Goal** | See what a diff means when the pipeline is deterministic. |
| **You will** | Make one intent change in the spec, regenerate, and look at exactly what changed in the Terraform. |
| **You need** | The generated Terraform from [Lab 3](lab03.md), your spec, a **PowerShell 7** terminal, and Git. You only need an Azure subscription for `terraform plan`. |
| **You will have** | A one-line diff you could approve in a minute, and a clear sense of why Lab 1's diff could not be reviewed. |
| **Previous** | [Lab 4](lab04.md) extended the generator. |
| **Next** | The [wrap-up.](../lab-guide.md#wrap-up-where-this-fits-on-your-team-10-minutes) |

Work in the repository root:

```powershell
cd C:\Workshop\FromArchitectureToTerraformWorkshop
```

**No Azure subscription?** Skip any step marked **[Azure]**. Do everything else.

## Introduction.

Everything so far has been about getting to Terraform: an AI interprets the architecture, a person reviews the contract, and a generator writes the files. This lab is about what happens *next*, because a real service does not stay still. A requirement changes, and the infrastructure must change with it.

In Lab 1, any change would have meant asking an AI to regenerate everything and then reading a noisy diff. Here you will make the smallest possible change, one number, and see whether the pipeline behaves the way a governed process should: one change in, one change out.

## What we are doing

1. Save a copy of the Terraform you generated in Lab 3.
2. Change one value in the spec: production minimum replicas for the API, from 2 to 3.
3. Regenerate into the same folder.
4. Compare before and after, first as raw files and then with the provenance headers set aside.
5. **[Azure]** See what Terraform would do about it.

## Background

**The change.** The architecture guide says the production API runs with a minimum number of replicas. Raising it from 2 to 3 is the kind of request an operations team makes: small, clear, and worth getting exactly right. In the spec, it is one line in the API's settings.

**Intent versus output.** The spec records intent ("production runs at least 3 replicas"). The Terraform records how to achieve it. When the pipeline is deterministic, one change of intent produces exactly the Terraform change it implies, and nothing more.

**The provenance header.** Every generated file begins with a comment such as `# Source: <spec file> (sha256 ...)`. The hash is a fingerprint of the spec that produced the file. Change the spec in any way and the hash changes in every file, even files whose content is otherwise the same. That is useful, because it ties each file back to the exact spec behind it, but it is noise when you want to see what actually changed. You will use a Git option that ignores those lines.

## Steps

1. Save a copy of the current generated Terraform (excluding Terraform's own working folder):

   ```powershell
   robocopy .\infra\terraform .\infra\terraform-before /E /XD .terraform | Out-Null
   ```

   (`robocopy` returns non-zero codes for success; ignore them.)

2. Make **one** intent change. In your YAML, change the production minimum replicas for the API from 2 to 3:

   ```yaml
   min_replicas: { dev: 0, qa: 1, prd: 3 }
   ```

   Find that line in your spec. If your AI named it differently, search for `min_replicas`.
3. Regenerate into the same folder:

   ```powershell
   .\tools\terraform-generator\New-TerraformConfiguration.ps1 -SpecPath .\infra\work-item-service.infra.yaml -OutputPath .\infra\terraform
   ```

4. See exactly what changed. First, the plain diff:

   ```powershell
   git -c core.autocrlf=false --no-pager diff --no-index --stat .\infra\terraform-before .\infra\terraform
   ```

   Every generated file changed by one line. Open one and find out why: each file's header records the SHA-256 of the spec that produced it, so the hash line changes whenever the spec changes. That is traceability, but it is noise in this diff. Ignore those lines:

   ```powershell
   git -c core.autocrlf=false --no-pager diff --no-index -I '# Source:' .\infra\terraform-before .\infra\terraform
   ```

   Now you should see one real change: `container_app_api_min_replicas` goes from 2 to 3 in `environments\prd.tfvars`, and nothing else.

   (`--no-pager` keeps Git from opening a scrolling viewer; if you land in one, press `q`. `-c core.autocrlf=false` silences harmless line-ending warnings. `git diff` exits with code 1 when files differ, which is expected here.)

5. **[Azure]** Plan the prod environment:

   ```powershell
   cd .\infra\terraform
   terraform plan -var-file=environments/prd.tfvars
   cd ..\..
   ```

### What you should see

The first diff lists every generated file with one line changed apiece, which looks alarming but is only the hash header. The second diff, with the headers ignored, shows a single small hunk in `environments\prd.tfvars` and nothing in `dev` or `qa`, because you changed only the production value. Everything outside that hunk, including every other file, is untouched.

For the plan: the change should be limited to what depends on the replica count, most likely the API Container App changing in place. Read the plan for anything being destroyed or replaced, and if you see more than you expected, work out why before deciding the change was safe. Your plan follows your YAML, so the exact output varies.

## Stretch: the full loop (if the AI is quick)

Edit section 7 of `docs\infrastructure-architecture-guide.md` to say production runs three minimum replicas. Re-run `/create-infrastructure-spec` into a copy of your YAML and compare the two YAML files with `git -c core.autocrlf=false --no-pager diff --no-index`. Then regenerate. Notice how much of the YAML stayed the same, and how much of the Terraform diff followed from one sentence.

Restore the guide afterward with `git restore docs\infrastructure-architecture-guide.md` so later runs are not affected.

## The lesson

Compare this diff with the one from Lab 1. There, two runs from identical input differed everywhere, and no reviewer could say which differences mattered. Here, one deliberate change of intent produced exactly one meaningful change in the output, and the only other differences are a header that exists to prove where the files came from.

That is what determinism buys. A reviewer can approve this change in a minute because there is nothing else to review. An auditor can trace a file back to the spec hash that produced it. A rollback is just the previous spec. The whole control chain, from document to contract to Terraform, can be followed in both directions.

And it explains the shape of the whole pipeline: AI handles the fuzzy part once, a person reviews a small contract, and code does the exact part every time.

## Notice

> After setting aside the hash header, how many files changed? How big was the diff? Could a reviewer approve this in one minute?

## Check your understanding

<details>
<summary>1. Why did every file show a change in the first diff?</summary>
Each generated file's header contains the hash of the spec. Any change to the spec changes the hash in every file, even those with no other change. The header is deliberate provenance, but it is noise when you review.
</details>

<details>
<summary>2. Why is the second diff so small, and what does that tell you?</summary>
Only one intent value changed, and the generator is deterministic, so only the output that depends on that value changed. It tells you the pipeline has no side effects: changes in equal changes out.
</details>

<details>
<summary>3. How does this change what code review and audit look like?</summary>

Review shrinks to the spec change and the diff it produces, which are small and explainable. Audit gains a trace: a file, the spec hash in its header, and the spec version in Git. "What did we deploy, and from what?" has a definite answer.
</details>

<details>
<summary>4. If you had asked an AI to edit the Terraform directly instead, what would you have lost?</summary>

Repeatability and trust in the diff. The AI might change the requested value and also reorder, rename, or restructure other things. You would be back in Lab 1, reading a diff to find out which changes were intended.
</details>

## Troubleshooting

| Problem | What to do |
|---|---|
| `robocopy` seems to fail | Exit codes 0 to 7 mean success. Check that `infra\terraform-before` now exists. |
| `infra\terraform` does not exist | Lab 3 was not completed. Run the generator from Lab 3 Part A first. |
| You cannot find `min_replicas` | Search the spec for `min_replicas`. If your AI used a different name, search for `replicas`. |
| The second diff shows more than one change | Check that you changed only the `prd` value. Also check that you did not run `terraform init` between saving the copy and regenerating, since that adds files such as `.terraform.lock.hcl`. |
| The diff output stops at `:` or `(END)` | Git opened its pager. Press `q`, and use `--no-pager` as shown. |
| A wall of "LF will be replaced by CRLF" warnings | Harmless line-ending notices. Use the `-c core.autocrlf=false` form shown above. |
| `terraform plan` asks for credentials | Run `az login`, or skip the step. It is marked **[Azure]**. |

## Go further

- **Change a `dev` value instead.** Which files change, and which don't?
- **Change something shared.** Change a value that applies to every environment. How does the diff differ?
- **Revert.** Change the value back, regenerate, and diff against `infra\terraform-before`. Because the spec is byte-for-byte the same, the hash is the same too, so you should see no differences at all, not even in the header. What does that say about the spec as the single source of truth?

## Doing this lab on your own

You do not need a facilitator. Allow 20 to 30 minutes. You must have completed Lab 3 first, because this lab starts from the Terraform it generated. The most valuable moment is the second diff, so run both and compare them side by side. When you finish, use the wrap-up questions in the [lab guide](../lab-guide.md#wrap-up-where-this-fits-on-your-team-10-minutes) to think through where this would fit on your own team.

---

[← Lab 4](lab04.md) · [Lab guide](../lab-guide.md) · [Wrap-up →](../lab-guide.md#wrap-up-where-this-fits-on-your-team-10-minutes)
