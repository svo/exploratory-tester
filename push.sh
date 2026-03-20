#!/usr/bin/env bash

image=$1 &&
architecture=$2 &&

if [ -z "$architecture" ]; then
  docker push "svanosselaer/exploratory-tester-${image}" --all-tags
else
  docker push "svanosselaer/exploratory-tester-${image}:${architecture}"
fi
