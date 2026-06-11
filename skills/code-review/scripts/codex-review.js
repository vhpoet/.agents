#!/usr/bin/env node

/**
 * Single-layer Codex review.
 * Reads the same prompt files as Claude agents, pipes to `codex review`, extracts findings.
 *
 * Usage:
 *   node codex-review.js --layer 5 --intent "Added classification pipeline stage"
 *   node codex-review.js --layer 5 --intent "..." --scope "backend/src/event/types.ts backend/src/event/service.ts"
 *
 * Options:
 *   --repo <path>    Repo root to review. `codex review` inspects the git diff
 *                    of its cwd, so this MUST be the repo under review — not the
 *                    skill dir. Defaults to $CLAUDE_PROJECT_DIR or process.cwd().
 *   --scope <files>  Space-separated file paths to limit the review to
 *   --timeout <ms>   Timeout in ms (default: 540000 = 9 minutes)
 *
 * Output: Writes findings to /tmp/codex-review-L<N>.txt and prints "done" to stdout.
 *   On error/timeout, the file contains a bracketed status message.
 */

import { spawn } from 'node:child_process';
import { readFile, writeFile, mkdtemp, rm, unlink } from 'node:fs/promises';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { tmpdir } from 'node:os';
import { getLayer } from './layers.js';

const RESULTS_DIR = '/tmp';

function resultsPath(layerNum) {
  return join(RESULTS_DIR, `codex-review-L${layerNum}.txt`);
}

const __dirname = dirname(fileURLToPath(import.meta.url));
const promptsDir = join(__dirname, '..', 'prompts');

const args = process.argv.slice(2);

function getArg(name) {
  const index = args.indexOf(`--${name}`);
  if (index === -1 || index + 1 >= args.length) return null;
  return args[index + 1];
}

const layerNumber = parseInt(getArg('layer') || '', 10);
const intent = getArg('intent');
const scope = getArg('scope');
const timeout = parseInt(getArg('timeout') || '540000', 10);
// `codex review` diffs its cwd. Pin it to the repo under review so it can't
// accidentally review the skill's own repo (e.g. when invoked after a `cd`).
const repo = getArg('repo') || process.env.CLAUDE_PROJECT_DIR || process.cwd();

if (!layerNumber || !intent) {
  console.error('Usage: node codex-review.js --layer 5 --intent "<summary>" [--scope "<files>"] [--timeout <ms>]');
  process.exit(1);
}

const layer = getLayer(layerNumber);
if (!layer) {
  console.error(`Unknown layer: ${layerNumber}`);
  process.exit(1);
}

function extractFindings(rawOutput) {
  const lines = rawOutput.split('\n');
  let lastCodexIndex = -1;
  for (let i = lines.length - 1; i >= 0; i--) {
    if (lines[i].trim() === 'codex') {
      lastCodexIndex = i;
      break;
    }
  }
  return lastCodexIndex >= 0
    ? lines.slice(lastCodexIndex + 1).join('\n').trim()
    : rawOutput.trim();
}

async function main() {
  await unlink(resultsPath(layerNumber)).catch(() => {});

  const commonPrompt = await readFile(join(promptsDir, 'common.md'), 'utf-8');
  const layerPrompt = await readFile(join(promptsDir, layer.promptFile), 'utf-8');

  const scopeSection = scope
    ? `\n\nSCOPE: Only review changes in these files (use \`git diff -- ${scope}\`):\n${scope.split(' ').map(f => `- ${f}`).join('\n')}`
    : '';

  const fullPrompt = `${commonPrompt}\n\n${layerPrompt}\n\nContext: ${intent}${scopeSection}`;

  const tmpDir = await mkdtemp(join(tmpdir(), 'codex-review-'));
  const promptPath = join(tmpDir, 'prompt.txt');
  const outputPath = join(tmpDir, 'output.txt');

  await writeFile(promptPath, fullPrompt, 'utf-8');

  try {
    const result = await new Promise((resolve) => {
      let resolved = false;
      const done = (r) => {
        if (resolved) return;
        resolved = true;
        clearTimeout(timer);
        resolve(r);
      };

      const child = spawn('sh', ['-c', `cat "${promptPath}" | codex review - > "${outputPath}" 2>&1`], {
        stdio: 'ignore',
        cwd: repo,
      });

      const timer = setTimeout(() => {
        child.kill('SIGTERM');
        done({ timedOut: true });
      }, timeout);

      child.on('close', () => done({ timedOut: false }));
      child.on('error', () => done({ timedOut: false, error: true }));
    });

    let status = 'ok';
    let findings = '';

    if (result.timedOut) {
      status = 'timeout';
      findings = `[Codex timed out after ${timeout / 1000}s]`;
    } else if (result.error) {
      status = 'error';
      findings = '[Codex failed to start]';
    } else {
      try {
        const raw = await readFile(outputPath, 'utf-8');
        findings = extractFindings(raw);
        if (!findings) {
          status = 'empty';
          findings = `[Codex produced no findings. Raw output:\n${raw.slice(0, 2000)}]`;
        }
      } catch {
        status = 'error';
        findings = '[No output file produced]';
      }
    }

    await writeFile(resultsPath(layerNumber), findings, 'utf-8');
    console.log('done');
  } finally {
    await rm(tmpDir, { recursive: true, force: true }).catch(() => {});
  }
}

main();
