# Changelog

All notable changes to this project will be documented in this file.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## Unreleased

### Added
- `ansible-navigator.yml` — navigator configuration for Red Hat EE ee-supported-rhel9 with volume mounts for ~/.ansible/ and environment variable passthrough (closes #167)
- `scripts/bootstrap.sh` — bootstrap wrapper script with inventory validation, env var checks, and automatic Automation Hub token extraction
- `.gitignore` — exclude ansible-navigator.log and playbook-artifacts/ from version control

### Changed
- `ansible.cfg` — removed collections_path (collections pre-installed in EE image), moved Automation Hub token to env var lookup, removed hardcoded token value (closes #167)
- `CLAUDE.md` — updated Prerequisites section to use ansible-navigator + podman pull instead of ansible-galaxy collection install; updated bootstrap commands to use ansible-navigator run; added ansible-navigator.yml and scripts/bootstrap.sh to Key Files table; added navigator convention (closes #167)
- Workflow migrated from ansible-galaxy + ansible-playbook to ansible-navigator with Red Hat supported Execution Environment (closes #167)

### Previous Unreleased

### Added
- `inventories/rhdp-acme-cac/` — inventory for acme CaC demo environment

### Changed
- `.gitignore` — exclude `collections/` from version control (installed dependencies)
- `README.md` — expanded Automated Bootstrap section with clone step, Claude Code launch step, upgrade path (both commands), and restart notice (closes #165)

## Previous Unreleased

### Changed
- `.gitignore` — exclude `collections/` from version control (installed dependencies)

## Previous Unreleased

### Changed
- `README.md` — added "First time here?" section and `/aap-first-time` to skills table (closes #157)
- `CLAUDE.md` — added `/aap-first-time` to skills table, updated "Two skills" to three, updated Prerequisites to point to `/aap-first-time`, fixed hardcoded vault credential name (closes #157)

### Added
- `CLAUDE.md` — Claude-specific guidelines covering new AAP environment setup, bootstrap playbook usage, collection install steps, key files, and project conventions
- `ROADMAP.md` — DC1 strategic roadmap capturing architecture layers, migration sequence, phase plan, known F5 issues, and related repos
- `playbooks/bootstrap_dev.yml` — automates Phase 1 dev environment setup (Hub credentials, Vault credential, project, job template) against a fresh AAP instance; inline comments guide new users on token, vault password, and remote file hosting
- `inventories/rhdp-sample-demo/` — sample inventory template for new RHDP environments; copy and rename for each customer/demo combination

### Changed
- `CLAUDE.md` — updated bootstrap command to use `-i inventories/rhdp-<customer>-<demo>/`; added Claude Code Skills section with install instructions and skill reference (closes #154)
- `CLAUDE.md` — updated Key Files table to include `inventories/rhdp-sample-demo/`
- `README.md` — added Automated Bootstrap section referencing `/aap-bootstrap` and `/aap-setup-demo` skills
- `playbooks/bootstrap_dev.yml` — refactored to be inventory-driven; all environment vars moved to `inventories/rhdp-<customer>-<demo>/group_vars/all.yml` (closes #152)
- `playbooks/bootstrap_dev.yml` — changed `hosts: localhost` to `hosts: all` to support inventory targeting
- `playbooks/bootstrap_dev.yml` — corrected module usage: `ansible.controller` with `controller_oauthtoken` for credential/organization/project/job_template; `ansible.platform.token` used for token lifecycle only
- `ROADMAP.md` — marked issues #14, #18, #21, #23 resolved in Phase 1 checklist and Known Issues table; added issue links
- `docs/dev-environment.md` — local dev credentials file (excluded from git via .gitignore)
- `.gitignore` — exclude `docs/dev-environment.md` from version control

### Fixed
- `playbooks/bootstrap_dev.yml` — changed `scm_branch` from hardcoded `ericames/productdemo` to `main` (fixes #150)
