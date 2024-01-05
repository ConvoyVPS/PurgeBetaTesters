#!/bin/bash

LOGFILE="/var/log/proxmox_bulk_delete.log"

# Function to count VMs with IDs longer than 6 digits
count_vms() {
    local count=0
    VM_IDS=$(qm list | awk '{if(NR>1)print $1}') # Skipping the first row as it's usually headers
    for VM_ID in $VM_IDS; do
        if [ ${#VM_ID} -gt 6 ]; then
            ((count++))
        fi
    done
    echo $count
}

# Count the VMs to be deleted
VM_TO_DELETE_COUNT=$(count_vms)

# Display the count and ask for user confirmation
echo "Found $VM_TO_DELETE_COUNT VMs with IDs longer than 6 digits to be deleted."
read -p "Do you want to proceed with the deletion? (yes/no): " confirmation

# Check user confirmation
if [[ $confirmation != "yes" ]]; then
    echo "Deletion process cancelled by user."
    exit 0
fi

# Initialize counters
VM_DELETED_COUNT=0
VM_FAILED_COUNT=0

{
    echo "ProxMox bulk VM deletion process started."

    # Loop through each VM ID and check if it's greater than 8 digits
    for VM_ID in $VM_IDS; do
        if [ ${#VM_ID} -gt 6 ]; then
            echo "Stopping VM with ID: $VM_ID..."
            qm stop $VM_ID --skiplock

            # Wait a moment to ensure the VM is stopped
            sleep 5

            # Destroy the VM
            echo "Destroying VM with ID: $VM_ID..."
            if qm destroy $VM_ID; then
                echo "VM with ID: $VM_ID has been successfully deleted."
                ((VM_DELETED_COUNT++))
            else
                echo "Failed to delete VM with ID: $VM_ID."
                ((VM_FAILED_COUNT++))
            fi
        fi
    done

    echo "Bulk deletion completed."
    echo "Total VMs Deleted: $VM_DELETED_COUNT"
    echo "Total VMs Failed: $VM_FAILED_COUNT"
} 2>&1 | tee -a $LOGFILE    # Output to both the console and the log file
