# Kanban board (Web app screens)

A visual board that organises items into columns representing stages or statuses, allowing users to track and move work through a workflow.

- **Columns** — Distinct vertical lanes representing each stage of the workflow (To Do, In Progress, Done, or custom stages)
  - Tip: Every team structures their workflow differently, so adding, renaming, and reordering columns should be available
- **Cards** — Individual items displayed within each column, showing the title and key metadata at a glance
  - Tip: Title, assignee, and due date on the card face covers most use cases without cluttering
- **Drag and drop** — The ability to move cards between columns and reorder them within a column by dragging
  - Tip: A visual drop target as the card is dragged to indicate whereWithout it, users are never sure where the card will land
- **Quick add card** — A fast way to create a new card directly within a column without opening a full form
- **Card detail on click** — Clicking a card opening its full detail — description, comments, attachments, history — without leaving the board.
  - Tip: Card detail in a side panel or modal rather than navigating away — losing the board context frustrates users.
- **Column item count** — A count of how many cards are in each column, visible in the column header
  - Tip: A count is useful for conversations and to keep track of column amount without individually counting items
- **Filtering, sorting and grouping** — The ability to re-organise cards by assignee, label, priority, or due date to focus on a subset of work, as an example
