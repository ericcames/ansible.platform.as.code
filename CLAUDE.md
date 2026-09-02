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

- `~/.ansible/ansible.cfg` with a valid Automation Hub token under `[galaxy_server.rh_certified]`
  - Get it from: `console.redhat.com → Automation Hub → Connect to Hub → API token`
- `~/.ansible/secrets2` containing your vault password (single line)
- Collections installed locally:

```bash
ANSIBLE_CONFIG=~/.ansible/ansible.cfg \
  ansible-galaxy collection install ansible.platform ansible.controller \
  -p ./collections
```

### Running the Bootstrap

Each environment gets its own named inventory. Copy the sample and set env vars:

```bash
cp -r inventories/rhdp-sample-demo/ inventories/rhdp-<customer>-<demo>/
export CONTROLLER_HOST=<new AAP URL>
export CONTROLLER_USERNAME=admin
export CONTROLLER_PASSWORD=<new password>
ansible-playbook -i inventories/rhdp-<customer>-<demo>/ playbooks/bootstrap_dev.yml
```

The inventory `group_vars/all.yml` resolves all sensitive values at runtime via
env var and file lookups — no secrets are stored in the inventory.

The playbook creates:
- Automation Hub certified and validated credentials
- Galaxy credentials associated with the Default Organization
- Vault credential (name varies by user — reads password from `~/.ansible/secrets2`)
- `aap.as.code` project
- `Setup - AAP - CAC` job template

The bootstrap token is automatically deleted when the playbook completes
(even on failure) to prevent stale token accumulation.

### The AAP CaC token — a deliberate exception

Bootstrap also creates a second, **durable** token called `AAP CaC token` and writes it
into the `oauth_token` field of `AAP Credential`. This one is intentionally *not* deleted.

It has to persist because the `Red Hat Ansible Automation Platform` credential type
injects `aap_token: "{{oauth_token}}"` as an **extra var**. If `oauth_token` is empty,
`aap_token` arrives as `""`, every `infra.aap_configuration` role resolves
`controller_oauthtoken: "{{ aap_token | default(omit, true) }}"` to `omit`, and the
`ansible.controller` modules fall back to username/password auth — which POSTs to
`/api/controller/v2/tokens/`. **AAP 2.6+ removed that endpoint**, so `Setup - AAP - CAC`
fails at its first controller task with `Failed to get token: HTTP Error 404: Not Found`.

Extra vars are the highest-precedence source in Ansible, so this cannot be fixed from
inside `playbooks/main.yml` — not with `set_fact`, play vars, or `include_role` vars.
The token must be on the credential.

Bootstrap deletes any previous `AAP CaC token` before creating the new one, so exactly
one exists per environment. Deleting it by hand will break CaC on that instance.

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
| `playbooks/bootstrap_dev.yml` | Inventory-driven bootstrap playbook — run with `-i inventories/rhdp-<customer>-<demo>/` |
| `playbooks/main.yml` | Main CaC setup playbook (runs inside AAP) |
| `inventories/rhdp-sample-demo/` | Sample inventory template — copy for each new environment |
| `docs/dev-environment.md` | Local dev credentials — gitignored, never commit |
| `ROADMAP.md` | DC1 strategic roadmap and migration status |
| `CHANGELOG.md` | Record of all changes — always update before committing |

## Conventions

- Always update `CHANGELOG.md` before committing changes
- Document issues in GitHub before making fixes
- One fix per branch and PR
- Use `ansible.platform` modules where available; fall back to `ansible.controller`
  only when no platform equivalent exists
- Any playbook that creates a token must delete it in an `always:` block — the sole
  exception is the durable `AAP CaC token`, which must outlive the run (see above)
