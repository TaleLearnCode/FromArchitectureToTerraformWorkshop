# Attendee Lab Guide

**From Architecture to Terraform: A Hands-On Workshop (2 hours)**

This is the overall guide. Each lab has its own page with the goal, the steps, and a "Notice" box we will ask about in the debrief.

Work in the workshop repository (the one you cloned) unless a step says otherwise:

```powershell
cd C:\Workshop\FromArchitectureToTerraformWorkshop
```

Use a **PowerShell 7** terminal.

## Agenda

| Time | Block | Page |
|---|---|---|
| 0:00 | Framing and setup check (10 min) | [Prerequisites](prerequisites.md) |
| 0:10 | Lab 1: Break determinism (15 min) | [Lab 1](labs/lab01.md) |
| 0:25 | Lab 2: Architecture to YAML, and inspect it (25 min) | [Lab 2](labs/lab02.md) |
| 0:50 | Lab 3: Deterministic generation (20 min) | [Lab 3](labs/lab03.md) |
| 1:10 | Break (5 min) | |
| 1:15 | Lab 4: Extend the generator (20 min) | [Lab 4](labs/lab04.md) |
| 1:35 | Lab 5: Watch a change flow through (15 min) | [Lab 5](labs/lab05.md) |
| 1:50 | Wrap-up: where this fits on your team (10 min) | [Wrap-up](#wrap-up-where-this-fits-on-your-team-10-minutes) |

**Fallbacks.** If your AI assistant is slow or unavailable, use the matching file in the repository's `kit` folder. Every lab after Lab 2 can start from the fallback spec, so you are never blocked.

**No Azure subscription?** Skip any step marked **[Azure]**. Do everything else, including `terraform init`, `validate`, and `tflint`.

---

## Wrap-up: where this fits on your team (10 minutes)

Fill this out on your own for five minutes, then discuss with a neighbor.

| Question | Your answer |
|---|---|
| Which architecture documents do you already have that a machine could read? | |
| Which Terraform patterns does your team rewrite most often? | |
| Which of your standards would become a generator default (like local authentication being off)? | |
| What would your spec contract need to capture that this one does not? | |
| Where does the human review gate sit: before commit, in the pull request, or both? | |
| What is the smallest first slice you could try in the next 30 days? | |

## Cleaning up

```powershell
Remove-Item .\infra -Recurse -Force
git status --short
```

The command should print nothing, or only files you changed in Lab 4. Use `git restore .` to undo Lab 4 edits, or reclone.

## Take-home

- This repository: `https://github.com/TaleLearnCode/FromArchitectureToTerraformWorkshop`
- `guides\adapting-to-your-service.md`: apply this to your own service.
- `guides\extending-the-generator.md`: add more resource types.
