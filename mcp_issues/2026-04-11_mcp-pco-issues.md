# MCP PCO Server -- Issues & Wish List

Bugs and friction encountered while building an automated Sunday-service setup workflow for DPUMC, covering `mcp__pco-dpumc__dpumc_services` and `mcp__pco-dpumc__dpumc_publishing`. Tested 2026-04-11.

## Services -- bugs / friction

### `update_plan` -- top-level `title` parameter is silently ignored

**What happens:** Calling `update_plan` with `title` as a top-level parameter returns 200 OK with `title: null` in the response. The plan is not updated.

**Workaround:** Pass it inside `attributes`:
```json
{"action": "update_plan", "service_type_id": "...", "plan_id": "...",
 "attributes": {"title": "..."}}
```

**Suggested fix:** Either accept the top-level `title` param and pass it through to `attributes`, or remove the top-level `title` param from the schema since it doesn't work for `update_plan`. The current schema documents `title` as belonging to `create_plan` and several other actions, but a user reading the schema reasonably expects it to also work for `update_plan`.

---

## Publishing -- blockers

These prevent the workflow from being fully automated.

### `create_series` -- "Validation error: must exist"

**What happens:** Calling `create_series` with just a `title` returns:
```
Validation error: must exist
```
No indication of what "must exist." Likely needs a channel association or some other required FK, but there's no `channel_id` parameter exposed in the schema.

**Suggested fix:** Either expose a `channel_id` parameter (and make it required), or surface a clearer error message that names the missing field.

### `create_episode` -- multiple "cannot be assigned" rejections

When trying to create a fully-populated episode, the following fields all returned `Validation error: <field> cannot be assigned`:

- `services_plan_remote_identifier` -- this is the most painful one. There's no other way to link an episode to a Services plan via the API, but the PCO web UI does it as a single click. The whole point of creating the episode programmatically is so that the connection between Services plan and Publishing episode is automatic.
- `library_streaming_service` -- gets auto-inferred from `library_video_url`, so this is fine, but the schema/docs should say so.
- `published_live_at` -- but the field IS populated in the response (auto-inferred from channel defaults). Same complaint: the schema should say it's read-only / auto-derived.
- `published_to_library_at` -- same.

**Suggested fix:**
1. Allow `services_plan_remote_identifier` (and `services_service_type_remote_identifier`) on `create_episode` and `update_episode`. This is the single most important gap.
2. Mark the auto-derived fields as read-only in the schema documentation so callers don't waste time trying to set them.

### `create_episode_resource` -- chicken-and-egg with `kind`

**What happens:**
- Calling with `kind` set returns: `Validation error: kind cannot be assigned`
- Calling without `kind` returns: `Validation error: can't be blank` (likely referring to `kind`)

So it's impossible to create an episode resource via the API at all. You can list existing ones (`list_episode_resources`) but not create new ones.

**Context:** Every Sunday episode at DPUMC needs the same 3 resources (a giving fund link, a prayer-request people form, a newsletter signup people form). Right now these have to be added manually in the PCO UI for every episode.

**Suggested fix:** Either:
1. Allow `kind` to be assigned (with valid values being `giving_fund`, `people_form`, `url`, etc.), OR
2. Add a separate action like `add_giving_fund_resource`, `add_people_form_resource`, `add_url_resource` that takes the appropriate identifiers (giving fund ID for the first, form ID for the second).

Looking at how PCO's REST API actually works, episode resources of type `giving_fund` and `people_form` likely need an internal PCO ID (not just a URL) to associate them with the Giving fund or People form record. The MCP layer should expose those lookups or provide convenience actions that take the Church Center URL and resolve it to the right ID.

---

## Publishing -- nice-to-haves

- **Upload artwork via API.** `create_series` (Services and Publishing) and `update_series` should accept an artwork file path. Same for the YouTube `set_thumbnail` pattern -- it works great there. Currently John has to drop into the PCO UI just to upload a 16x9 image to a series he just created via API.
- **Better error responses.** Several errors said only `Validation error: must exist` or `Validation error: can't be blank` without naming the field. Echoing the field name would save guess-and-check time.

---

## Summary -- minimum API changes to fully automate Sunday workflow

Ranked by impact:

1. **`create_episode` should accept `services_plan_remote_identifier`.** Highest impact -- without it, the most valuable Publishing/Services link has to be done by hand.
2. **`create_episode_resource` should work at all** (currently impossible due to the `kind` field paradox).
3. **`create_series` (Publishing) should accept `channel_id`** (or whatever it actually needs -- the error doesn't say).
4. **Allow artwork uploads** on series in both Services and Publishing.
5. **`update_plan` top-level `title` should either work or be removed from the schema.**
6. **Mark auto-derived episode fields as read-only** in the docs/schema so callers aren't surprised.

With #1-#4 fixed, the entire weekly Sunday-service setup could be done by Claude in a single tool-call sequence with zero manual PCO UI steps.
