# Ubuntu install: retention + other user-scoped skills via dotfiles

As of 2026-04-16, user-scoped Claude Code skills (answer, answer-off,
note-win, note-ubu, retention-save, retention-restore, retention-list) and
the retention sync script now live in the `dotfiles` repo under `skills/`
and `scripts/retention/`. On the Windows box they're Windows junctions
from `~/.claude/skills` and `~/.claude/scripts/retention` into the dotfiles
working copy. Ubuntu needs symlinks set up the equivalent way, plus a
cron entry for the sync script.

**John's instruction**: follow these steps end-to-end on the Ubuntu box;
verify each step before moving on. When done, offer to delete this note.

---

## 1. Pull the latest dotfiles

```bash
git -C ~/code_projects/dotfiles pull
```

Confirm `~/code_projects/dotfiles/skills/` and
`~/code_projects/dotfiles/scripts/retention/` exist after pulling:

```bash
ls ~/code_projects/dotfiles/skills/
ls ~/code_projects/dotfiles/scripts/retention/
```

## 2. Remove any stale Ubuntu-local skills/scripts

If `~/.claude/skills/` or `~/.claude/scripts/retention/` already exist as
real directories on Ubuntu, check whether they hold anything that isn't in
the dotfiles repo. If they do, preserve those files; otherwise remove:

```bash
[ -d ~/.claude/skills ] && [ ! -L ~/.claude/skills ] && rm -rf ~/.claude/skills
[ -d ~/.claude/scripts/retention ] && [ ! -L ~/.claude/scripts/retention ] && rm -rf ~/.claude/scripts/retention
```

(Tests skip removal if the path is already a symlink.)

## 3. Create the symlinks

```bash
mkdir -p ~/.claude/scripts
ln -s ~/code_projects/dotfiles/skills ~/.claude/skills
ln -s ~/code_projects/dotfiles/scripts/retention ~/.claude/scripts/retention
```

Verify:

```bash
ls -la ~/.claude/skills
ls -la ~/.claude/scripts/retention
```

Both should show up as symlinks pointing into `~/code_projects/dotfiles/`.

## 4. Make sync.sh executable

The executable bit is stored in git on Linux, so this is usually
already set — but confirm:

```bash
chmod +x ~/.claude/scripts/retention/sync.sh
```

## 5. Sanity-check sync.sh

```bash
~/.claude/scripts/retention/sync.sh
echo "exit=$?"
```

Should print `exit=0` and produce no output (nothing to sync yet
on this box — archives are per-machine).

## 6. Install the cron entry

Run `crontab -e` and add:

```
0 12,22 * * * $HOME/.claude/scripts/retention/sync.sh
```

Verify:

```bash
crontab -l | grep retention
```

## 7. Restart Claude Code and verify skills

Quit any running Claude Code session and relaunch it. Confirm the
following appear in the `/` menu:

- `/answer`, `/answer-off`
- `/note-win`, `/note-ubu`
- `/retention-save`, `/retention-restore`, `/retention-list`

## 8. Archive scoping reminder

Retained transcripts live per-machine in `~/.claude/archive/`. An archive
saved on Windows is NOT visible from Ubuntu and vice versa — by design
(per John's decision, to avoid syncing secrets-laden transcripts through
git). If a specific session needs to move between boxes, `scp` it by hand
and rename the project-folder encoding to match the destination OS
(`C--Users-JohnBlack-...` vs `-home-john-...`).

---

**Delete this note when all 7 steps are verified on Ubuntu.**
