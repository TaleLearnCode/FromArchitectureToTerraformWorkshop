# Lab 3: Deterministic generation

**Time:** 20 minutes in the workshop (17 hands-on and a 3-minute debrief), 30 to 40 minutes on your own · Part of the [lab guide](../lab-guide.md)

| | |
|---|---|
| **Goal** | Run the code half of the pipeline, prove it is repeatable, and see what the machine catches that you did not. |
| **You will** | Generate Terraform from your spec, run it again to prove nothing changed, validate and lint it, then run a flawed spec through the generator. |
| **You need** | Your spec from [Lab 2](lab02.md) (or the reference spec), a **PowerShell 7** terminal, Git, Terraform, and `tflint`. You only need an Azure subscription for `terraform plan`. |
| **You will have** | A generated, validated, lint-clean Terraform configuration that nobody hand-edited, and a clear picture of what the generator can and cannot catch. |
| **Previous** | [Lab 2](lab02.md) produced and reviewed the YAML contract. |
| **Next** | [Lab 4](lab04.md) teaches the generator a new resource type. |

Work in the repository root:

```powershell
cd C:\Workshop\FromArchitectureToTerraformWorkshop
```

**No Azure subscription?** Skip any step marked **[Azure]**. Do everything else.

## Introduction

You now have a spec that a person reviewed. This lab turns it into Terraform, and the crucial thing is *how*. There is no AI in this step. A PowerShell program reads the YAML and writes the Terraform files, applying the same rules every time.

That is the answer to Lab 1. The AI's contribution (interpreting the document) happens once, ahead of time, and a person approves it. The Terraform itself comes from code, so the same spec always gives byte-for-byte the same files. A diff of the output means something because only a change to the spec can cause it.

You will also see the limits. A generator can reject a malformed spec and can refuse to generate one with a broken reference. It cannot tell whether the spec is *true*. Seeing exactly where that line falls is the second half of this lab.

## What we are doing

1. Run the generator on your spec and look at what it produces (Part A).
2. Run it a second time and prove with Git that nothing changed (Part B).
3. Initialize, validate, lint, and (if you have Azure) plan the output (Part C).
4. Run the deliberately flawed spec from Lab 2 through the generator, and compare what it catches with your Lab 2 list (Part D).

## Background

**The generator.** It lives in `tools\terraform-generator`:

- `New-TerraformConfiguration.ps1` is the orchestrator you run.
- `Actions\` holds one script per resource type; each knows how to write the Terraform for that type.
- `Private\` holds shared helpers, including the type table and the semantic checks.
- `schema\infra-spec.schema.json` defines what a valid spec looks like.
- `tests\Test-Generator.ps1` runs the generator's own tests.

**Two stages of checking.** The generator validates the spec before it writes anything. First, the **schema** check asks whether each resource has the right fields in the right shapes. Then the **semantic** checks ask whether the spec makes sense as a whole, for example, whether a reference points to something that exists. It stops at the first stage that fails, so a spec with schema errors never reaches the semantic stage.

**Security defaults live in the code.** Things such as "local authentication is off" are written once into the action scripts, not repeated in every spec. A spec cannot forget them. Lab 4 returns to this.

**Provenance.** Every generated file starts with a header such as `# Source: <spec file> (sha256 ...)`. It records which spec produced the file. You will see it again in Lab 5.

## Part A: Generate (4 minutes in the workshop)

1. Skim `tools\terraform-generator`. Find the orchestrator `New-TerraformConfiguration.ps1`, the `Actions` folder (one script per resource type), and the `schema` folder.
2. Run the generator on your spec:

   ```powershell
   .\tools\terraform-generator\New-TerraformConfiguration.ps1 -SpecPath .\infra\work-item-service.infra.yaml -OutputPath .\infra\terraform
   ```

   Expect "Spec OK", a warning about placeholder state values, and a line like `Generated 17 resources`. If your spec has a different file name, use it. Note that 17 is the number of resources in the spec; the plan count in Part C is higher, because it also counts role assignments and diagnostic settings.

Open a generated file, for example `infra\terraform\main.tf`, and look at the header and the first few resources. This is ordinary, readable Terraform with consistent naming and tags. The placeholder warning is expected: the `state:` block in your spec still holds `REPLACE_WITH_...` values, which is correct until a real team chooses real backend names.

## Part B: Prove it is deterministic (2 minutes in the workshop)

3. Stage the output, run the same command again, and check that nothing changed:

   ```powershell
   git -c core.autocrlf=false add infra
   .\tools\terraform-generator\New-TerraformConfiguration.ps1 -SpecPath .\infra\work-item-service.infra.yaml -OutputPath .\infra\terraform
   git -c core.autocrlf=false status --short infra
   ```

   Every file should show `A` only, with no `M` or `AM`. Do this **before** `terraform init`, so only generated files are in the folder. (The `-c core.autocrlf=false` option stops Git from printing harmless line-ending warnings.)

   If any file shows `AM`, the second run changed it, which would mean the generator is not deterministic. Tell your facilitator, or check that you did not edit a file by hand.

> **Notice.** Compare this to Lab 1. What would your pull request diff look like now?

## Part C: Initialize, validate, lint, plan (6 minutes in the workshop)

4. Point Terraform at local state. This file is for the workshop only and is not part of generated output:

   ```powershell
   Set-Content -Path .\infra\terraform\backend_override.tf -Value 'terraform {', '  backend "local" {}', '}'
   cd .\infra\terraform
   ```

5. Run the checks:

   ```powershell
   terraform init
   terraform validate
   tflint
   ```

   **No Azure subscription? Stop here.** You have a validated, lint-clean configuration that nobody hand-edited.

6. **[Azure]** Plan one environment:

   ```powershell
   terraform plan -var-file="environments/dev.tfvars"
   ```

   With the reference spec, expect **Plan: 32 to add, 0 to change, 0 to destroy.** Your count follows your YAML. Nothing is applied.

7. Return to the repo root:

   ```powershell
   cd ..\..
   ```

### What you should see

`terraform init` downloads the Azure provider and finishes with a "successfully initialized" message. `terraform validate` prints `Success! The configuration is valid.` and `tflint` prints nothing, or only informational notes. The plan, for those who run it, ends with a count of resources to add and says nothing will change until you apply. You never apply in this workshop.

## Part D: What does the machine catch? (4 minutes in the workshop)

8. Run the generator against the flawed spec from Lab 2:

   ```powershell
   .\tools\terraform-generator\New-TerraformConfiguration.ps1 -SpecPath .\kit\flawed\work-item-service.flawed.infra.yaml -OutputPath .\infra\flawed-terraform
   ```

9. Read the error. Schema errors are long and repetitive; search the output for a field name such as `default_message_ttl` or `memory`. Copy the flawed spec to `infra\flawed.infra.yaml`, **fix only what the generator complains about**, and run again. Repeat until it prints `Spec OK`.
10. Now compare. Look at your Lab 2 table: which flaws did the generator make you fix, and which are still in the file? The generator is happy with those. Clean up:

    ```powershell
    Remove-Item .\infra\flawed-terraform -Recurse -Force -ErrorAction SilentlyContinue
    ```

### What you should see

The generator rejects the flawed spec, and it does so in stages: first with a long schema error, then, once those are fixed, with a shorter semantic error. When it finally says `Spec OK`, most of the flaws you listed in Lab 2 are still in the file. The generator found only a minority of them, the ones that are wrong in *shape* or *reference*. The rest- the wrong numbers, the wrong access direction, the invented names- pass untouched.

> **Notice.** The schema checks the *shape* of the contract. It cannot check whether the contract is *true*. That is why the review in Lab 2 exists.

## The lesson

Two properties make this stage trustworthy. It is **deterministic**: the same spec always yields the same Terraform, so a diff reflects a real change. And it is **checked**: malformed or inconsistent specs are rejected before anything is written. Together they turn "an AI wrote some Terraform" into "a reviewed spec was compiled into Terraform."

The generator is also honest about its limits. The checks you saw guard structure, not truth. If a person (or an AI) writes a well-formed spec with the wrong retention period, the generator will compile it faithfully. That is not a defect. It is the division of labor: code guarantees repeatability and structure, and people guarantee the spec says what the architecture requires. Lab 2's review and Lab 3's generator are two halves of one control.

## Check your understanding

<details>
<summary>1. Why must you check determinism before running <code>terraform init</code>?</summary>
`init` creates its own files in the folder (the `.terraform` directory and a lock file). They would show up in `git status` and hide whether the generator's own output changed. Checking first means only generated files are in the folder.
</details>

<details>
<summary>2. The generator printed "Spec OK" for the flawed spec after you fixed two or three things. Does that mean the spec is correct?</summary>

No. It means the spec has the right shape and consistent references. Values can still be wrong, access can still point the wrong way, and names can still be invented. Only a review against the guide finds those.
</details>

<details>
<summary>3. Why are security defaults in the generator and not in each spec?</summary>

So they cannot be forgotten or varied. A rule written once in code applies to every spec, every environment, every run. A rule that has to be restated in every spec depends on someone, or an AI, remembering it every time.
</details>

<details>
<summary>4. What would a pull request diff look like if you changed one value in the spec and regenerated?</summary>

Small and specific: only the files affected by that value change, plus the provenance header lines, which record the new spec hash. Lab 5 shows this exactly.
</details>

## Troubleshooting

| Problem | What to do |
|---|---|
| `powershell-yaml` or `ConvertFrom-Yaml` is not found | Install it: `Install-Module powershell-yaml -Scope CurrentUser`. See the prerequisites. |
| The generator says the spec file does not exist | Check the path and file name. Use `Get-ChildItem .\infra` to see what you have. |
| `Spec OK` never appears for the flawed spec | Fix one error at a time and rerun. Search the output for the line starting `at '/resources/`, which names the field. |
| A file shows `AM` in Part B | Something changed it after generation. Did you edit it, or run `terraform init` first? Delete `infra\terraform`, regenerate, and try again. |
| `terraform` or `tflint` is not found | Install it (see the prerequisites) and open a new terminal. |
| `terraform init` cannot reach the provider registry | Check your network or proxy. Provider downloads need access to `registry.terraform.io`. |
| `terraform plan` asks for credentials | Run `az login` and set the subscription, or skip this step. It is marked **[Azure]**. |

## Go further

- **Open the generator.** Pick one action script, such as `Actions\ServicebusTopic.ps1`, and read it. How much of it is the resource, and how much is security defaults and naming?
- **Change a value, regenerate, and look.** Edit a `dev` value in your spec and regenerate into a copy of the folder. Compare the two folders with `git -c core.autocrlf=false --no-pager diff --no-index`. Lab 5 does this in a more structured way.
- **Run the tests.** `.\tools\terraform-generator\tests\Test-Generator.ps1` runs the generator's own checks.

## Doing this lab on your own

You do not need a facilitator. Allow 30 to 40 minutes, longer if you need to install Terraform or `tflint`. Do the parts in order, and do not skip Part D: it is the one that connects this lab to your Lab 2 list. If you don't have an Azure subscription, stop after terraform validate and tflint; that is enough to learn the lesson. Then continue to [Lab 4](lab04.md).

---

[← Lab 2](lab02.md) · [Lab guide](../lab-guide.md) · [Lab 4 →](lab04.md)
