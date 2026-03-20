#!/usr/bin/env bash

image=$1

docker manifest rm "svanosselaer/exploratory-tester-${image}:latest" 2>/dev/null || true

docker manifest create \
  "svanosselaer/exploratory-tester-${image}:latest" \
  --amend "svanosselaer/exploratory-tester-${image}:amd64" \
  --amend "svanosselaer/exploratory-tester-${image}:arm64" &&
docker manifest push "svanosselaer/exploratory-tester-${image}:latest"
