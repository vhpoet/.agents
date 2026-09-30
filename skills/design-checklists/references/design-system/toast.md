# Toast (Design system foundations & components)

A toast is a brief, non-disruptive message that appears temporarily at the edge of the screen to provide feedback about an action or system status.

- **Copy** — The text in the toast
  - Tip: Copy should be clear and concise, focusing on a status or action
- **Placement** — Toast should appear on the corners of the viewport, not as the focus
- **Usage** — Toasts are triggered to appear after an action or event
- **Variants** — Dictated by colour usually, variants affects the emotion of a message
  - Tip: Example: A green toast informing success, red toast informing error. If informing a status, don't rely on just color and leverage icons or the copy.
- **Length of appearance** — Toasts should be visible long enough to read but short enough to not obstruct other information for too long
  - Tip: Read the text out loud slowly to gauge how much time is needed
- **Dismissable** — Depending on the amount of content, a toast can be closed by a user (it should fade away shortly after appearing if it cannot be manually dismissed)

Design considerations:
- **Action** — A toast can contain an action: to dismiss, or a specific action related to the context of the toast (view, undo, remove). Not every toast requires an action, so long as it disappears after a set time.
- **Icons**
- **Placement** — Toasts typically appear on the edges of an interface, to be intrusive but not interrupting. The visual represents common spots it can be placed on desktop.
- **Automatic dismissal** — Toasts should stay visible enough to be acknowledged, but eventually dismiss to not intrude the interface for too long
