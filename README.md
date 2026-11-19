# Drift Check CI and examples

Companion repository for [Drift Check by testedmcp](https://github.com/testedmcp/drift-check). GitHub Marketplace listings cannot include workflow files in the Action repository, so the workflows and a small fixture server live here.

This repository is maintained by the testedmcp team.

## What is in this repository

- `fixtures/tiny-mcp/server.js` — a tiny newline-delimited JSON-RPC MCP server with two tools (`echo`, `ping`).
- `baselines/tiny-mcp-fixture.json` — a baseline for the fixture: a JSON object whose `tools` array holds each tool's `name`, `inputSchema` and `description_hash` (SHA-256 of the description). Use it as a model for your own baseline file.
- `.github/workflows/ci.yml` — runs the Action unit tests and then runs the Action itself against the fixture.
- `examples/drift-check.yml` — a starter workflow maintainers can copy into their own MCP server repository as `.github/workflows/drift-check.yml`. It uses `testedmcp/drift-check@v1` and sets `baseline-url` to a baseline file in your repository, because the testedmcp.com baseline files are not published yet. It is not under `.github/workflows/` here, so it does not run on this repository.
- `scripts/run-fixture.sh` — the same fixture run, for use on a local machine (no GitHub required).

## Local fixture run

From this repository, with the Action repository checked out as a sibling at `../drift-check`:

```sh
./scripts/run-fixture.sh
```

That script installs the Action with `npm ci --ignore-scripts`, runs its unit tests, bundles it with `npm run build`, then starts the fixture server with the Action's client code and compares the result with `baselines/tiny-mcp-fixture.json`. Set `ACTION_ROOT` to use a checkout in another place.

Questions: [support@testedmcp.com](mailto:support@testedmcp.com).

## Licence

MIT. Copyright the testedmcp team. See the Action repository for the licence text.
