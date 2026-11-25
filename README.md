# HomeSync

Offline-first household management app for one household: budget and expenses, bills, chores, family calendar, pantry and grocery, emergency preparedness, health and medicine, document vault, vehicles, home maintenance, household inventory, food planner and rental management.

Every member records data on their own device without internet; changes sync to everyone when a connection returns.

## Repository layout

| Folder | What it holds |
| --- | --- |
| `app/` | Flutter app (Android + web) |
| `api/` | Laravel API — the sync hub |
| `docs/` | Sync protocol, decisions, schema notes |

## Branches

- `main` — always releasable
- `develop` — integration branch for finished features
- `feature/*`, `fix/*` — one branch per unit of work, branched from `develop`, merged by pull request

## Status

Phase 0 — Foundations (auth, households, roles, sync engine).
