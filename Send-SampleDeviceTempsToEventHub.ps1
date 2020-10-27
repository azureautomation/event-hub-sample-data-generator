workflow Send-SampleDeviceTempsToEventHub
{
<#

.SYNOPSIS
Generates sample payloads for temperature sensors and submits to an Azure Event Hub.

.DESCRIPTION
The Send-SampleDeviceTempsToEventHub workflow is a simplified freestanding Event Hub Sample device.
It bypasses the need for using the Azure SDK to generate the signature string, instead just takes the keyname and key 
direct from the Azure Portal UI.

.PARAMETER ehName 
The name of the Event Hub as it appears in the Azure Portal

.PARAMETER ehNamespace
The namespace of the Event Hub as it appears in the Azure Portal 

.PARAMETER keyname
The name of the key from the Azure Portal

.PARAMETER key
The actual access key that gets generated in the Azure Portal

.PARAMETER deviceIdPrefix
The name of the device as it will be logged in the Event Hub.  The device will be suffixed by a number automatically.

.PARAMETER deviceIdStartRange
The name of the device will be suffixed by a number, this is the start of that number range.

.PARAMETER deviceIdEndRange
The name of the device will be suffixed by a number, this is the end of that number range.

.PARAMETER tempStartRange
The sample temperature will be generated randomly in a range, this is the start of the temp range.

.PARAMETER tempEndRange
The sample temperature will be generated randomly in a range, this is the end of the temp range.

.EXAMPLE

Calls the workflow and submits the Event.  NB, My keyname and keys do not exist, so this is not a working sample

Send-SampleDeviceTempsToEventHub -ehName "phonehubclassic" -ehNamespace "phonehubclassic-ns.servicebus.windows.net" -keyname "DeviceWriteKey" -key "AUQl8USs/CM8tuo3tu3jdlrue89OkCQeJZItkbvsGy0=" -deviceIdPrefix "device-" -deviceIdStartRange 1 -deviceIdEndRange 5 -tempStartRange 22 -tempEndRange 45.

.NOTES

Best run inside Azure Automation as a Runbook on a regular schedule

#>

    param([Parameter(Mandatory=$true)]
          [string]
          $ehName,

          [Parameter(Mandatory=$true)]
          [string]
          $ehNamespace ,

          [Parameter(Mandatory=$true)]
          [string]
          $keyname ,

          [Parameter(Mandatory=$true)]
          [string]
          $key,
        
          [Parameter(Mandatory=$true)]
          [string]
          $deviceIdPrefix="device-",

          [Parameter(Mandatory=$true)]
          [int]
          $deviceIdStartRange = 1 ,

          [Parameter(Mandatory=$true)]
          [int]
          $deviceIdEndRange = 5 ,
        
          [Parameter(Mandatory=$true)]
          [float]
          $tempStartRange,
        
          [Parameter(Mandatory=$true)]
          [float]
          $tempEndRange
     )  
    
    function Send-EventHubMessage  
    {  
        param([string]$ehName,
              [string]$ehNamespace ,
              [string]$keyname ,
              [string]$key,
              [string]$jsonMessage)  

       [System.Reflection.Assembly]::LoadWithPartialName("System.web")

        $method = "POST"
        $URI = "https://$ehNamespace/$ehName/messages"
        $encodedURI = [System.Web.HttpUtility]::UrlEncode($URI)

        # Calculate expiry value one hour ahead
        $sinceEpoch = NEW-TIMESPAN –Start $([datetime]”01/01/1970 00:00”) –End ((Get-Date) + $(New-TimeSpan -Hours 1))
        $expiry = [Math]::Floor([decimal]($sinceEpoch.TotalSeconds + 3600))

        # Create the signature
        $stringToSign = $encodedURI + "`n" + $expiry
        $hmacsha = New-Object System.Security.Cryptography.HMACSHA256
        $hmacsha.key = [Text.Encoding]::ASCII.GetBytes($key)
        $signature = $hmacsha.ComputeHash([Text.Encoding]::ASCII.GetBytes($stringToSign))
        $signature = [System.Web.HttpUtility]::UrlEncode([Convert]::ToBase64String($signature))

        # Work out content length
        $contentLength = [Text.Encoding]::ASCII.GetBytes($jsonMessage).length

        # API headers
        $headers = @{
                    "Authorization"="SharedAccessSignature sr=" + $encodedURI + "&sig=" + $signature + "&se=" + $expiry + "&skn=" + $keyname;
                    "Content-Type"="application/atom+xml;type=entry;charset=utf-8";
                    "Content-Length" = "$contentLength"
                    }

        # execute the Azure REST API
        Write-host "Posting $jsonMessage to $URI"
        Invoke-RestMethod -Uri "$URI" -Method $method -Headers $headers -Body $jsonMessage
    }

    
    for($i=$deviceIdStartRange; $i -le $deviceIdEndRange; $i++){
        $deviceId= "$deviceIdPrefix$i"
        $randomTemp = Get-Random -minimum $tempStartRange -maximum $tempEndRange
        Send-EventHubMessage -ehName $ehName -ehNamespace $ehNamespace -keyname $keyname -key $key -jsonMessage "{'DeviceId':'$deviceId', 'Temperature':'$randomTemp'}"
     }    
}

