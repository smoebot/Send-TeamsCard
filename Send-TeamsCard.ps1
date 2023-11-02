#requires -version 5
<#
.SYNOPSIS
  Publishes Adaptive cards to Microsoft Teams Webhooks
.DESCRIPTION
  Publishes Adaptive cards to Microsoft Teams Webhooks
.PARAMETER <Parameter_Name>
  None at this stage
.NOTES
  Author: Joel Ashman
  v0.1 - (2023-08-09) Initial version
  Potential to add parameter and call specific 

# type - Must be set to "message".
# attachments - This is the container for the adaptive card itself.
# contentType - Must be of the type `application/vnd.microsoft.card.adaptive`.
# content - The header and content of the adaptive card.
    # $schema - Must have a value of [`http://adaptivecards.io/schemas/adaptive-card.json`](<http://adaptivecards.io/schemas/adaptive-card.json>) to import the proper schema for validation.
    # type - Set to the type of "AdaptiveCard".
    # version - Currently set to version "1.2".
# body - The content of the card itself to display.
# Columns Options:
    # width - This can be of the type "auto" or "stretch". Stretch means that it will expand to fill the available container width whereas auto only expands to the content itself.
# FactSet Options:
    # title - The title of the fact to display, in bold.
    # value - The associated value of the fact.

# When in doubt, use the resource at https://adaptivecards.io/designer/ to build your card.  You'll likely need to replace everything in the "body": [ ] section

.EXAMPLE
  <Example explanation goes here>
#>

#---------------------------------------------------------[Script Parameters]------------------------------------------------------

#Param (
  #Script parameters go here
#)

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

#Set Error Action to Silently Continue
$ErrorActionPreference = 'SilentlyContinue'

#Import Modules & Snap-ins

#----------------------------------------------------------[Declarations]----------------------------------------------------------
# This is not secure.  Anyone with access to this webhook can POST to this WebHook
$WebhookUrl = "<webhook-url-goes-here>"
$LocalDateTime = Get-Date -format s
$UtcDateTime = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ss')

# Perhaps build some variables here for $AlertTextTitle, $AlertTextDescription $AlertTextSummary

#-----------------------------------------------------------[Execution]------------------------------------------------------------

# type - Must be set to `message`.
# attachments - This is the container for the adaptive card itself.
# contentType - Must be of the type `application/vnd.microsoft.card.adaptive`.
# content - The header and content of the adaptive card.
# $schema - Must have a value of [`http://adaptivecards.io/schemas/adaptive-card.json`](<http://adaptivecards.io/schemas/adaptive-card.json>) to import the proper schema for validation.
# type - Set to the type of `AdaptiveCard`.
# version - Currently set to version `1.0`.
# body - The content of the card itself to display.

# Columns Options:
# width - This can be of the type "auto" or "stretch". Stretch means that it will expand to fill the available container width whereas auto only expands to the content itself.

# FactSet Options:
# title - The title of the fact to display, in bold.
# value - The associated value of the fact.

# Build the JSON payload in standard in powershell style JSON. 

$JsonPayload = [ordered]@{  
    type = "message"  
    attachments =@(  
        @{  
            contentType = "application/vnd.microsoft.card.adaptive"  
            contentUrl = "null"  
            content = @{  
                "$schema" = "http://adaptivecards.io/schemas/adaptive-card.json"  
                type = "AdaptiveCard"  
                version = "1.2"  
                msteams = @{
                    width = "Full"
                }
                body = @(
                    @{
                        type = "TextBlock"
                        weight = "Bolder"
                        text = "Meaningful Alert Title"
                        style = "heading"
                        wrap = "true"
                        size = "ExtraLarge"
                    },
                    @{
                        type = "ColumnSet"
                        columns = @(
                            @{
                                type = "Column"
                                width = "auto"
                                items = @(
                                    @{
                                        type = "Image"
                                        style = "default"
                                        url = "<logo-file-path>"
                                        altText = "Logo"
                                        size = "Large"
                                    }
                                )
                            },
                            @{
                                type = "Column"
                                width = "stretch"
                                items = @(
                                    @{
                                        type = "TextBlock"
                                        weight = "Bolder"
                                        text = "Alert Creation Time"
                                        wrap = "true"
                                    },
                                    @{
                                        type = "TextBlock"
                                        spacing = "None"
                                        text = "Local: $($LocalDateTime)"
                                        isSubtle = "true"
                                    }
                                    @{
                                        type = "TextBlock"
                                        spacing = "None"
                                        text = "UTC: $($UtcDateTime)"
                                        isSubtle = "true"
                                        wrap = "true"
                                    }
                                )
                            }
                        )
                    },
                    @{
                        type = "TextBlock"
                        text = "Alert Description - Brief meaningful headline description or information"
                        wrap = "true"
                        weight = "Bolder"
                        size = "Large"
                    },
                    @{
                        type = "TextBlock"
                        text = "Alert Summary - More details or verbose information.  `r`nThis could include detail like a link to a wiki, a playbook, or a some technical detail about the alert"
                        wrap = "true"
                        size = "Default"
                    },
                    @{
                        type = "FactSet"
                        facts = @(
                            @{
                                title = "Relevant Parameter:"
                                value = "eg - username"
                            },
                            @{
                                title = "Relevant Parameter:"
                                value = "eg - asset name"
                            }
                        )
                    }
                )  
             }  
        }  
    )  
} | ConvertTo-Json -Depth 20

$Parameters = @{
  "URI"         = $WebhookUrl
  "Method"      = 'POST'
  "Body"        = $JsonPayload
  "ContentType" = 'application/json'
}

Invoke-RestMethod @Parameters
