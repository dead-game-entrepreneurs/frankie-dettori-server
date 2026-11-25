# Implementation plan

The first milestone is a fresh, unmodified PAL client reaching the online menu
through the replacement backend. Racing and betting-party games follow as
separate validation milestones.

## 1. Finish the native HTTP contract

Trace concrete request serialization and response parsing beneath the master
transport. Produce synthetic fixtures for challenge, signup, login, logout,
empty search and populated search. Confirm content type, separators, escaping,
numeric types, success/failure records and HTTP framing. The outer HTTP engine
supports form requests, but that alone does not establish every master payload.

Check the password transform at `0x11c050` independently. Its MD5-like initial
state is present, but the input handling, digest encoding and normalization must
be established before selecting stored credential fields. Keep credentials and
future captures out of logs/Git.

## 2. Implement account startup

Build a small standalone Go service with configuration, health checks and private
atomic persistence. Route `/MCMasterServer/challenge.php` and the four returned
service paths. Challenge should return a replacement `SERVER` URL using the
same controlled host. Implement signup, case/name policy, login, random sessions,
logout and explicit native errors; do not report success for unsupported calls.

Use the existing DNS resolver and DNAS revival routing in local testing. Capture
a fresh boot through DNAS, challenge, account creation and named login. Compare
real requests/replies with the synthetic fixtures before continuing.

## 3. Implement listings and direct joins

Add ownership-bound game IDs, expiring listings and native search filters.
Implement publish, quick/filtered search, start/cancel/end and participant counts.
Trace which details travel over HTTP versus UDP/native peers. In particular,
`MasterServerJoinGame` asks the NAT service to introduce the selected game and
starts the peer connection; it is not a Quazal-style join RPC.

Validate two clients through browser, host/join, metadata updates, leaving and
host cleanup. Test jockey racing and betting-party settings independently.

## 4. Implement NAT introductions, then assess relay

Recover the complete comma-separated UDP grammar, transaction IDs, ACK/retry
rules, registration expiry and source-address checks. Login supplies the NAT
address/timers; native setup advertises gameplay port 3658. Keep that client port
separate from the not-yet-selected replacement NAT server port.

Build only authenticated, bounded introductions: bind session ownership to the
observed UDP endpoint, authorize game access and avoid arbitrary third-party
forwarding. Establish direct play across two PCs first.

Inspect peer handshake, advertised addresses, host role, message reliability and
connection identity before choosing a relay design. Reuse the proven engineering
patterns from Quetzal (independent endpoint proofs, bounded allocations, expiry,
metrics and temporary direct-only test blocks), rather than its PRUDP framing or
CID/RVCID-specific implementation. Validate blocked-direct fallback separately
if the stock client can select it.

## 5. Validate full games and deploy

Complete a jockey race and a betting-party session, including results, next-race
transitions and host departure. Recheck whether any backend stats calls actually
occur. Friends/player-list stubs do not justify implementing inaccessible social
APIs; a configured stats URL alone does not establish leaderboards.

Only then add production Docker/Compose, exact DNS documentation, TCP80 reverse
proxy and the recovered NAT/relay ports on RackNerd. Preserve the other hosted
games, DNAS and production state. Public Internet and physical-console results
must be recorded separately from synthetic and LAN checks.
