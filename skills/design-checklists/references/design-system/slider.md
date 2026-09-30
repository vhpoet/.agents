# Slider (Design system foundations & components)

A slider is an interactive control that allows users to select a value from a continuous range by dragging a handle along a track. It often provides intuitive visual feedback as it is interacted with.

- **Style** — How the range and the handlers look visually (see documentation for inspiration)
- **Intervals** — Whether the slider intervals has continuous (any value between 0-10000), or stepped (fixed values like a 0-5 rating)
- **Handles** — The elements that users select to drag and change the slider value
  - Tip: Handles should clearly 'break' out from the slider container to be easily identified
- **Labelling** — Text that conveys the spectrum of the slider, or if there are intervals between those ends too
- **Interaction states** — What the handles and slider look like when the user is changing the value

Design considerations:
- **Style** — Sliders can look different based on the context and purpose. The direction of your other design system components can influence how it should look too.
- **Labels** — Labels help define the ends of your slider spectrum, or the intervals available, depending on what the slider is being used for.
- **Handle interaction** — It's critical for it to be visually clear when a user is interacting with the handle to change the value.
- **Tooltip** — If the slider value is more abstract, it's typical to show the value by default or on interaction, so the user understands precisely what is selected.
- **Input as value** — If a slider has an extremely wide range, an input can help make it easier to define a particular value, instead of relying on the user to drag to that exact point.
