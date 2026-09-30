# Banner (Design system foundations & components)

A banner is a prominent notification item that displays important messages to users. It communicates things like errors, success confirmations, warnings, or general information using distinct colors and placement to stand out from regular page content and grab attention.

- **Style** — How the banner types look (fill, text colour, border radius etc)
  - Tip: Ensure the banner stands out enough on your default UI as it’s usage typically means it should not be missed
- **Content** — A title is a must but you can consider a description if you feel a title does not convey enough information
- **Types** — Banners typically appear as 5 options: information, success, warning, error, neutral. This helps visually establish context and level of importance.
- **Call to action button** — A banner may call for the user to do something, like fix the error it is calling out, or viewing the successful outcome of an event.
  - Tip: Only have a button if it feels needed, banners typically work best to inform
- **Placement** — Where the banner sits on the page, dependent on context and importance
  - Tip: Consider the impact the banner contents has on the user experience to determine where it’s placed best e.g. information affecting the entire application should have a banner at the top on every page. Information only affecting a small feature may be within a relevant section.
- **Dismissable** — Whether the banner can be dismissed. Positive/neutral banners (info and success) would suit this, but not warning/error banners as they are too critical.

Design considerations:
- **Variations** — Different colours can be used to match the message type: red for errors, green for success, yellow for warnings, and blue or neutral for general information. This helps the first impression be more specific.
- **Content** — It’s perfectly fine to just have 1 line of text to explain the scenario. If more details are needed, it’s good to have a short, clear title followed by a longer description. This lets people quickly scan the main message or read more if they want to.
- **Actions** — An error or warning banner is common to contain an action, to take you directly to where the issue can be fixed or investigated.
- **Contrast to UI** — Make banners look different from the rest of the page so they grab attention. Use background colors, borders, or shadows that make the banner clearly separate from normal page content.
- **Icons** — Add simple, recognizable symbols that match the message - like checkmarks for success or warning triangles for problems. Icons help people understand the banner's meaning at a glance, even before reading the text.
- **Placement** — Put banners where users will notice them relative to the context. Top of the page works for site-wide messages, while placing near related content works better for specific notifications.
