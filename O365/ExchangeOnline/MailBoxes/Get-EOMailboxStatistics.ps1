﻿#Requires -Version 4.0

<#
    .SYNOPSIS
        Connect to Exchange Online and retrieves the mailbox statistics for the mailbox of the user
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, AppSphere AG assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of AppSphere AG.
        © AppSphere AG

    .COMPONENT       
        ScriptRunner Version 4.x or higher

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/ExchangeOnline/MailBoxes

    .Parameter MailboxId
        Specifies the Alias, Display name, Distinguished name, SamAccountName, Guid or user principal name of the Mailbox from which to get statistics

    .Parameter Archive
        Specifies whether to return mailbox statistics for the archive mailbox associated with the specified mailbox
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$MailboxId,
    [switch]$Archive
)

#Clear
#$ErrorActionPreference='Stop'

try{
    $box = Get-Mailbox  -Identity $MailboxId
    if($null -ne $box){
        $res = Get-MailboxStatistics -Identity $MailboxId -Archive:$Archive 
        if($SRXEnv) {
            $SRXEnv.ResultMessage = $res
        } 
        else{
            Write-Output $res 
        }
    }
    else{
        if($SRXEnv) {
            $SRXEnv.ResultMessage = "Mailbox not found"
        } 
        Throw  "Mailbox not found"
    }
}
finally{
    
}