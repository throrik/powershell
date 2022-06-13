# Please remember to connect to the correct vCenter First

# Location of the script, and CSV file:
$scriptLocation = "LOCATIONPATH"

$iscsitargets = ‘10.x.x.x',
                '10.x.x.x',
                '10.x.x.x',
                '10.x.x.x'

# Import CSV with hosts you want to add iSCSI targets to
Import-Csv $scriptLocation/PATHTOCSV.csv |

ForEach-Object {

    $esxihost = $_.esxihost

    $hbahost = Get-VMHost $esxihost | Get-VMHostHba -type iscsi

    foreach ($TargetIP in $iscsitargets) {
    
            New-IScsiHbaTarget -IScsiHba $hbahost -Address $TargetIP

   }

}

