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
export INPUT_COMMAND="$CI_ROOT/fixtures/tiny-mcp/server.js"
# The Action expects a start command; prefix node when the file is passed alone.
export INPUT_COMMAND="node $CI_ROOT/fixtures/tiny-mcp/server.js"
export INPUT_FAIL_ON=breaking
export INPUT_COMMENT=false
export INPUT_BASELINE_URL="$CI_ROOT/baselines/tiny-mcp-fixture.json"
export INPUT_TIMEOUT=10000
# core.setFailed throws in a local run without GitHub; invoke the classifier path via the tests above,
# then do a direct list+compare so this script also exercises the bundled file's client.
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
