# Workshop Facilitator Guide

**From Architecture to Terraform: A Hands-On Workshop (2 hours)**

This guide is for the facilitator. It covers preparation, a run of show, talking points and debrief questions for each lab, a recovery table, and an answer key for the Lab 2 flawed spec. Attendee materials live in the repository: `workshop\prerequisites.md`, `workshop\lab-guide.md` (the overview), and one page per lab in `workshop\labs\` (Lab 2 includes the YAML inspection checklist), with fallback files in `kit\`.

**This folder is not published.** The answer key below would spoil Lab 3 Part D, so the repository's `.gitignore` excludes `facilitator\`. Keep it local, or move it somewhere private.

## The workshop in one minute

Attendees live the arc of the talk. They see AI fail at deterministic generation (Lab 1), give it the job it is good at and review its work (Lab 2), run the deterministic half and prove it repeatable (Lab 3), extend that deterministic half (Lab 4), and watch one intent change flow through as a small diff (Lab 5).

The message to leave with is the same as the talk: AI handles the fuzzy work, scripts handle the deterministic work, engineers handle judgment. The workshop adds one thing the talk cannot show: the review step is a skill, and it can be practiced.

## Assumptions

- Attendees are on Windows with PowerShell 7. Mac and Linux users convert the few commands themselves.
- Attendees can create resources in an Azure subscription. Those who cannot stop after `init`, `validate`, and `tflint` in Lab 3. Nothing is ever applied.
- Attendees have Copilot Chat (agent mode, Claude model) or Claude Code. Those who do not use fallback files.
- No containers or Codespaces. Preparation is the attendee's responsibility, covered by the prerequisites page.

## Run of show

| Time | Min | Block | Facilitator focus |
|---|---|---|---|
| 0:00 | 10 | Framing and setup check | 5-minute story, 5-minute preflight |
| 0:10 | 15 | Lab 1: Break determinism | Make the drift visible and visceral |
| 0:25 | 25 | Lab 2: Architecture to YAML, and inspect it | Teach review as a skill |
| 0:50 | 20 | Lab 3: Deterministic generation | Prove repeatability, then reveal what machines catch |
| 1:10 | 5 | Break | Reset stragglers |
| 1:15 | 20 | Lab 4: Extend the generator | Show how small the extension is |
| 1:35 | 15 | Lab 5: Watch a change flow through | The diff is the payoff |
| 1:50 | 10 | Wrap-up | Adoption worksheet and discussion |

## Preparation

### Two weeks out

- Send the repository link and point attendees at `workshop\prerequisites.md`.
- Ask registrants whether they have an AI assistant and Azure access, so you know how many need fallbacks.

### The kit

The kit is the repository's `kit` folder, so attendees get it with their clone and there is nothing separate to download. Two of its three parts are already built and tested; the third needs your rehearsal.

| Kit item | Status |
|---|---|
| `kit\flawed\work-item-service.flawed.infra.yaml` | **Built.** The reference spec with nine flaws applied (see the answer key). |
| `kit\lab4\work-item-service-queue.infra.yaml` | **Built.** The reference spec with the queue added. |
| `kit\lab4\solution\` | **Built.** A working `servicebus_queue` implementation (four changed files plus a README). |
| `kit\lab1-fallback\run1`, `run2` | **You build it.** Run the Lab 1 prompt twice in fresh chats and save both outputs into `kit\lab1-fallback\run1` and `run2`, then commit them. Pick a pair that differs visibly in names, ordering, and tags. A README is already in that folder. |

**How the built parts were checked.** The flawed spec, the queue spec, and the solution were run through the demo repo's generator (PowerShell 7.4) and its test script, with the repo as of mid-October 2026. Because the build environment could not install `powershell-yaml`, a stand-in YAML parser was used. Results should be identical, but repeat the checks on Windows with the real module during your rehearsal. The test script's one failure in that environment was the "committed example output matches" check, which needed files that were not copied; confirm it passes in your repo.

### Rehearse end to end

Run every lab once on a clean machine. Record these numbers and replace the placeholders in your notes:

- Lab 1: time for each AI run: ______ and ______ minutes
- Lab 2: time for `/create-infrastructure-spec` to finish: ______ minutes
- Lab 3: the generator prints `Generated 17 resources` for the reference spec; `terraform plan` should report ______ (the demo guide expects 32, because role assignments and diagnostic settings count)
- Lab 4: time for a competent engineer to finish without opening `guides\extending-the-generator.md`: ______ minutes. If it exceeds 15, let attendees open the guide earlier.
- Lab 5: `git diff --no-index -I '# Source:'` should show exactly one change: `container_app_api_min_replicas` 2 to 3 in `environments\prd.tfvars`. Confirm on your machine.

Confirm in rehearsal that `tflint` is clean and that `git diff --no-index` and `robocopy` behave as the guide says on your machine.

### Room

- Wi-Fi that handles 30 simultaneous AI sessions and Terraform provider downloads. The `terraform init` download is the usual bottleneck; ask attendees to run it in the prerequisites step if you can, so the provider is cached.
- A projected screen with large fonts.
- One helper per 15 attendees if possible. Lab 4 is where people get stuck.

## Block-by-block

Each lab's time includes its debrief (about 3 to 5 minutes). Start debriefs on schedule even if some attendees are unfinished; the fallbacks and the stretch goals exist for that.

### Framing and setup check (0:00, 10 minutes)

Tell the story fast: two-week infrastructure builds, the bold claim, the prototype that worked, and the second run that did not match. End with the model on the board: Architecture, AI, YAML, PowerShell, Terraform. Do not teach it; they will discover it.

Spend the last five minutes on a preflight show of hands: run the preflight script, flag anyone with MISSING lines, and pair them with a neighbor so the room does not stall.

Say how the workshop works: short labs, a "Notice" box in each, and a debrief after each. Agree up front that fallbacks are normal.

### Lab 1: Break determinism (0:10, 15 minutes)

**Goal.** Attendees see drift with their own eyes.

**Tips.**
- The new chat for run 2 matters. Without it the second run has run 1 in context and drifts less.
- Expect run times of a few minutes each. Tell people to start run 2 as soon as run 1 finishes, and to read the architecture guide while they wait.
- `git diff --no-index` returning exit code 1 looks like an error. Tell them it is not.

**Debrief (3 minutes).**
1. What differed? Collect a list on the board: names, ordering, tags, comments, structure.
2. Is either run wrong? (Usually not. That is the point: both are plausible, neither reviewable against the other.)
3. What does this do to a pull request, an audit, a rollback?

**Land the point.** The output was fine. It was not reproducible. Infrastructure needs reproducible.

### Lab 2: Architecture to YAML, and inspect it (0:25, 25 minutes)

**Goal.** Attendees get the AI result and learn to review it systematically.

**Tips.**
- Part A is mostly waiting. Use the wait time to point them at the prompt file and its rules about assumptions.
- Part B is the heart of the lab. Walk the room. People tend to skim; push them to compare at least three per-environment values against section 7 of the guide by eye.
- Part C is the stretch. If the room is behind at 0:45, skip Part C and run it as a 5-minute group exercise in Lab 3 Part D instead, projected on screen.
- Point out the exact line of the exercise: a clean result is valid, as long as you can say how you know.

**Debrief (4 minutes).** Use the four debrief questions at the end of the Lab 2 page. Capture on the board how many problems they found by type. Tell them Lab 3 will show how many the machine finds.

**Be honest about slide 32.** AI will not produce byte-identical YAML twice. What stays stable is the structure, because the schema constrains it, and because the YAML is reviewed and committed before anything builds from it. If someone asks, say that directly. Do not claim identical YAML.

### Lab 3: Deterministic generation (0:50, 20 minutes)

**Goal.** Prove repeatability, run the real toolchain, then compare machine review to human review.

**Tips.**
- `git add infra` before the second generation, and run the check before `terraform init`, or `.terraform` files muddy the status.
- The warning about placeholder state values is expected. Make a point of it: the AI did not invent them.
- `terraform init` can be slow on first run. This is the moment to talk while it downloads.
- Azure attendees run `plan`; others stop after `tflint`. Do not let either group feel behind.

**Part D is the reveal.** Attendees run the flawed spec, fix only what the generator rejects, and repeat until it prints `Spec OK`. Expect three rounds: schema errors first (the bad duration and the bad size), then the semantic error (the unknown `from:` attribute), then success. At that point the file still contains six flaws, and the generator will happily produce Terraform from it. Put that on screen and let the room sit with it.

Two things to know. First, schema errors are very long: each resource contributes about fourteen near-identical lines, and the useful line (for example `at '/resources/8/default_message_ttl'`) is buried. Tell attendees to search for the field name. This is a real usability issue in the generator and a good discussion point. Second, the generator stops at the first failing stage, so semantic errors only appear once schema errors are fixed.

**Debrief (3 minutes).**
1. Which of the problems did the machine catch? Which did only a human catch?
2. The schema checks the shape of the contract. What checks whether it is true?
3. What changes about review when you know the next step is deterministic?

### Break (1:10, 5 minutes)

Reset stragglers. Anyone who failed `terraform init` or never got a spec should copy the reference spec and regenerate, so Lab 4 has a working base.

### Lab 4: Extend the generator (1:15, 20 minutes)

**Goal.** Show that adding a resource type is small, mechanical, and AI-free, and that security defaults belong in the generator.

**Tips.**
- This lab has the highest dropout risk. Tell people that opening `kit\lab4\solution` is a normal choice, and invite them to diff their work against it afterward.
- **Decide how to treat the extending guide.** `guides\extending-the-generator.md` in the repo contains this exact example, including the complete action script, schema entry, and dependency check. The lab guide tells attendees to try first and open the guide only if stuck. If you would rather they learn by following along, say so up front and treat the guide as the handout. If you want real discovery, swap the lab to a type the guide does not cover and rebuild `kit\lab4\solution` for it.
- The four touch points (type table, action script, schema, dependency check) are the whole lesson. Put them on a slide.
- The common mistake is a misspelled helper function. Tell people to copy the topic script and change as little as possible.
- If the test script fails on something unrelated to their change, check you are in a clean checkout.

**Debrief (3 minutes).**
1. How much of this needed AI? (None.)
2. Why do security defaults live in the script instead of the spec?
3. Which standard on your team would you encode this way first?

**Stretch material for fast finishers.** Misspell a field to see schema rejection; make `max_delivery_count` vary by environment.

### Lab 5: Watch a change flow through (1:35, 15 minutes)

**Goal.** The payoff: one sentence of intent becomes one value in one file.

**Tips.**
- The `robocopy` step is needed so `.terraform` does not pollute the diff. Tell attendees non-zero exit codes from `robocopy` are normal.
- If the AI is quick, the full-loop stretch is powerful, but it will not fit for most. Offer it as a take-home.
- The plain diff touches every generated file, because each file's header records the SHA-256 of the spec. Attendees are told to expect that and then ignore the header lines with `git diff --no-index -I '# Source:'`. Treat it as a feature: the header proves which spec produced which output.
- After filtering, only `environments\prd.tfvars` should differ. If other files differ, someone regenerated from a different spec or edited something else.

**Debrief (3 minutes).** How many files changed? Could you approve this in a minute? Compare to the Lab 1 diff.

### Wrap-up (1:50, 10 minutes)

Five minutes on the worksheet, five on discussion. Prompt with two questions: what is the smallest first slice you could try in 30 days, and which of your standards would become a generator default? End with the closing line from the talk: AI handles the fuzzy work, scripts handle the deterministic work, engineers handle judgment.

Point attendees at the repo, the adapting guide, and the extending guide.

## If something goes wrong

| Problem | What to do |
|---|---|
| AI is slow or unavailable | Use fallback files: `kit\lab1-fallback` for Lab 1, the reference spec copy for Lab 2. Continue with Lab 3. |
| Rate limits hit many attendees | Run Lab 2 once on your screen, then hand out the YAML. Attendees still do inspection and everything after. |
| AI YAML has a mistake | Use it. Inspection is the lab. |
| Generator fails on `ConvertFrom-Yaml` | `Install-Module powershell-yaml -Scope CurrentUser` |
| Generator says it needs PowerShell 7 | Open `pwsh`, not Windows PowerShell |
| `terraform init` asks for backend settings | `backend_override.tf` is missing or in the wrong folder. It must be in `infra\terraform`. |
| `terraform init` complains the backend changed | `terraform init -reconfigure` |
| `terraform plan` fails on credentials | `az login` and set `$env:ARM_SUBSCRIPTION_ID` in this terminal. Or skip: they stop after `tflint`. |
| `git status` shows `AM` after the second generation | Something is non-deterministic or the run used a different spec path. Check the spec path, then investigate. This would be a real finding. |
| Lab 4 is over time for most of the room | Hand out `kit\lab4\solution` and have them read it. The lesson is the four touch points. |
| Room is behind overall | Skip Lab 2 Part C; skip Lab 4 stretch; cut Lab 5 to steps 1 to 4. |
| Room is ahead | Offer Lab 4 stretch goals and the Lab 5 full loop. |

## Appendix: Lab 2 flawed spec answer key

`kit\flawed\work-item-service.flawed.infra.yaml` is the reference spec with nine flaws applied. Each was run through the generator on its own. **Do not give attendees this table before Lab 3 Part D.**

| # | Flaw | Reference value | Flawed value | Generator result |
|---|---|---|---|---|
| 1 | Key Vault purge protection on in dev | `dev: false` | `dev: true` | Accepted (H) |
| 2 | Cosmos DB backup retention in prd too short | `prd: 30` | `prd: 7` | Accepted (H) |
| 3 | Wrong duration format on the audit subscription | `default_message_ttl: P7D` | `7d` | Rejected by the schema (S) |
| 4 | Invented remote-state storage account | `REPLACE_WITH_PLATFORM_STATE_STORAGE_ACCOUNT` | `stmmtmplatformstate01` | Accepted (H). The placeholder warning still appears because the resource group value is a placeholder, so it is easy to miss. |
| 5 | API granted the wrong Service Bus role | `Azure Service Bus Data Sender` | `Azure Service Bus Data Receiver` | Accepted (H) |
| 6 | Function loses its Cosmos DB access | Present in `access:` | Removed | Accepted (H) |
| 7 | Function max instances in dev too high | `dev: 40` | `dev: 100` | Accepted (H) |
| 8 | Unknown attribute in a `from:` setting | `cosmosdb_account.endpoint` | `cosmosdb_account.uri` | Rejected by the semantic check (G) |
| 9 | Wrong size format on the container app | `memory: 1Gi` | `memory: 1GB` | Rejected by the schema (S) |

Summary for the debrief: of nine problems, the generator catches three (two by schema, one by a semantic check) and passes six. Those six are all questions of truth, not shape: values that are well-formed but wrong, or that disagree with the architecture guide.

Flaws 5 and 6 show that the generator cannot know whether the access list matches section 6.3. Flaw 4 is the sneakiest: a plausible invented value that looks like a real convention. If attendees ask how to catch these mechanically, the honest answer is a second control outside the generator, such as a diff against the last approved spec in a pull request.

## Cheat sheet

| Item | Value |
|---|---|
| Repo | `C:\Workshop\FromArchitectureToTerraformWorkshop` (github.com/TaleLearnCode/FromArchitectureToTerraformWorkshop) |
| Kit | `kit\` in the repository |
| Prompt | `/create-infrastructure-spec` |
| Spec produced | `infra\work-item-service.infra.yaml` |
| Reference spec | `tools\terraform-generator\examples\work-item-service\work-item-service.infra.yaml` |
| Generator | `tools\terraform-generator\New-TerraformConfiguration.ps1` |
| Generated Terraform | `infra\terraform` |
| Generator tests | `tools\terraform-generator\tests\Test-Generator.ps1` |
| Extending guide | `guides\extending-the-generator.md` |
| Environments | dev, qa, prd (all East US 2) |
| Resources the generator reports for the reference spec | 17 (18 with the Lab 4 queue) |
| Resources in the reference plan | 32 (per the demo guide) |
