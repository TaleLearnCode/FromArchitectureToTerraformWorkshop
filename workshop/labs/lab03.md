# Lab 3: Deterministic generation

**Time:** 20 minutes · Part of the [lab guide](../lab-guide.md)

Work in the repository root in a **PowerShell 7** terminal:

```powershell
cd C:\Workshop\FromArchitectureToTerraformWorkshop
```

**No Azure subscription?** Skip any step marked **[Azure]**. Do everything else.

Keep the "Notice" box in mind; we will ask about it in the debrief.

**Goal:** run the code half of the pipeline, prove it is repeatable, and see what the machine catches that you did not.

## Part A: Generate (4 minutes)

1. Skim `tools\terraform-generator`. Find the orchestrator `New-TerraformConfiguration.ps1`, the `Actions` folder (one script per resource type), and the `schema` folder.
2. Run the generator on your spec:

   ```powershell
   .\tools\terraform-generator\New-TerraformConfiguration.ps1 -SpecPath .\infra\work-item-service.infra.yaml -OutputPath .\infra\terraform
   ```

   Expect "Spec OK", a warning about placeholder state values, and a line like `Generated 17 resources`. If your spec has a different file name, use it. Note that 17 is the number of resources in the spec; the plan count in Part C is higher, because it also counts role assignments and diagnostic settings.

## Part B: Prove it is deterministic (2 minutes)

3. Stage the output, run the same command again, and check nothing changed:

   ```powershell
   git add infra
   .\tools\terraform-generator\New-TerraformConfiguration.ps1 -SpecPath .\infra\work-item-service.infra.yaml -OutputPath .\infra\terraform
   git status --short infra
   ```

   Every file should show `A` only, with no `M` or `AM`. Do this **before** `terraform init`, so only generated files are in the folder.

> **Notice.** Compare this to Lab 1. What would your pull request diff look like now?

## Part C: Initialize, validate, lint, plan (6 minutes)

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
   terraform plan -var-file=environments/dev.tfvars
   ```

   With the reference spec, expect **Plan: 32 to add, 0 to change, 0 to destroy.** Your count follows your YAML. Nothing is applied.

7. Return to the repo root:

   ```powershell
   cd ..\..
   ```

## Part D: What does the machine catch? (4 minutes)

8. Run the generator against the flawed spec from Lab 2:

   ```powershell
   .\tools\terraform-generator\New-TerraformConfiguration.ps1 -SpecPath .\kit\flawed\work-item-service.flawed.infra.yaml -OutputPath .\infra\flawed-terraform
   ```

9. Read the error. Schema errors are long and repetitive; search the output for a field name such as `default_message_ttl` or `memory`. Copy the flawed spec to `infra\flawed.infra.yaml`, **fix only what the generator complains about**, and run again. Repeat until it prints `Spec OK`.
10. Now compare. Look at your Lab 2 table: which flaws did the generator make you fix, and which are still in the file? The generator is happy with those. Clean up:

    ```powershell
    Remove-Item .\infra\flawed-terraform -Recurse -Force -ErrorAction SilentlyContinue
    ```

> **Notice.** The schema checks the *shape* of the contract. It cannot check whether the contract is *true*. That is why the review in Lab 2 exists.

---

[← Lab 2](lab02.md) · [Lab guide](../lab-guide.md) · [Lab 4 →](lab04.md)
