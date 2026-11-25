# Initial protocol map

Evidence: Australian PAL `SLES_533.14`, SHA-256
`6475dd0f18a2a073736cab1ae521fe3a55f6b0277cba152f8d27bc86aafd8b83`.
All addresses below are native EE virtual addresses. This is static Ghidra
research, not a tested server contract or a packet capture.

## Startup and HTTP master service

`0x24a0a0` constructs the concrete master transport and installs the hardcoded
challenge URL. `0x249d00` starts the challenge; the common request builder
`0x2452a0` supplies `PLATFORM=ps2` and adds the current session when logged in.
The challenge also supplies `VERSION` and `LANGUAGE=en`.

`0x245af0` dispatches completed master-service responses. For `CHALLENGE_OK`,
it reads `SERVER` and appends these paths:

| Internal service category | Suffix | Known actions / native writer |
| --- | --- | --- |
| 1 | Original challenge URL | `CHALLENGE`, `0x249d00` |
| 2 | `/login.php` | `LOGIN`, `0x249470`; `LOGOUT`, `0x2492c0` |
| 3 | `/game.php` | `POSTGAME`, `0x2484a0`; `SEARCHGAME`, `0x247fa0` / `0x2482e0`; `STARTGAME` / `ADDPLAYER`, `0x247980`; `CANCELGAME`, `0x247710`; `ENDGAME`, `0x247390` |
| 4 | `/user.php` | `CREATEUSER`, `0x248e70` |
| 5 | `/stats.php` | Endpoint configured; no caller using category 5 found in the inspected send graph |

These category numbers are internal transport selectors, not Quazal/RMC protocol
numbers. All direct references to master send `0x35fde0` were inspected.

Observed application keys include `TYPE`, `PLATFORM`, `SESSION_ID`, `VERSION`,
`LOGIN`, `PASSWORD`, `EMAIL`, `COUNTRY`, `LANGUAGE`, `LOCAL_ADDRESS` and game
fields. Login/create transform the supplied password through `0x11c050`.
That routine initializes MD5-like state; exact input processing and output
encoding need an independent synthetic check.

Known response types include `CHALLENGE_OK`, `LOGIN_OK`, `LOGIN_FAIL`,
`LOGOUT_OK`, `CREATE_OK`, `CREATE_FAIL`, `POSTGAME_OK`, `POSTGAME_FAIL`,
`SEARCHGAME_RESULT`, `CANCELGAME_OK`, `CANCELGAME_FAIL`, `UPDATEGAME_OK`,
`DELETEGAME_OK`, `ERROR` and `CONNECTION_LOST`. The dispatcher reads `REASON`
for errors and an optional `MOTD` on login.

`LOGIN_OK` must provide `SESSION_ID`, `NAT_SERVER`,
`NAT_REGISTER_FREQUENCY` and `NAT_RETRY_TIMEOUT`. It configures native NAT
registration before reporting successful login. No usable replacement can stop
at returning a login success marker.

The concrete HTTP engine is `0x3595e0`. Its strings include
`application/x-www-form-urlencoded`, `MabHTTP/1.1`, GET/POST construction,
Content-Length and chunked-response handling. Final master request/response
serialization still needs tracing beneath the concrete transport vtable; no
JSON/XML or raw key-value response format is assumed here.

## Game listings and peer sessions

The two online modes are jockey racing and betting party. The native listing
reader checks `GAME_TYPE` and consumes mode-dependent fields. Known keys include
`GAME_ID`, `NAME`, `ADDRESS`, `FREE_SLOTS`, `MAX_PLAYERS`, `TRACK_ID`, `NUM_RACES`,
`VIEW_RACE`, `TIMELIMIT_ID`, `STARTING_CAP_ID`, `BETS_PER_ROUND`, `DIFFICULTY_ID`,
`GOING_ID`, `WEATHER_ID` and `RANDOM_SEED` across publication/search/settings.

Search responses include `NAT_ADDRESS`, `COUNT` and `GAME0`, `GAME1`, … records.
The dispatcher performs plus/space handling and decodes each listing into a
parameter list. Complete nesting/escaping must be verified before generating
fixtures. Search results are followed by native QoS/probe processing.

Join writer `0x247dd0` finds the selected local listing, issues the NAT join
request through `0x2446a0`, and starts a native peer connection through
`0x2428a0`. It does not send a standalone HTTP join request in that function.
Native peer states cover lobby, countdown, loading, betting, horse selection,
racing, race finish and results. Reliable and unreliable horse-state data are
separate. The master server is not the race simulation.

The native challenge/publish code advertises local gameplay port **3658**
(`0xe4a`). This does not establish the replacement NAT service's UDP port.
DNAS occurs earlier and remains independently routed.

## Custom NAT service

`0x243f00` handles registration, retries and native NAT replies.
The outgoing queue wraps each payload as:

```text
ps2,<transaction-id>,<payload>
```

Payload builders include `<session>,REGISTER`, `<session>,JOINGAME,<game-id>`,
`<session>,CREATEGAME,<game-id>` and
`<session>,UPDATEGAME,<game-id>,<count>`. Known received tokens include `ACK`,
`TESTCONNECTION_COMPLETE` and `OPENNAT`. `OPENNAT` is parsed as five comma-separated
fields; address/port/retry semantics must be checked against the sender and a
live trace. Native direct connectivity tests also use `TESTCONNECTION`,
`PINGTEST` and `PINGTEST_OK`.

The native peer wire framing, authentication, authority and relay compatibility
remain open. Quazal's seed-0 SYN/proof and CID/RVCID rules must not be applied to
this protocol without evidence.

## Social and stats scope

The Lua registration function `0x24a120` binds these PS2 functions:

| Function | Address | Behavior |
| --- | --- | --- |
| MasterServerIsFriendsSupported | `0x247370` | Returns false |
| MasterServerFriendsList | `0x247380` | No-op |
| MasterServerIsPlayersSupported | `0x247350` | Returns false |
| MasterServerPlayersList | `0x247360` | No-op |
| MasterServerHasAcceptedGameInvite | `0x24c0a0` | Returns false |
| MasterServerSetOnlineStatus | `0x245ad0` | No-op |

Shared Lua menus contain friends/platform-player branches, but the native PS2
support checks disable them. Notification strings alone do not establish social
backend support. No clan API was found in this initial sweep.

The stats endpoint is registered, but every recovered direct master-send call
uses categories 1–4. No active online leaderboards or stat uploads have been
established. Local career/horse-rank fields are separate from backend stats.
A full end-of-game capture remains necessary before concluding no stats are sent.
