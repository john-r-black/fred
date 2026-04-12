# DPUMC Sunday Service Setup Workflow

End-to-end process for setting up a Sunday worship service across PCO Services, YouTube, and PCO Publishing. Designed to be driven by Claude with one input document from John.

## Inputs John Provides

For each Sunday (or batch of Sundays for a series), John supplies:

- **Date** (e.g., 2026-04-12)
- **Series name** -- if standalone, the series name = the message title
- **Message title**
- **Scripture reference** (e.g., "Acts 5:27-32")
- **2-3 sentence synopsis** -- raw material for the YouTube/Publishing description
- **Communion?** -- yes/no (swaps slot 17: Invitation to Discipleship <-> Holy Communion)
- **Series artwork** -- absolute file path to a 16x9 image. Used for PCO Services series art, PCO Publishing series art, and the YouTube thumbnail.

Songs are out of scope -- the music director updates them directly in PCO Services on their own schedule.

## What Stays the Same Every Week

- **Plan structure**: 22 items, batch-created in PCO Services at the start of the year. Only ~6 of the 22 items change week-to-week (songs, sermon scripture, occasionally communion).
- **Service time**: 10:00 AM CT, livestream goes live at 9:55 AM CT
- **YouTube broadcast**: scheduled 14:45 UTC (9:45 AM CT), public, category 29, bound to stream `fo6OsNXk9Io8b6B_YNVPBg1650172008984074`
- **YouTube title format**: `Worship Service of Deer Park United Methodist Church (MM/DD/YYYY)`
- **Description footer** (YouTube + Publishing -- always identical text):
  ```
  John R. Black
  dpumc.org

  #dpumc #christianity #methodist #umc #<series_slug> #<scripture_slug> [+ message-specific tags]

  Don't forget to check-in (https://dpumc.churchcenter.com/check-ins)
  Share your prayer requests (https://dpumc.churchcenter.com/people/forms/270725)
  Give to support DPUMC (https://dpumc.churchcenter.com/giving)
  ```
- **Publishing channel ID**: `8116` (Sunday Worship)
- **Publishing service type**: `1028241` (Sunday Worship)
- **Episode resources** (always the same 3):
  - Tithes and Offerings -- `https://dpumc.churchcenter.com/giving/to/general` (featured)
  - Prayer Requests -- `https://dpumc.churchcenter.com/people/forms/270725`
  - Newsletter Sign-Up -- `https://dpumc.churchcenter.com/people/forms/273137`

## Execution Steps

### Step 1 -- PCO Services (plan + series)

1. Find the existing plan for the date via `list_plans` (filter `past`/`future`, sort by `sort_date`). The plans were batch-created Jan 3, 2026 for the whole year.
2. `update_plan` -- set the title and series_title via the `attributes` object:
   ```json
   {"attributes": {"title": "<message title>", "series_title": "<series name>", "public": true}}
   ```
   Note: passing `title` as a top-level parameter to `update_plan` does **not** work. It must be inside `attributes`.
3. `list_items` to find the Sermon item (it's the one titled "Sermon", typically sequence 11).
4. `update_item` -- set the sermon item's `description` to the scripture reference:
   ```json
   {"attributes": {"description": "<scripture ref>"}}
   ```
5. `create_series` (Services) with the series title. Save the returned series ID for reference.
   - **The artwork cannot be uploaded via API.** John must upload it manually in the PCO UI.

### Step 2 -- YouTube broadcast

1. `create_livestream`:
   - `title`: `Worship Service of Deer Park United Methodist Church (MM/DD/YYYY)`
   - `scheduledStartTime`: `<date>T14:45:00Z`
   - `privacyStatus`: `public`
   - `description`: prose paragraph derived from the synopsis + standard footer (see template below)
2. `bind_broadcast` -- bind the new broadcast to stream `fo6OsNXk9Io8b6B_YNVPBg1650172008984074`.
3. `update_video`:
   - `categoryId`: `29`
   - `tags`: `["dpumc", "christianity", "methodist", "umc", <series_slug>, <scripture_slug>, ...message tags]`
4. `set_thumbnail` with the absolute path to the artwork file.

**Save the broadcast ID** (== YouTube video ID) for Step 3.

### Step 3 -- PCO Publishing (episode)

1. `create_episode`:
   ```json
   {
     "title": "<message title>",
     "attributes": {
       "description": "<same description text used on YouTube>",
       "channel_id": "8116",
       "library_video_url": "https://www.youtube.com/watch?v=<video_id>"
     }
   }
   ```
   - Do **not** include `services_plan_remote_identifier`, `library_streaming_service`, `published_live_at`, or `published_to_library_at` -- the API rejects all of them as "cannot be assigned." `library_streaming_service` and `published_live_at` get inferred automatically from `library_video_url` and the channel defaults.
2. **Manual UI steps** (these cannot be done via the current MCP):
   - In PCO Publishing, link the episode to the Services plan.
   - Assign or create the Publishing series and upload artwork.
   - Add the 3 standard episode resources (Tithes/Offerings, Prayer Requests, Newsletter Sign-Up).
   - Set `published_to_library_at` if you want it different from the auto value.

## Description Template (YouTube + Publishing)

The description used on YouTube and PCO Publishing is **always identical**. Claude writes a fresh 2-3 paragraph prose intro from the synopsis -- no formulaic "this is the Nth message in..." opener -- followed by the standard footer.

```
<engaging prose intro derived from John's synopsis -- 2-3 sentences that
sound human and inviting, not templated>

John R. Black
dpumc.org

#dpumc #christianity #methodist #umc #<series_slug> #<scripture_slug> [+ message tags]

Don't forget to check-in (https://dpumc.churchcenter.com/check-ins)
Share your prayer requests (https://dpumc.churchcenter.com/people/forms/270725)
Give to support DPUMC (https://dpumc.churchcenter.com/giving)
```

## Standalone Weeks

If a Sunday isn't part of an ongoing series, treat the message title as the series name. Create the series in both Services and Publishing with that name. Make unique artwork for the week.

## Communion Sundays

In the plan, slot 17 normally contains "Invitation to Discipleship." On communion Sundays, replace that item title with "Celebration of Holy Communion" via `update_item`.

## Reference IDs

| Thing | ID |
|---|---|
| PCO Services -- Sunday Worship service type | `1028241` |
| PCO Publishing -- Sunday Worship channel | `8116` |
| YouTube -- bound stream | `fo6OsNXk9Io8b6B_YNVPBg1650172008984074` |
| YouTube -- channel | Deer Park UMC |

## Known Limitations

The current MCP servers can't do everything end-to-end. See `mcp_issues/2026-04-11_mcp-pco-issues.md` for the list of API gaps that, if fixed, would let this workflow run with zero manual UI steps.
