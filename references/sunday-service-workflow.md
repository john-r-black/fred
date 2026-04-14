# DPUMC Sunday Service Setup Workflow

End-to-end process for setting up a Sunday worship service across PCO Services, YouTube, and PCO Publishing. Designed to be driven by Claude given a short series/week input document from John.

## MCP tools used

| Purpose | Tool name |
|---|---|
| PCO Services (plans, items, series, artwork) | `mcp__pco-dpumc__dpumc_services` |
| PCO Publishing (episodes, series, speakerships) | `mcp__pco-dpumc__dpumc_publishing` |
| YouTube (livestream, thumbnail, playlist) | `mcp__google-dpumc-yt__dpumc_yt_youtube` |

**Gotcha**: there is also a `mcp__google-dpumc-admin__dpumc_admin_youtube` tool — it looks identical but fails with `"user is not enabled for live streaming"` on `create_livestream`. Always use `dpumc_yt_youtube`, never `dpumc_admin_youtube`.

## Inputs John provides

| Field | Required | Notes |
|---|---|---|
| **Date** | yes | e.g. `2026-04-19`. Plans are batch-created at the start of the year; find the existing plan via `list_plans`, never `create_plan`. |
| **Series name** | yes | If this is a standalone week, `series_name` == `message_title`. |
| **Message title** | yes | Plan title in Services, episode title in Publishing. |
| **Scripture reference** | yes | e.g. `Luke 24:13-35`. Goes on the Sermon plan item as its description. |
| **2-3 sentence synopsis** | yes | Raw material for the YouTube/Publishing description. Rewrite into a blurb — never paste the synopsis verbatim. |
| **Preacher** | if not John | Default is John Black (`92412499`). Otherwise John will name the person; look them up via `list_speakers`. |
| **Series artwork** | yes | Absolute file path to a 16x9 image on John's disk (typically under `D:\OneDrive - DPUMC - John\...`). One file feeds Services series art, Publishing series art, and the YouTube thumbnail. |

**Communion is not an input.** First Sunday of each month = communion, every other Sunday = no communion. More importantly, the plans are already correctly templated when batch-created at the start of the year — communion Sundays already have the "Celebration of Holy Communion" item in place, non-communion Sundays have "Invitation to Discipleship". Don't rename or edit these items; the templates are authoritative.
| **Message-specific hashtags** | optional | Extra tags beyond the always-included `dpumc <series_slug> <scripture_slug>`. |

**Before running the workflow**: verify every required field is present. If anything is missing, ask John. Don't run partial and try to patch later — back out and ask.

Songs are out of scope — the music director updates them directly in PCO Services on their own schedule.

### Example input document

```
Series: And He Walks with Me
Artwork: D:\OneDrive - DPUMC - John\...\And He Walks With Me.jpg

Week 1 — 2026-04-19
  Title: And He Walks with Me
  Scripture: Luke 24:13-35
  Preacher: Joel Coulter
  Communion: no
  Synopsis: Two disciples walking to Emmaus unexpectedly encounter
    the risen Christ. They don't recognize him until he breaks bread.
    The message is about finding Jesus when we walk the road alongside others.

Week 2 — 2026-04-26
  Title: On the Road
  Scripture: Acts 8:26-40
  ...
```

Any prose format is acceptable as long as every required field is present.

## Execution overview

**Order of operations per Sunday**:

```
Step 1 (Services)  ─┬─→  Step 3 (Publishing)
Step 2 (YouTube)   ─┘        ↑
                             needs video_id from step 2
                             needs plan_id from step 1
```

Steps 1 and 2 are independent — run in parallel where possible. Step 3 depends on both.

**Data that passes between steps**:

| Value | Produced by | Consumed by |
|---|---|---|
| `plan_id` (Services) | Step 1.1 `list_plans` | Step 1.2-1.5, Step 3.1 |
| `sermon_item_id` | Step 1.3 `list_items` | Step 1.4 `update_item` |
| `services_series_id` | Step 1.5 `create_series` (first week only) | Step 1.5 `upload_series_artwork` |
| `video_id` (YouTube) | Step 2.1 `create_livestream` | Steps 2.2-2.5, Step 3.2, Step 3.3 |
| `episode_id` (Publishing) | Step 3.1 `create_episode_from_services` | Steps 3.2-3.5 |
| `publishing_series_id` | Step 3.1 (or Step 3.1.fix) | Step 3.4 (art check) |
| `episode_time_id` | Step 3.3 `list_episode_times` | Step 3.3 `update_episode_time` |

**Multi-week handling**: when John provides a whole series, loop over the weeks and run steps 1-3 for each. Services series creation (step 1.5) runs **once for the whole series on the first week**; skip it on subsequent weeks — setting `series_title` on the plan auto-links to the existing series by title match.

**Error handling rule**: if any step fails, **stop and report to John immediately**. Don't try to patch partial state yourself. John would rather know at step 2 than find a half-broken episode on Sunday morning.

**Idempotency / already-populated rule**: if any field you're about to set is already populated with a value that **differs** from John's input, stop and ask. If it matches, continue (idempotent replay is safe). This catches the case where John already ran part of the workflow manually or from a previous conversation.

## Constants

| Thing | Value |
|---|---|
| Service time | 10:00 AM Central, feed goes live 9:55 AM |
| YouTube broadcast start | **9:50 AM Central** (`14:50:00Z` during CDT Mar–Nov; `15:50:00Z` during CST Nov–Mar) |
| YouTube title format | `Worship Service of Deer Park United Methodist Church (MM/DD/YYYY)` |
| YouTube bound stream ID | `fo6OsNXk9Io8b6B_YNVPBg1650172008984074` |
| YouTube "Worship Services" playlist ID | `PLg0k5q7bY9EFqmZezemOhcNehUHtc_NIl` |
| YouTube category ID | `29` |
| Publishing channel ID (Sunday Worship) | `8116` |
| Publishing `assigning` valid values | `["title", "series"]` |
| Services service type ID (Sunday Worship) | `1028241` |
| Standard hashtags (always included) | `dpumc <series_slug> <scripture_slug>` |
| John Black speaker ID | `92412499` |
| Joel Coulter speaker ID | `75157708` |
| Publishing "publish to library" time | Sunday **11:00 AM Central** (`T16:00:00Z` CDT / `T17:00:00Z` CST) |

**3 standard episode resources** (Tithes/Offerings, Prayer Requests, Newsletter Sign-Up) are attached to every new episode automatically as channel defaults — **no per-episode action needed**.

## Slug format

For the `<series_slug>` and `<scripture_slug>` placeholders in hashtags:

- **Series slug**: PascalCase, remove spaces and punctuation. `"And He Walks with Me"` → `AndHeWalksWithMe`. `"40 Days in the Wilderness"` → `40DaysInTheWilderness`.
- **Scripture slug**: `Book + Chapter`, no verse range, no spaces. `"Luke 24:13-35"` → `Luke24`. `"1 Corinthians 13:1-13"` → `1Corinthians13`. For multi-chapter references, pick the first chapter.

---

## Step 1 — PCO Services

1. **Find the plan**. `list_plans` with `service_type_id: "1028241"`, `filter: "future"`, `order: "sort_date"`. Iterate the results and pick the plan whose `dates` field matches the target Sunday (e.g. `"April 19, 2026"`). If no plan matches, stop and ask John — do NOT `create_plan`.
2. **Update plan metadata**. `update_plan` with:
   ```json
   {"attributes": {"title": "<message title>", "series_title": "<series name>", "public": true}}
   ```
3. **Find the Sermon item**. `list_items` and pick the item where `title == "Sermon"` and `item_type == "item"`. Save `sermon_item_id`. Do NOT rely on sequence number — item order may vary.
4. **Set the scripture**. `update_item` with:
   ```json
   {"attributes": {"description": "<scripture ref>"}}
   ```
5. **Services series creation** (first week of a new series / standalone weeks only — skip for subsequent weeks):
   1. `create_series` with `title: "<series name>"`. Save the returned series ID.
   2. `upload_series_artwork` with `series_id` + `file_path` (the absolute path John provided). The MCP uploads to PCO's file service and attaches it.

   Both sub-steps must complete **before** Step 3.1 runs. If the Services series has no art when `create_episode_from_services` imports it, the Publishing series will inherit a placeholder — hard to fix after the fact.

## Step 2 — YouTube broadcast

Write the description blurb first (see § Description Template below). You'll reuse the exact same string in Step 3.2.

1. **Create the broadcast**. `create_livestream` with:
   - `title`: `Worship Service of Deer Park United Methodist Church (MM/DD/YYYY)` — use the target Sunday date
   - `scheduledStartTime`: `<date>T14:50:00Z` (CDT) or `<date>T15:50:00Z` (CST)
   - `privacyStatus`: `public`
   - `description`: the blurb string

   Save the returned `id` as `video_id`.
2. **Bind to the DPUMC stream**. `bind_broadcast` with `broadcastId: video_id`, `streamId: "fo6OsNXk9Io8b6B_YNVPBg1650172008984074"`.
3. **Set category + tags**. `update_video` with `videoId: video_id`, `categoryId: "29"`, `tags: ["dpumc", "<series_slug>", "<scripture_slug>", ...message tags]`.
4. **Set thumbnail**. `set_thumbnail` with `videoId: video_id`, `filePath: <artwork file path>`.
5. **Add to playlist**. `add_to_playlist` with `playlistId: "PLg0k5q7bY9EFqmZezemOhcNehUHtc_NIl"`, `videoId: video_id`. Do NOT pass `position` — playlist is auto-sorted.

John will manually verify "Altered content = No" and "Location = Deer Park United Methodist Church" in YouTube Studio once per new channel state; these inherit from channel defaults once set, so no per-broadcast action.

**Save `video_id` — you need it for Step 3.2 and 3.3.**

## Step 3 — PCO Publishing

### 3.1. Import the plan into a new episode

`create_episode_from_services` with:
```json
{
  "channel_id": "8116",
  "plan_id": "<services plan id>",
  "service_type_id": "1028241",
  "assigning": ["title", "series"]
}
```

This auto-creates the Publishing episode, attaches (or reuses) the matching Publishing series, copies Services series art into a first-time Publishing series, and establishes the Services↔Publishing bidirectional link.

**Race condition handling**: the action returns a `warning: "linked_publishing_episode_id not found on plan"` about 30% of the time — the job completes but the plan read is too fast. If you see this warning, wait 2 seconds and call `get_plan` on the Services plan; `linked_publishing_episode_id` will be there. Retry up to 3 times, 2 seconds apart. If still missing after 3 retries, stop and report.

**Required post-creation checks** (don't skip these — both are known-buggy):

- **Check A: series_id populated.** `get_episode` on the new episode. If `series_id` is null, the import failed to link the Publishing series. Fix: `list_series` (Publishing) and find the entry whose `title` matches the series name. `update_episode` with `{"attributes": {"series_id": "<id>"}}`.
- **Check B: art is not a placeholder.** On the same `get_episode` result, look at `art.attributes.source`. If it equals `"default"` (or the `name` ends in `-large.png`), the episode has the PCO default placeholder. Fix via one of:
  - **A (cheap)**: `get_series` on the Publishing series → read `art.attributes.signed_identifier` → `update_episode` with `{"attributes": {"art": "<that string>"}}` (bare string, not an object).
  - **B (fresh upload)**: `upload_episode_art` with `episode_id` + `file_path`. Use this when the Publishing series itself also has no art.

### 3.2. Populate remaining episode fields

`update_episode` with:
```json
{
  "attributes": {
    "description": "<same blurb used on YouTube>",
    "library_video_url": "https://www.youtube.com/watch?v=<video_id>",
    "published_to_library_at": "<sunday>T16:00:00Z"
  }
}
```

- `description` must be **byte-identical** to the YouTube description — don't regenerate.
- `library_video_url` populates the "Video on-demand library" field.
- `published_to_library_at` = Sunday **11:00 AM Central** (`T16:00:00Z` CDT / `T17:00:00Z` CST).
- Never send `services_plan_remote_identifier`, `library_streaming_service`, or `published_live_at` — they are auto-derived or read-only.

### 3.3. Set the live video URL on the EpisodeTime

DPUMC's Sunday Worship channel has "My livestream URL stays the same from week to week" **unchecked** (because the URL changes every week), which forces episodes into "Time-specific livestream URLs" mode. In that mode, `episode.video_url` is ignored by the Watch Live panel — the URL must live on each `EpisodeTime` child record instead.

Two calls:
1. `list_episode_times` with `episode_id` — DPUMC plans have exactly one service time, so the first (only) result is what you want. Save `episode_time_id`.
2. `update_episode_time` with `episode_id`, `episode_time_id`, `attributes: {"video_url": "https://www.youtube.com/watch?v=<video_id>"}`. Use the **same YouTube URL** as `library_video_url` from Step 3.2 — DPUMC's convention is identical URLs on Watch Live and On-demand.

### 3.4. Attach the speaker

`create_speakership` with `episode_id` and `speaker_id`. Default speaker is John Black (`92412499`); for any other preacher John names, `list_speakers` first and find the matching `formatted_name` (case-insensitive contains match on first name + last name is usually enough).

**If John names a preacher not in the list**: stop and tell John. PCO doesn't expose `create_speaker` via API — John must add them to Publishing → Speakers in the UI first, then re-run this step.

### 3.5. Final verification

Before reporting success, `get_episode` once and confirm:

- [ ] `title` matches John's input
- [ ] `description` is the final blurb (not the synopsis)
- [ ] `series_id` is populated (not null)
- [ ] `art.attributes.source` is NOT `"default"`
- [ ] `services_plan_remote_identifier` matches the Services plan ID
- [ ] `library_video_url` is the YouTube URL
- [ ] `published_live_at` is set to the Sunday morning time
- [ ] `published_to_library_at` is set to Sunday 11:00 AM Central
- [ ] `video_url` on the episode_time (via `list_episode_times`) is the YouTube URL
- [ ] `speakerships_ids` is non-empty

Report the episode URL (`church_center_url`) to John along with the list of what you set. If any check fails, report which and stop.

---

## Description template

The description is used identically on YouTube and PCO Publishing. Write a fresh 2-3 sentence prose intro from John's synopsis — no formulaic "this is the Nth message in..." opener — followed by the standard footer.

```
<engaging 2-3 sentence prose intro derived from the synopsis — human and
inviting, not templated or formulaic>

<preacher name>
dpumc.org

#dpumc #<series_slug> #<scripture_slug> [+ message tags]

Don't forget to check-in (https://dpumc.churchcenter.com/check-ins)
Share your prayer requests (https://dpumc.churchcenter.com/people/forms/270725)
Give to support DPUMC (https://dpumc.churchcenter.com/giving)
```

**Signoff rule**: the name above `dpumc.org` is the **preacher's name**, not the publisher. Readers see it as attribution for the message, not the person who uploaded the video. Use John's name when John preaches (default), swap to the guest preacher otherwise.

**Intro style**: focus on the message, not the story. If John's synopsis recounts a biblical narrative, don't retell the narrative — distill the message and speak to the reader's life.

---

## Known limitations

As of 2026-04-13 the MCP closes every gap except two rare cases:

1. **New guest speakers**: PCO has no `create_speaker` API. When a brand-new guest preaches for the first time ever, John must add them to PCO Publishing → Speakers in the web UI first. Subsequent sermons by the same guest are fully automated.
2. **YouTube Studio per-broadcast settings**: the `update_video` MCP action doesn't expose `madeForKids` ("Altered content") or `recordingDetails.location`. Both typically inherit from channel defaults once set — verify once, then forget.

Full API-gap history and MCP bug workarounds: `mcp_issues/pco_mcp_issues/2026-04-11_mcp-pco-issues.md`.
