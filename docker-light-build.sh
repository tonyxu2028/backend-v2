#!/bin/sh
set -e

# Check Node.js version
NODE_VERSION=$(node -v)
REQUIRED_VERSION="v16"

if [[ "$NODE_VERSION" != *"$REQUIRED_VERSION"* ]]; then
  echo "Error: This script requires Node.js version $REQUIRED_VERSION"
  exit 1
fi

echo '开始编译程序';

VUE_APP_URL=/api/ yarn build