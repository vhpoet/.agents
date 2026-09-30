# Login (Mobile app screens)

Everything a returning user needs to authenticate quickly and securely.

- **Social sign-in** — Sign-in options that connect to an existing Apple or Google account, bypassing manual credential entry.
  - Tip: On iOS, Apple Sign In is required by App Store guidelines if any other social provider is offered.
- **Email field** — The input where users enter the email address associated with their account.
- **Password field** — A masked text input for the account password, with the option to reveal what has been typed.
- **Biometric authentication** — Face ID or fingerprint sign-in for returning users who have already authenticated once with a password
  - Tip: Encouraged to suggest after initial login so it’s a faster experience in the future
- **Credential autofill** — System-level support for pre-filling saved email and password from the user's password manager.
  - Tip: textContentType on iOS and autoComplete on Android are the attributes that trigger native autofill.
- **Forgot password link** — The link users reach for when they can't recall their password, leading into the reset flow.
- **Error states** — Feedback shown when authentication fails, distinguishing between an unrecognised email address and an incorrect password.
  - Tip: Generic 'incorrect credentials' gives users no useful signal — knowing whether the email or password is wrong helps them recover without guessing.
- **Passwordless sign-in (magic link)** — An alternative sign-in method that sends a one-time link to the user's email, requiring no password
  - Tip: Useful for infrequent-use apps where remembering a password between sessions is difficult

Design considerations:
- **Face ID post-login**
- **Social login options**
- **Magic link**
