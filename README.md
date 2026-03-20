# Exploratory Tester

[![Build Development](https://github.com/svo/exploratory-tester/actions/workflows/development.yml/badge.svg)](https://github.com/svo/exploratory-tester/actions/workflows/development.yml)
[![Build Builder](https://github.com/svo/exploratory-tester/actions/workflows/builder.yml/badge.svg)](https://github.com/svo/exploratory-tester/actions/workflows/builder.yml)
[![Build Service](https://github.com/svo/exploratory-tester/actions/workflows/service.yml/badge.svg)](https://github.com/svo/exploratory-tester/actions/workflows/service.yml)

A toolkit for automating exploratory testing of web applications.

## Architecture

The project produces three Docker images, each serving a distinct purpose:

| Image | Base | Purpose | Port |
|-------|------|---------|------|
| **development** | `dockette/vagrant:debian-12` | Full local development environment with all tools | 22 (SSH) |
| **builder** | `debian:12-slim` | CI/CD build and test environment | 22 (SSH) |
| **service** | `debian:12-slim` | Lightweight runtime for exploratory testing capabilities | |

The **service** container is the core runtime where the exploratory testing capabilities are installed. It uses [Playwright MCP](https://github.com/microsoft/playwright-mcp) for browser automation, driven by either [Claude Code](https://github.com/anthropics/claude-code) or [Rovo Dev CLI](https://support.atlassian.com/rovo/docs/install-and-run-rovo-dev-cli-on-your-device/) as the AI agent. Infrastructure is defined as code via Packer HCL configurations that use the Ansible provisioner to configure each image through playbooks and reusable roles.

## Project Structure

```
.
├── bin/
│   ├── create-image                  # Packer build wrapper
│   └── setup-image-requirements      # Base image setup (SSH, Python)
├── infrastructure/
│   ├── packer/
│   │   ├── development.pkr.hcl       # Development image definition
│   │   ├── builder.pkr.hcl           # Builder image definition
│   │   └── service.pkr.hcl           # Service image definition
│   ├── ansible/
│   │   ├── playbook-development.yml  # Development provisioning
│   │   ├── playbook-builder.yml      # Builder provisioning
│   │   ├── playbook-service.yml      # Service provisioning
│   │   └── roles/                    # Reusable Ansible roles
├── .github/workflows/                # CI/CD pipelines
├── Vagrantfile                       # Local development via Docker provider
├── build.sh                          # Build images
├── push.sh                           # Push images to Docker Hub
└── create-latest.sh                  # Create multi-arch manifests
```

## Prerequisites

* [Vagrant](https://www.vagrantup.com/)
* [Ansible](https://www.ansible.com/)
* [Colima](https://github.com/abiosoft/colima)
* [Docker](https://www.docker.com/)

## Local Development

The Vagrant environment uses the Docker provider to run the development image locally:

```bash
vagrant up
vagrant ssh
```

## Building

Images are built using the `build.sh` script, which runs Packer inside the builder container:

```bash
# Build for a specific architecture
./build.sh service arm64
./build.sh service amd64

# Build for all architectures
./build.sh service

# Push to Docker Hub
./push.sh service arm64
./push.sh service amd64

# Create and push multi-arch manifest
./create-latest.sh service
```

Replace `service` with `development` or `builder` to build the other images.

## Usage

The service supports two AI agents, selected via the `AGENT` environment variable (defaults to `claude`).

### Claude Code

```bash
docker run --rm \
  -e TARGET_URL=https://example.com \
  -e ANTHROPIC_API_KEY=sk-... \
  -v $(pwd)/output:/output \
  svanosselaer/exploratory-tester-service:latest
```

### Rovo Dev CLI

```bash
docker run --rm \
  -e AGENT=rovo \
  -e TARGET_URL=https://example.com \
  -e ATLASSIAN_EMAIL=user@example.com \
  -e ATLASSIAN_API_TOKEN=... \
  -v $(pwd)/output:/output \
  svanosselaer/exploratory-tester-service:latest
```

### Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `TARGET_URL` | Yes | URL of the web application to test |
| `AGENT` | No | AI agent to use: `claude` (default) or `rovo` |
| `ANTHROPIC_API_KEY` | When `AGENT=claude` | Anthropic API key for Claude Code |
| `ATLASSIAN_EMAIL` | When `AGENT=rovo` | Atlassian account email |
| `ATLASSIAN_API_TOKEN` | When `AGENT=rovo` | Rovo Dev scoped API token |
| `TEST_PROMPT` | No | Custom testing instructions (defaults to general exploratory testing) |

Results and screenshots are written to the `/output` directory.
