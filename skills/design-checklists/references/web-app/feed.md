# Feed (Web app screens)

A stream of content, activity, or updates that users scroll through to stay informed.

- **Feed item preview** — A preview of each feed item (title, excerpt, or thumbnail) sufficient to judge whether the item is worth opening
  - Tip: Variable-height items force the eye to re-adjust between each card whereas a consistent layout makes items harder to differentiate
- **Author** — The name and avatar of the person who created or posted each item
  - Tip: Linking the author name to their profile is a natural interaction expectation in most social or collaborative contexts
- **Timestamps** — When each item was published or last updated
  - Tip: Relative time works well for recent items, but eventually it should switch to the exact date and time
- **Engagement actions** — Ways to interact with feed items (like, comment, share, save, or react)
  - Tip: Consider size of every interaction in terms of prominence and frequency of use
- **New content indicator** — A banner or button that appears when new items have been posted since the user loaded the feed
  - Tip: Auto-injecting new posts while the user is reading pushes existing content down and makes scrolling janky
- **Filtering** — Controls for narrowing the feed to a specific category, content type, or followed accounts
  - Tip: Always indicate when filters are active for users to understand why specific content may or may not be shown
- **Pagination or infinite scroll** — A mechanism for loading more items as the user reaches the bottom of the feed
  - Tip: Pagination is suited well for work-related apps that have extensive databases
- **Empty state** — The state shown when the feed has no items to display whether due to no connections, no activity, or an empty filter result
  - Tip: A first-use empty state can point towards a specific action e.g. follow people, create a post, invite a colleague
