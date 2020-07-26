[CmdletBinding(SupportsShouldProcess)]
param(
  [Parameter(Mandatory=$true)]
  [String]$ResourceGroupName,
  
  [Parameter(Mandatory=$true)]
  [String]$ApimInstanceName,
  
  [Parameter(Mandatory=$false)]
  [switch]$RunInteractively
)

# Get apim context
$apimContext = New-AzApiManagementContext -ResourceGroupName $ResourceGroupName -ServiceName $ApimInstanceName

# Get all APIs from context
$apis = [array](Get-AzApiManagementApi -Context $apimContext)

# Enrich all API objects with schema information
$apisWithMultipleSchemas = [array]($apis | ForEach-Object { $_ | Add-Member NoteProperty 'Schemas' @(Get-AzApiManagementApiSchema -Context $apimContext -ApiId $_.ApiId); $_ } | Where-Object { $_.Schemas.Length -gt 1 })

if ($null -eq $apisWithMultipleSchemas){
    Write-Output "No APIs with multiple schemas were found."
    return;
}

# Loop through all APIs with multiple schemas and try to remove redundant ones
$apisWithMultipleSchemas | ForEach-Object {
    $api = $_
    Write-Output "API '$($api.Name)' (id: $($api.ApiId)) has multiple schemas: $($api.Schemas.SchemaId)."

    # Option A - you can use the following cmdlet suppressing the errors as the cmdlet currently won't allow you to delete schemas which are being used.
    # [array]$_.Schemas | ForEach-Object { Remove-AzApiManagementApiSchema -Context $apimContext -ApiId $api.ApiId -SchemaId $_.SchemaId -ErrorAction SilentlyContinue } 

    # Option B - specifically figure out which schemas are safe to delete in case the cmdlet changes behaviour
    $apiOperations = [array](Get-AzApiManagementOperation -Context $apimContext -ApiId $api.ApiId)
    $schemaIdUsedByOperation = [array]($apiOperations.Responses.Representations.SchemaId) + [array]($apiOperations.Request.Representations.SchemaId) | Get-Unique

    [array]$api.Schemas.SchemaId | Where-Object { $_ -notin $schemaIdUsedByOperation } | ForEach-Object {
        if ($RunInteractively){
            Write-Output "Do you want to delete the possibly unused schema id $_ for API '$($api.Name)' (id: $($api.ApiId))?"
            Remove-AzApiManagementApiSchema -Context $apimContext -ApiId $api.ApiId -SchemaId $_ -Confirm
        }
        else {
            Write-Output "Deleting schema id $_ for API '$($api.Name)' (id: $($api.ApiId))."
            Remove-AzApiManagementApiSchema -Context $apimContext -ApiId $api.ApiId -SchemaId $_
        }
    }
}