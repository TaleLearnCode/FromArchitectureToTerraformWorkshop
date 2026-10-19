# Workshop Slide Outline

**From Architecture to Terraform: A Hands-On Workshop (2 hours)**

All clock times assume a **10:00 AM start**. If your start time differs, shift every time by the same amount; the durations do not change.

## How the slides are used

The deck has three kinds of slides: **talk** slides you present, **lab** slides that stay on screen while attendees work, and **debrief** slides you use to run each discussion. Every lab slide carries two times: when hands-on work ends and when the lab block ends. The gap between them is the debrief.

| Clock | Block | Slides | Lab hands-on ends | Block ends |
|---|---|---|---|---|
| 10:00 | Opening and setup check | 1 to 7 | | 10:10 |
| 10:10 | Lab 1: Break determinism | 8, 9 | 10:22 | 10:25 |
| 10:25 | Lab 2: Architecture to YAML, and inspect it | 10, 11 | 10:46 | 10:50 |
| 10:50 | Lab 3: Deterministic generation | 12, 13 | 11:07 | 11:10 |
| 11:10 | Break | 14 | | 11:15 |
| 11:15 | Lab 4: Extend the generator | 15, 16 | 11:32 | 11:35 |
| 11:35 | Lab 5: Watch a change flow through | 17, 18 | 11:47 | 11:50 |
| 11:50 | Wrap-up | 19 to 22 | | 12:00 |

Total: 22 slides.

## Design notes

- Keep lab slides sparse and large: a title, the goal, the finish times, and a short "if you're stuck" line. Attendees read them from across a room while working.
- Use the same layout for all five lab slides so the finish time is always in the same corner.
- Put a small footer on lab slides: "Fallbacks: the repository's `kit` folder".
- Consider a visible clock or countdown on lab slides. If your slide tool cannot do one, keep the finish times large instead.

---

## Opening (10:00 to 10:10)

### Slide 1: Title

**From Architecture to Terraform: A Hands-On Workshop**
Letting AI do the boring parts

Name, handle, event, and date.

*Speaker notes (30 seconds).* Welcome. Today is not a talk. You will do five short labs, and each one ends with a debrief. Expect to have code running in under fifteen minutes.

### Slide 2: Two weeks for every new service

Big number: **2 weeks** to build infrastructure for each new service.

- Developers waiting with nowhere to deploy
- The same Terraform patterns rewritten each time
- Review gates on every build

*Speaker notes (45 seconds).* The value stream mapping story. Most new services needed the same components, yet each one took about two weeks. The bottleneck was human assembly work, not technology.

### Slide 3: The bold claim, and the prototype that worked

Two panels: **"Two weeks to two days"** and **Architecture docs, AI, Terraform: it worked.**

- AI read the architecture and chose our opinionated modules
- The output passed `validate` and `tflint` on the first run

*Speaker notes (60 seconds).* The claim, the silence in the room, and the prototype that appeared to prove it. Let the success land; the next slide breaks it.

### Slide 4: Then we ran it again

Side-by-side: **Run 1** and **Run 2**, same input, same prompt, same model.

Labels on the differences: naming, ordering, structure, tags.

*Speaker notes (45 seconds).* Same input, different Terraform. Both versions were plausible. Neither was reproducible. You cannot review a diff that changes with no change in intent. This is what you will see for yourselves in Lab 1.

### Slide 5: The model we landed on

Diagram: **Architecture, then AI (interpretation), then YAML (the contract), then PowerShell (generation), then Terraform.**

Caption: AI handles fuzzy work. Scripts handle deterministic work. Engineers handle judgment.

*Speaker notes (90 seconds).* The two-stage pipeline. AI reads human-written architecture and fills a structured spec. A script turns the spec into Terraform, the same way every time. Engineers review at two gates: the YAML and the plan. Say this slide out loud once and move on; the labs teach it.

### Slide 6: Today's plan

A timeline with clock times:

| Clock | Lab |
|---|---|
| 10:10 | Lab 1: Break determinism |
| 10:25 | Lab 2: Architecture to YAML, and inspect it |
| 10:50 | Lab 3: Deterministic generation |
| 11:10 | Break |
| 11:15 | Lab 4: Extend the generator |
| 11:35 | Lab 5: Watch a change flow through |
| 11:50 | Wrap-up |
| 12:00 | Done |

Footer: Each lab ends with a short debrief. Fallbacks are normal.

*Speaker notes (30 seconds).* How the workshop works: short labs, a "Notice" box in each, a debrief after each. Using a fallback file is fine; nobody should be stuck.

### Slide 7: Setup check

**10:05 to 10:10.** Run the preflight script. Every line should say OK.

Show the checklist in short form:

- PowerShell 7, Git, Terraform, TFLint, `powershell-yaml`
- Repo cloned (the fallback kit is inside it)
- AI assistant in agent mode (or fallbacks)
- Azure signed in (optional: otherwise stop after `tflint`)

Footer: Missing something? Pair with a neighbor.

*Speaker notes (5 minutes).* Paste the preflight script on screen. Walk the room. Pair anyone with a MISSING line. State the Azure rule once: with a subscription, you run `terraform plan`; without one, you stop after `init`, `validate`, and `tflint`.

---

## Lab 1: Break determinism (10:10 to 10:25)

### Slide 8: Lab 1 (stays up during the lab)

**Lab 1: Break determinism**

- **Hands-on ends 10:22**
- **Block ends 10:25**

Goal: see for yourself why "ask AI for the Terraform" doesn't work for governed infrastructure.

Steps in one line each: run the same prompt twice in fresh chats, then diff the two outputs.

Footer: No AI? Use `kit\lab1-fallback`.

### Slide 9: Lab 1 debrief (10:22 to 10:25)

Questions:

1. What differed between the two runs?
2. Is either one wrong?
3. What does this do to a pull request, an audit, a rollback?

Takeaway line: *The output was fine. It was not reproducible.*

*Speaker notes.* Collect the differences on a board or flip chart: names, ordering, tags, comments, structure.

---

## Lab 2: Architecture to YAML, and inspect it (10:25 to 10:50)

### Slide 10: Lab 2 (stays up during the lab)

**Lab 2: Architecture to YAML, and inspect it**

- **Hands-on ends 10:46**
- **Block ends 10:50**

Goal: give the AI the job it is good at, then review its work like an engineer.

Parts: **A** run the prompt, **B** inspect your YAML with the checklist, **C** calibrate on the flawed spec (if time allows).

Footer: No AI? Copy the reference spec. Checklist: `workshop\labs\lab02.md`.

### Slide 11: Lab 2 debrief (10:46 to 10:50)

Questions:

1. How many problems did machine-style checks cover? How many needed a human?
2. Which kind worried you most?
3. What would make your team trust this review?
4. Where would this review gate sit in your process?

Takeaway line: *A clean result is a valid result, if you can say how you know.*

*Speaker notes.* Tally findings by type on the board. Tell them Lab 3 will show how many problems the machine finds. Be honest about slide-32 style claims: AI does not produce byte-identical YAML twice; what stays stable is the structure.

---

## Lab 3: Deterministic generation (10:50 to 11:10)

### Slide 12: Lab 3 (stays up during the lab)

**Lab 3: Deterministic generation**

- **Hands-on ends 11:07**
- **Block ends 11:10**

Goal: run the code half of the pipeline, prove it repeatable, then see what the machine catches that you missed.

Parts: **A** generate, **B** run it twice and check `git status`, **C** `init`, `validate`, `tflint`, `plan`, **D** run the flawed spec until it passes.

Footer: No Azure subscription? Stop after `tflint`.

### Slide 13: Lab 3 debrief (11:07 to 11:10)

Questions:

1. Which problems did the machine catch, and which did only a human catch?
2. The schema checks the shape of the contract. What checks whether it is true?
3. What changes about review when the next step is deterministic?

Takeaway line: *The generator is happy with six of nine flaws. Review is your job.*

*Speaker notes.* Show the six flaws that passed. Let the room sit with the fact that the output is valid Terraform containing wrong values.

---

## Break (11:10 to 11:15)

### Slide 14: Break

**Break. Back at 11:15.**

Footer: Missing a spec or a failed `terraform init`? Copy the reference spec and regenerate so Lab 4 has a working base.

---

## Lab 4: Extend the generator (11:15 to 11:35)

### Slide 15: Lab 4 (stays up during the lab)

**Lab 4: Extend the generator**

- **Hands-on ends 11:32**
- **Block ends 11:35**

Goal: add a new resource type, a Service Bus queue.

Four touch points, shown as a row: **type table, action script, schema, dependency check.**

Footer: Stuck? Compare against `kit\lab4\solution`.

### Slide 16: Lab 4 debrief (11:32 to 11:35)

Questions:

1. How much of this needed AI?
2. Why do security defaults live in the script instead of the spec?
3. Which standard on your team would you encode this way first?

Takeaway line: *One script plus one schema entry. No AI required.*

---

## Lab 5: Watch a change flow through (11:35 to 11:50)

### Slide 17: Lab 5 (stays up during the lab)

**Lab 5: Watch a change flow through**

- **Hands-on ends 11:47**
- **Block ends 11:50**

Goal: see what a diff means when the pipeline is deterministic.

Steps in one line each: save a copy of the output, change one value in the YAML, regenerate, diff.

Footer: Hint: ignore the hash header with `git diff --no-index -I '# Source:'`.

### Slide 18: Lab 5 debrief (11:47 to 11:50)

Questions:

1. After setting aside the hash header, how many files changed?
2. How big was the diff?
3. Could a reviewer approve this in one minute?

Takeaway line: *Diffs now reflect intent, not AI variation.*

---

## Wrap-up (11:50 to 12:00)

### Slide 19: Where this fits on your team (11:50 to 11:55)

Worksheet prompts, one per line:

- Which architecture documents could a machine read today?
- Which Terraform patterns do you rewrite most?
- Which standards would become generator defaults?
- What would your spec need to capture that this one does not?
- Where does the human review gate sit?
- What is the smallest first slice for the next 30 days?

Footer: Five minutes on your own, then discuss with a neighbor.

### Slide 20: Discussion (11:55 to 11:58)

Two questions to talk through:

1. What is the smallest first slice you could try in 30 days?
2. Which of your standards would become a generator default?

*Speaker notes.* Take two or three answers from the room. Resist giving advice; let attendees hear each other.

### Slide 21: What to remember

Three lines:

- **AI handles the fuzzy work.**
- **Scripts handle the deterministic work.**
- **Engineers handle judgment.**

Below, smaller: *AI didn't replace the platform engineers. It replaced the boring parts.*

### Slide 22: Take it home (11:58 to 12:00)

- Repo: `github.com/TaleLearnCode/FromArchitectureToTerraformWorkshop`
- `guides\adapting-to-your-service.md`: apply this to your own service
- `guides\extending-the-generator.md`: add more resource types
- Your contact details and a link to feedback

*Speaker notes.* Thank the room. Remind them to clean up with `Remove-Item .\infra -Recurse -Force`.

---

## Reuse from the original talk

If you are building the deck from your existing slides, these map well:

| Workshop slide | Original talk slides |
|---|---|
| 2 | 2, 3 (the problem and value stream map) |
| 3 | 4, 7, 10 (the claim and the prototype) |
| 4 | 13, 14 (running the same architecture again) |
| 5 | 23, 29 (the new model and the breakthrough) |
| 21 | 29, 36 (final message) |

Slides 8 through 20 are new.
