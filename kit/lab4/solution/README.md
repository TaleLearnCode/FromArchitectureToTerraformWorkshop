# Lab 4 solution: `servicebus_queue`

This is a working implementation, tested against the generator in this repository. It changes four places in `tools\terraform-generator`. Compare your work against it; do not copy it over your files unless you are stuck.

| File | Change |
|---|---|
| `Private\ResourceTypes.ps1` | One new row in `$script:ResourceTypes`, after `servicebus_subscription` |
| `Actions\ServicebusQueue.ps1` | New file, defines `New-ServicebusQueueHcl` |
| `schema\infra-spec.schema.json` | `servicebus_queue` added to the type `enum`, plus one new `if`/`then` entry in `allOf` |
| `Private\Spec.ps1` | One new `case` in the `switch ($type)` of `Assert-InfraSpecSemantics`: a queue needs a namespace |

The files here are full copies from the repository version the workshop was built against. If the generator has changed since, apply the four changes by hand rather than overwriting.

`kit\lab4\work-item-service-queue.infra.yaml` is the reference spec with this queue added. Generating from it should create `azurerm_servicebus_queue.work_item_retries` in `main.tf`.
