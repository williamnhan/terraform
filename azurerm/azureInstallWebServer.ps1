#Define CSS for table
$header = @"
<style>
  TABLE {border-width: 2px; border-style: solid; border-color: black; border-collapse: collapse;}
  TH {border-width: 1px; padding: 5px; border-style: solid; border-color: black; background-color: cyan; text-align: left}
  TD {border-width: 1px; padding: 5px; border-style: solid; border-color: black; text-align: left}
</style>
"@

#Install IIS
Install-WindowsFeature -name Web-Server

#Query Azure Instance Metadata service
$metadata = Invoke-RestMethod -Headers @{"Metadata"="true"} -URI http://169.254.169.254/metadata/instance?api-version=2017-08-01 -Method get

#Create object containing data to render 
$body = New-Object System.Collections.ArrayList
$body.Add([pscustomobject] @{"Heading" = "Server Name"; "Data" = $metadata.compute.name}) | Out-Null
$body.Add([pscustomobject] @{"Heading" = "Azure Location"; "Data" = $metadata.compute.location}) | Out-Null
$body.Add([pscustomobject] @{"Heading" = "Resource Group"; "Data" = $metadata.compute.resourceGroupName}) | Out-Null
$body.Add([pscustomobject] @{"Heading" = "Private IP"; "Data" = $metadata.network.interface.ipv4.ipAddress.privateIpAddress}) | Out-Null

#Convert object to HTML and overwrite existing index
$HTML = $body | ConvertTo-Html -Title "WebServer Details"-Head $header
$HTML | Out-File -FilePath "C:\inetpub\wwwroot\index.html" -Force