[CmdletBinding(SupportsShouldProcess)]
param(
  [Parameter(Mandatory=$true)]
  [String]$ResourceGroupName,
  
  [Parameter(Mandatory=$true)]
  [String]$ApimInstanceName
)

New-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateFile petstore-api.template.json -TemplateParameterObject @{ ApimServiceName = $ApimInstanceName }
New-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateFile petstore-v2-api.template.json -TemplateParameterObject @{ ApimServiceName = $ApimInstanceName }