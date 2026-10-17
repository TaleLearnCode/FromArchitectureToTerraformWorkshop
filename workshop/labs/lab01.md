# Lab 1: Break determinism

**Time:** 15 minutes · Part of the [lab guide](../lab-guide.md)

Work in the repository root in a **PowerShell 7** terminal:

```powershell
cd C:\Workshop\FromArchitectureToTerraformWorkshop
```

Keep the "Notice" box in mind; we will ask about it in the debrief.

**Goal:** see for yourself why "ask AI to write the Terraform" does not work for governed infrastructure.

## Steps

1. Open the repo in VS Code. Open `docs\infrastructure-architecture-guide.md` and skim section 4 and the table in section 5.1. This is the input.
2. Make a scratch folder:

   ```powershell
   New-Item -ItemType Directory .\lab1 | Out-Null
   ```

3. Start a **new chat**. Use agent mode with a Claude model. Paste this prompt exactly:

   ```
   Read docs/infrastructure-architecture-guide.md. Write complete azurerm Terraform
   for the dev environment into lab1/run1. Do not ask me questions; make
   reasonable choices.
   ```

4. When it finishes, start a **brand new chat** (so it has no memory of run 1). Paste the same prompt, changing only `run1` to `run2`.
5. Compare the two runs.

   ```powershell
   git diff --no-index --stat .\lab1\run1 .\lab1\run2
   ```

   Then compare just the resources each run declared:

   ```powershell
   $a = Get-ChildItem .\lab1\run1 -Filter *.tf -Recurse | Select-String '^resource ' | ForEach-Object { $_.Line.Trim() } | Sort-Object
   $b = Get-ChildItem .\lab1\run2 -Filter *.tf -Recurse | Select-String '^resource ' | ForEach-Object { $_.Line.Trim() } | Sort-Object
   Compare-Object $a $b
   ```

   `git diff` exits with code 1 when files differ. That is expected here.

6. Write down at least four things that differ: ______________________________

**No AI assistant?** Use `kit\lab1-fallback\run1` and `run2` and start at step 5.

> **Notice.** Same input, same prompt, same model. Is either run *wrong*? Could you merge the diff into a pull request and review it? Try imagining this across 40 services.

---

[← Lab guide](../lab-guide.md) · [Lab guide](../lab-guide.md) · [Lab 2 →](lab02.md)
