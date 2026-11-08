# What a project provides

`clean-room-reset` and `product-council` run in any repo. They read four things from the project and configure nothing else:

- **Records**, committed under the repo root: `docs/product-resets/<slug>/` and `docs/architecture-resets/<slug>/` for a reset, `docs/product-council/<yyyy-mm-dd>-<slug>/` for a council decision.
- **The product bar**: the project's vision docs when it has them (a product vision, its theses, a UX bar), named in its instructions; otherwise the founder's brief alone. Product-line agents apply it and never re-derive it.
- **Sources of user voice and numbers**: whatever the project's instructions name (CRM, support channels, call transcripts, analytics, the database and the tooling that queries it), with the exclusions the project states (demo and internal accounts) applied to every count. The project's languages and which of them are machine-translated, the platforms whose rules bind it, and the device the founder reviews on come from the same instructions.
- **The appetite**: the `## Appetite` section of the scope's spec when the project's spec format has one; otherwise the scout writes `ARCHITECTURE_APPETITE.md` in the format `architecture-forces.md` defines ("Appetite").

Role references resolve the same way. "The project's entropy or convergence review", "the project's implementation skill" and "the project's UX bar" mean the skill or doc the project's instructions name for that role. Without one, the global rules apply: `~/.agents/greenfield-convergence.md` and `~/.agents/coding-guidelines.md` for implementation, the premise check in the council's brief sheet in place of the review, and the founder's brief as the UX bar.
