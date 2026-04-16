# Catch-up: Ubuntu side-effects from the 2026-04-16 Windows session

On 2026-04-16 John spent a long Windows session building new user-scoped
skills (retention-save/restore/list, answer, answer-off, note-win,
note-ubu) and moving them into the `dotfiles` repo under `skills/` and
`scripts/retention/`. Most of the Ubuntu-side install is covered in
`n_install_retention_skills_on_ubuntu.md` — do that note first.

This note covers the things that are **not** in that other note: a couple
of quick verifications and awareness items for Ubuntu Claude once the
install note is done.

## 1. Confirm the CLAUDE.md symlink

On Windows, `~/.claude/CLAUDE.md` is a symlink into `~/code_projects/dotfiles/CLAUDE.md`, which is why preferences stay in sync between what John edits and what ships to GitHub. Ubuntu should be the same. Verify:

```bash
ls -la ~/.claude/CLAUDE.md
```

Expected: a symlink pointing at `~/code_projects/dotfiles/CLAUDE.md`. If it's a real file instead, the dotfiles copy is diverging from the live copy — flag to John so he can decide which to keep before overwriting.

## 2. Confirm new preferences took effect

After `git -C ~/code_projects/dotfiles pull`, the dotfiles CLAUDE.md gains four lines John added on Windows but hadn't synced yet (commit `231b9cd`):

- "If I slip into vague language…"
- "In unfamiliar territory, be the lead…"
- "For web UIs…click-by-click steps…"
- "Terminal commands: one self-contained command per line…"

Because `~/.claude/CLAUDE.md` is a symlink to the dotfiles copy, these take effect automatically in the next Ubuntu session — no install needed. Verify by grepping:

```bash
grep -c "one self-contained command" ~/.claude/CLAUDE.md
```

Should return `1`. If it returns `0`, the symlink or the pull is broken.

## 3. Auto-memory is machine-local by design

Two new auto-memory entries were saved on Windows today
(`feedback_latest_data.md`, `feedback_pushback_welcome.md`) plus MEMORY.md
index updates. These live under
`~/.claude/projects/<encoded-cwd>/memory/` and are NOT synced between
machines (John's explicit decision — transcripts and memories stay local).

Ubuntu doesn't need to do anything here — just be aware that if John
references a recent feedback item you don't have, the Windows box may
hold a newer version of that memory file. If it matters, John will ask
you to save the equivalent on Ubuntu separately.

## 4. Archive scoping reminder

Retained transcripts (saved via `/retention-save`) live per-machine in
`~/.claude/archive/`. A session archived on Windows is not visible from
Ubuntu — same machine-local design as auto-memory. The scheduled sync
script only keeps the local archive current with the local live
transcript.

---

**Delete this note when items 1 and 2 are verified (items 3 and 4 are
awareness only — nothing to "complete").**
