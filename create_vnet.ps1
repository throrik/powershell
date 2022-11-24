# Create a resource group

$resourceGroup = @{

    Name = 'test-rg'
    Location = 'UKWest'

}

New-AzResourceGroup @resourceGroup 

# Create a vNET

$vNet = @{

    Name = 'test-vNet'
    ResourceGroupName = 'test-rg'
    Location = 'UKWest'
    AddressPrefix = '10.0.0.0/16'

}

New-AZVirtualNetwork @vNet