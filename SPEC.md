# Behavioral Specifications & Invariants

## Formal Type Contracts

- **`args::AddArgs`** (`struct`): Public interface entity
- **`args::AdminArgs`** (`struct`): Arguments for `rabbet admin`.
- **`args::AdminSubcommand`** (`enum`): Admin subcommands.
- **`impact::AffectedTest`** (`struct`): An affected unit test or integration test detected in the blast radius.
- **`decision::AgentClaim`** (`struct`): Active agent claim lock with lease expiry semantics.
- **`model::AnonymizedSynthesisTrace`** (`struct`): Wire contract representing an AST-anonymized synthesis run per `CONTRACTS.md`.
- **`mod::AppState`** (`struct`): Shared application state for all daemon handlers.
- **`ingest_handler::AppState`** (`struct`): Shared application state injected into Axum route handlers.
- **`args::AskDecisionArgs`** (`struct`): Public interface entity
- **`indexer::AstIndexer`** (`struct`): Turns source code into encoded [`FunctionSymbol`]s.  The indexer is stateless, so it is `Sync` and can be shared by the parallel ingestion pipeline in the engine.
- **`verifier::AstVerifier`** (`struct`): Verification engine coordinating splicing, AST validation, compiler checks, and tests.
- **`slicer::Attention`** (`struct`): Public interface entity
- **`mod::AuditArgs`** (`struct`): Arguments parsed for the `miter_audit` tool.
- **`audit::AuditConfig`** (`struct`): Configuration options for workspace auditing.
- **`audit::AuditFormat`** (`enum`): Format choice for `miter audit`.
- **`audit::AuditSeverity`** (`enum`): Severity classification of a line count violation.
- **`config::AuditToolConfig`** (`struct`): Tool-specific configuration for file-length auditing.
- **`audit::AuditViolation`** (`struct`): A violation flagged during workspace auditing.
- **`model::BatchIngestRequest`** (`struct`): Public batch submission payload for `POST /api/v1/traces`.
- **`model::BatchIngestResponse`** (`struct`): Response returned by `POST /api/v1/traces`.
