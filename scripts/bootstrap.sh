#!/usr/bin/env bash
set -euo pipefail

INVENTORY="${1:-}"
if [[ -z "$INVENTORY" ]]; then
    echo "Usage: $0 <inventory-name>"
    echo "Example: $0 rhdp-customer-demo"
    exit 1
fi

INVENTORY_PATH="inventories/${INVENTORY}/"
if [[ ! -d "$INVENTORY_PATH" ]]; then
    echo "ERROR: Inventory not found: $INVENTORY_PATH"
    exit 1
fi

# Verify required environment variables
: "${CONTROLLER_HOST:?ERROR: CONTROLLER_HOST not set}"
: "${CONTROLLER_USERNAME:?ERROR: CONTROLLER_USERNAME not set}"
: "${CONTROLLER_PASSWORD:?ERROR: CONTROLLER_PASSWORD not set}"

# Extract Automation Hub token from ansible.cfg if not already set
if [[ -z "${ANSIBLE_GALAXY_TOKEN:-}" ]]; then
    if [[ -f ~/.ansible/ansible.cfg ]]; then
        export ANSIBLE_GALAXY_TOKEN=$(grep -A3 '\[galaxy_server.automation_hub\]' ~/.ansible/ansible.cfg | grep token | cut -d'=' -f2 | tr -d ' ')
    fi
fi

echo "Running bootstrap for inventory: $INVENTORY"
ansible-navigator run playbooks/bootstrap_dev.yml \
  -i "$INVENTORY_PATH" \
  --mode stdout \
  --pull-policy missing
