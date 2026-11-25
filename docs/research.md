# Build provenance and research workflow

The initial disc is `Frankie Dettori Racing (Australia).iso`, containing PAL
boot executable `SLES_533.14`. `SYSTEM.CNF` declares VER 1.01 and VMODE PAL;
these are disc configuration fields, not a recovered master-server VERSION.
ISO metadata identifies `MELBOURNECUP`, volume set `MCCFDR`, publisher Home
Entertainment Supplies and copyright Sidhe Interactive.

| File | SHA-256 |
| --- | --- |
| `SLES_533.14` | `6475dd0f18a2a073736cab1ae521fe3a55f6b0277cba152f8d27bc86aafd8b83` |
| `DATA/PS2/DNAS/DNAS_NET.ERX` | `95d523571bd9dbadfa3e8ab4090c5301b3f72fa4d6429ed7de7da0aba8a0d25e` |

The main executable is little-endian ELF32/R5900, entry `0x100008`. Ghidra
analysis used `r5900:LE:32:default`. Analysis completed and saved, with warnings
from vector-unit routines and false PNG detections; protocol conclusions rely
on inspected scalar call paths, references and instructions. Decompiled types
and floating-point argument recovery can be inaccurate.

## Reproduce

```sh
tools/extract_disc.sh '/path/to/Frankie Dettori Racing (Australia).iso'
tools/ghidra.sh import
tools/ghidra.sh decompile work/dettori/startup.c \
  code:0x24a0a0 code:0x249d00 code:0x2452a0
tools/ghidra.sh decompile work/dettori/social.c \
  code:0x247350 code:0x247360 code:0x247370 code:0x247380 code:0x24c0a0
tools/ghidra.sh decompile work/dettori/master.c \
  code:0x245af0 code:0x248e70 code:0x249470 callers:0x35fde0
```

Import once. The project is `ghidra/dettori.gpr`, backed by
`ghidra/dettori.rep/`. `import -overwrite` deliberately replaces annotations.
Decompilation runs read-only without reanalysis. The exporter accepts
`code:0xADDRESS`, `addrrefs:0xADDRESS`, `callers:0xADDRESS`, `asm:0xADDRESS`,
`refs:TEXT`, `name:SUBSTRING` and `range:0xSTART:0xEND` (end exclusive).
Bare addresses must include `0x`.

## Resources and evidence boundaries

The disc's `DISK.MAP` lists sector-addressed resources inside `DATA.PAK`.
Selected online-menu Lua 5.0 bytecode/XML and common configuration resources
were read privately to correlate menu features with native bindings. Original
resources remain under ignored `work/dettori/resources/` and are not repository
source or server dependencies. The map includes stale size metadata for the
main executable; validate each selected extent and actual content rather than
blindly treating every map entry as the ISO directory record.

The account flow's Lua constants establish network configuration, EULA, DNAS,
challenge, then sign-in/sign-up stages. Online-mode constants establish jockey
racing and betting party. Shared menus contain features that the PS2 native
functions disable, so strings alone are not treated as active server calls.

Current private exports: `initial-services.c`, `request-writers.c`,
`operations.c`, `transport.c` and annotated working copies under `work/dettori/`.
They contain original decompilation and must not be committed. Record only
addresses, contracts, independent code and synthetic fixtures in Git.

Next research targets: the master transport vtables (`0x5623a0`, `0x5623c0`),
concrete send `0x35edd0`, completion path `0x35ed70`, and password helper
`0x11c050`. Confirm codecs with synthetic native execution before wiring a
server. No emulator, Internet, relay or physical-console test has run yet.
