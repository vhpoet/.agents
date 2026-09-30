# Tabs (Design system foundations & components)

Tabs are navigation elements that organize and separate content into different sections within the same view. They allow users to switch between related content, maintaining context while reducing clutter.

- **Labels** — Name of each tab
  - Tip: Label should be logical enough for the user to predict what's in the tab Keep it concise, ideally 1 word
- **Content area** — Where the content for the active tab is displayed
  - Tip: Typically underneath a horizontal tab, or to the right of a vertical tab
- **Style** — How the active tab and inactive tabs differentiate visually, as well as the tab container overall
- **Item order** — Consider the arrangement of tabs to be ordered by popularity or familiarity
- **States** — Default, active, hover are the key states

Design considerations:
- **Style** — How your tab container and cells look. It's important to view them in context of the UI surrounding it, to help it stay aligned
- **Dynamic content** — Make sure that navigating between tabs only changes content underneath it. The user will not expect content to change above the tabs or significantly further away from the component.
- **States** — These are the 3 key states, but you may also want to consider focused and disabled.
