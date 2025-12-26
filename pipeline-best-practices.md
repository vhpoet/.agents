# Pipeline Best Practices for LLM Contributions

This guide covers how to design and build data pipelines (including scraping pipelines) that are reliable, debuggable, and safe to evolve. A pipeline here means a repeatable workflow that ingests data, validates and transforms it, and publishes outputs for downstream use.

## Core Principles

- Determinism and idempotency. Re-runs should produce the same result for the same inputs.
- Clear contracts. Inputs and outputs have explicit schemas, expectations, and owners.
- Observable by default. You can answer what ran, what changed, and what broke.
- Separate concerns. Ingest, transform, and publish as distinct stages.
- Small, reversible changes. Pipelines are production systems with real users.

## Pipeline Architecture

- Use a staged design: ingest -> raw/landing -> transform -> serving.
- Keep raw data immutable. If you must change it, write a new version.
- Choose batch, streaming, or hybrid based on latency needs and cost.
- Treat orchestration as the control plane, and transformations as pure steps.

## Inputs and Contracts

- Define source ownership, expected cadence, volume, and failure modes.
- Document schema, primary keys, nullability, and uniqueness constraints.
- Validate inputs early and quarantine bad records with reasons.
- Track schema versions and add compatibility rules for breaking changes.
- Prefer incremental ingestion with watermarks and deduplication keys.

## Outputs and Destinations

- Define output contracts for downstream consumers (schema and semantics).
- Use atomic writes and partitioned outputs when possible.
- Prefer UPSERT or merge operations to avoid duplicates on retries.
- Emit run metadata (run_id, interval, source version, row counts).

## Orchestration and Scheduling

- Model dependencies explicitly in a DAG; avoid hidden ordering.
- Avoid local disk for inter-task handoff; use shared storage.
- Parameterize runs by data interval; avoid non-deterministic now() usage.
- Use retries with exponential backoff and clear timeouts.
- Make tasks transaction-like: no partial writes at the end of a step.

## Data Quality and Testing

- Add data unit tests for critical fields (ranges, nulls, uniqueness).
- Validate row counts and distribution shifts between stages.
- Keep golden datasets for key transformations and run in CI.
- Make failures actionable: include sample bad rows and context.

## Observability and Operations

- Log inputs, outputs, and timing per stage with consistent keys.
- Track throughput, freshness, lag, error rate, and cost metrics.
- Alert on SLA breaches, schema drift, and unusual volume changes.
- Use dead-letter queues or quarantine tables for failed records.
- Keep runbooks for common failures and backfill procedures.

## Performance and Cost

- Partition and cluster on common query keys and time ranges.
- Push filters down to sources and reduce unnecessary data movement.
- Use claim check patterns for large payloads between steps.

## Scraping-Specific Practices

- Use per-domain rate limits and backoff to avoid overload.
- Prefer stable identifiers and canonical URLs for deduping.
- Store raw HTML and extraction versions for replay and audit.
- Detect layout changes and alert on parsing failures.
- Separate fetching from parsing so you can reprocess without recrawl.

## LLM Usage in Pipelines

- Treat LLM calls as non-deterministic; lock settings for production runs.
- Keep prompts explicit: clear instructions, separators, and target schemas.
- Iterate from simple prompts; split complex tasks into smaller stages when needed.

## RAG and Retrieval Practices

- Prefer retrieval-augmented generation for fresh or proprietary knowledge.
- Build a clear RAG flow: ingest -> chunk -> embed -> store -> retrieve -> generate.
- Keep chunks consistent and focused; store source IDs and metadata for traceability.
- Retrieve the minimum context needed to reduce noise and hallucinations.

## LLM Data Prep and Quality

- Clean and dedupe text before embedding or training.
- Standardize text encoding and normalize formatting across sources.
- Detect language and handle mixed-language data explicitly.
- Version datasets used for prompts, retrieval, or fine-tuning.

## LLM Observability and Safety

- Log model, prompt template, parameters, and retrieved sources per run.
- Track latency, error rates, and quality metrics over time.
- Add human feedback loops for evaluation and continuous improvement.
- Monitor for prompt injection and unsafe outputs; add validation and fallbacks.
- Use purpose-built EL/ETL for ingestion rather than ad-hoc LLM loaders.

## Code Organization and Boundaries

- Separate data access, business logic, and IO in different modules.
- Keep transforms pure; isolate side effects in small, explicit functions.
- Define clear input and output types for every stage and helper.
- Encapsulate validation at boundaries (ingest and publish).
- Use narrow interfaces; pass only what a function needs.
- Prefer small files with focused responsibilities over large multipurpose modules.
- Group code by domain feature, not by tech layers alone.
- Keep configuration in one place; avoid hardcoded constants in logic.

## Change Checklist

- Did I define or update input and output contracts?
- Are runs idempotent with safe retry behavior?
- Are data quality checks and alerts in place?
- Can I backfill safely without impacting prod consumers?

## When to Ask Questions

- The pipeline needs new sources, credentials, or permissions.
- The request implies real-time or low-latency requirements.
- A schema change will impact downstream consumers.
- The data contains sensitive or regulated fields.

## What to Avoid

- Reading from or writing to moving targets without a time partition.
- Hidden side effects inside transforms or orchestration steps.
- Full reloads when incremental loads are possible.
- Manual spreadsheet inputs without strict change controls.
- Logging sensitive data or storing secrets in config files.
