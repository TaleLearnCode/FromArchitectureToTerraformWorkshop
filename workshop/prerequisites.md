# Before You Arrive: Prerequisites

**From Architecture to Terraform: A Hands-On Workshop**

Please complete this checklist before the workshop. It takes about 20 minutes, mostly downloads. We will not spend workshop time installing software.

The workshop assumes **Windows with PowerShell 7**. If you use macOS or Linux, you can follow along; the few Windows-specific commands (paths with backslashes, `Remove-Item`, `robocopy`) have simple equivalents you will know how to convert.

## What you need

| Item                                                         | Why                                                          | Check                                       |
| ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------- |
| [PowerShell 7](https://learn.microsoft.com/en-us/powershell/scripting/install/install-powershell?view=powershell-7.6) (`pwsh`) | The generator needs 7. Windows PowerShell 5.1 will not run it. | `$PSVersionTable.PSVersion` shows 7.x       |
| [Git](https://git-scm.com/install/)                          | Clone the repo and check determinism                         | `git --version`                             |
| [`powershell-yaml` module](https://www.powershellgallery.com/packages/powershell-yaml/0.4.12) | The generator reads YAML                                     | `Get-Module -ListAvailable powershell-yaml` |
| [Terraform 1.6 or later](https://developer.hashicorp.com/terraform/install) | `init`, `validate`, `plan`                                   | `terraform version`                         |
| [TFLint](https://github.com/terraform-linters/tflint)        | Lint check                                                   | `tflint --version`                          |
| [VS Code](https://code.visualstudio.com/download)            | Editor for all labs                                          | Opens without errors                        |
| An AI coding assistant (see below)                           | Labs 1, 2, and optionally 5                                  | Works in agent mode                         |
| [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest) | Only if you will run `terraform plan`                        | `az account show`                           |
| An Azure subscription where you can create resources         | Only for `terraform plan`                                    | See "Azure access"                          |

### AI coding assistant

Use **one** of these:

- **[GitHub Copilot](https://github.com/features/copilot)** with [VS Code](https://github.com/features/copilot/ai-code-editor), [GitHub Copilot App](https://github.com/features/ai/github-app), or [Copilot CLI](https://github.com/features/copilot/cli)
- **[Claude Code](https://claude.com/product/claude-code)**, run from the repo folder.

No assistant? You can still do every lab. We provide fallback files so nothing blocks you. You will miss the experience of seeing the AI work, so partner with a neighbor for Labs 1 and 2.

### Azure access

The labs assume you can create resources in an Azure subscription. We stop at `terraform plan`, so nothing is created, but `plan` needs credentials and read access.

If you **do not** have subscription access, that is fine. You will stop after `terraform init`, `terraform validate`, and `tflint` in Lab 3. Everything else is the same.

## Setup steps

1. Install the tools above.

2. Install the YAML module:

   ```powershell
   Install-Module powershell-yaml -Scope CurrentUser
   ```

3. Clone the repository:

   ```powershell
   git clone https://github.com/TaleLearnCode/FromArchitectureToTerraformWorkshop.git C:\Workshop\FromArchitectureToTerraformWorkshop
   ```

4. There is nothing else to download. The repository's `kit` folder holds the fallback files used when the AI is slow or unavailable, and the generator, architecture documents, and guides are in the repository too.

5. If you have Azure access, sign in and set your subscription in the terminal you will use:

   ```powershell
   az login
   $env:ARM_SUBSCRIPTION_ID = "<subscription id>"
   ```

6. Run the preflight check below.

## Preflight check

Paste this into a PowerShell 7 terminal. Every line should say `OK`.

```powershell
function Check($name, $test) { if (& $test) { "OK       $name" } else { "MISSING  $name" } }
Check 'PowerShell 7'      { $PSVersionTable.PSVersion.Major -ge 7 }
Check 'git'               { Get-Command git -ErrorAction SilentlyContinue }
Check 'terraform'         { Get-Command terraform -ErrorAction SilentlyContinue }
Check 'tflint'            { Get-Command tflint -ErrorAction SilentlyContinue }
Check 'powershell-yaml'   { Get-Module -ListAvailable powershell-yaml }
Check 'az (optional)'     { Get-Command az -ErrorAction SilentlyContinue }
Check 'repo cloned'       { Test-Path C:\Workshop\FromArchitectureToTerraformWorkshop\tools\terraform-generator }
Check 'fallback kit'       { Test-Path C:\Workshop\FromArchitectureToTerraformWorkshop\kit }
```

Then open `C:\Workshop\FromArchitectureToTerraformWorkshop` in VS Code (File > Open Folder) and confirm:

- [ ] Your AI assistant is in agent mode (Copilot) or runs from this folder (Claude Code).
- [ ] Typing `/` shows `create-infrastructure-spec`.
- [ ] `docs\infrastructure-architecture-guide.md` opens, and the Markdown preview (Ctrl+Shift+V) renders its deployment diagram.

## If something fails

Email the facilitator before the workshop, or arrive 15 minutes early. We will help you at the door, but we cannot hold the room for installs.