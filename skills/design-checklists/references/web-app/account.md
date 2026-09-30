# Account (Web app screens)

Where users view and manage their personal information, preferences, and account-level details

- **Profile photo** — A way for users to upload or change their profile image
  - Tip: Consider a sensible fallback like initials or a placeholder icon for users who haven't uploaded a photo so a profile image still exists
- **Display name** — The name shown to other users or across the product interface e.g. username, email address, first and last name
  - Tip: Worth clarifying whether this is a public-facing name or an internal account label
- **Account details** — Fields for email address, phone number, job title, or other relevant identifying information based on the product and information collected
  - Tip: If the information becomes extensive, it's suitable to group e.g. contact information, job history
- **Linked accounts (if applicable)** — A view of which third-party accounts are connected for sign-in or data access, with ability to disconnect
- **Save confirmation** — Clear feedback that changes have been saved, either inline or as a toast
  - Tip: Auto-save with a subtle confirmation is more pleasant than explicit save, but if you want an explicit save button, it should remain disabled until there are changes
- **Delete or deactivate account** — Options to deactivate or permanently delete the account, clearly separated from other settings
