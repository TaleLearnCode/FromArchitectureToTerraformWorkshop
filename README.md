# From Architecture to Terraform: A Hands-On Workshop

![Status: Active](https://img.shields.io/badge/Status-Active-brightgreen) 🛠️Workshop 🟢 Intermediate

AI is good at reading architecture documents and bad at producing identical Terraform twice. In this two-hour workshop you will see both for yourself, then build a pipeline that uses each tool for what it does best: AI turns a human-written architecture guide into a structured YAML contract, and a deterministic PowerShell generator turns that contract into governed Terraform.

You will not apply anything to Azure. The labs stop at `terraform plan` (or earlier, if you have no subscription).

## Before you arrive

Complete [`workshop/prerequisites.md`](workshop/prerequisites.md). It takes about 20 minutes, mostly downloads, and includes a preflight script.

```powershell
git clone https://github.com/TaleLearnCode/FromArchitectureToTerraformWorkshop.git C:\Workshop\FromArchitectureToTerraformWorkshop
```

Everything you need is in this repository, including the fallback files used when an AI assistant is slow or unavailable.

## What you will do

| Lab | Time | You will |
|---|---|---|
| Opening and setup check | 10 min | Hear the story, run the preflight script |
| [Lab 1: Break determinism](workshop/labs/lab01.md) | 15 min | Run the same AI prompt twice and compare the Terraform |
| [Lab 2: Architecture to YAML, and inspect it](workshop/labs/lab02.md) | 25 min | Have AI produce the YAML contract, then review it for problems |
| [Lab 3: Deterministic generation](workshop/labs/lab03.md) | 20 min | Generate Terraform, prove it repeatable, validate, lint, and plan |
| Break | 5 min | |
| [Lab 4: Extend the generator](workshop/labs/lab04.md) | 20 min | Teach the generator a new resource type |
| [Lab 5: Watch a change flow through](workshop/labs/lab05.md) | 15 min | Trace one intent change through the whole pipeline |
| Wrap-up | 10 min | Decide where this fits on your team |

The overall guide is [`workshop/lab-guide.md`](workshop/lab-guide.md), and each lab has its own page in `workshop/labs/`.

## What is in this repository

| Folder | Contents |
|---|---|
| `workshop/` | Prerequisites, the overall lab guide, and one page per lab in `workshop/labs/` |
| `kit/` | Fallback files: a spec with deliberate flaws for Lab 2, the Lab 4 solution, and saved AI output for Lab 1 |
| `docs/` | The six architecture documents for the example service (a Work Item Service for Momentum Rocket Skates) |
| `guides/` | How to adapt this approach to your own service, and how to extend the generator |
| `tools/terraform-generator/` | The PowerShell generator, its JSON schema, tests, and a reference example |
| `.github/prompts/` and `.claude/skills/` | The `/create-infrastructure-spec` prompt for GitHub Copilot and the equivalent skill for Claude Code |

## After the workshop

- [`guides/adapting-to-your-service.md`](guides/adapting-to-your-service.md): apply this to your own service
- [`guides/extending-the-generator.md`](guides/extending-the-generator.md): add more resource types
- [`tools/terraform-generator/README.md`](tools/terraform-generator/README.md): how the generator works

To start over after the labs, delete what they created:

```powershell
Remove-Item .\infra -Recurse -Force
git status --short
```

## Related

The standalone demo used in the conference talk is at [AutomatedTerraformGeneratorDemo](https://github.com/TaleLearnCode/AutomatedTerraformGeneratorDemo).

Email [chadgreen@chadgreen.com](mailto:chadgreen@chadgreen.com?subject=Workshop%20Request:%20From%20Architecture%20to%20Terraform) to have Chad deliver this workshop at your event.

## License

MIT. See [LICENSE](LICENSE).
