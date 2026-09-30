# Data Table (Web app screens)

A structured grid for dense datasets with sorting, filtering, bulk operations, and column control.

- **Sortable columns** — Column headers that sort rows by that value on click, toggling ascending and descending
  - Tip: A sort indicator in the header making the current sort direction always visible, since users lose track easily
- **Column visibility and order** — Controls to show or hide individual columns and drag to reorder them
  - Tip: Persisting column preferences across sessions is expected by power users, since resetting on each visit is a consistent complaint
- **Row selection and bulk actions** — Checkboxes on each row and a persistent action bar appearing when rows are selected
  - Tip: Showing the count of selected rows ('3 items selected') keeps the user oriented, especially when the selection spans a filtered result
- **Row actions on hover** — Contextual actions (edit, delete, view) appearing when hovering over a row
  - Tip: Two to three hover actions maximum, since anything beyond belongs in an overflow menu. A row full of icons is hard to scan
- **Search and filter** — A search input for quick lookup alongside filter controls for narrowing by specific attributes.
  - Tip: Active filters persisted visually as chips above the table — users need to know at a glance that results are being filtered.
- **Pagination** — Controls to navigate between pages of results, with an option to choose how many rows show per page
  - Tip: Showing the total count ('1–50 of 1,240') gives users a sense of scale and progress
- **Frozen columns** — The first column pinned so it remains visible when the user scrolls horizontally
  - Tip: Essential for wide tables that likely exceed window width so context can remain as the user scrolls
- **Export action** — A way to download the visible or selected rows as CSV, spreadsheet, or another format
  - Tip: Show export reflecting the current filter and any other states so user understands exactly what is being exported
- **Empty and loading states** — The states shown when the table has no rows or when data is being fetched
  - Tip: Skeleton rows during loading prevent layout shift and set expectations about how many rows will appear
