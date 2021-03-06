#Requires -Version 4.0
#Requires -Modules PrintManagement

<#
.SYNOPSIS
    Sets the properties of an existing printer.
    Only parameters with value are set

.DESCRIPTION

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, AppSphere AG assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of AppSphere AG.
    © AppSphere AG

.COMPONENT
    Requires Module PrintManagement

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/WinPrintManagement/Printers

.Parameter PrinterName
    Specifies the name of the printer to modify

.Parameter ComputerName
    Specifies the name of the computer on which the printer is installed

.Parameter DriverName
    Specifies the name of the printer driver for the printer

.Parameter Shared
    Indicates whether to share the printer on the network

.Parameter ShareName
    Specifies the name by which to share the printer on the network

.Parameter PortName
    Specifies the name of the existing port that is used or created for the printer

.Parameter Comment
    Specifies the text to add to the Comment field for the specified printer

.Parameter Location
    Specifies the location of the printer
    
.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.

.Parameter DataType
    Specifies the data type the printer uses to record print jobs

.Parameter PrintProcessor
    Specifies the name of the print processor used by the printer

.Parameter RenderingMode
    Specifies the rendering mode for the printer

#>
   
[CmdLetBinding()]
Param(
    [Parameter(Mandatory=$true)]
    [string]$PrinterName,
    [string]$ComputerName,
    [string]$DriverName,
    [switch]$Shared,
    [string]$ShareName,
    [string]$PortName,
    [string]$Comment,
    [string]$Location,
    [PSCredential]$AccessAccount,
    [string]$DataType='RAW',
    [string]$PrintProcessor='winprint',
    [ValidateSet('SSR','CSR','BranchOffice')]
    [string]$RenderingMode='SSR'
)

Import-Module PrintManagement

$Script:Cim =$null
$Script:Output=@()
try{
    if([System.String]::IsNullOrWhiteSpace($ComputerName)){
        $ComputerName=[System.Net.DNS]::GetHostByName('').HostName
    }  
    if($null -eq $AccessAccount){
        $Script:Cim =New-CimSession -ComputerName $ComputerName -ErrorAction Stop
    }
    else {
        $Script:Cim =New-CimSession -ComputerName $ComputerName -Credential $AccessAccount -ErrorAction Stop
    }
    $prn=Get-Printer -CimSession $Script:Cim -Name $PrinterName -ComputerName $ComputerName -ErrorAction SilentlyContinue 
    if($null -eq $prn){
        $Script:Output += "Printer $($PrinterName) not found"
    }
    else{
        if($PSBoundParameters.ContainsKey('Shared') -eq $true){
            if([System.String]::IsNullOrWhiteSpace($ShareName)){
                $ShareName=$PrinterName
            }
            Set-Printer -CimSession $Script:Cim -ComputerName $ComputerName -Shared -ShareName $ShareName -Name $PrinterName 
        }
        if($PSBoundParameters.ContainsKey('PrintProcessor') -eq $true){
            Set-Printer -CimSession $Script:Cim -ComputerName $ComputerName -Name $PrinterName -PrintProcessor $PrintProcessor
        }
        if($PSBoundParameters.ContainsKey('Comment') -eq $true){
            Set-Printer -CimSession $Script:Cim -ComputerName $ComputerName -Name $PrinterName -Comment $Comment
        }
        if($PSBoundParameters.ContainsKey('DriverName') -eq $true){
            Set-Printer -CimSession $Script:Cim -ComputerName $ComputerName -Name $PrinterName -DriverName $DriverName
        }
        if($PSBoundParameters.ContainsKey('Location') -eq $true){
            Set-Printer -CimSession $Script:Cim -ComputerName $ComputerName -Name $PrinterName -Location $Location
        }
        if($PSBoundParameters.ContainsKey('Datatype') -eq $true){
            Set-Printer -CimSession $Script:Cim -ComputerName $ComputerName -Name $PrinterName -Datatype $Datatype
        }
        if($PSBoundParameters.ContainsKey('RenderingMode') -eq $true){
            Set-Printer -CimSession $Script:Cim -ComputerName $ComputerName -Name $PrinterName -RenderingMode $RenderingMode
        }
        if($PSBoundParameters.ContainsKey('PortName') -eq $true){
            Set-Printer -CimSession $Script:Cim -ComputerName $ComputerName -Name $PrinterName -PortName $PortName
        }
        $Script:Output += "Printer: $($PrinterName) changed"
    }   
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $Script:Output
    } 
    else {
        Write-Output $Script:Output   
    }    
}
catch{
    Throw 
}
finally{
    if($null -ne $Script:Cim){
        Remove-CimSession $Script:Cim 
    }
}