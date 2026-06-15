# aap.as.code — Claude Guidelines

## Working with a New AAP Environment

When a user provides a new AAP URL and password, update `docs/dev-environment.md`
with the new values before running anything. This file is excluded from git — never
commit credentials and never share them in chat.

```
docs/dev-environment.md
├── URL      → new AAP instance URL
├── Username → admin (default)
└── Password → provided password
```

## Bootstrapping a Fresh AAP Instance

A fresh AAP instance has none of the required credentials, projects, or job templates.
Run `playbooks/bootstrap_dev.yml` first — it creates the prerequisites automatically.

### Prerequisites (one-time local setup)

Run `/aap-first-time` inside Claude Code to set these up interactively, or configure manually:

- Red Hat Container Registry authentication:
  ```bash
  podman login registry.redhat.io
  # Username: your Red Hat account
  # Password: your Red Hat password or registry token
  ```

- Pull the AAP 2.6 Execution Environment image:
  ```bash
  podman pull registry.redhat.io/ansible-automation-platform-26/ee-supported-rhel9:latest
  ```

- `~/.ansible/ansible.cfg` with a valid Automation Hub token under `[galaxy_server.automation_hub]`
  - Get it from: `console.redhat.com → Automation Hub → Connect to Hub → API token`

- `~/.ansible/secrets2` containing your vault password (single line)

- ansible-navigator installed:
  ```bash
  python3 -m pip install ansible-navigator
  ```

**Note**: Collections are NOT installed locally — they are pre-installed in the EE container image.

### Running the Bootstrap

Each environment gets its own named inventory. Copy the sample and set env vars:

```bash
cp -r inventories/rhdp-sample-demo/ inventories/rhdp-<customer>-<demo>/

export CONTROLLER_HOST=<new AAP URL>
export CONTROLLER_USERNAME=admin
export CONTROLLER_PASSWORD=<new password>

# Run with ansible-navigator
ansible-navigator run playbooks/bootstrap_dev.yml \
  -i inventories/rhdp-<customer>-<demo>/ \
  --mode stdout

# Or use the helper script
./scripts/bootstrap.sh rhdp-<customer>-<demo>
```

The inventory `group_vars/all.yml` resolves all sensitive values at runtime via
env var and file lookups — no secrets are stored in the inventory.

The bootstrap runs inside the Red Hat supported Execution Environment container,
ensuring identical behavior between local development and AAP production execution.

The playbook creates:
- Automation Hub certified and validated credentials
- Galaxy credentials associated with the Default Organization
- Vault credential (name varies by user — reads password from `~/.ansible/secrets2`)
- `aap.as.code` project
- `Setup - AAP - CAC` job template

The bootstrap token is automatically deleted when the playbook completes
(even on failure) to prevent stale token accumulation.

### After Bootstrap — Run Setup

Once bootstrap completes, launch `Setup - AAP - CAC` from AAP to load all
demo configurations via CaC.

## Claude Code Skills

Three skills automate the bootstrap workflow inside Claude Code. Install them once:

```bash
claude plugins marketplace add ericcames/aap-skills
claude plugins install aap-skills
```

| Skill | Command | Purpose |
|-------|---------|---------|
| aap-first-time | `/aap-first-time` | One-time local setup — walks through ansible.cfg, secrets2, collections, SSH key, and vault file interactively |
| aap-bootstrap | `/aap-bootstrap` | Collect credentials, generate inventory, run bootstrap — stops when AAP is ready |
| aap-setup-demo | `/aap-setup-demo` | Everything above, then launches `Setup - AAP - CAC` as a live demo story |

Skills are published at [github.com/ericcames/aap-skills](https://github.com/ericcames/aap-skills).
Update to the latest version with:

```bash
claude plugins marketplace update aap-skills
claude plugins update aap-skills@aap-skills
```

## Key Files

| File | Purpose |
|------|---------|
| `ansible-navigator.yml` | Navigator configuration — EE image, volume mounts, environment variables |
| `playbooks/bootstrap_dev.yml` | Inventory-driven bootstrap playbook — run with ansible-navigator |
| `playbooks/main.yml` | Main CaC setup playbook (runs inside AAP) |
| `inventories/rhdp-sample-demo/` | Sample inventory template — copy for each new environment |
| `scripts/bootstrap.sh` | Bootstrap wrapper script with validation and token extraction |
| `collections/requirements.yml` | Collection dependencies (reference only — pre-installed in EE) |
| `docs/dev-environment.md` | Local dev credentials — gitignored, never commit |
| `ROADMAP.md` | DC1 strategic roadmap and migration status |
| `CHANGELOG.md` | Record of all changes — always update before committing |

## Conventions

- Always update `CHANGELOG.md` before committing changes
- Document issues in GitHub before making fixes
- One fix per branch and PR
- Use `ansible.platform` modules where available; fall back to `ansible.controller`
  only when no platform equivalent exists
- Run playbooks with `ansible-navigator` to ensure execution environment consistency
- Collections are managed via the EE container image, not local installation
- Any playbook that creates a token must delete it in an `always:` block
