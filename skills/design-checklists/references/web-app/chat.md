# Chat (Web app screens)

A screen for real-time or asynchronous messaging between users, either one-on-one or in a group context.

- **Message thread** — A chronological display of messages in the conversation, with the most recent at the bottom
  - Tip: Auto-scrolling to the latest message on load is expected, but scrolling up to read history should never be interrupted by new messages arriving
- **Message input** — A text field for composing and sending messages, with support for multi-line input
  - Tip: Multi-line input is often defined with Shift + Enter, with just Enter alone triggering the message to be sent
- **Sender identification** — The sender's name and avatar displayed alongside each message, making the conversation easy to follow
  - Tip: Consecutive messages from the same sender typically don't need repeated name and avatar, so grouping them reduces visual clutter
- **Timestamps** — When each message was sent, using relative time for recent messages and a full timestamp for older ones
- **Read receipts** — An indicator showing whether the other participant has seen a message.
  - Tip: Not all users want this level of visibility into their activity — read receipts are worth making optional where the product allows.
- **File and media sharing** — The ability to attach images, files, or links within the conversation, and show those attachments within the conversation
- **Reactions** — Emoji reactions on individual messages as a lightweight way to respond without sending a full reply
