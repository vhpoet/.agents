# Product forces

The named forces that make a product clear or confusing, small or sprawling. Every product-line agent judges by these names instead of by taste: the evidence collector scores the current product on them, the council's proposers design against them, its critics and judge score against them, the direction review compares against them. A finding that no force here names is taste, and taste is not a finding. The forces apply the project's product bar (its vision docs and UX bar, `project-conventions.md`); they replace neither.

The two questions every product-line agent answers:

1. What is the smallest number of concepts, decisions and interactions we can expose while still fully solving the user's job?
2. Is this complexity inherent in the user's problem, or are we making the user understand complexity that belongs to us?

## Scorecard format

Wherever a sheet asks for a forces scorecard, write this markdown table, one row per force with a finding. Forces with nothing to report are listed once under the table as "no finding". Scripts read the Severity column, so keep the five columns and the exact severity words.

```text
| Force | Finding | Evidence (screens, copy, analytics, support threads, CRM notes) | Cost (what the user must think, do or wait for) | Severity |
```

Severity is one of:

- `local`: fixable in one ordinary change without changing what the product is
- `structural`: the product shape itself must change; a local fix would add a setting, a step or an explanation
- `none`: checked, nothing to report

The structural rows are what a reset exists to fix. The brief restates them as required outcomes, the candidates answer them, the direction review checks each is closed without opening another.

## How to count concepts

A concept is a noun or a state the user must understand; a label is not a concept. A direction's count includes only the concepts it adds for the user; concepts the existing product already has are not counted. List them, numbered, then count. A critic or judge recounts instead of trusting the author's number, and recounts a proposal that counted existing concepts before comparing it with the others. Two directions are "the same shape" when their mechanism class and golden path match and their counts are within one of each other.

## Product shape and clarity

- **Conceptual model**: the mental model the user forms of how the product works. From the screen alone, can a first-time user say what this is and what happens on tap?
- **Product surface area**: how much product the user has to understand.
- **Information architecture**: how features and content are organized and reached. Some problems are not a screen problem but an IA problem.
- **Interaction model**: consistent rules for how the user acts. Three interaction models for the same action is a failure.
- **Affordance**: an available action looks available.
- **Discoverability**: how easily the user finds what exists.
- **Progressive disclosure**: complexity appears only when it is relevant.
- **Default path**: the experience most users follow. Optimize it, not every edge case.

## Simplicity

- **Product complexity**: how much the user must understand. **Essential** complexity is inherent in the user's problem; **accidental** complexity is ours: configuring seven unrelated settings before the first publish.
- **Cognitive load**: how much the user must think. **Decision load**: decisions we make the user take that they should not care about. **Choice overload**: too many options at one point.
- **Concept count**: how many new concepts the user must learn, counted as "How to count concepts" says. Low is elegant.

## Coherence

- **Conceptual integrity**: one coherent product, not thirty independent features.
- **Consistency**: internal (the product obeys its own rules) and external (it follows conventions the user already knows). **Least surprise**: would the user have predicted this behavior before trying it?

## User value

- **Job to be done**: the progress the user wants, not the feature they name. Not "the seller wants promo codes" but "the seller wants to give a group cheaper access without operational work".
- **User intent**, **outcome**, **value moment**, **time to value**, **activation**: when the user first gets what they came for, and how long that took.

## Friction

- **Incidental friction** has no value; remove it. **Intentional friction** protects: "Refund all 294 orders?"
- **Interaction cost**: taps, typing, thinking, navigation, waiting.
- **Coordination cost**: effort that exists only because people or systems must coordinate. A user messaging us to change something is coordination cost.
- **Operational burden**: work created outside the product because the product does not handle it.

## Paths and flows

- **Happy path**; **critical path** (the actions that are strictly necessary); **golden path** (the one we deliberately optimize when several valid paths exist).
- **Escape hatch**: a way out for unusual cases that does not contaminate the normal product.
- **Dead end**: a state with no next step. **Recovery path**: how the user gets back. **Reversibility**: a reversible action needs no confirmation dialog.

## Defaults and configuration

- **Sensible defaults**, **opinionated product**, **zero-config**, **convention over configuration**. **Configuration burden** is what remains when we ask instead of infer. "Can we infer this instead of asking?"

## Power and simplicity

- **Progressive complexity**: simple by default, powerful when needed. **Power-user path**, **capability ceiling**, depth against breadth. Never a literal expert mode.

## Abstraction in product

- **User-facing abstraction**: the backend has orders, entitlements, allocations and payment intents; the buyer needs one noun.
- **Implementation leakage**: an internal concept reaches the UI because it was convenient for engineering. Why does the user need to understand our settlement batch?
- **Jargon leakage**: our words where the user's words belong. Domain language is the user's language.

## Scope

- **Thin vertical slice**: one complete path from the user's first action to the value moment, nothing beside it. **Minimum lovable product**, **scope discipline**, **feature creep**.
- **Product sprawl**: individually reasonable features that together destroy coherence.

## Prioritization

- **Leverage**, **force multiplier**, **unlock** (a verified account is an unlock for payouts, teams and analytics), **constraint**, **bottleneck** ("acquisition is not the rate limiter, activation is"), **marginal value**.

## Behavior and engagement

- **Trigger**, **habit loop**, **retention loop**, **network effect**, **flywheel**. A flywheel must contain a real reinforcing loop: more supply, better discovery, more demand, more sales, more supply.

## Trust

- **Trust surface**: payments, refunds, payouts, and every fact the user cannot verify alone. **Trust signal**, **expectation setting**, **transparency**, **perceived control**: a reliable product still feels unreliable when perceived control is low.

## Failure and edge cases

- **Edge case**, **long tail**, **failure mode**, **graceful degradation**, **fail-safe**, **error prevention over error messages**, **recovery**. The question: do we need to support this edge case, or can we deliberately constrain the product?

## Strategy

- **Wedge**, **beachhead**, **expansion vector**, **adjacency**, **right to win**, **differentiation**, **positioning**, **moat**, **commoditization**. These are decided in the project's vision docs; a reset applies them, it does not re-derive them.

## The twenty to keep

Conceptual model, product surface area, cognitive load, essential vs accidental complexity, progressive disclosure, golden path, escape hatch, sensible defaults, configuration burden, user intent, job to be done, time to value, interaction cost, operational burden, product sprawl, conceptual integrity, constraint, leverage, wedge, flywheel.
