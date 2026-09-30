# Tooltip (Design system foundations & components)

A tooltip is a small informational popup that appears when users hover over or focus on an element, providing additional context or explanations. It disappears when the user moves away, making it ideal for offering brief, helpful hints without cluttering the interface.

- **Information** — Keep content clear and concise
  - Tip: Information should be entirely relevant to what the tooltip is for, and elaborate on what is already visible
- **Contrast** — The background should be different from the underlying content
  - Tip: An inverse colour works best for contrast - if behind the tooltip is dominantly light, make the tooltip background dark with light text
- **Visibility** — How a tooltip looks and shows
  - Tip: A tooltip should activate on hover or select of an icon or text it is relevant to Only one tooltip should be visible at a time A tooltip should not cover the content it is relevant to
- **Dismiss action** — Depending on how intrusive or extensive the tooltip is, a dismiss allows the user to feel more in control and allow the tooltip to feel more flexible and non-compulsory

Design considerations:
- **Interaction** — Tooltips typically appear through hover or focus, and disappear when leaving the trigger area, so it does not obstruct other information permanently.
- **Additional description** — Tooltips may have another level of text if more context is needed, without making the title too overwhelming.
- **Width** — Maintain readability with a limiting width, with a maximum value of 150-300px.
- **Relative position** — Tooltips can dynamically appear relative to the interaction trigger, and its position can help reduce obstruction of other information.
- **Use cases** — Tooltips can go beyond providing additional context. Consider their usage in revealing shortcuts, displaying statuses or previewing data.
