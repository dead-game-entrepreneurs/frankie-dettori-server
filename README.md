# Frankie Dettori Server

An independent replacement-server project for **Frankie Dettori Racing** on PS2,
starting with the Australian PAL disc, **SLES-533.14**. The disc identifies itself
as Melbourne Cup Challenge (`MELBOURNECUP` / `MCCFDR`).

**Status: protocol research and implementation planning. No replacement server
is implemented or deployed yet.** The supported executable has been imported
into Ghidra and its account, matchmaking, NAT and feature-support paths traced.

## Backend identified

This build uses a custom HTTP master server and custom UDP peer/NAT code.
It does not use Quetzal's Quazal Rendez-Vous/PRUDP protocol on the traced paths.
Native strings identify `MabHTTP/1.1` and a game-specific `MC/1.0` component.

The initial URL is:

```text
http://challenge.melbournecupchallenge.com/MCMasterServer/challenge.php
```

The challenge response supplies a `SERVER` base URL. The game appends
`/login.php`, `/game.php`, `/user.php` and `/stats.php`. Login then supplies
a `SESSION_ID`, NAT server address, registration frequency and retry timeout.
DNAS remains a separate authentication step before the challenge.

| Area | Research finding |
| --- | --- |
| Accounts | Native create-user, login and logout requests found |
| Matchmaking | Publish/search/join/start/cancel/end-game paths found |
| Online modes | Jockey racing and betting-party menus found |
| Peer connectivity | Custom UDP registration, introductions, probes and native gameplay |
| Friends / platform player lists | PS2 support functions return false; list functions are no-ops |
| Stats / leaderboards | Stats URL is configured, but no request to category 5 appears in the inspected master-server send call graph |
| Relay | Requires its own native-protocol investigation; Quazal relay cannot be assumed compatible |

All findings are static; there has been no emulator connection or live packet
validation for this project yet. See the [protocol map](docs/protocols.md),
[implementation plan](docs/plan.md) and [build/research notes](docs/research.md).

## Research tools

Use your own copy of the supported disc. Requirements: Python 3, 7-Zip,
`readelf`, and Ghidra with the Emotion Engine language `r5900:LE:32:default`.
The wrapper defaults to Ghidra 12.1.4; override `GHIDRA_INSTALL_DIR` if needed.

```sh
tools/extract_disc.sh '/path/to/Frankie Dettori Racing (Australia).iso'
tools/ghidra.sh import
tools/ghidra.sh decompile work/dettori/bootstrap.c code:0x24a0a0 code:0x249d00
```

Original executables, disc resources, Ghidra databases, exports and future player
state/captures stay in ignored local directories. They are not distributed.

## Planned server

A standalone Go HTTP service plus a title-specific UDP NAT service, with private
account persistence and expiring sessions/game listings. It can share a hosting
machine and DNS resolver with Quetzal while running as a separate service.
The future HTTP service must be reachable on TCP80 for the original hostname;
the game-provided NAT address should determine its separately configured UDP port.
No production DNS redirect or port assignment has been installed yet.

This project is unaffiliated with the game's developers, publishers or platform
holders. Research tooling was adapted from
[Quetzal](https://github.com/dead-game-entrepreneurs/quetzal); game wire formats
remain independent.
