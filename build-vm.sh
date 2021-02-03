#!/bin/bash

# Do your domain-specific steps here (e.g. accept args for different infrastructures
# and set certain environment variables for Packer to use.)

# ...

# infrastructure specific options and steps
case "$INFRASTRUCTURE" in
  "$INFRA_VMWARE")
    export PACKER_BUILDER="vmware-vmx"
    # ...
  ;;
  "$INFRA_AMAZON")
    export PACKER_BUILDER="amazon-ebs"
    # ...
  ;;
  # ...
esac

# build the vm via packer
cd "${SRC_BASE}/build/packer-storreduce" && packer build -only $PACKER_BUILDER storreduce.json

# special case for vmware builds - convert to ova AFTER packer has run
if [[ "${INFRASTRUCTURE}" == "${INFRA_VMWARE}" ]]; then
  cd "${SCRIPT_DIR}" && ./vmx-to-ova.sh -s "${PACKER_OUTPUT_DIRECTORY}"
fi
