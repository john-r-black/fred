# OAuth Verification — copy-paste materials

Working doc for Phase 1 and 2 of the `mcp-google` OAuth verification path
(see `john/extend_token_time.md` for background). Every field below is
ready to paste directly into the Google Cloud Console OAuth consent
screen and the verification form.

GCP project: **avid-circle-492115-b0**
Consent screen URL: https://console.cloud.google.com/apis/credentials/consent

---

## OAuth consent screen fields

### App information
| Field | Value |
|---|---|
| App name | `1421 MCP Google Bridge` |
| User support email | `john.r.black@gmail.com` |
| App logo | *(skip — uploading a logo triggers extra brand verification)* |

### App domain
| Field | Value |
|---|---|
| Application home page | `https://john-r-black.github.io/mcp-google-app/` |
| Privacy policy link | `https://john-r-black.github.io/mcp-google-app/privacy.html` |
| Terms of service | *(leave blank)* |
| Authorized domains | `github.io` |

### Developer contact information
`john.r.black@gmail.com`

### Test users
Make sure all five are listed:
- `john.r.black@gmail.com`
- `john@1421.me`
- `john@dpumc.org`
- `admin@dpumc.org`
- `youtube@dpumc.org`

---

## Scopes to add

Paste each of these into the "Add or remove scopes" dialog. Google will
categorize them automatically into Non-sensitive / Sensitive / Restricted.

```
https://www.googleapis.com/auth/gmail.modify
https://www.googleapis.com/auth/gmail.send
https://www.googleapis.com/auth/gmail.settings.basic
https://www.googleapis.com/auth/drive
https://www.googleapis.com/auth/documents
https://www.googleapis.com/auth/spreadsheets
https://www.googleapis.com/auth/calendar
https://www.googleapis.com/auth/script.projects
https://www.googleapis.com/auth/contacts
https://www.googleapis.com/auth/youtube
https://www.googleapis.com/auth/meetings.space.created
https://www.googleapis.com/auth/admin.directory.user
https://www.googleapis.com/auth/admin.directory.group
```

Expected classification after Google sorts them:
- **Restricted:** `gmail.modify`, `drive`, `admin.directory.user`
- **Sensitive:** everything else

---

## Scope justifications

These are written to be pasted one-to-one into the "Justification" field
that appears under each restricted/sensitive scope in the verification
form. Each paragraph is tight, specific, and names the concrete API
calls the application makes. Keep the framing consistent: a single-user
personal automation tool, used only by its owner, with no data leaving
the owner's own infrastructure.

### gmail.modify
The application is a single-user personal automation bridge that lets
the account owner's local AI assistant act on his own Gmail mailbox.
The `gmail.modify` scope is needed so the assistant can read specific
messages and threads the owner asks about (`users.messages.get`,
`users.threads.get`), search his inbox for relevant correspondence
(`users.messages.list`), apply or remove labels to organize mail
(`users.messages.modify`, `users.labels.*`), archive or trash messages
on request (`users.messages.trash`), and mark messages read or unread.
No message content is stored, forwarded, logged, or analyzed outside
the account owner's own request-response loop with his private
assistant running on a device he owns.

### gmail.send
The application sends mail on the account owner's behalf when he asks
his local AI assistant to draft and send correspondence. This uses
`users.messages.send` and `users.drafts.send`. All outgoing messages
are explicitly requested by the owner via his assistant; the
application does not send mail autonomously, on a schedule, or in bulk.

### gmail.settings.basic
The application exposes two Gmail settings operations the owner
occasionally uses: managing `sendAs` aliases on his accounts
(`users.settings.sendAs.get` / `users.settings.sendAs.update`) and
turning the vacation responder on and off
(`users.settings.getVacation` / `users.settings.updateVacation`).
These are invoked only when the owner explicitly asks his assistant
to update those settings.

### drive
The application is a bridge between the account owner's local AI
assistant and his own Google Drive. The `drive` scope is needed
because the owner's documents and spreadsheets are not all created
through the app — most of them already exist in his Drive, and he
asks his assistant to open, read, and occasionally edit those
existing files. The narrower `drive.file` scope would not cover
this use case because it only grants access to files the application
itself created or that the user picks through a Google Picker, and
there is no picker in a headless MCP server. Concrete calls include
`files.list` and `files.get` to find files by name or ID,
`files.create` to write new files when the owner asks, and
`files.update` / `files.export` for content the owner wants read or
exported. No Drive data is cached, replicated, or shared beyond the
live response to the owner's request.

### documents
For reading and editing Google Docs that the owner asks his
assistant to work with. Calls include `documents.get` to read a
document's content and `documents.batchUpdate` to apply edits the
owner has described to the assistant (insert text, format paragraphs,
replace content). Scoped to the account owner's own documents only.

### spreadsheets
For reading and editing Google Sheets the owner works with.
`spreadsheets.values.get` and `spreadsheets.values.batchGet` to read
ranges, `spreadsheets.values.update` / `.append` / `.batchUpdate` to
write values, `spreadsheets.batchUpdate` for structural edits. Used
against the owner's own spreadsheets at his explicit request.

### calendar
Core feature of the bridge: the owner routinely asks his assistant
about upcoming events, asks it to schedule meetings, reschedule
events, and send invitations on his behalf across his personal,
family, and work calendars. Uses `events.list`, `events.get`,
`events.insert`, `events.patch`, `events.delete`, and
`calendarList.list`. The `calendar.events` scope alone would not be
enough because the application also needs to enumerate the owner's
accessible calendars before acting on events.

### script.projects
The owner maintains several Google Apps Script projects (used for
church administration and personal automations). He asks his
assistant to read the source of these scripts and occasionally
update them. Uses `projects.get`, `projects.getContent`, and
`projects.updateContent`. Scoped to the owner's own script projects.

### contacts
For reading the owner's Google Contacts when his assistant needs to
look up someone's email address or phone number to act on another
request (e.g. "send an email to Jane" where Jane is in his
contacts). Uses `people.connections.list` and `people.get`. Read-only
in practice; the contacts data is used only to resolve identifiers
for the current request and is not stored.

### youtube
The owner operates a YouTube channel for his church (the
`youtube@dpumc.org` account) and uses the assistant to manage video
metadata, playlists, and scheduled live streams for Sunday services.
Uses `videos.list`, `videos.update`, `playlists.*`, `playlistItems.*`,
and `liveBroadcasts.*`. All activity is scoped to channels the
account owner administers.

### meetings.space.created
For creating Google Meet spaces when the owner schedules a meeting
through his assistant. This is a narrowly scoped Meet API that only
allows managing Meet spaces the caller itself created. No access to
pre-existing meetings, no recording access.

### admin.directory.user (Workspace accounts only)
The owner administers two Google Workspace domains (`1421.me` and
`dpumc.org`) and asks his assistant to look up directory information
about users in those domains — finding a user's primary email,
resolving aliases, checking group membership — when handling
administrative requests. Uses `users.get` and `users.list` only.
The application does not create, modify, suspend, or delete
directory users; those actions are still performed manually in the
Admin Console.

### admin.directory.group (Workspace accounts only)
Same pattern as `admin.directory.user`: read-only lookups of
Workspace groups in the two domains the owner administers, used to
answer questions like "who is on the staff list" or "is this person
in the worship team group". Uses `groups.get`, `groups.list`, and
`members.list`. The application does not create, modify, or delete
groups or group membership programmatically.

---

## Homepage and privacy policy

Live now:
- https://john-r-black.github.io/mcp-google-app/
- https://john-r-black.github.io/mcp-google-app/privacy.html

Source: https://github.com/john-r-black/mcp-google-app

---

## Demo video — shot-by-shot script

Record ~3-5 minutes total. YouTube Unlisted is fine. The reviewer
wants to see: (1) the OAuth consent flow showing your branding and
scopes, (2) the app actually exercising each restricted scope.

### Setup before recording
- One browser window, fresh incognito
- Terminal window visible with the Pi SSH session ready
- Have test content ready: a throwaway Gmail message, a throwaway
  Drive document, an admin directory user you can look up

### Scene 1 — Consent flow (60 seconds)
1. In the terminal, run a fresh `node grant.js jrb` (delete the
   jrb token first to force a new consent).
2. Paste the printed URL into the browser.
3. Sign in as `john.r.black@gmail.com`.
4. Show the consent screen clearly — Google will display your app
   name ("1421 MCP Google Bridge"), the homepage URL, the privacy
   policy URL, and the full scope list. **Hover over each scope so
   the text is readable.**
5. Click Continue / Allow.
6. Show the "Authentication successful!" page.
7. Cut back to the terminal showing "Token saved to..."

### Scene 2 — Gmail (30 seconds)
- In Claude Code (or any MCP client pointed at the bridge), run a
  simple Gmail search on the jrb account, then read one of the
  returned messages. On-screen narration: "This exercises the
  gmail.modify scope."

### Scene 3 — Drive + Docs (30 seconds)
- Ask the assistant to list recent files in Drive, then read one
  Google Doc. Narration: "drive and documents scopes."

### Scene 4 — Calendar (20 seconds)
- List upcoming events on the jrb calendar. Narration: "calendar."

### Scene 5 — Admin directory (20 seconds, Workspace account only)
- Switch to the `1421` account tool. Look up a user by email in the
  directory. Narration: "admin.directory.user, read-only lookup."

### Scene 6 — Close (10 seconds)
- Narration: "All access is initiated by me, the sole user. No data
  is persisted or shared beyond the live request. Thanks for
  reviewing."

### Upload
- YouTube → Unlisted
- Title: `1421 MCP Google Bridge — OAuth verification demo`
- Description: paste the homepage URL and a one-line summary
- Copy the share link → paste into the verification form

---

## Domain verification

Because the homepage is on `github.io` (a shared domain), Google may
ask you to verify the domain via Search Console. For `github.io` you
cannot add DNS records, but you can use the HTML file method:
Search Console will give you a file like `google-abc123.html` — commit
it to the root of the `mcp-google-app` repo, push, and verify. I can
do that step directly when Google asks for it.
