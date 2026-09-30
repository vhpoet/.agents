---
name: telegram
description: Read and write the user's personal Telegram account (MTProto) — check history, list chats, draft a message into the input box, or send. Use for "draft a message to X", "what did X say".
---

# Telegram

All commands run through one CLI backed by the user's logged-in personal account.
It lives in `~/localhost/telegram` (keys in `.env`, session in `session.txt`) and must
run from that directory because of Yarn PnP:

```bash
cd ~/localhost/telegram && yarn node tg.mjs <command> ...
```

## Commands

```bash
yarn node tg.mjs dialogs [--limit N] [--json]          # recent conversations (default 40)
yarn node tg.mjs history <who> [--since 7d] [--limit N] [--json]
yarn node tg.mjs export <who> [--since 7d] [--limit N]   # full export to exports/<name>/:
                                                       # conversation.md + messages.json + media/,
                                                       # voice messages transcribed via Gemini
yarn node tg.mjs draft <who> --message "text" [--links] # draft into the chat's input box
yarn node tg.mjs draft <who> --file /path/to/text [--links] # multiline draft
yarn node tg.mjs get-draft <who>                       # show what draft the server holds for a chat
yarn node tg.mjs clear-draft <who>
yarn node tg.mjs send <who> --message "text" [--links]  # sends immediately — see policy below
yarn node tg.mjs edit <who> <message-id> --file path [--links] # edit an already-SENT message of the user's
                                                       # (id from history --json; send policy applies)
yarn node tg.mjs me                                    # sanity check: who is logged in
yarn node tg.mjs resolve-phone +10000000000            # is this number on Telegram? prints name/id/username;
                                                       # uses contacts.resolvePhone, never adds a contact
```

**Two accounts.** Every command runs as the user's personal account by default. Add
`--as support` to run it as **@EsoraSupport**, the separate Esora support account where
organizers (Anna, Ben, …) write in — `history anna --as support`, `draft anna --as support
--message "…"`. Its session is read from the esora backend's `.env`
(`TELEGRAM_SUPPORT_SESSION`), never stored here; `login` is personal-only. Organizer
support threads are NOT visible from the personal account (there "Esora Support" is just
the user's own chat with that account), so when the user says "on esorasupport" use
`--as support`. The same threads are also ingested into esora's `dm_message` table
(`platform = 'telegram_support'`), which is the read-only fallback.

`<who>` accepts an `@username`, a phone number, or a plain name — names are matched
against dialog titles and contacts. If ambiguous, the CLI prints the candidates and
exits with code 2; re-run with the `@username` or a more specific name.
`--since` accepts `7d` / `24h` / `30m` / `2026-07-01`. History defaults to the last
50 messages; with `--since` it fetches up to 2000.

**Voice notes**: `history` shows media as bare placeholders (`[document]`, `[voice]`).
Whenever a conversation contains voice/audio you need the content of, use `export` — it
downloads media and inlines Gemini transcripts in `conversation.md`.

## Draft vs send — policy

- **Default to `draft`.** "Draft a message to X", "write to X", "prepare a reply" → save a
  draft. It appears in the chat's input box on the user's phone/desktop instantly; they
  review and hit send themselves.
- **Before revising a draft you saved earlier, `get-draft` first.** The user manually
  edits drafts in their Telegram clients, so the text you last saved may be stale —
  overwriting from your own copy silently destroys their edits. Always read the server's
  current draft, diff it against what you last saved, carry the user's changes into the
  new version, and only then save. This applies to every revision of an existing draft,
  even one you wrote seconds ago in the same session.
- **`send` only when the user explicitly says to send** ("send it", "send X a message
  saying …"). Never send as a convenience upgrade of a drafting request, and never
  send bulk/broadcast messages.
- A new draft overwrites any existing draft in that chat — if unsure, mention it.
- **The clobber trap**: drafts are last-write-wins across sessions. Any Telegram client
  that has the target chat OPEN with an empty input box pushes that empty state back as
  the newest draft, silently deleting a just-saved one — Telegram Desktop left sitting on
  the chat is the usual culprit, and it can strike minutes later. The `draft` command
  defends itself: it verifies by read-back, watches the server draft for ~9s, re-saves up
  to 3 times if another session wipes it, and if it keeps losing, parks the text in the
  user's Saved Messages and explains. If the user still reports a missing draft, run
  `get-draft` to see what the server actually holds: if the draft is there, it's a client
  display lag; if it's gone, ask the user to navigate away from that chat in EVERY
  Telegram app (chat list is enough), then re-save.
- Always pass `--links` and write links as `[words](https://url)` so the reader sees
  clickable words, never a raw URL. No other markdown renders. Keep messages to the
  minimum context the reader needs.

## Writing in the user's voice

Before drafting or sending any message, read the chat history with that person (if it
isn't already in context) and match how the user actually talks to them — the message
goes out under the user's name. Mirror the register the history shows for that specific
chat: language choice, formality, capitalization, punctuation, greeting/sign-off habits,
message length, emoji use, and how casually or precisely they phrase things. Different
chats have different registers — never carry one contact's tone over to another, and
never default to polished assistant prose when the history shows short lowercase
messages (or vice versa).

## Multiline messages

Write the text to a scratchpad file and use `--file` — shell quoting mangles newlines
in `--message`.

## When the session expires

Commands fail with a "session missing or expired" message. Tell the user to run
interactively (it prompts for a login code sent to their Telegram):

```bash
! cd ~/localhost/telegram && yarn node tg.mjs login
```

## Notes

- Timestamps in `dialogs`/`history`/`export` output are laptop-local time — and this
  machine runs on UTC, not the user's Armenia time (+04). Convert before storing them
  anywhere (CRM notes, docs).
- This is the user's real personal account — treat message content as private; quote
  only what the task needs.
- Works with users, groups, and channels alike (drafts too).
- Rate limits: fine for single operations; add delays only when looping over many chats.
