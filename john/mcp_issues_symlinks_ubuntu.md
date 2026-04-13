# Recreate mcp_issues symlinks on Ubuntu

The `fred/mcp_issues/` folder has three symlinks pointing at sibling
`mcp-*` repos. They're per-machine and gitignored, so after cloning
fred on a new Ubuntu machine you need to recreate them.

Assumes all four repos live side-by-side under `~/code_projects/`:

```
~/code_projects/fred
~/code_projects/mcp-google
~/code_projects/mcp-pco
~/code_projects/mcp-ui
```

Make sure each sibling repo has its own `mcp_issues/` folder first
(create it if missing), then from `fred/mcp_issues/`:

```bash
cd ~/code_projects/fred/mcp_issues
ln -s ../../mcp-google/mcp_issues google_mcp_issues
ln -s ../../mcp-pco/mcp_issues    pco_mcp_issues
ln -s ../../mcp-ui/mcp_issues     ui_mcp_issues
```

Verify with `ls -la` — the three entries should show as symlinks
pointing at the sibling repos.

On Windows these were created with `cmd //c "mklink /D ..."` instead
of `ln -s`, because Git Bash's `ln` without admin/Dev Mode falls back
to copying.
