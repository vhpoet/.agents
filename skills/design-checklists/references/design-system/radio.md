# Radio (Design system foundations & components)

A radio button is an interactive control that allows users to select exactly one option from a predefined set of mutually exclusive choices. Unlike checkboxes, when one radio button is selected, all others in the same group are automatically deselected.

- **Label** — Text associated with the radio input
- **Grouping** — There must be more than one radio option for the experience to work
  - Tip: Utilise radio to surface all inputs options, only being able to select one Radios with short labels can be align horizontally, but should usually be aligned vertically
- **Default selection** — Start with a radio option selected
  - Tip: This doesn't always have to be the first option, it can be the more likely option based on previous research and experiences
- **Style** — Make sure radio is unique and stands out from other input options
- **Clickability** — Consider what is clickable to make the radio option active (text label, container)
- **States** — Radio can be default, active and disabled (see examples below)

Design considerations:
- **Style** — A container on a radio can improve it's clickability, but will take up more space. It's worth considering both options in your design system.
- **States** — All the possible variations a radio can exist as depending on interaction and logic.
