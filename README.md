# Azure API Management - redundant schema removal

## Issue
When deploying ARM templates of APIs to Azure API Management, schemas are not replaced as they are just added. So if there has been any changes causing the schema id (type `Microsoft.ApiManagement/service/apis/schemas`) to change there will be a redundant schema "hanging around" causing issues like:

* When exporting the Swagger/OpenAPI definition you will lose some information and will see an attribute/message similar to this in the exported yaml/json definition: `
"x-ms-export-notes": ["Definitions/body parameters are not exported since this API references multiple schemas with OpenAPI components as opposed to one. Schemas referenced: 4f1dbdabb6c3ea11cc9fd20f,5f1dbdabb6c3ea11cc9fd20e"]`

## Solution
A suggestion for solving this is to clean up the redundant and/or duplicate schemas as a part of your deployment pipeline. You can do this by using the powershell sdk, use the az cli, and/or use the API.

### Powershell script - AT YOUR OWN RISK
The [script](src/apim-remove-redundant-schemas.ps1) is pretty straight forward - fetches the APIs for the instance; checks for multiple schemas pr API; and then deletes redundant schemas.
Note that there is an optional `RunInteractively` parameter which will prompt you whether you really want to delete the individual schema(s) or not. (This flag should obviously not be used in a deployment pipeline.)

#### Example usage
``` apim-remove-redundant-schemas.ps1 -ResourceGroupName "api-management-rg" -ApimInstanceName "my-apim-instance" -RunInteractively```

#### Responsibility
No responsibility is taken by the author(s), you are responsible for proofreading whatever code you take into your own test and/or production environments.

## License
Free use - no attribution or other requirements. But if you see any errors or room for improvements, feedback and pull requests are always appreciated.