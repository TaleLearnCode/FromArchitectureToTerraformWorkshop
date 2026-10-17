# Lab 5: Watch a change flow through

**Time:** 15 minutes · Part of the [lab guide](../lab-guide.md)

Work in the repository root in a **PowerShell 7** terminal:

```powershell
cd C:\Workshop\FromArchitectureToTerraformWorkshop
```

**No Azure subscription?** Skip any step marked **[Azure]**. Do everything else.

Keep the "Notice" box in mind; we will ask about it in the debrief.

**Goal:** see what a diff means when the pipeline is deterministic.

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
   git diff --no-index --stat .\infra\terraform-before .\infra\terraform
   ```

   Every generated file changed by one line. Open one and find out why: each file's header records the SHA-256 of the spec that produced it, so the hash line changes whenever the spec changes. That is traceability, but it is noise in this diff. Ignore those lines:

   ```powershell
   git diff --no-index -I '# Source:' .\infra\terraform-before .\infra\terraform
   ```

   Now you should see one real change: `container_app_api_min_replicas` goes from 2 to 3 in `environments\prd.tfvars`, and nothing else.

5. **[Azure]** Plan the prod environment:

   ```powershell
   cd .\infra\terraform
   terraform plan -var-file=environments/prd.tfvars
   cd ..\..
   ```

## Stretch: the full loop (if the AI is quick)

Edit section 7 of `docs\infrastructure-architecture-guide.md` to say production runs three minimum replicas. Re-run `/create-infrastructure-spec` into a copy of your YAML and compare the two YAML files with `git diff --no-index`. Then regenerate. Notice how much of the YAML stayed the same, and how much of the Terraform diff followed from one sentence.

> **Notice.** After setting aside the hash header, how many files changed? How big was the diff? Could a reviewer approve this in one minute?

---

[← Lab 4](lab04.md) · [Lab guide](../lab-guide.md) · [Wrap-up →](../lab-guide.md#wrap-up-where-this-fits-on-your-team-10-minutes)
