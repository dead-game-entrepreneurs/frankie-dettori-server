#!/usr/bin/env bash
# Isolate Ghidra settings, projects and exports from the server source.
set -euo pipefail
cd "$(dirname "$0")/.."
ghidra_install=${GHIDRA_INSTALL_DIR:-$HOME/.local/opt/ghidra_12.1.4_PUBLIC}
export XDG_CONFIG_HOME="$PWD/work/ghidra-config"
export XDG_CACHE_HOME="$PWD/work/ghidra-cache"
export GHIDRA_HEADLESS_JAVA_OPTIONS="${GHIDRA_HEADLESS_JAVA_OPTIONS:-} -Duser.home=$PWD/work/ghidra-home"
mkdir -p ghidra work/dettori
case "${1:-}" in
  import)
    shift
    exec "$ghidra_install/support/analyzeHeadless" ghidra dettori \
      -import disc/dettori/SLES_533.14 -processor r5900:LE:32:default \
      -scriptPath ghidra/scripts -analysisTimeoutPerFile 300 \
      -log work/dettori/import.log "$@"
    ;;
  decompile)
    shift
    if [ "$#" -lt 2 ]; then
      echo 'Usage: tools/ghidra.sh decompile OUTPUT SELECTOR ...' >&2
      exit 2
    fi
    exec "$ghidra_install/support/analyzeHeadless" ghidra dettori \
      -process SLES_533.14 -noanalysis -readOnly -scriptPath ghidra/scripts \
      -postScript Research.java "$@"
    ;;
  *)
    echo 'Usage: tools/ghidra.sh import | decompile OUTPUT SELECTOR ...' >&2
    exit 2
    ;;
esac
