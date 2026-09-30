# Avatar (Design system foundations & components)

An avatar is a visual representation of a user. It helps identify individuals across a digital interface, commonly used in user profiles, comment sections, and chat applications.

- **Visualiser** — Show what the avatar looks like before posting or updating
- **Link to upload or select avatar** — Accessible link for a user to select
  - Tip: If you want the avatar visual itself to be clickable to change, add an indicator on it to show it's editable from that source e.g. a pencil icon
- **Placeholder image** — If a user hasn't uploaded or added an avatar yet there should be a placeholder e.g. a default icon, or the user's initials
- **Acceptable file types** — Tell the user what file types are allowed (JPEG, PNG, SVG)
- **Status change updating avatar** — This doesn't have to be apart of the avatar component (it can be a banner or toast for example), but it is possible to incorporate it
- **Alternatives** — If a user doesn't want to upload an image, offer an illustrative alternative, as it's better than nothing and can still convey their personality
- **Editing uploaded avatar** — Allow a user to crop and resize their avatar before saving it

Design considerations:
- **Shape** — An avatar can be rounded in several ways, but what matters most is establishing a consistent shape.
- **Size** — Having pre-determined sizes can help apply an avatar across multiple scenarios.
- **Status** — Accompanying an avatar can be a symbol indicating status, verification and more.
- **Fallback** — Incase a user doesn't want to upload an avatar, it's important to have fallbacks so the component can still appear in the UI.
