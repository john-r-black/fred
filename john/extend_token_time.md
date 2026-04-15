# Extending Google OAuth refresh-token lifetime

**Problem:** mcp-google refresh tokens expire after 7 days, so tools start
returning `invalid_grant` about once a week and you have to run
`node grant.js <account>` on 1421home for each of the five accounts, then
scp the new tokens to the Pi.

**Root cause:** The Google Cloud project that hosts the OAuth client
(`~/.google-mcp/gcp-oauth.keys.json`) has its OAuth consent screen set to
**User type = External** and **Publishing status = Testing**. In that
combination, Google hands out refresh tokens with a hard 7-day expiry as
an anti-abuse measure.

This file lays out the real options for getting rid of the weekly cycle.

---

## The one OAuth client that exists today

All five accounts — `jrb`, `1421`, `dpumc`, `dpumc_admin`, `dpumc_yt` — use
the **same** OAuth client ID. That OAuth client lives in **one** Google
Cloud project, and that project's consent screen has **one** user-type
setting. So whatever we do to that one consent screen affects all five
accounts simultaneously.

(If we wanted different settings for different accounts, we'd need
different OAuth clients in different projects, and the code in
`register-tools.js` would have to load a different client file per
account. That's a bigger refactor — an option, but not the simplest.)

---

## Which combinations actually give you long-lived refresh tokens

| User type | Publishing | Refresh token lifetime | Verification required? |
|---|---|---|---|
| External | Testing | **7 days** (current state) | no |
| External | In Production | No expiry (unless unused 6 months) | **yes**, for sensitive/restricted scopes |
| Internal | — | No expiry (unless unused 6 months) | no |

"Internal" means "only users inside one Google Workspace org can sign in."
It's not available for consumer Gmail (`jrb` → `john.r.black@gmail.com`
can't be Internal) and it's only available when the Cloud project is
owned by a Workspace org, not by a consumer Gmail account.

---

## The scopes you're asking for are "restricted"

Restricted scopes include:

- `https://mail.google.com/` (full Gmail access — `jrb` and `1421`)
- `https://www.googleapis.com/auth/gmail.modify` and `.send` (all dpumc accounts)
- `https://www.googleapis.com/auth/drive` (full Drive)
- `https://www.googleapis.com/auth/admin.directory.*` (Workspace admin)

Restricted-scope apps that are "External + In Production" must go through
Google's app verification process, which requires:
- A verified privacy policy URL on a domain you own
- A verified homepage URL
- Sometimes a third-party security assessment (CASA tier 2/3)
- Multi-week review, sometimes longer
- Ongoing renewal

For a single-user personal-use app this is a lot of friction.

---

## Your practical options, from simplest to most work

### Option 1 — Do nothing. Keep the weekly re-grant cycle. ⭐ recommended default
**Effort:** 0 now, ~5 min/week forever
**What it means:** When `invalid_grant` shows up, run the runbook in
`~/code_projects/mcp-google/references/2026-04-14_pi-deployment.md` §11.
Takes about five minutes. The five `node grant.js` calls can even be
scripted, except each one still needs a browser click to consent.
**Why this might be fine:** you've been doing this already and it hasn't
been the worst thing in your week. Ship-it-and-forget-it wins.

---

### Option 2 — Move the four Workspace accounts to Internal-only OAuth clients
**Effort:** ~1 hour one-time + a `register-tools.js` code change
**What it eliminates:** weekly re-grant for `1421`, `dpumc`, `dpumc_admin`,
and `dpumc_yt` (4 of 5 accounts). `jrb` still needs weekly re-grant.
**Net gain:** probably still a weekly ritual but only for one account.

**How it would work:**

1. **For the 1421.me account** (`john@1421.me`):
   - Create a new Google Cloud project owned by your `1421.me` Workspace
     (sign in to GCP as `john@1421.me`, create project, make sure the
     organization selector shows `1421.me`, not "No organization")
   - Enable the APIs you use (Gmail, Drive, Calendar, Docs, Sheets, Script,
     Contacts, YouTube, Meet)
   - OAuth consent screen → **User type: Internal** → fill in app name,
     support email → save
   - Create OAuth client ID, type = **Desktop app**, download the JSON
   - Save it somewhere like `~/.google-mcp/gcp-oauth-1421.keys.json`

2. **For the dpumc.org accounts** (`john@dpumc.org`, `admin@dpumc.org`,
   `youtube@dpumc.org`):
   - Same thing, but signed in to GCP as an admin of the `dpumc.org`
     workspace. Likely means using `admin@dpumc.org` or another super-admin
     identity to create a project owned by the `dpumc.org` org.
   - OAuth consent screen → User type: Internal → save
   - New OAuth client → Desktop app → download
   - Save as `~/.google-mcp/gcp-oauth-dpumc.keys.json`
   - All three dpumc_* accounts can share this single dpumc-internal client
     because they're all users in the same workspace org.

3. **Keep the existing consumer-Gmail client for `jrb`** at
   `~/.google-mcp/gcp-oauth.keys.json`.

4. **Code change in `register-tools.js`:** replace the single
   `MCP_GOOGLE_OAUTH_CLIENT` env var with a per-account lookup. Something
   like: extend `accounts.js` so each account has an optional
   `oauth_client_file` field; in `register-tools.js`'s `loadOAuthClient()`,
   read the account-specific file instead of one global file.

5. **On the Pi:** deploy the new client files to `/etc/mcp-google/`
   (mode 640 root:1421MCP), update `/etc/mcp-google/server.env` to point
   at them, `grant.js` each of the four Workspace accounts once using
   their new client IDs, scp the fresh tokens up, restart the service.

**Caveat to verify:** I have not confirmed that you actually have admin
access to create new projects owned by `1421.me` and `dpumc.org`
organizations. If those Workspace orgs weren't set up with an org-level
GCP admin, you may need to enable Cloud console for the domain first, or
elevate your own account.

**Also:** if John's personal Gmail account owns the existing Google Cloud
project, there's no way to "convert" that project's ownership to a
Workspace org. You genuinely have to make new projects.

---

### Option 3 — Publish the existing External project to "In Production" and get verified
**Effort:** multi-week process, ongoing renewal, tiny chance of rejection
**What it eliminates:** all five accounts stop needing weekly re-grants
**Why you probably don't want this:**
- Need a privacy policy URL on a domain you own (e.g.
  `google-mcp.1421mcps.com/privacy`)
- Need a homepage URL
- Google will ask for a demo video showing your app using each restricted
  scope
- For `https://mail.google.com/` (full Gmail) they may require a CASA
  security assessment from a third-party vendor, which is **paid** and
  takes weeks
- The review process is human-reviewed and can ping-pong for minor
  paperwork issues
- Every year or so you re-verify

Not worth it for a single-user app. Listed here only for completeness.

---

### Option 4 — Hybrid: Option 2 for Workspace accounts + drop `jrb` from mcp-google
**Effort:** same as Option 2, plus a small scope reduction
**Idea:** if the weekly `jrb` re-grant is annoying but the other four
weren't the pain point, consider whether you actually use `jrb`'s Google
tools through mcp-google often. If it's rare, you could remove `jrb` from
`accounts.js` entirely and access your personal Gmail some other way
(direct in the Gmail UI, or a different tool). That's 4 accounts on
Option 2 and 1 account dropped.

---

## What I'd actually recommend

**Start with Option 1 for one more week.** Watch whether the `tokens`
event handler we added actually rewrites the token files correctly on
refresh — see the refresh-persistence follow-up in the Phase 5 wrap.
If the handler works, the weekly re-grant burden is five minutes.

**If the five-minute weekly ritual is still irritating after a month,
pick Option 2.** Creating two new OAuth clients and extending
`accounts.js` with a `oauth_client_file` field is one focused hour of
work, and it buys you long-lived tokens for four of the five accounts
permanently. The code change is small enough that you can ask a future
Claude Code session to do the whole thing in one pass.

**Do not pursue Option 3** unless a hypothetical future version of
mcp-google gets multiple users and needs to be "a real product."

---

## Quick reference: where to look in the Google Cloud Console

- OAuth consent screen (where you set User type + Publishing status):
  https://console.cloud.google.com/apis/credentials/consent
  (select the project in the top bar first)
- OAuth clients list (where you'd download a new `.keys.json`):
  https://console.cloud.google.com/apis/credentials
- Project picker — make sure you're in the right project BEFORE you
  change any of these settings; it's easy to edit the wrong consent
  screen.

To find out which project currently owns the OAuth client you're using:
```bash
cat ~/.google-mcp/gcp-oauth.keys.json | python3 -c 'import json,sys; d=json.load(sys.stdin)["installed"]; print("client_id:", d["client_id"]); print("project_id:", d["project_id"])'
```
The `project_id` field tells you which Cloud project to open in the
console.
