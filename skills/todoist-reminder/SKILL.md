---
name: todoist-reminder
description: Set a Todoist reminder for the founder so he gets a push notification on his devices. Use whenever he asks to be reminded, to "check back" on something, or to follow up in N days.
---

# Todoist reminder

Creates a task in the founder's Todoist. This is his push channel: a properly
set task fires a notification on all his devices. It is the answer to "how do I
remember to X" — never leave such a request at a todo-list entry or a memory
note; those are passive.

## Hard rules

1. **Always set a TIME, never a bare date.** A date-only task shows up in the
   list but does not push a notification. If he didn't name a time, default to
   `10:00`. If he didn't name a date, ask yourself what the task implies (e.g.
   "in a week" → +7 days) — only ask him when genuinely ambiguous.
2. **Always write a `description`** — one or two sentences answering: what is
   this about, and exactly what should he tell Claude (or do himself) when it
   fires. He will read it cold, days later, with zero context. If the action is
   "open a session and continue some work", spell out the phrase to say and any
   id needed (todo id, spec path). Write it so the next session can run on the
   description alone.
3. **Content is a short imperative title** (≤ ~8 words). Detail goes in the
   description, not the title.
4. **Always pick the project from the current work context — never default to
   Inbox silently.** Fetch his projects (`GET /api/v1/projects`) and match:
   work in the Esora repo / anything Esora-product-related → **Esora**; other
   client/professional work → **Work**; errands, health, purchases, personal
   life → the matching personal project (Personal, Body, Money, Buy, Family,
   Social, …). Pass `project_id` in the create call. If nothing clearly fits,
   use Inbox and tell him you did, so he can redirect.

## API

Token: `~/.config/todoist.env` (`TODOIST_API_TOKEN=...`, file is chmod 600).
Endpoint: `https://api.todoist.com/api/v1/tasks` (the `/rest/v2/` endpoints are
dead — they return a deprecation notice, not JSON).

```bash
source ~/.config/todoist.env
curl -s -X POST "https://api.todoist.com/api/v1/tasks" \
  -H "Authorization: Bearer $TODOIST_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "content": "Dedup shadow review — flip decision",
    "description": "Open any Claude session and say: \"dedup shadow review\" (todo b107ea72).",
    "due_string": "2026-08-11 at 10:00"
  }'
```

- `due_string` in the form `YYYY-MM-DD at HH:MM` parses reliably and lands in
  his local timezone. Verify the response's `due.date` includes the `THH:MM:SS`
  part — if the time is missing, the reminder will not fire; fix and retry.
- A successful create returns the task JSON (`id`, `due`, …). A 401 means the
  token was rotated — ask him for a new one and update `~/.config/todoist.env`.
- To update or delete later: `POST /api/v1/tasks/<id>` (update) and
  `DELETE /api/v1/tasks/<id>`. Moving between projects is its own endpoint:
  `POST /api/v1/tasks/<id>/move` with `{"project_id": "..."}`.
- To complete a task: `POST /api/v1/tasks/<id>/close` (returns 204). The id is
  the last hyphen-separated segment of an `app.todoist.com/app/task/<slug>-<id>`
  link. Confirm with `GET /api/v1/tasks/<id>` → `checked: true`.

## After creating

Echo back: title, exact local fire time, **project**, and the description —
so he can correct any of them on the spot.

