# Ubuntu install: retention-save / retention-restore / retention-list

On 2026-04-16 the three `retention-*` skills and the `sync.sh` script were built on the Windows box. They need to be installed on the Ubuntu box too, because Claude Code transcripts are machine-local — the Windows archives aren't accessible to an Ubuntu Claude session.

These skills archive conversation transcripts from `~/.claude/projects/<encoded-cwd>/` (where Claude Code auto-cleans them after `cleanupPeriodDays`, default 30 days) to `~/.claude/archive/<encoded-cwd>/` (permanent). A cron job runs the sync script twice daily to keep archives current while the original session is still live.

**John's instruction**: follow these steps end-to-end on the Ubuntu box; verify each step before moving on. When done, offer to delete this note.

---

## 1. Create the three skill directories and the scripts directory

```bash
mkdir -p ~/.claude/skills/retention-save
mkdir -p ~/.claude/skills/retention-restore
mkdir -p ~/.claude/skills/retention-list
mkdir -p ~/.claude/scripts/retention
```

## 2. Write `~/.claude/skills/retention-save/SKILL.md`

```markdown
---
name: retention-save
description: Retain the current conversation transcript outside the 30-day auto-cleanup directory so it can be restored later with /retention-restore. Optional label argument; otherwise prompts for approval of a suggested label.
argument-hint: [label]
disable-model-invocation: true
allowed-tools: Bash(*)
---

# retention-save

Copy the current session transcript (and its tool-results spill directory if present) from `~/.claude/projects/` into `~/.claude/archive/` so it survives Claude Code's `cleanupPeriodDays` auto-delete. A scheduled sync job keeps the archive current while the session is still live.

Use `$ARGUMENTS` as an optional label. If empty, suggest one derived from the first user message in the transcript and get approval before writing it.

Steps:

1. **Determine session ID.** Prefer `${CLAUDE_SESSION_ID}`. If empty, use the basename (minus `.jsonl`) of the newest `.jsonl` in the project's live folder.
2. **Compute project-encoded folder name** from `$PWD`: replace every `:`, `/`, `\`, `_` with `-`. E.g. `/home/john/code_projects/fred` → `-home-john-code-projects-fred`.
3. `mkdir -p ~/.claude/archive/<project-encoded>/`.
4. `cp ~/.claude/projects/<project-encoded>/<sessionId>.jsonl ~/.claude/archive/<project-encoded>/<sessionId>.jsonl`.
5. If `~/.claude/projects/<project-encoded>/<sessionId>/` exists (spill directory), `rm -rf` any prior archived copy and `cp -r` the live one into `~/.claude/archive/<project-encoded>/<sessionId>/`.
6. **Label** (stored in `<sessionId>.label.txt` beside the archived `.jsonl`):
   - If `$ARGUMENTS` is non-empty: use it verbatim, write the sidecar, no prompting.
   - Else: extract a suggestion from the first user message in the `.jsonl` (parse lines with `"type":"user"`, take the first one's text, strip newlines, truncate to 60 chars). Show: `Suggested label: "<text>" — accept (a), edit (e), or skip (s)?`. On `a` write the suggestion; on `e` prompt for replacement and write that; on `s` skip the sidecar. If parsing fails or no user messages exist, fall through to `edit` with an empty default.
7. Report: archive path, label written (or "no label"), whether the spill directory was included, reminder that `~/.claude/scripts/retention/sync.sh` runs twice daily via cron to keep the archive current.
```

## 3. Write `~/.claude/skills/retention-restore/SKILL.md`

```markdown
---
name: retention-restore
description: Restore a previously retained conversation back into the live projects folder so /resume can see it. Shows a numbered menu of archives for the current project; user picks one.
disable-model-invocation: true
allowed-tools: Bash(*)
---

# retention-restore

Copy a previously retained transcript from `~/.claude/archive/` back into `~/.claude/projects/` so Claude Code's `/resume` picker lists it again.

Steps:

1. **Compute project-encoded folder name** from `$PWD`: replace every `:`, `/`, `\`, `_` with `-`.
2. List `~/.claude/archive/<project-encoded>/*.jsonl`. If none, say so and stop.
3. For each archive file, show a numbered line with: short session ID (first 8 chars), label, modification time, size in MB. Label priority: (a) `<sessionId>.label.txt` sidecar if present; (b) else first user message from the `.jsonl` truncated to 60 chars as a best-effort preview; (c) if both fail, show `—`.
4. Ask the user to pick a number.
5. Copy the chosen `<sessionId>.jsonl` back to `~/.claude/projects/<project-encoded>/<sessionId>.jsonl`. If the archive has a `<sessionId>/` spill directory, copy that too. **Do not delete** from the archive — restore is non-destructive.
6. Tell the user to quit Claude Code and relaunch, then run `/resume` to see the restored session in the picker.
```

## 4. Write `~/.claude/skills/retention-list/SKILL.md`

```markdown
---
name: retention-list
description: Show every retained conversation across all projects. Displays project, short session ID, label (or first-prompt preview), modification time, and size.
disable-model-invocation: true
allowed-tools: Bash(*)
---

# retention-list

List every archived transcript under `~/.claude/archive/`, grouped by project.

Steps:

1. Walk each subfolder under `~/.claude/archive/`.
2. For each `*.jsonl` inside, print a row with:
   - Project folder name (the encoded-cwd name, e.g. `-home-john-code-projects-fred`).
   - Short session ID (first 8 chars).
   - Label. Priority: (a) `<sessionId>.label.txt` sidecar if present; (b) first user message from the `.jsonl` truncated to 60 chars; (c) `—` if both fail.
   - Modification time.
   - Size in MB.
3. Group by project, project header as a section break.
4. If `~/.claude/archive/` is empty or missing, say so.
```

## 5. Write `~/.claude/scripts/retention/sync.sh`

```bash
#!/usr/bin/env bash
# Claude Code conversation archive sync.
# For each archived .jsonl in ~/.claude/archive/<project>/, check whether the
# live transcript in ~/.claude/projects/<project>/ is newer. If yes, overwrite
# the archive (and mirror the tool-results spill directory if present).
# Silently skips when live file is already gone (archive becomes the final
# snapshot after Claude Code cleans up the original).

set -euo pipefail
ARCHIVE_ROOT="$HOME/.claude/archive"
PROJECTS_ROOT="$HOME/.claude/projects"

[ -d "$ARCHIVE_ROOT" ] || exit 0

for project_dir in "$ARCHIVE_ROOT"/*/; do
    [ -d "$project_dir" ] || continue
    project_name=$(basename "$project_dir")
    live_dir="$PROJECTS_ROOT/$project_name"
    [ -d "$live_dir" ] || continue

    for archive_file in "$project_dir"*.jsonl; do
        [ -f "$archive_file" ] || continue
        session_id=$(basename "$archive_file" .jsonl)
        live_file="$live_dir/$session_id.jsonl"

        if [ -f "$live_file" ] && [ "$live_file" -nt "$archive_file" ]; then
            cp "$live_file" "$archive_file"
            if [ -d "$live_dir/$session_id" ]; then
                rm -rf "${project_dir}${session_id}"
                cp -r "$live_dir/$session_id" "${project_dir}${session_id}"
            fi
        fi
    done
done
```

## 6. Make the sync script executable

```bash
chmod +x ~/.claude/scripts/retention/sync.sh
```

## 7. Sanity-check the sync script

```bash
~/.claude/scripts/retention/sync.sh
echo "exit=$?"
```

Should print `exit=0` and produce no output (nothing to sync yet).

## 8. Install the cron entry

Run `crontab -e` and add this line (twice-daily, matching Windows schedule):

```
0 12,22 * * * $HOME/.claude/scripts/retention/sync.sh
```

Verify with:

```bash
crontab -l | grep retention
```

## 9. Verify skills are discovered

Quit any running Claude Code session and relaunch it. In the `/` menu, confirm the three new skills appear:

- `/retention-save`
- `/retention-restore`
- `/retention-list`

Note: Ubuntu paths encode differently from Windows. A cwd of `/home/john/code_projects/fred` becomes `-home-john-code-projects-fred` as the archive subfolder name. The skill logic handles this automatically — the encoding rule (replace `:` `/` `\` `_` with `-`) works for both OSes.

## 10. Cross-machine note

Archives on Ubuntu are separate from archives on Windows. A retained session on one machine is **not** visible from the other. If you need a specific Ubuntu transcript on Windows (or vice versa), copy it manually via `scp` or similar — transcripts reference absolute paths from the originating machine, so resume on the other side is best-effort (conversational continuity works; any file-references in the transcript won't resolve).

---

**Delete this note when install is complete and verified.**
