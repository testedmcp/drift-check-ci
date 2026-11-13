#!/usr/bin/env node
'use strict';
// Tiny newline-delimited JSON-RPC MCP server used as a Drift Check fixture.
// Lists two tools and does not require credentials. It never calls out.

const tools = [
  {
    name: 'echo',
    description: 'Returns the text it was given.',
    inputSchema: {
      type: 'object',
      properties: { text: { type: 'string' } },
      required: ['text'],
    },
  },
  {
    name: 'ping',
    description: 'Returns pong.',
    inputSchema: { type: 'object', properties: {} },
  },
];

function send(obj) {
  process.stdout.write(JSON.stringify(obj) + '\n');
}

let buf = '';
process.stdin.setEncoding('utf8');
process.stdin.on('data', (chunk) => {
  buf += chunk;
  let idx;
  while ((idx = buf.indexOf('\n')) >= 0) {
    const line = buf.slice(0, idx).trim();
    buf = buf.slice(idx + 1);
    if (!line) continue;
    let msg;
    try { msg = JSON.parse(line); } catch { continue; }
    if (msg.method === 'initialize' && msg.id != null) {
      send({
        jsonrpc: '2.0',
        id: msg.id,
        result: {
          protocolVersion: '2025-06-18',
          capabilities: { tools: {} },
          serverInfo: { name: 'tiny-mcp-fixture', version: '1.0.0' },
        },
      });
    } else if (msg.method === 'notifications/initialized') {
      // nothing to return
    } else if (msg.method === 'tools/list' && msg.id != null) {
      send({ jsonrpc: '2.0', id: msg.id, result: { tools } });
    } else if (msg.id != null) {
      send({ jsonrpc: '2.0', id: msg.id, error: { code: -32601, message: 'Method not found' } });
    }
  }
});
process.stdin.on('end', () => process.exit(0));
