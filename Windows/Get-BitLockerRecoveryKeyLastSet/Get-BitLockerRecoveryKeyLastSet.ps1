[string]$SearchBase = "OU=example,OU=example,DC=contoso,DC=com"

Try { Import-Module ActiveDirectory -ErrorAction Stop }
Catch { Write-Warning "Unable to load Active Directory module because $($Error[0])"; Exit }

Write-Verbose "Getting Workstations..." -Verbose
$Computers = Get-ADComputer -Filter * -SearchBase $SearchBase -Properties LastLogonDate,Description
$Results = ForEach ($Computer in $Computers)
{
New-Object PSObject -Property @{
        ComputerName = $Computer.Name
        Description = $Computer.Description
        LastLogonDate = $Computer.LastLogonDate
        BitLockerRecoveryKeyLastSet = Get-ADObject -Filter "objectClass -eq 'msFVE-RecoveryInformation'" -SearchBase $Computer.distinguishedName -Properties whenCreated | Sort whenCreated -Descending | Select -First 1 | Select -ExpandProperty whenCreated
    }
}
Write-Progress -Id 0 -Activity " " -Status " " -Completed

$ReportPath = Join-Path (Split-Path $MyInvocation.MyCommand.Path) -ChildPath "BitLockerRecoveryKeyLastSet.csv"
Write-Verbose "Building the report..." -Verbose
$Results | Select ComputerName,Description,LastLogonDate,BitLockerRecoveryKeyLastSet | Sort ComputerName | Export-Csv $ReportPath -NoTypeInformation
Write-Verbose "Report saved at: $ReportPath" -Verbose