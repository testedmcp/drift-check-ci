# Drift Check CI and examples

Companion repository for [Drift Check by testedmcp](https://github.com/testedmcp/drift-check). GitHub Marketplace listings cannot include workflow files in the Action repository, so the workflows and a small fixture server live here.

This repository is maintained by the testedmcp team.

## What is in this repository

- `fixtures/tiny-mcp/server.js` — a tiny newline-delimited JSON-RPC MCP server with two tools (`echo`, `ping`).
- `baselines/tiny-mcp-fixture.json` — a baseline file in the same shape as `https://testedmcp.com/api/baseline/<slug>.json`.
- `.github/workflows/ci.yml` — runs the Action unit tests and then runs the Action itself against the fixture.
- `.github/workflows/example.yml` — a starter workflow maintainers can copy into their own MCP server repository.
- `scripts/run-fixture.sh` — the same fixture run, for use on a local machine (no GitHub required).

## Local fixture run

From this repository, with the Action repository checked out as a sibling at `../drift-check`:

```sh
./scripts/run-fixture.sh
```

That script installs the Action with `npm ci --ignore-scripts`, bundles it if needed, starts the fixture server through the Action entry, and compares it to `baselines/tiny-mcp-fixture.json`.

## Licence

MIT. Copyright the testedmcp team. See the Action repository for the licence text.
