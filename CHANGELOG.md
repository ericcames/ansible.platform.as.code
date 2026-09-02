# Changelog

All notable changes to this project will be documented in this file.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## Unreleased

### Fixed
- `playbooks/bootstrap_dev.yml` — populate `oauth_token` on the `AAP Credential` so the `aap_token` extra var it injects is a real token. AAP 2.6+ removed the controller OAuth token endpoints, so without it every `ansible.controller` role falls back to username/password auth and `Setup - AAP - CAC` fails at the first controller task with `Failed to get token: HTTP Error 404: Not Found`. Creates a durable `AAP CaC token` that is intentionally not deleted at the end of the run, and removes superseded ones first. Looks up the credential's existing organization rather than assuming `Default`, and writes all six `inputs` fields because `inputs` is replaced wholesale on update (closes #169)

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
