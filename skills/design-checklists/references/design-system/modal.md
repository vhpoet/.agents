# Modal (Design system foundations & components)

A modal is a dialog box or popup window that appears on top of the main content, requiring user attention or interaction before returning to the main interface. It creates a focused experience by temporarily disabling the underlying page and dimming the background.

- **Title** — Clear, simple text explaining the action of the modal
  - Tip: Ensure your icon is recognisable in all possible sizes it's displayed at, and whether the detail needs to be simplified at a smaller size
- **Actionable item** — A button or link to continue or close the event
  - Tip: Users should always have an idea where they will be going to, or what event will happen before clicking a button If your button has generic copy such as 'Okay' or 'Cancel', include a label above it describing the event or purpose of the button
- **Close action** — A way to exit the modal
- **Responsiveness** — Consider the size of the modal on different device sizes, and whether a modal is suitable on all
  - Tip: On mobile, adapt the modal to full screen to gain more space
- **Background change behind modal** — Darken, blur or lighten - change the background behind the modal to bring focus to it
- **Description** — Incase they require more information to understand how to make their decision

Design considerations:
- **Buttons** — Consider the button hierarchy and variations in a modal. It's common to have 2 contrasting button types that present opposing actions e.g. continue and cancel.
- **Close action** — To dismiss the modal, but this can be a variable if you want to force the user to select a button to proceed, as the close action is a generic dismiss.
- **Responsiveness** — A modal takes up a part of the desktop screen, but it is recommended to make a modal full size on mobile. This is incase the modal content requires scrolling, which is easier to interact with if the modal takes up the entire screen.
