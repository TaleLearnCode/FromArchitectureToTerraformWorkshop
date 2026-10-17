# Lab 4: Extend the generator

**Time:** 20 minutes · Part of the [lab guide](../lab-guide.md)

Work in the repository root in a **PowerShell 7** terminal:

```powershell
cd C:\Workshop\FromArchitectureToTerraformWorkshop
```

Keep the "Notice" box in mind; we will ask about it in the debrief.

**Goal:** see how little it takes to teach the generator a new resource type, and why that is the right place for security defaults.

You will add a **Service Bus queue** (`servicebus_queue`). The generator already knows topics; a queue is nearly the same.

## Where changes go

| Step | File |
|---|---|
| 1. Register the type | `tools\terraform-generator\Private\ResourceTypes.ps1` |
| 2. Write the action | `tools\terraform-generator\Actions\ServicebusQueue.ps1` |
| 3. Add schema rules | `tools\terraform-generator\schema\infra-spec.schema.json` |
| 4. Add a dependency check | `Assert-InfraSpecSemantics` in `tools\terraform-generator\Private\Spec.ps1` |

The `kit\lab4` folder has a ready-made spec and a working solution to compare against. The repo's [`guides\extending-the-generator.md`](../../guides/extending-the-generator.md) walks through this very example. Try it yourself first and open the guide only if you get stuck.

## Steps

1. **Register.** In `ResourceTypes.ps1`, add a row to `$script:ResourceTypes`:

   ```powershell
   servicebus_queue = @{ Terraform = 'azurerm_servicebus_queue'; Abbreviation = ''; Keyed = $true; Component = $false }
   ```

2. **Write the action.** Copy `Actions\ServicebusTopic.ps1` to `Actions\ServicebusQueue.ps1`. Rename the function to `New-ServicebusQueueHcl`, keep `param($Context, $Resource)`, and change the Terraform type and arguments. A queue needs a name, the namespace, `max_delivery_count`, and `default_message_ttl`. Reuse the helpers the topic script uses (`New-HclAttr`, `Get-FieldHcl`, `Get-SingletonAddress`, `New-HclResource`). The function name must match the file name; the generator finds actions by that rule.
3. **Schema.** In `infra-spec.schema.json`, add `servicebus_queue` to the `enum` of resource types, and add an `if`/`then` entry under `allOf`. Copy the topic's entry and adapt it: `key`, `max_delivery_count` (integer, at least 1), and `default_message_ttl` (ISO 8601 duration) are required. Keep `"additionalProperties": false` so a misspelled field fails loudly.
4. **Dependency check.** In `Assert-InfraSpecSemantics`, add a case for `servicebus_queue` that requires a `servicebus_namespace` in the spec.
5. **Try it.** Copy your spec to `infra\work-item-service-queue.infra.yaml` and add this resource under `resources:`, for example after the `audit` subscription (indented like its neighbors):

   ```yaml
     - type: servicebus_queue
       key: work-item-retries
       max_delivery_count: 5
       default_message_ttl: P1D
   ```

   `kit\lab4\work-item-service-queue.infra.yaml` is a ready-made copy if you want to skip the editing. A queue needs no reference to the namespace; the action finds it. Generate:

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

## Stretch goals (if you finish early)

- Misspell `max_delivery_count` in the spec and see the error. Why does that failure matter?
- Remove the `servicebus_namespace` from a copy of the spec and watch your dependency check fire.
- Make `max_delivery_count` vary by environment (`dev` / `qa` / `prd`). Add it to `$script:TunableFields` and allow the per-environment form in the schema, as the existing tunable fields do.
- Look at your action script for any security default. Where should it live: in the spec, or in the script? Why?

> **Notice.** Adding a type was one script plus one schema entry. Nothing about it needed AI. Which of your team's standards would you encode this way?

---

[← Lab 3](lab03.md) · [Lab guide](../lab-guide.md) · [Lab 5 →](lab05.md)
