# Billing (Web app screens)

Payment methods, invoices, and everything related to the financial side of the account

- **Payment method on file** — The current card or payment method linked to the account, shown with masked details
  - Tip: Last 4 digits of card are enough for the user to identify which card is in use without exposing sensitive information
- **Add or update payment method action** — A way to enter a new card or change the current one
- **Next billing date and amount** — When the next payment will be taken and for how much
  - Tip: Including the plan name alongside the amount if applicable
- **Invoices and receipts** — A list of past charges with the ability to download a PDF invoice for each.
  - Tip: Ensure invoices include company name, address, and VAT number — legally required in many countries and a frequent request from business users.
- **Tax and VAT (if applicable)** — Applicable tax or VAT shown on invoices and billing history
- **Failed payment recovery** — Clear messaging and recovery instructions when a payment attempt has failed
  - Tip: Surface this issue prominently in the app as it can eventually restrict access if not resolve in time
- **Billing contact email** — The email address where invoices and billing notifications are sent
  - Tip: For larger teams, this is often different from the account owner's email
