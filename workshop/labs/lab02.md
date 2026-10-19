# Lab 2: Architecture to YAML, and inspect it

**Time:** 25 minutes in the workshop (21 hands-on and a 4-minute debrief), 35 to 45 minutes on your own · Part of the [lab guide](../lab-guide.md)

| | |
|---|---|
| **Goal** | Give the AI the job it does well, then review its work like an engineer. |
| **You will** | Have an AI turn the architecture guide into a YAML spec, then inspect that spec against the guide. |
| **You need** | An AI coding assistant in agent mode (or the reference spec), a **PowerShell 7** terminal, and the repository cloned. |
| **You will have** | A YAML spec in `infra\`, a completed inspection checklist, and a list of problems found in a deliberately flawed spec. |
| **Previous** | [Lab 1](lab01.md) showed that AI-written Terraform is plausible but not repeatable. |
| **Next** | [Lab 3](lab03.md) turns the spec into Terraform with no AI at all. |

Work in the repository root:

```powershell
cd C:\Workshop\FromArchitectureToTerraformWorkshop
```

## Introduction

Lab 1 showed the problem: ask an AI for Terraform and you get something good-looking that changes from run to run. The fix is not to stop using AI. It is to give the AI a narrower job.

AI is good at reading a document written for people and working out what it means. So in this lab the AI does only that. Its output is not Terraform. It is a short, structured YAML file that states *what* the infrastructure must be: which resources, with which settings, in which environments. We call that file the **spec** or the **contract**. In Lab 3, ordinary code turns the contract into Terraform the same way every time.

That arrangement only works if the contract is right. Whatever is wrong in the YAML is wrong in every environment, every run, and every audit afterward. So the second half of this lab is the part AI cannot do for you: reviewing its work. The YAML is the human review gate in the pipeline.

## What we are doing

1. Run a prompt that tells the AI to read the architecture guide and write a YAML spec (Part A).
2. Read what the AI says about its own work: what it assumed, and what it wants a human to decide (Part A).
3. Inspect your spec against the guide, using a checklist (Part B).
4. Practice on a spec with problems added on purpose, so you can see which kinds of problems are easy to miss (Part C).

## Background

**The spec.** `infra\work-item-service.infra.yaml` lists the resources the service needs, such as the Container App, the Function App, Service Bus, and Cosmos DB, plus their settings. Values that differ by environment use a small `{ dev: ..., qa: ..., prd: ... }` form. The spec also has a `state:` block for where Terraform keeps its state, which should contain `REPLACE_WITH_...` placeholders, not real names. The format is defined by a JSON schema in the generator's `schema` folder.

**The prompt.** `.github\prompts\create-infrastructure-spec.prompt.md` is the instruction the AI follows. It tells the AI what to read, what shape the output takes, and, importantly, what to do when the guide does not say something: record an assumption or ask a question instead of inventing a value. It is worth reading before you run it. Compare it with the one-sentence prompt from Lab 1.

**What the AI reports.** The prompt asks the AI to print three things in chat alongside the YAML: a traceability table (which guide row produced which resource), a list of assumptions, and questions for a human. These are your starting point for review. They tell you where the AI itself was unsure.

**Four ways interpretation goes wrong.** The AI is interpreting a document written for people, and interpretation can fail in four ways. Machines can catch some of these. People catch the rest. Your job is to find out which is which.

| Failure | What it looks like |
|---|---|
| **Wrong value** | A number or setting that does not match the guide |
| **Wrong unit or format** | Right idea, wrong representation |
| **Invented value** | Something the guide never said |
| **Missing or extra item** | A resource or access rule left out, or added without a source. |

## Part A: Run the prompt and read the output (8 minutes in the workshop)

1. Remove the Lab 1 scratch folder so it does not confuse the AI (skip this if you did not do Lab 1):

   ```powershell
   Remove-Item .\lab1 -Recurse -Force -ErrorAction SilentlyContinue
   ```

2. Open `.github\prompts\create-infrastructure-spec.prompt.md`. Read it. Note what it tells the AI to do, and what it tells it **not** to do.
3. In a new chat in agent mode, type:

   ```
   /create-infrastructure-spec
   ```

   (Claude Code users: run the same skill, `/create-infrastructure-spec`.)

4. While it works, read the prompt file again. Find the rules about assumptions.
5. When it finishes, read its chat output (see below) before you open the YAML.

**No AI assistant, or still waiting after 5 minutes?** Use the reference spec:

```powershell
New-Item -ItemType Directory .\infra -Force | Out-Null
Copy-Item .\tools\terraform-generator\examples\work-item-service\work-item-service.infra.yaml .\infra\
```

**Read the output (2 minutes).** The chat output from `/create-infrastructure-spec` should contain three things. If you used the reference spec, there is no chat output; skip to Part B.

1. **The traceability table.** Does every "New" row in section 5.1 of the guide appear? Count them.
2. **Assumptions.** Where did the AI have to make a choice? Is each choice reasonable, or does it need an owner's decision?
3. **Questions for a human.** If it says "None", ask whether that is believable for a document this size.

Write down one assumption you would challenge: ______________________

### What you should see

A spec file at `infra\work-item-service.infra.yaml` (the AI may use a slightly different name), with comments naming the guide section each resource came from. The reference spec describes 17 resources. Yours may differ by a few, and that is already a finding worth checking in Part B. Compared with Lab 1, the output should vary much less from run to run, because the schema and the prompt leave the AI little room to improvise, though it will not be identical. Expect it to look plausible, long, and confident. That is exactly why you need to inspect it.

## Part B: Inspect your own YAML (10 minutes in the workshop)

Open `infra\work-item-service.infra.yaml` beside `docs\infrastructure-architecture-guide.md`. Work through the checklist. Tick what checks out; write a note for anything that does not. As you go, notice *how* you find each problem: by checking the spec against the guide, or because something looked odd. The Notice box at the end of this lab asks about that.

### Inspection checklist

**1. Completeness**
- [ ] Every "New" row in section 5.1 has a matching resource entry.
- [ ] Nothing in the YAML lacks a source. Each resource has a comment naming a guide section or IG obligation, and the section it cites really says that.

**2. Per-environment values (guide section 7)**
- [ ] Every value that differs by environment uses the `dev` / `qa` / `prd` format.
- [ ] Each value matches section 7 exactly. Check replicas, retention periods, SKUs, backup retention, and instance limits.
- [ ] Nothing that should be the same in all environments has been given different values.

**3. Units and formats**
- [ ] Durations are ISO 8601 (`P7D`, not `7` or `7 days`).
- [ ] Sizes use the expected format (`1Gi`, not `1GB` or `1024`).
- [ ] CPU, memory, and port values match the guide.

**4. Invented values**
- [ ] The `state:` block still holds `REPLACE_WITH_...` placeholders. Real-looking names there mean the AI made something up.
- [ ] Names, subscription IDs, tenants, image names, and endpoints are placeholders or come from the guide.
- [ ] Anything you cannot trace to the guide is either listed in the AI's assumptions or is a finding.

**5. Access (guide section 6.3)**
- [ ] Each identity has exactly the roles section 6.3 lists. No more.
- [ ] Direction is right: who sends, who receives, who reads, who writes.
- [ ] Scope is right: the topic, the database, the vault, the configuration store.

**6. References and names**
- [ ] Every `from:` value points to something that exists in the spec.
- [ ] Names, keys, and tags follow section 6.7.

**7. Contradictions with obligations**
- [ ] Nothing in the spec asks for something the IG obligations forbid (local authentication, shared keys, public access, and similar). Remember that some security defaults live in the generator, not the spec. If the spec tries to set them, ask why.

### Record your findings

| # | Where in the YAML | What is wrong | Which failure type | Source in the guide |
|---|---|---|---|---|
| 1 | | | | |
| 2 | | | | |
| 3 | | | | |

If you find nothing, say so. A clean result is a valid result, and you should be able to say how you know. Many runs will produce one or two small findings, usually an assumption or a missing detail, and that is normal.

## Part C: Calibrate on a flawed spec (3 minutes in the workshop, in pairs)

The repository's `kit` folder contains `kit\flawed\work-item-service.flawed.infra.yaml`. It is the reference spec with several problems added on purpose. Do **not** run it through the generator yet.

With a partner (or alone, if you are working through this by yourself), use the same checklist and find as many problems as you can. Write each one in the table above, then mark how you think it could be caught:

- **S**: a schema check would reject it
- **G**: the generator's semantic checks would reject it (for example, a reference to something that does not exist)
- **H**: only a human comparing it to the guide would notice

Keep your list. In Lab 3, you will run this file through the generator and see which problems the machine actually catches. On your own, allow 15 to 20 minutes for this part; flaws are easy to miss without a deadline, and the deadline isn't the point. Finding them is.

> **Notice.** Which findings did you make by comparing against the guide, and which by noticing something looked odd? Which would a script ever catch?

## The lesson

The AI did the part that suits it: reading a long human document and turning it into a precise, structured description. It did that quickly, and unlike Lab 1, the result is small enough for a person to review and stable enough to diff. A spec with a few hundred lines is a far better thing to put in a pull request than thousands of lines of Terraform.

But a spec that *looks* right can be wrong, and the errors that matter most are the quiet ones: a number that is plausible but not the number in the guide, a role that grants the wrong direction of access slightly, a name the AI invented to fill a gap. A schema can tell you a value has the right shape. It cannot tell you the value is true. That is a job for a person holding the source document, which is why the review sits between the AI and the generator.

The practical rule is: **machines handle repeatability, engineers handle judgment.** Review is not a formality to be skipped when the output looks good. Good-looking output is the case where it matters most.

## Check your understanding

<details>
<summary>1. Why does the AI produce YAML instead of Terraform in this lab?</summary>
Because interpretation is the part AI is good at, and Terraform generation is the part that must be exact. The YAML captures the AI's interpretation in a small, reviewable, diffable form. A deterministic generator then does the exact work.
</details>

<details>
<summary>2. The AI's "Questions for a human" section says "None". Should you trust that?</summary>

Not automatically. A document of this size nearly always leaves gaps, so "None" may mean the AI quietly filled them in. Look for unexplained values and check whether they appear in the assumptions list. An unlisted assumption is a finding.
</details>

<details>
<summary>3. Why does the checklist begin with the guide, not the YAML?</summary>
The guide is the source of truth. If you review the YAML only for internal consistency, you will miss every error where the AI is consistent but wrong. Each check compares the YAML against something the guide says.
</details>

<details>
<summary>4. Which kinds of problems are hardest for a script to catch?</summary>

Wrong values and invented well-formed values: a valid number that is the wrong number, a valid role on the wrong scope. Scripts can check shape and references. Only a comparison with the source document checks meaning.
</details>

## Troubleshooting

| Problem | What to do |
|---|---|
| `/create-infrastructure-spec` is not recognized | Make sure the repository folder (not a parent) is open in VS Code, and the chat is in agent mode. Prompt files live in `.github\prompts`. In Claude Code, run it from the repository root. |
| The AI says it needs more information. | Tell it to follow the prompt file: record assumptions and questions instead of stopping. |
| The AI starts reading the `kit`, `examples`, or the generator folder. | Stop it and say to use only the files in `docs`. Copying an existing spec is not interpreting the guide, and it defeats the point of the review. |
| The YAML file is not where you expected | Search the repository for `*.infra.yaml`. Use whatever path the AI chose in the later labs. |
| Output takes more than five minutes. | Use the reference spec (see Part A) and do Part B on that. |
| The `\` paths do not work. | You are probably not in PowerShell. Open a PowerShell 7 terminal. On macOS or Linux, change `\` to `/`. |

## Go further

- **Run it twice.** Save your YAML as `infra\run1.yaml`, delete the original, start a new chat, run the prompt again, and compare with `git -c core.autocrlf=false --no-pager diff --no-index .\infra\run1.yaml .\infra\work-item-service.infra.yaml`. How does the gap compare with Lab 1? What differs, and does any difference change meaning?
- **Break the contract on purpose.** Change one value in your spec so it disagrees with the guide, then show it to a colleague without telling them. Do they find it?
- **Write a rule.** Pick one check from the checklist that a script could do, such as "durations are ISO 8601", and describe how you would automate it. Which checks could not be automated?

## Doing this lab on your own

You do not need a facilitator. Read Introduction and Background first, then do the parts in order. Part A takes as long as the AI takes. Part B is the heart of the lab, so give it your full attention. Part C is where the learning sticks: take your time and keep your findings list for [Lab 3](lab03.md). The debrief questions below work well as a few minutes of writing, or as a conversation with a teammate.

## Debrief questions

1. How many problems did the machine-style checks (S, G) cover, and how many needed a human (H)?
2. Which category worried you most, and why?
3. What would make your team trust this review? A checklist, a second reviewer, a diff against the last approved version?
4. Where in your own process would this review gate sit: before commit, in the pull request, or both?

---

[← Lab 1](lab01.md) · [Lab guide](../lab-guide.md) · [Lab 3 →](lab03.md)
