#!/usr/bin/env bash
# Extract the Australian PS2 executable and disc map for private research.
set -euo pipefail
cd "$(dirname "$0")/.."
iso=${1:?Usage: tools/extract_disc.sh /path/to/Frankie-Dettori-Racing-Australia.iso}
mkdir -p disc/dettori work/dettori
7z x -y -odisc/dettori "$iso" SLES_533.14 SYSTEM.CNF DISK.MAP \
  LICENSE/LIBEENET.TXT DATA/PS2/DNAS/DNAS_NET.ERX
sha256sum disc/dettori/SLES_533.14 disc/dettori/DATA/PS2/DNAS/DNAS_NET.ERX \
  > work/dettori/executable.sha256
readelf -h -l -S disc/dettori/SLES_533.14 > work/dettori/elf.txt
python3 tools/elf_strings.py disc/dettori/SLES_533.14 > work/dettori/main.strings.tsv
