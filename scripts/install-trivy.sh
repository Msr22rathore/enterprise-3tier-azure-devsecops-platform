#!/usr/bin/env bash

set -e

TRIVY_VERSION="0.72.0"

echo "Installing Trivy ${TRIVY_VERSION}..."

curl -sfL \
  "https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz" \
  -o /tmp/trivy.tar.gz

tar -xzf /tmp/trivy.tar.gz -C /tmp

sudo mv /tmp/trivy /usr/local/bin/trivy

echo "Installed Trivy:"
trivy --version