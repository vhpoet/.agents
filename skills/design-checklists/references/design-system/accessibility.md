# Accessibility (Design system foundations & components)

The accessibility foundation of a design system including the standards, tooling, and shared conventions that ensure every component and pattern is built inclusively from the start.

- **Target conformance level** — The WCAG conformance target the team has committed to documented and referenced in contribution guidelines. AA as a baseline for most products, with AAA achievable for specific criteria such as text contrast.
  - Tip: WCAG AA is a typical baseline for most products, with AAA achievable for specific criteria such as text contrast
- **Colour contrast standards** — The contrast ratios verified across all text and interactive element colour combinations (4.5:1 for normal text, 3:1 for large text and UI components)
  - Tip: Show these ratios in existing UI
- **Focus indicator design** — A visible, high-contrast focus indicator designed for every interactive component
  - Tip: Show clear examples for most common interactive components like button and input field
- **Keyboard navigation patterns** — Standard keyboard interaction patterns documented and applied consistently e.g. arrow keys for menus and listboxes, Enter and Space for activation, Escape for dismissal
- **ARIA pattern library** — Attributes that make web content accessible to those who use assistive technologies with roles, states, and properties defined for every interactive component pattern
- **Screen reader testing** — Components tested with at least VoiceOver on Safari and NVDA on Chrome before shipping
- **Accessibility annotations in design** — A shared annotation kit used in design files to specify ARIA labels, roles, reading order, and focus behaviour
- **Accessibility in contribution guidelines** — Ensuring accessibility requirements are part of the component contribution checklist
