#!/usr/bin/env bash

set -xeou pipefail

[ "$(whoami)" = root ] || { sudo "$0" "$@"; exit $?; }

apt-get update -y && apt-get dist-upgrade

apt-get install -y python3-pip python3-venv curl wget && \
pip3 install azure-cli black