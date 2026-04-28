# ProPresenter workspace migration plan

**Decided: 2026-04-24. Executing: Sunday afternoon 2026-04-26.**

## Why

The worship computer currently uses `C:\Users\Sanctuary2021\Documents\ProPresenter\`
as its workspace. That path is user-specific and can never exist identically
on another machine. Every .pro file has that root baked in, so every sync
to a second machine (Pastor2023) results in broken media links. Patching
around it with Search Paths or junctions is fragile long-term.

Fix: move both machines to a shared, user-agnostic workspace path. .pro
files then store portable paths that resolve identically on every machine.

## Target architecture

| | Worship | Pastor2023 |
|---|---|---|
| Workspace (live editing) | `C:\ProPresenter\` | `C:\ProPresenter\` |
| Sync folder | existing transit location (no change needed) | `D:\ProPresenterSync\` (unchanged) |
| Manage Media Automatically | ON | ON |

.pro files will store paths like `C:\ProPresenter\Media\Assets\<file>` —
resolves on both machines with no relink, no junction, no Search Paths.

## Pre-migration cleanup (do on worship before Phase 1)

**Media Bin Google Drive items**: ~70 items on worship currently reference
`C:\Users\Sanctuary2021\My Drive\Media\<file>`. Workspace migration does
NOT fix these — they point at Google Drive, independent of workspace
location.

John's call: delete and re-add each item as a drag-in import so
ProPresenter copies it into managed Media\Assets and the reference becomes
portable. Tedious one-time cleanup but makes the Media Bin fully portable.

Do this on worship **before** Phase 1 so the migrated workspace is
already clean.

## Phase 1 — Worship migration (Sunday afternoon 2026-04-26)

1. On worship, open Preferences and note current settings: Active Workspace
   path, Sync folder path, all toggles (Manage Media, Relink, Search Paths).
2. Quit ProPresenter completely.
3. **Copy** (not move yet) `C:\Users\Sanctuary2021\Documents\ProPresenter\`
   → `C:\ProPresenter\`. Use File Explorer or `xcopy /E /I /Y` from an
   admin shell. Don't touch the original until the new one is verified.
4. Relaunch ProPresenter. Through the Workspace picker (Preferences →
   General → Active Workspace), point it at `C:\ProPresenter\`.
5. Open 5–10 presentations across different libraries. Verify backgrounds,
   chord charts, Media Bin items render correctly.
6. Verify sync still works — do a push to the sync folder and spot-check
   contents look right.
7. Only after 4–6 are clean: rename old `C:\Users\Sanctuary2021\Documents\ProPresenter\`
   → `C:\Users\Sanctuary2021\Documents\ProPresenter.OLD\`. Don't delete.
8. Run at least one rehearsal/service through it. If stable for 2 weeks,
   delete `.OLD`.

## Phase 2 — Pastor2023 fresh install (after Phase 1 stable)

ProPresenter on Pastor2023 will be uninstalled before Phase 1 executes.
No data there to preserve.

1. After Phase 1 stable, install fresh ProPresenter.
2. Before first launch, delete residue:
   - `C:\Users\JohnBlack\AppData\Roaming\RenewedVision\ProPresenter\`
   - `C:\Users\JohnBlack\Documents\My Drive\Media\` (leftover from staging)
   - Any `C:\Users\Sanctuary2021\` folder if intermediate folders got
     created during junction experiments
3. On first launch, when it asks for workspace location, pick
   `C:\ProPresenter\` (create the folder).
4. Configure Sync → point at `D:\ProPresenterSync\`.
5. Pull sync. Files populate into `C:\ProPresenter\`.
6. Open presentations, verify rendering. Should just work — all stored
   paths now match the workspace structure.

## Risks to watch

- **Workspace picker capability**: the ProPresenter 21.3.1 UI may or may
  not allow pointing at an arbitrary root-level C:\ path. If the UI fights
  it, fallback is editing the workspace path in
  `%AppData%\RenewedVision\ProPresenter\media-manager.toml` manually. Verify
  via UI first before committing.
- **License re-auth on Pastor2023**: fresh install means re-entering the
  license key. Have it ready before uninstalling.
- **Worship is in active use**: Sunday afternoon is the right window. Don't
  touch it Saturday night or before a Wednesday service.

## Rollback

If Phase 1 goes sideways:
- ProPresenter: point workspace back at `C:\Users\Sanctuary2021\Documents\ProPresenter\`.
  The original folder is still there (we only copied, not moved).
- `C:\ProPresenter\` can be deleted afterward.
