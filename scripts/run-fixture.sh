#!/bin/sh
# Run Drift Check against the tiny fixture, locally. No GitHub account is required.
set -eu
CI_ROOT=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
ACTION_ROOT=${ACTION_ROOT:-"$CI_ROOT/../drift-check"}
if [ ! -f "$ACTION_ROOT/src/index.js" ]; then
  echo "Action repository not found at $ACTION_ROOT" >&2
  exit 1
fi
cd "$ACTION_ROOT"
npm ci --ignore-scripts
npm test
npm run build
export INPUT_SLUG=tiny-mcp-fixture
# The Action expects a start command, so node is part of it.
export INPUT_COMMAND="node $CI_ROOT/fixtures/tiny-mcp/server.js"
export INPUT_FAIL_ON=breaking
export INPUT_COMMENT=false
export INPUT_BASELINE_URL="$CI_ROOT/baselines/tiny-mcp-fixture.json"
export INPUT_TIMEOUT=10000
# A local run has no GitHub job summary file, so instead of running dist/index.js this does a direct
# list and compare with the Action's client and classifier from src/.
node --input-type=commonjs <<'NODE'
const path = require('path');
const { listTools } = require(path.resolve('src/client'));
const { classify, shouldFail } = require(path.resolve('src/diff'));
const fs = require('fs');
(async () => {
  const baseline = JSON.parse(fs.readFileSync(process.env.INPUT_BASELINE_URL, 'utf8'));
  const live = await listTools({ command: process.env.INPUT_COMMAND, timeoutMs: Number(process.env.INPUT_TIMEOUT) });
  if (!live.ok) { console.error(live.error); process.exit(1); }
  const result = classify({ baseline, current: live, startupFailed: !live.ok, startupError: live.error });
  console.log(JSON.stringify({ started: live.ok, ms: live.ms, tools: live.tools.map(t => t.name), same: result.same, breaking: result.breaking, nonBreaking: result.nonBreaking }, null, 2));
  if (shouldFail(process.env.INPUT_FAIL_ON, result) || !result.same) {
    console.error('Fixture did not match the baseline.');
    process.exit(1);
  }
})();
NODE
