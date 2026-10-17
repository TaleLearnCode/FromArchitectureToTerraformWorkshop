# servicebus_queue -> azurerm_servicebus_queue
function New-ServicebusQueueHcl {
    param($Context, $Resource)
    $namespace = Get-SingletonAddress $Context 'servicebus_namespace'
    $body = @(
        (New-HclAttr 'name' ('local.names.' + (Get-NameId $Resource)))
        (New-HclAttr 'namespace_id' "$namespace.id")
        (New-HclAttr 'max_delivery_count' (Get-FieldHcl $Context $Resource 'max_delivery_count'))
        (New-HclAttr 'default_message_ttl' (Get-FieldHcl $Context $Resource 'default_message_ttl'))
        (New-HclAttr 'dead_lettering_on_message_expiration' (Get-FieldHcl $Context $Resource 'dead_letter_on_expiration' $true))
    )
    New-HclResource 'azurerm_servicebus_queue' $Resource.Label $body
}
