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
| **Preacher** | no | **Defaults to John R. Black (`92412499`) when not specified.** Only required if someone else is preaching; in that case John will name the person and you look them up via `list_speakers`. |
| **Series artwork** | yes | Absolute file path to a 16x9 image on John's disk (typically under `D:\OneDrive - DPUMC - John\...`). One file feeds Services series art, Publishing series art, and the YouTube thumbnail. |

**Communion is not an input.** First Sunday of each month = communion, every other Sunday = no communion. More importantly, the plans are already correctly templated when batch-created at the start of the year — communion Sundays already have the "Celebration of Holy Communion" item in place, non-communion Sundays have "Invitation to Discipleship". Don't rename or edit these items; the templates are authoritative.

**Hashtags are not an input.** The tag set is fixed at `#dpumc #<series_slug> #<scripture_slug>` — three tags, no more. Don't invent message-specific tags and don't ask John for them.

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

**Order of operations**:

```
Pre-step (Services): create series + upload artwork   ← runs ONCE per series
      │
      ▼
Step 1 (Services)  ─┬─→  Step 3 (Publishing)
Step 2 (YouTube)   ─┘        ↑
                             needs video_id from step 2
                             needs plan_id from step 1
```

The pre-step must complete before *any* Step 1 or Step 3 work starts — `update_plan` needs `services_series_id` to link the plan, and `create_episode_from_services` needs the series art already in place or Publishing inherits a placeholder. Once the pre-step is done, Steps 1 and 2 are independent per week and can run in parallel; Step 3 depends on both.

**Data that passes between steps**:

| Value | Produced by | Consumed by |
|---|---|---|
| `services_series_id` | Pre-step `create_series` | Pre-step `upload_series_artwork`, Step 1.2 `update_plan` |
| `plan_id` (Services) | Step 1.1 `list_plans` | Step 1.2-1.4, Step 3.1 |
| `sermon_item_id` | Step 1.3 `list_items` | Step 1.4 `update_item` |
| `video_id` (YouTube) | Step 2.1 `create_livestream` | Steps 2.2-2.5, Step 3.2, Step 3.3 |
| `episode_id` (Publishing) | Step 3.1 `create_episode_from_services` | Steps 3.2-3.5 |
| `publishing_series_id` | Step 3.1 (or Step 3.1.fix) | Step 3.4 (art check) |
| `episode_time_id` | Step 3.3 `list_episode_times` | Step 3.3 `update_episode_time` |

**Multi-week handling**: when John provides a whole series, run the pre-step once, then loop Steps 1–3 per week. The per-week steps are uniform — no "first week only" conditional. Every week passes the same `services_series_id` into `update_plan`.

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

## Pre-step — Services series creation

Runs **once per series** before any per-week work. For a standalone week, still run it — treat the message as a one-week series.

1. **Create the series**. `create_series` with `title: "<series name>"`. Save the returned ID as `services_series_id`.
2. **Upload artwork**. `upload_series_artwork` with `series_id: services_series_id` + `file_path` (absolute path John provided). The MCP uploads to PCO's file service and attaches it.

Both must complete before Step 1.2 runs for any week. `update_plan` needs `services_series_id` to link the plan (title-based auto-match does NOT work on update — you must pass the ID explicitly), and `create_episode_from_services` in Step 3.1 needs the Services series art already in place or the Publishing episode inherits a placeholder that's hard to fix after the fact.

## Step 1 — PCO Services (per week)

1. **Find the plan**. `list_plans` with `service_type_id: "1028241"`, `filter: "future"`, `order: "sort_date"`. Iterate the results and pick the plan whose `dates` field matches the target Sunday (e.g. `"April 19, 2026"`). If no plan matches, stop and ask John — do NOT `create_plan`.
2. **Update plan metadata**. `update_plan` with:
   ```json
   {"attributes": {"title": "<message title>", "series_title": "<series name>", "series_id": "<services_series_id>", "public": true}}
   ```
   `series_id` is **required** — passing only `series_title` will leave the plan unlinked from the series and its artwork.
3. **Find the Sermon item**. `list_items` and pick the item where `title == "Sermon"` and `item_type == "item"`. Save `sermon_item_id`. Do NOT rely on sequence number — item order may vary.
4. **Set the scripture**. `update_item` with:
   ```json
   {"attributes": {"description": "<scripture ref>"}}
   ```

## Step 2 — YouTube broadcast

Write the description blurb first (see § Description Template below). You'll reuse the exact same string in Step 3.2.

1. **Create the broadcast**. `create_livestream` with:
   - `title`: `Worship Service of Deer Park United Methodist Church (MM/DD/YYYY)` — use the target Sunday date
   - `scheduledStartTime`: `<date>T14:50:00Z` (CDT) or `<date>T15:50:00Z` (CST)
   - `privacyStatus`: `public`
   - `description`: the blurb string

   Save the returned `id` as `video_id`.
2. **Bind to the DPUMC stream**. `bind_broadcast` with `broadcastId: video_id`, `streamId: "fo6OsNXk9Io8b6B_YNVPBg1650172008984074"`.
3. **Set category + tags**. `update_video` with `videoId: video_id`, `categoryId: "29"`, `tags: ["dpumc", "<series_slug>", "<scripture_slug>"]`.
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

This auto-creates the Publishing episode, attaches (or creates) a matching Publishing series with the same title as the Services series, inherits the Services series art **onto the Publishing series** (not the episode — see Check B), and establishes the Services↔Publishing bidirectional link.

**Race condition handling**: the action returns a `warning: "linked_publishing_episode_id not found on plan"` roughly every time under fast/parallel execution. The job completes but the plan read is too fast. When you see this warning, call `get_plan` on the Services plan to retrieve `linked_publishing_episode_id`. In practice one follow-up read is enough; if still missing, retry up to 3 times 2 seconds apart, then stop and report.

**Ghost Publishing series gotcha**: if a prior failed run or manual cleanup left a stale Publishing series with the same title (even empty), `create_episode_from_services` will NOT reuse it — it creates a new series and appends `(1)` to the title. If you see `"Live Like This (1)"` (or similar) on the Publishing series of the first week's episode, there's a duplicate upstream. Report this to John and offer to delete the stale one and rename the new one back. Weeks 2-N of the same run will correctly match the `(n)`-suffixed series once it exists.

**Required post-creation checks**:

- **Check A: series_id populated.** `get_episode` on the new episode (pass `include: "series"`). The `series_id` attribute should be non-null. Post-reorder (pre-step runs before Step 3.1), this almost always passes on the first try. If it's null, the import failed to create/link the Publishing series — stop and report to John. Do NOT try to fix via `list_series`: that endpoint returns every series in the org as one giant response that will overflow the tool result; and title-matching is unreliable due to the ghost-series gotcha above.
- **Check B: art is not a placeholder.** (Expected to fire — the episode-level art inheritance is known-broken.) On the same `get_episode` result, look at `art.attributes.source`. If it equals `"default"` (or `name` ends in `-large.png`), fix it as follows:
  - **Preferred (cheap)**: `get_series` on the Publishing series returned by Check A → read `art.attributes.signed_identifier` (a long base64-ish string) → `update_episode` with `{"attributes": {"art": "<that string>"}}`. Note: `art` is set as a bare string, NOT an object. This reuses the artwork already attached to the Publishing series — no re-upload, no cache.
  - **Fallback (fresh upload)**: `upload_episode_art` with `episode_id` + `file_path`. Use this only when the Publishing series itself also has no art — in the current flow that shouldn't happen because the pre-step uploads to Services and the Services→Publishing series inheritance does work.

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

#dpumc #<series_slug> #<scripture_slug>

Don't forget to check-in (https://dpumc.churchcenter.com/check-ins)
Share your prayer requests (https://dpumc.churchcenter.com/people/forms/270725)
Give to support DPUMC (https://dpumc.churchcenter.com/giving)
```

**Signoff rule**: the name above `dpumc.org` is the **preacher's name**, not the publisher. Readers see it as attribution for the message, not the person who uploaded the video. Use John's name when John preaches (default), swap to the guest preacher otherwise.

**Intro style**: focus on the message, not the story. If John's synopsis recounts a biblical narrative, don't retell the narrative — distill the message and speak to the reader's life.

---

## Known limitations

As of 2026-04-14 the MCP closes every gap except these cases:

1. **New guest speakers**: PCO has no `create_speaker` API. When a brand-new guest preaches for the first time ever, John must add them to PCO Publishing → Speakers in the web UI first. Subsequent sermons by the same guest are fully automated.
2. **YouTube Studio per-broadcast settings**: the `update_video` MCP action doesn't expose `madeForKids` ("Altered content") or `recordingDetails.location`. Both typically inherit from channel defaults once set — verify once, then forget.
3. **Publishing episode art inheritance**: `create_episode_from_services` puts the Services series art on the Publishing *series* but leaves the *episode* with a default placeholder. Always patch via Check B. See 3.1.
4. **`list_series` (Publishing) response size**: returns every series in the org in one response and overflows the MCP result budget. Don't use it for title-based lookup; get the `publishing_series_id` from the episode via `get_episode` with `include: "series"`.
5. **`create_series` (Publishing) is not usable from the MCP**: validation rejects every variant of `channel_id`/`channel` in attributes. There is no documented way to create a Publishing series directly via this MCP — which is fine, because `create_episode_from_services` creates the Publishing series as a side effect of the first episode import.

Full API-gap history and MCP bug workarounds: `gh issue list --repo john-r-black/mcp-pco`.
