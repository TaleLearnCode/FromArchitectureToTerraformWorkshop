# Lab 2: Architecture to YAML, and inspect it

**Time:** 25 minutes · Part of the [lab guide](../lab-guide.md)

Work in the repository root in a **PowerShell 7** terminal:

```powershell
cd C:\Workshop\FromArchitectureToTerraformWorkshop
```

Keep the "Notice" box in mind; we will ask about it in the debrief.

**Goal:** give the AI the job it is good at, then review its work like an engineer.

The AI gave you a YAML spec. It looks right. It is long, confident, and well commented. That is exactly why you need to inspect it.

In real use, the YAML is the contract. Whatever is wrong in it is wrong in every environment, every run, and every audit afterward. A short, disciplined review here is the "engineers handle judgment" part of the model.

## What to look for

The AI is interpreting a document written for people. Interpretation can go wrong in four ways:

| Failure | What it looks like |
|---|---|
| **Wrong value** | A number or setting that does not match the guide |
| **Wrong unit or format** | Right idea, wrong representation |
| **Invented value** | Something the guide never said |
| **Missing or extra item** | A resource or access rule left out, or added without a source |

Machines can catch some of these. People catch the rest. Your job is to find out which is which.

## Part A: Run the prompt and read the output (8 minutes)

1. Remove the Lab 1 scratch folder so it does not confuse the AI:

   ```powershell
   Remove-Item .\lab1 -Recurse -Force
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
2. **Assumptions.** Where did the AI have to choose? Is each choice reasonable, or does it need an owner's decision?
3. **Questions for a human.** If it says "None", ask whether that is believable for a document this size.

Write down one assumption you would challenge: ______________________

## Part B: Inspect your own YAML (10 minutes)

Open `infra\work-item-service.infra.yaml` beside `docs\infrastructure-architecture-guide.md`. Work through the checklist. Tick what checks out; write a note for anything that does not.

### Inspection checklist

**1. Completeness**
- [ ] Every "New" row in section 5.1 has a matching resource entry.
- [ ] Nothing in the YAML lacks a source. Each resource has a comment naming a guide section or IG obligation, and the section it cites really says that.

**2. Per-environment values (guide section 7)**
- [ ] Every value that differs by environment uses the `dev` / `qa` / `prd` form.
- [ ] Each value matches section 7 exactly. Check replicas, retention periods, SKUs, backup retention, and instance limits.
- [ ] Nothing that should be the same in all environments has been given different values.

**3. Units and formats**
- [ ] Durations are ISO 8601 (`P7D`, not `7` or `7 days`).
- [ ] Sizes use the expected form (`1Gi`, not `1GB` or `1024`).
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

If you find nothing, say so. A clean result is a valid result, and you should be able to say how you know.

## Part C: Calibrate on a flawed spec (3 minutes, in pairs)

The repository's `kit` folder contains `kit\flawed\work-item-service.flawed.infra.yaml`. It is the reference spec with several problems added on purpose. Do **not** run it through the generator yet.

With a partner, use the same checklist and find as many problems as you can. Write each one in the table above, then mark how you think it could be caught:

- **S**: a schema check would reject it
- **G**: the generator's semantic checks would reject it (for example, a reference to something that does not exist)
- **H**: only a human comparing it to the guide would notice

Keep your list. In Lab 3 you will run this file through the generator and see which problems the machine actually catches.

> **Notice.** Which findings did you make by comparing against the guide, and which by noticing something looked odd? Which would a script ever catch?

## Debrief questions

1. How many problems did the machine-style checks (S, G) cover, and how many needed a human (H)?
2. Which category worried you most, and why?
3. What would make your team trust this review? A checklist, a second reviewer, a diff against the last approved version?
4. Where in your own process would this review gate sit: before commit, in the pull request, or both?

---

[← Lab 1](lab01.md) · [Lab guide](../lab-guide.md) · [Lab 3 →](lab03.md)
