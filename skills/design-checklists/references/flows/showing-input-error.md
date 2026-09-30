# Showing input error (UX flows)

Users mistype all the time - whether it's a finger slipping or rushing through letters, errors happen. So for an everyday occurrence, solving an error should be obvious and seamless. The key parts of making that happen are strong visuals, clear communication, and state changes — which are all featured below.

1. **Keep the input in default state** — The text field should be checked for errors only after the information has been entered.
2. **Allow user to enter information** — Let the user type without interruptions and submit the information aka don't assess as changes are made.
3. **Signal error after loss of focus** — After the input has lost focus (user has clicked another element), the field should be assessed. Looks like we have an error here! In this case, explain why the error happened, and what is required to resolve it. For accessibility, combine the text with a visual icon that indicates an error was found.
4. **Return to default state upon reattempt** — Once the user focuses on the field again, the error message should disappear. If there is an error again, the process will simply repeat until they are able to continue.
