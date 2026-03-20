# Exploratory Tester

[![Build Development](https://github.com/svo/exploratory-tester/actions/workflows/development.yml/badge.svg)](https://github.com/svo/exploratory-tester/actions/workflows/development.yml)
[![Build Builder](https://github.com/svo/exploratory-tester/actions/workflows/builder.yml/badge.svg)](https://github.com/svo/exploratory-tester/actions/workflows/builder.yml)
[![Build Service](https://github.com/svo/exploratory-tester/actions/workflows/service.yml/badge.svg)](https://github.com/svo/exploratory-tester/actions/workflows/service.yml)

## Prerequisites

* `vagrant`
* `ansible`
* `colima`
* `docker`

## Building

```bash
# Build for a specific architecture
./build.sh service arm64
./build.sh service amd64

# Push
./push.sh service arm64
./push.sh service amd64

# Create and push multi-arch manifest
./create-latest.sh service
```
