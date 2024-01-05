LOGFILE="./proxmox_bulk_delete.log"

# Fetch list of VMs and count those with IDs longer than 6 digits
VM_IDS=$(qm list | awk '{if(NR>1)print $1}') # Skip the first row as it usually contains headers.
VM_TO_DELETE_COUNT=0
for VM_ID in $VM_IDS; do
    if [ ${#VM_ID} -gt 6 ]; then
        ((VM_TO_DELETE_COUNT++))
    fi
done

# Display the count and ask for user confirmation
echo "Found $VM_TO_DELETE_COUNT VMs with IDs longer than 6 digits to be deleted."

# Proceed only if user confirms
read -p "Do you want to proceed with the deletion? (yes/no): " confirmation
if [[ $confirmation != [yY][eE][sS] ]]; then
    echo "Deletion process cancelled by user."
    exit 0
fi

# Initialize counters
VM_DELETED_COUNT=0
VM_FAILED_COUNT=0

{
    echo "ProxMox bulk VM deletion process started."

    # Loop through the VM IDs to stop and delete VMs
    for VM_ID in $VM_IDS; do
        if [ ${#VM_ID} -gt 6 ]; then
            echo "Stopping VM with ID: $VM_ID ..."
            qm stop $VM_ID --skiplock 2>/dev/null
            sleep 5  # Allow some time for VM to stop

            echo "Destroying VM with ID: $VM_ID ..."
            if qm destroy $VM_ID 2>/dev/null; then
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
} | tee -a $LOGFILE
