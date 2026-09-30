# Settings (Web app screens)

A screen that gives users control over their account, preferences, and application behaviour

- **Structure** — Organising settings controls into logical categories e.g. account, notifications, security, billing.
  - Tip: Consider elevating the most commonly changed settings rather than the most important
- **Account details** — The fields where users update their name, email address, and profile photo
- **Security details** — The ability to change the password, two-factor authentication and other security information
  - Tip: These fields should require re-authentication to save changes
- **Notification preferences** — Controls for which notifications the user receives and through which channel, grouped by type (product updates, reminders, billing)
  - Tip: Grouping by type and/or platform helps reduce the chances of a user disabling all notifications rather than some
- **Billing** — Managing payment method, upgrading or cancelling a payment — this could also be a preview of this information with a link directly to the billing page if separate
- **Additional preferences (if applicable)** — Language, timezone, date format, and appearance settings like dark mode
- **Danger zone** — Destructive actions like account deletion, clearly separated from the rest of settings
  - Tip: Include a confirmation step for any destructive actions, with details on what will be lost if the user continues
