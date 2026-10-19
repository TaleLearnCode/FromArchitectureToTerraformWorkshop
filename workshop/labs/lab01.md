# Lab 1: Break determinism

**Time:** 15 minutes in the workshop (about 12 minutes hands-on and a 3-minute debrief), 20 to 25 minutes on your own · Part of the [lab guide](../lab-guide.md)

| | |
|---|---|
| **Goal** | See for yourself why "ask AI to write the Terraform" does not work for governed infrastructure. |
| **You will** | Give an AI assistant the same architecture document twice, then compare what it produced. |
| **You need** | An AI coding assistant in agent mode (a Claude model works well), Git, and the repository cloned |
| **You will have** | Two sets of Terraform from identical input, and a list of what differs between them |
| **Next** | [Lab 2](lab02.md) gives the AI a narrower job and shows why it behaves better. |

## Introduction

Most cloud services need the same building blocks: a resource group, messaging, a data store, a container host, some identity and monitoring. Yet teams often write the Terraform for each new service by hand, and that assembly work can take weeks. In the project this workshop is based on, building the infrastructure for one new service took about two weeks, and developers waited because they had nowhere to deploy.

AI looks like the obvious fix. It reads documents well, recognizes patterns, and writes plausible Terraform in minutes. A first prototype that fed architecture documents to an AI and asked for Terraform did work: the output was valid, followed the team's standards, and passed `terraform validate` and `tflint` on the first run.

The trouble showed up the second time. Same input, same prompt, same model, different Terraform. This lab recreates that moment so you can see it yourself rather than take our word for it.

## What we are doing

You will run one experiment:

1. Read the architecture document the AI will be working from.
2. Ask an AI assistant to write Terraform from it, saving the result in `lab1\run1`.
3. Start a completely fresh chat and ask for exactly the same thing, saving the result in `lab1\run2`.
4. Compare the two outputs, first as raw files and then by the resources they declare.

You are not judging whether the Terraform is good. You are looking at whether the two runs agree.

## Background

**The input.** The repository contains six architecture documents for an example service, a Work Item Service for a fictional company (Momentum Rocket Skates). The one that matters here is `docs\infrastructure-architecture-guide.md`. It describes the Azure infrastructure in plain language: a resource group, a Container App for the API, a Function App for the event processor, Service Bus, Cosmos DB, App Configuration, Key Vault, and monitoring. It also lists obligations such as "local authentication is disabled" and a naming and tagging pattern. It was written for people, not machines.

**Why the prompt looks the way it does.**

- *"Read docs/infrastructure-architecture-guide.md"* grounds the AI in the document instead of its general knowledge.
- *"for the dev environment"* keeps the scope the same in both runs.
- *"into lab1/run1"* keeps the two outputs apart so you can compare them.
- *"Do not ask me questions; make reasonable choices"* stops the AI from starting a conversation. Without it, the two runs could differ simply because you answered clarifying questions differently.
- A **new chat** for the second run matters. If the AI can see its first answer, it will tend to repeat it, and you would be measuring memory rather than variation.

**Why identical input can give different output.** A language model produces text by choosing likely next words, and it does not always choose the single most likely one. Many ways of writing the same Terraform are equally valid, so different runs take different paths: different resource labels, file layouts, orderings, comments. Settings that reduce this randomness are usually not exposed in coding assistants, and even where they exist, they do not guarantee identical output across runs, tools, or model updates. Treat variation as a built-in property, not a bug someone will fix.

## Steps

1. Open the repository in VS Code. Open `docs\infrastructure-architecture-guide.md` and skim section 4 and the table in section 5.1. This is the input. You do not need to read all of it.

2. Make a scratch folder:

   ```powershell
   New-Item -ItemType Directory .\lab1 | Out-Null
   ```

3. Start a **new chat**. Use agent mode with a Claude model. Paste this prompt exactly:

   ```
   Read docs/infrastructure-architecture-guide.md. Write complete azurerm Terraform for the dev environment into lab1/run1. Do not ask me questions; make reasonable choices. Use only that document as input: do not read or copy anything else under lab1, and do not run terraform.
   ```

   Let it finish. This usually takes a few minutes.

   **Review what it produced.** Open the files in `lab1\run1` and look them over. You are checking that this is *good* Terraform, because it should be:

   - Does it declare the resources the architecture guide describes (resource group, Container App, Function App, Service Bus, Cosmos DB, App Configuration, Key Vault, monitoring)?
   - Does it follow the guide's obligations, such as turning off local authentication and using the naming and tagging pattern?
   - Does it read like something a competent engineer would write: sensible variables, clear structure, no obvious gaps?

   Most people find that it does. That matters for the rest of the lab: the problem you are about to see is not bad output.

4. Start a **brand new chat** (so it has no memory of run 1). Paste the same prompt, changing only `run1` to `run2` (both places). Use the same model and mode as before. The extra sentence matters: an agent can read your workspace, so without it, run 2 may find `lab1\run1` and copy it.

   While run 2 works, read the infrastructure guide's section 6.7 (naming and tagging). Notice how specific it is, and keep it in mind for step 6.

   **Review run 2 the same way.** Open `lab1\run2` and skim it. At a glance, it should look very close to run 1: the same kinds of resources, similar structure, the same general approach. If someone handed you either folder, you would probably accept it. Hold that impression, because the next step looks closer.

5. Compare the two runs.

   ```powershell
   git -c core.autocrlf=false --no-pager diff --no-index --stat .\lab1\run1 .\lab1\run2
   ```

   `--no-pager` keeps Git from opening a scrolling viewer (if you ever land in one, press `q` to leave). `-c core.autocrlf=false` silences "LF will be replaced by CRLF" line-ending warnings, which are harmless. `git diff` exits with code 1 when files differ. That is expected here, not an error.

   If the stat shows almost nothing, or only a file such as `.terraform.lock.hcl` (created when someone runs `terraform init`), the two runs are suspiciously identical. See Troubleshooting.

   Then compare just the resources each run declared:

   ```powershell
   $a = Get-ChildItem .\lab1\run1 -Filter *.tf -Recurse | Select-String '^resource ' | ForEach-Object { $_.Line.Trim() } | Sort-Object
   $b = Get-ChildItem .\lab1\run2 -Filter *.tf -Recurse | Select-String '^resource ' | ForEach-Object { $_.Line.Trim() } | Sort-Object
   Compare-Object $a $b
   ```

6. Write down at least four things that differ: ______________________________

**No AI assistant?** Use `kit\lab1-fallback\run1` and `run2` and start at step 5.

## What you should see

Your results will be different from anyone else's, which is the point. The two runs look nearly the same at a glance, so the question is what the closer comparison shows. Here is how to read it.

**`git diff --stat`** lists every file that differs and how many lines changed. Expect differences in nearly every file, and possibly files that exist in one run but not the other. If the two runs split their Terraform into different files, the diff will look larger than the real difference.

**`Compare-Object`** prints one line per resource declaration that appears in only one run. In its output, `<=` means the line is only in run 1 and `=>` means it is only in run 2. A resource appearing on both sides with a slightly different label (for example, one run calling something `main` and the other naming it after its role) is the most common difference. If the output is empty, both runs declared exactly the same resource lines; check the diff in step 5 for the rest, because other things will almost certainly still differ.

Common differences:

- **Naming:** resource labels and the names given to Azure resources
- **Ordering:** which resources and arguments come first
- **Structure:** one big file versus several, and how variables and locals are used
- **Tags:** where they are defined and which ones appear
- **Comments:** presence, wording, and placement
- **Scope:** a resource or setting one run included and the other left out (diagnostics and role assignments are good places to look)

## The lesson

Both runs are probably *reasonable*. Neither is obviously wrong. That is exactly what makes this a problem for infrastructure:

- **Diffs stop meaning anything.** In a pipeline, a diff should show that someone changed intent. If regenerating produces a different file, reviewers cannot tell a real change from noise.
- **Reproducibility disappears.** You cannot rebuild the same environment from the same inputs next quarter and expect the same files.
- **Audits lose integrity.** "What did we deploy, and from what?" has no stable answer.
- **Standards drift quietly.** If each run interprets naming and tagging a little differently, the standard erodes without anyone deciding to change it.

None of this means AI is bad at the job. It means AI was doing two jobs at once: understanding the architecture, which is fuzzy and where variety is fine, and writing the Terraform, which must be exact and repeatable. AI is strong at the first and unsuited to the second. The rest of the workshop separates those jobs.

## Notice

> Same input, same prompt, same model. Is either run *wrong*? Could you merge the diff into a pull request and review it? Try imagining this across 40 services.

## Check your understanding

<details>
<summary>1. Why did we start a new chat for run 2?</summary>
So the AI could not see run 1. Otherwise, it would tend to repeat its earlier answer, and you would be measuring memory instead of the natural variation between runs.
</details>

<details>
<summary>2. Both runs passed review by eye. Why is that not enough?</summary>
Plausible is not the same as reproducible. Pipelines, audits, and rollbacks depend on the same input producing the same output, so a generator that changes its mind between runs cannot be trusted as a source of governed infrastructure, however good each .result looks.
</details>

<details>
<summary>3. What is the AI good at here, and what is it not?</summary>
It is good at reading a human-written architecture document and determining the infrastructure needs. It is not suited to writing the final Terraform, because that has to be identical every time. Lab 2 gives it only the first job.
</details>

## Troubleshooting

| Problem | What to do |
|---|---|
| The AI asks clarifying questions anyway. | Answer "Use your best judgment" and continue. Do the same in both runs. |
| The AI writes files outside `lab1\run1` | Move them into the right folder, or delete the strays and run again. Both runs must be in their own folders. |
| `git diff` prints nothing | Check that both folders contain files, and that the second run did not overwrite the first. |
| `Compare-Object` prints nothing | Both runs declared the same resource lines. Check the `git diff` output for other differences, or try a third run. |
| The run 2 chat seems to know about run 1 | It was not a new chat. Start over with a fresh one. |
| `git` is not found | Install Git (see the prerequisites) and open a new terminal. |
| You have no AI assistant. | Use the fallback runs in `kit\lab1-fallback`, or partner with someone who has one. |

## Go further

- **Run it a third time** and see how many resource lines all three runs share.
- **Tighten the prompt.** Add the naming and tagging pattern from section 6.7 to the prompt and repeat both runs. Does the gap between runs shrink? Does it disappear? Why or why not?
- **Check validity.** Both runs may be valid Terraform even though they differ. If you want to confirm, run `terraform init` and `terraform validate` in each run's folder.

## Doing this lab on your own

You do not need a facilitator. Allow 20 to 25 minutes, mostly for the AI runs, and read the Background and The lesson sections before and after the steps. The Check your understanding answers above are the debrief. When you are ready, continue to [Lab 2](lab02.md), which shows what happens when you give the AI a narrower job.

---

[← Lab guide](../lab-guide.md) · [Lab 2 →](lab02.md)
