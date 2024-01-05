#!/bin/bash

echo "Fetching VM list from ProxMox..."

# Get a list of all VMs - extract just the IDs
VM_IDS=$(qm list | awk '{if(NR>1)print $1}') # Skipping the first row as it's usually headers

# Loop through each VM ID and check if it's greater than 8 digits
for VM_ID in $VM_IDS; do
    # Check if VM_ID has more than 8 digits using string length
    if [ ${#VM_ID} -gt 8 ]; then
        echo "Deleting VM with ID: $VM_ID"
        # Shutdown the VM if it's running and wait for the operation to complete
        qm stop "$VM_ID" --skiplock --kill
        
        # Wait a moment to ensure the VM is stopped
        sleep 5
        
        # Destroy the VM
        qm destroy "$VM_ID" --purge
        echo "VM with ID: $VM_ID has been deleted."
    fi
done

echo "Bulk deletion of ProxMox VMs with IDs larger than 8 digits completed."
