#!/bin/bash
set -e
set -o pipefail

./Scripts/check-for-duplicate-provider-localized-names.sh
lua Tests/Test.lua
