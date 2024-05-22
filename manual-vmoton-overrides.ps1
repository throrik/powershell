Import-Module VMware.PowerCLI

Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false

$vCenterServer = "vCenter_FQDN"
$credential = Get-Credential
Connect-VIServer -Server $vCenterServer -Credential $credential

$csvPath = "input.csv"

$vms = Import-Csv -Path $csvPath

# Iterate through each VM listed within the csv file.
foreach ($vm in $vms) {
    $vmName = $vm.VMName

    $vmObject = Get-VM -Name $vmName -ErrorAction SilentlyContinue

    if ($vmObject) {

        # Get the MOB Reference for the VM
        $vmRef = New-Object VMware.Vim.ManagedObjectReference
        $vmRef.Type = 'VirtualMachine'
        $vmRef.Value = $vmObject.ExtensionData.MoRef.Value
        $cluster = Get-Cluster -VM $vmObject

        # Create an override to set vMotion as manual
        $spec = New-Object VMware.Vim.ClusterConfigSpecEx
        $spec.DrsConfig = New-Object VMware.Vim.ClusterDrsConfigInfo
        $spec.DpmConfig = New-Object VMware.Vim.ClusterDpmConfigInfo
        $spec.DrsVmConfigSpec = New-Object VMware.Vim.ClusterDrsVmConfigSpec[] (1)
        $spec.DrsVmConfigSpec[0] = New-Object VMware.Vim.ClusterDrsVmConfigSpec
        $spec.DrsVmConfigSpec[0].Operation = 'add'
        $spec.DrsVmConfigSpec[0].Info = New-Object VMware.Vim.ClusterDrsVmConfigInfo
        $spec.DrsVmConfigSpec[0].Info.Behavior = 'manual'
        $spec.DrsVmConfigSpec[0].Info.Enabled = $true
        $spec.DrsVmConfigSpec[0].Info.Key = $vmRef

        # Apply the configuration to the cluster
        $clusterView = Get-View -Id $cluster.Id
        $modify = $true
        $clusterView.ReconfigureComputeResource_Task($spec, $modify)
        
        Write-Output "vMotion override set to manual for VM: $vmName"
    } else {
        Write-Warning "VM $vmName not found."
    }
}

Disconnect-VIServer -Confirm:$false