#!/bin/bash

echo "Fetching VM list from ProxMox..."

# Get a list of all VM IDs
VM_IDS=$(qm list | awk '{if(NR>1)print $1}') # Skipping the first row as it's usually headers

# Loop through each VM ID and check if it's greater than 8 digits
for VM_ID in $VM_IDS; do
    # Check if VM_ID has more than 8 digits
    if [ ${#VM_ID} -gt 8 ]; then
        echo "Stopping VM with ID: $VM_ID, if it's running..."
        # Force stop the VM
        qm stop $VM_ID --skiplock 1>/dev/null
        
        # Wait a moment to ensure the VM is stopped
        sleep 5
        
        # Destroy the VM
        echo "Destroying VM with ID: $VM_ID..."
        qm destroy $VM_ID 2>&1
        
        if [ $? -eq 0 ]; then
            echo "VM with ID: $VM_ID has been deleted."
        else
            echo "An error occurred while attempting to delete VM with ID: $VM_ID"
        fi
    fi
done

echo "Bulk deletion of ProxMox VMs with IDs larger than 8 digits completed."
