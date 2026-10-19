# Lab 4: Extend the generator

**Time:** 20 minutes in the workshop (17 hands-on and a 3-minute debrief), 40 to 60 minutes on your own · Part of the [lab guide](../lab-guide.md)

| | |
|---|---|
| **Goal** | See how little it takes to teach the generator a new resource type, and why that is the right place for security defaults. |
| **You will** | Add a Service Bus queue (`servicebus_queue`) to the generator: one table row, one action script, one schema entry, one dependency check. |
| **You need** | The repository, a **PowerShell 7** terminal, and Terraform (for `fmt`, `init`, and `validate`). No Azure subscription is needed. |
| **You will have** | A generator that understands queues, a spec that uses one, generated Terraform that validates, and passing generator tests. |
| **Previous** | [Lab 3](lab03.md) ran the generator and showed what it can and cannot catch. |
| **Next** | [Lab 5](lab05.md) follows a single change through the pipeline. |

Work in the repository root:

```powershell
cd C:\Workshop\FromArchitectureToTerraformWorkshop
```

## Introduction

So far the generator has been a black box that happens to know about Container Apps, Cosmos DB, Service Bus topics, and the rest. But real teams need resource types the generator does not yet support. If every missing type meant waiting for someone to rewrite the tool, the approach would not scale.

It does not need to be a rewrite. The generator is built so a new resource type is a small, mechanical addition in four known places. This lab has you make that addition for a Service Bus queue. The generator already handles topics, and a queue is nearly the same thing, so you can copy and adapt rather than start from nothing.

The larger point is where this knowledge lives. When you add a type, you also decide its security defaults and naming once, in code, for every spec that will ever use it. That is how a team encodes its standards so they apply without anyone remembering them.

## What we are doing

1. Register the new type in the type table.
2. Write the action script that produces its Terraform.
3. Add schema rules so a bad queue entry fails loudly.
4. Add a dependency check: a queue needs a Service Bus namespace.
5. Add a queue to a spec, generate, and validate the result.
6. Run the generator's own tests.

## Background

**Where changes go.** The same four places each time:

| Step | File |
|---|---|
| 1. Register the type | `tools\terraform-generator\Private\ResourceTypes.ps1` |
| 2. Write the action | `tools\terraform-generator\Actions\ServicebusQueue.ps1` |
| 3. Add schema rules | `tools\terraform-generator\schema\infra-spec.schema.json` |
| 4. Add a dependency check | `Assert-InfraSpecSemantics` in `tools\terraform-generator\Private\Spec.ps1` |

**Convention over configuration.** The generator finds an action by name. A type called `servicebus_queue` is handled by a function `New-ServicebusQueueHcl` in a file `Actions\ServicebusQueue.ps1`. If the file name or function name does not match, the generator will not find it. The most common mistake in this lab is a misspelled name.

**Helpers.** The action scripts share small helper functions, such as `New-HclAttr` (one attribute), `Get-FieldHcl` (a field from the spec), `Get-SingletonAddress` (the address of a resource there is only one of, such as the namespace), and `New-HclResource` (the resource block). Reuse them. Copy a working action and change as little as possible.

**A reference to compare with.** `kit\lab4` holds a ready-made spec and a working solution. The repository's [`guides\extending-the-generator.md`](../../guides/extending-the-generator.md) walks through this very example. Try it yourself first and open them only if you get stuck. Opening the solution is a normal choice, not a failure; this lab has the steepest learning curve in the workshop.

## Steps

1. **Register.** In `ResourceTypes.ps1`, add a row to `$script:ResourceTypes`:

   ```powershell
   servicebus_queue = @{ Terraform = 'azurerm_servicebus_queue'; Abbreviation = ''; Keyed = $true; Component = $false }
   ```

2. **Write the action.** Copy `Actions\ServicebusTopic.ps1` to `Actions\ServicebusQueue.ps1`. Rename the function to `New-ServicebusQueueHcl`, keep `param($Context, $Resource)`, and change the Terraform type and arguments. A queue needs a name, the namespace, `max_delivery_count`, and `default_message_ttl`. Reuse the helpers the topic script uses (`New-HclAttr`, `Get-FieldHcl`, `Get-SingletonAddress`, `New-HclResource`). The function name must match the file name; the generator finds actions by that rule.
3. **Schema.** In `infra-spec.schema.json`, add `servicebus_queue` to the `enum` of resource types, and add an `if`/`then` entry under `allOf`. Copy the topic's entry and adapt it: `key`, `max_delivery_count` (integer, at least 1), and `default_message_ttl` (ISO 8601 duration) are required. Keep `"additionalProperties": false` so a misspelled field fails loudly.
4. **Dependency check.** In `Assert-InfraSpecSemantics`, add a case for `servicebus_queue` that requires a `servicebus_namespace` in the spec.
5. **Try it.** Copy your spec to `infra\work-item-service-queue.infra.yaml` and add this resource under `resources:`, for example, after the `audit` subscription (indented like its neighbors):

   ```yaml
     - type: servicebus_queue
       key: work-item-retries
       max_delivery_count: 5
       default_message_ttl: P1D
   ```

   `kit\lab4\work-item-service-queue.infra.yaml` is a ready-made copy if you want to skip editing. A queue needs no reference to the namespace; the action finds it. Generate:

   ```powershell
   .\tools\terraform-generator\New-TerraformConfiguration.ps1 -SpecPath .\infra\work-item-service-queue.infra.yaml -OutputPath .\infra\terraform-queue
   ```

6. Confirm `main.tf` contains `azurerm_servicebus_queue "work_item_retries"` and the summary says `Generated 18 resources`. Then:

   ```powershell
   cd .\infra\terraform-queue
   terraform fmt -check
   terraform init
   terraform validate
   cd ..\..
   ```

7. Run the generator's own tests:

   ```powershell
   .\tools\terraform-generator\tests\Test-Generator.ps1
   ```

### What you should see

After step 5, the generator reports `Spec OK` and `Generated 18 resources`, one more than the 17 in the reference spec. Searching `infra\terraform-queue\main.tf` for `servicebus_queue` should find a block named `work_item_retries`, with the queue name built from the same naming pattern as every other resource and the namespace attached by reference, not by a hard-coded name. In step 6, `terraform fmt -check` prints nothing if the formatting is clean, and `validate` prints `Success! The configuration is valid.` The tests may include a check that compares committed example output with the output of a fresh run; if one fails only because of a missing example folder, that is not caused by your change.

When something fails, the message usually points at the cause:

- An error saying the type is unknown means step 1 or the schema `enum` in step 3 is missing.
- An error about a missing function means the function or file name does not match (step 2).
- A schema error naming a field means a field in your YAML or schema entry is spelled differently.
- A dependency error means the semantic check in step 4 fired, which is the point of that check.

## The lesson

Adding a type took one table row, one script, one schema entry, and one check. None of that involved AI, and none of it is large. That is the design working: the generator's surface for extension is deliberately small and regular, so the people who own a standard can encode it without understanding the whole tool.

Look at what your action script decided *for* every future spec: the naming pattern, the namespace it attaches to, which settings are fixed and which are tunable. Anything security-relevant belongs here, in the script, not in the spec. If it lived in the spec, each author (or each AI run) would have to remember it, and sooner or later someone would not. Put it in the script, and it holds for every service that uses the type.

This is also the answer to "what do we do about resource types we do not support yet?" You add them, deliberately, with a test, once.

## Notice

> Adding a type was one script plus one schema entry. Nothing about it needed AI. Which of your team's standards would you encode this way?

## Check your understanding

<details>
<summary>1. Why must the action's file name and function name match the type?</summary>

The generator locates actions by a naming rule rather than a registry. `servicebus_queue` becomes `ServicebusQueue.ps1` and `New-ServicebusQueueHcl`. The rule keeps adding a type mechanical, but a misspelling means the action is silently never found.
</details>

<details>
<summary>2. Why keep <code>"additionalProperties": false</code> in the schema?</summary>

So a misspelled or unsupported field is an error instead of being ignored. Without it, a typo such as `max_delivery_cout` would pass validation, be dropped, and leave the queue with a default nobody chose.
</details>

<details>
<summary>3. Why add a dependency check when the action already looks up the namespace?</summary>

The check turns a confusing failure at generation time into a clear failure at spec time: "a queue needs a namespace." Catching it early, with a message written for the person editing the spec, is the whole value.
</details>

<details>
<summary>4. Where should a security default such as "disable local authentication" live: in the spec or the action script?</summary>

In the action script. Written once in code, it applies to every spec and cannot be forgotten or varied. A default that must be repeated in every spec depends on every author, human or AI, remembering it every time.
</details>

## Troubleshooting

| Problem | What to do |
|---|---|
| "No action found" or similar for `servicebus_queue` | Check that the file is `Actions\ServicebusQueue.ps1` and the function is exactly `New-ServicebusQueueHcl`. |
| A schema error about an unknown type | Add `servicebus_queue` to the `enum` in `infra-spec.schema.json`. |
| A schema error naming a field | Compare your YAML field names with your schema entry. The error includes the field path, such as `/resources/9/max_delivery_count`. |
| A "term is not recognized" error from PowerShell | A helper function name is misspelled. Copy names from `ServicebusTopic.ps1` rather than typing them. |
| `Generated 17 resources`, not 18 | The queue entry is missing or not under `resources:`. Check the indentation, because YAML is strict. |
| `terraform fmt -check` lists a file | The generated file is not canonically formatted. Run `terraform fmt` in the folder to see the change, and treat it as a finding about the action script's output. |
| Test-Generator reports failures | Compare with the baseline. Failures that exist without your change are not yours. For anything new, compare your files with `kit\lab4\solution`. |
| You are stuck | Compare with `kit\lab4\solution`, or read `guides\extending-the-generator.md`. |

## Go further

- **Misspell a field.** Change `max_delivery_count` to `max_delivery_cout` in the spec and read the error. Why does that failure matter?
- **Remove the namespace.** Delete the `servicebus_namespace` from a copy of the spec and watch your dependency check fire.
- **Make a value per-environment.** Make `max_delivery_count` vary by environment (`dev` / `qa` / `prd`). Add it to `$script:TunableFields` and allow the per-environment form in the schema, as the existing tunable fields do.
- **Audit your defaults.** Look at your action script for any security defaults so that.. Where should it live: in the spec, or in the script? Why?
- **Pick a type of your own.** Which resource type does your team use most that the generator does not know? Sketch the four changes it would need.

## Doing this lab on your own

You do not need a facilitator. Allow 40 to 60 minutes, and more if PowerShell is new to you. Work through the four changes in order, generating after each step if you like. Use `kit\lab4\solution` and `guides\extending-the-generator.md` freely: the aim is to understand how an extension fits together, not to prove you can write it unaided. When you are done, continue to [Lab 5](lab05.md).

---

[← Lab 3](lab03.md) · [Lab guide](../lab-guide.md) · [Lab 5 →](lab05.md)
