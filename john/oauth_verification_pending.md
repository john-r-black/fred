# OAuth verification pending — waiting on Google

**Submitted:** 2026-04-16
**Expected response:** 1–6 weeks, to john@1421.me
**GCP project:** avid-circle-492115-b0
**Console:** https://console.cloud.google.com/apis/credentials/consent?project=avid-circle-492115-b0

## What was done

- Dropped `mail.google.com/` scope from mcp-google (pi-migration branch,
  commit fdacce2). Replaced with `gmail.modify` + `gmail.send` +
  `gmail.settings.basic`.
- Fixed `grant.js` to honor `MCP_GOOGLE_OAUTH_CLIENT` and
  `MCP_GOOGLE_TOKEN_DIR` env vars (commit 638ec52).
- Re-granted all 5 accounts with new scopes. Tokens verified working.
- Created GitHub Pages site for homepage + privacy policy:
  https://john-r-black.github.io/mcp-google-app/
  (repo: john-r-black/mcp-google-app)
- Filled out OAuth consent screen (Branding, Audience, Data Access).
- Verified domain ownership via Google Search Console (HTML file method).
- Recorded and uploaded demo video: https://youtu.be/HU2xxOkeXao
- Submitted scope justifications for all 13 scopes.
- Submitted verification questionnaire.
- Enabled Admin SDK API in the GCP project.

## What to do when Google responds

### If approved
1. SSH to Pi: `ssh 1421mcp` (key auth from Windows, alias in ~/.ssh/config)
2. Re-grant all 5 accounts to get verified-app tokens:
   ```
   ssh -L 3456:localhost:3456 1421mcp
   cd ~/mcp-google
   export MCP_GOOGLE_OAUTH_CLIENT=/etc/mcp-google/oauth-client.json
   export MCP_GOOGLE_TOKEN_DIR=/var/lib/mcp-google
   node grant.js jrb
   node grant.js 1421
   node grant.js dpumc
   node grant.js dpumc_admin
   node grant.js dpumc_yt
   ```
   Each prints a URL → paste into browser → sign in as that account → Allow.
3. Restart the service: `sudo systemctl restart mcp-google`
4. Wait 8 days. If no `invalid_grant` errors, tokens are long-lived. Done.
5. Delete this file.

### If Google asks for clarification
- Paste their email into a Claude Code session in fred. The scope
  justifications are in `john/oauth_verification_prep.md`. Claude can
  draft the response.

### If Google demands CASA (paid security audit)
1. Go to Cloud Console → Verification Center → Audience.
2. Click "Back to testing". Confirm.
3. Re-grant all 5 accounts (same commands as above).
4. Back to weekly re-grant cycle. No money spent.
5. Delete this file.

## Key files
- `john/oauth_verification_prep.md` — scope justifications, app info, video script
- `john/extend_token_time.md` — background analysis of all options
- Privacy policy repo: github.com/john-r-black/mcp-google-app
