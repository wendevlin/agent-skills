#!/usr/bin/env bash
# Installs what the skill needs (cloud container: Debian/Ubuntu, root).
set -e
if ! command -v openscad >/dev/null; then
  (apt-get update -qq && apt-get install -y -qq openscad xvfb) >/dev/null
fi
command -v xvfb-run >/dev/null || apt-get install -y -qq xvfb >/dev/null
python3 -c "import numpy" 2>/dev/null || pip install -q numpy
openscad --version 2>&1 | head -1
