# Loading (Design system foundations & components)

A loading indicator is a visual element that communicates to users that content or an action is being processed. It provides feedback through animations like spinning wheels, progress bars, or skeleton screens to maintain user engagement during wait times.

- **Visual indicator** — A clear representation that content is loading or in progress of change
- **Text** — Explaining the loading state
  - Tip: Let the standard 'loading' text be a fallback, and try to be more specific e.g. 'adding your contacts, syncing your emails'
- **Time** — Determine how long the time between two actions must be to require a loading component
  - Tip: Don't interrupt two actions that instantly transition, but if there's a known 5 second period between two actions then the component is appropriate
- **Accessibility** — Ensure your loading state can be clearly seen
  - Tip: Place the loading indicator in a container to ensure accessibility, regardless of background If the loading indicator is on its own, create a version appropriate for light/dark backgrounds
- **Visuals** — Entertain the user with an illustration during the loading state

Design considerations:
- **Style** — A loading indicator can have many different looks, the core principle must be that it shows a motion in loop or towards and endpoint.
- **Text** — Text can help remind users what is happening and that they need to wait. It is optional, depending on how much space there is in the area that is loading.
- **Context (optional)** — It doesn't just have to be 'loading'. The loading text can be specific to what action is being run. There's also a chance here to add some personality, as waiting for something to load is typically a mundane experience.
