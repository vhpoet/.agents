# Pipeline Best Practices

## Core Principles

- Determinism and idempotency. Re-runs produce the same result for same inputs.
- Clear contracts. Inputs and outputs have explicit schemas and owners.
- Observable by default. You can answer what ran, what changed, what broke.
- Separate concerns. Ingest, transform, and publish as distinct stages.
- Small, reversible changes. Pipelines are production systems.

## Architecture

- Staged design: ingest → raw/landing → transform → serving.
- Keep raw data immutable. Write new versions if changes needed.
- Choose batch, streaming, or hybrid based on latency needs and cost.
- Orchestration is the control plane; transformations are pure steps.

## Inputs and Contracts

- Define source ownership, cadence, volume, and failure modes.
- Document schema, primary keys, nullability, uniqueness constraints.
- Validate inputs early; quarantine bad records with reasons.
- Track schema versions; add compatibility rules for breaking changes.
- Prefer incremental ingestion with watermarks and deduplication keys.

## Outputs

- Define output contracts for downstream consumers.
- Use atomic writes and partitioned outputs.
- Prefer UPSERT/merge to avoid duplicates on retries.
- Emit run metadata (run_id, interval, source version, row counts).

## Orchestration

- Model dependencies explicitly in a DAG; avoid hidden ordering.
- Avoid local disk for inter-task handoff; use shared storage.
- Parameterize runs by data interval; avoid non-deterministic `now()`.
- Retries with exponential backoff and clear timeouts.
- Tasks should be transaction-like: no partial writes.

## Data Quality

- Add data unit tests for critical fields (ranges, nulls, uniqueness).
- Validate row counts and distribution shifts between stages.
- Keep golden datasets for key transformations; run in CI.
- Make failures actionable: include sample bad rows and context.

## Observability

- Log inputs, outputs, timing per stage with consistent keys.
- Track throughput, freshness, lag, error rate, cost.
- Alert on SLA breaches, schema drift, unusual volume changes.
- Use dead-letter queues for failed records.

## Scraping

- Per-domain rate limits and backoff.
- Stable identifiers and canonical URLs for deduping.
- Store raw HTML and extraction versions for replay.
- Detect layout changes; alert on parsing failures.
- Separate fetching from parsing for reprocessing without recrawl.

## LLM in Pipelines

- Treat LLM calls as non-deterministic; lock settings for production.
- Keep prompts explicit with clear instructions and target schemas.
- Split complex tasks into smaller stages.

## RAG

- Flow: ingest → chunk → embed → store → retrieve → generate.
- Keep chunks consistent and focused; store source IDs for traceability.
- Retrieve minimum context needed to reduce noise.

## Code Organization

- Separate data access, business logic, and IO.
- Keep transforms pure; isolate side effects.
- Define clear input/output types for every stage.
- Prefer small files with focused responsibilities.
- Keep configuration in one place.

## What to Avoid

- Reading/writing to moving targets without time partitions.
- Hidden side effects inside transforms.
- Full reloads when incremental loads are possible.
- Logging sensitive data or storing secrets in config.
