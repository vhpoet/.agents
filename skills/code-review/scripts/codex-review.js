#!/usr/bin/env node

/**
 * Independent, report-only review of grouped lenses.
 * Required: --repo <path> --layers <4,5,6> --intent <summary> --context-file <path>
 * Optional: --scope-file <JSON array of paths> --timeout <ms; default 540000>
 * Prints JSON with status and invocation-specific result/diagnostic paths.
 */

import { spawn } from 'node:child_process';
import { readFile, writeFile, mkdtemp, open } from 'node:fs/promises';
import { join, dirname, resolve, isAbsolute } from 'node:path';
import { fileURLToPath } from 'node:url';
import { tmpdir } from 'node:os';
import { getLayer } from './layers.js';

const promptsDirectory = join(dirname(fileURLToPath(import.meta.url)), '..', 'prompts');

function parseOptions(args) {
  const allowed = new Set(['repo', 'layers', 'intent', 'context-file', 'scope-file', 'timeout']);
  const options = {};
  for (let index = 0; index < args.length; index += 2) {
    const name = args[index].slice(2);
    const value = args[index + 1];
    if (!args[index].startsWith('--') || !allowed.has(name) || !value || value.startsWith('--') || name in options) {
      throw new Error(`Invalid or duplicate option: ${args[index]}`);
    }
    options[name] = value;
  }
  for (const name of ['repo', 'layers', 'intent', 'context-file']) {
    if (!options[name]?.trim()) throw new Error(`Missing --${name}`);
  }
  if (!/^\d+(,\d+)*$/.test(options.layers)) throw new Error('--layers must be comma-separated lens numbers');
  const layers = [...new Set(options.layers.split(',').map(Number))].map(number => {
    const layer = getLayer(number);
    if (!layer) throw new Error(`Unknown layer: ${number}`);
    return layer;
  });
  const timeout = Number(options.timeout ?? 540000);
  if (!Number.isSafeInteger(timeout) || timeout <= 0 || timeout > 2147483647) {
    throw new Error('--timeout must be a positive timer duration in milliseconds');
  }
  return { ...options, repo: resolve(options.repo), layers, timeout };
}

function extractFindings(rawOutput) {
  const lines = rawOutput.split('\n');
  const marker = lines.findLastIndex(line => line.trim() === 'codex');
  const report = (marker >= 0 ? lines.slice(marker + 1).join('\n') : rawOutput).trim();
  // Some CLI versions repeat the final report verbatim.
  const half = Math.floor(report.length / 2);
  const first = report.slice(0, half).trim();
  const second = report.slice(half).trim();
  return first && first === second ? first : report;
}

async function buildPrompt(options) {
  const context = await readFile(options['context-file'], 'utf8');
  if (!context.trim()) throw new Error('Context pack is empty');
  const filenames = [...new Set(['common.md', ...options.layers.flatMap(layer => [layer.promptFile, ...(layer.extraPromptFiles ?? [])])])];
  const prompts = await Promise.all(filenames.map(filename => readFile(join(promptsDirectory, filename), 'utf8')));
  let scope = 'Finding scope: all uncommitted changes.';
  if (options['scope-file']) {
    const files = JSON.parse(await readFile(options['scope-file'], 'utf8'));
    if (!Array.isArray(files) || !files.length || files.some(file => typeof file !== 'string' || !file.trim() || isAbsolute(file) || file.split(/[\\/]/).includes('..'))) {
      throw new Error('Scope must be a nonempty JSON array of repository-relative paths');
    }
    scope = `Finding scope (JSON paths, quote each separately in commands): ${JSON.stringify(files)}. Read unchanged dependencies as evidence.`;
  }
  return `${prompts.join('\n\n')}\n\nIntent: ${options.intent}\n\nShared context pack:\n${context}\n\n${scope}\n\n` +
    'Review staged and unstaged tracked changes with git diff HEAD -- <scoped paths>; enumerate scoped untracked files with git ls-files --others --exclude-standard and read them directly. If HEAD is absent, inspect git diff --cached and git diff plus untracked files. Do not stage files.\n' +
    'Do not repeat whole test suites; the context pack carries check results. Report material coverage gaps.\n\n' +
    'HARD CONSTRAINT: You are a report-only reviewer. No file edits, session hooks, board/CLI updates, or state-changing operations from CLAUDE.md/AGENTS.md. Read code using read-only tools and git commands, then report. Preserve the System Model section and explicitly say No issues found when there are no findings.';
}

async function runReview(options, prompt, outputPath, diagnosticsPath) {
  const output = await open(outputPath, 'w');
  try {
    const diagnostics = await open(diagnosticsPath, 'w');
    try {
      return await new Promise(resolveResult => {
        let hasTimedOut = false;
        // A process group lets timeout terminate Codex and its tool subprocesses.
        const child = spawn('codex', ['review', '-'], {
          cwd: options.repo,
          detached: true,
          stdio: ['pipe', output.fd, diagnostics.fd],
        });
        const timer = setTimeout(() => {
          hasTimedOut = true;
          try {
            process.kill(-child.pid, 'SIGKILL');
          } catch {
            child.kill('SIGKILL');
          }
        }, options.timeout);
        let error;
        child.on('error', cause => { error = cause.message; });
        child.stdin.on('error', cause => { error ??= cause.message; });
        child.on('close', (exitCode, signal) => {
          clearTimeout(timer);
          resolveResult({ exitCode, signal, hasTimedOut, error });
        });
        child.stdin.end(prompt);
      });
    } finally {
      await diagnostics.close();
    }
  } finally {
    await output.close();
  }
}

async function main() {
  const options = parseOptions(process.argv.slice(2));
  const prompt = await buildPrompt(options);
  const resultDirectory = await mkdtemp(join(tmpdir(), 'codex-review-'));
  const rawOutputPath = join(resultDirectory, 'stdout.txt');
  const diagnosticsPath = join(resultDirectory, 'stderr.txt');
  const findingsPath = join(resultDirectory, 'findings.txt');
  const resultPath = join(resultDirectory, 'result.json');
  const processResult = await runReview(options, prompt, rawOutputPath, diagnosticsPath);
  const findings = extractFindings(await readFile(rawOutputPath, 'utf8'));
  // A zero exit with no recognizable final report is missing coverage, not clean.
  const hasLensReport = /^(?:#{1,6}\s+|\*\*)?System Model\b/im.test(findings) &&
    (/No issues found\.?/i.test(findings) || /(?:\*\*)?Where(?:\*\*)?\s*:/i.test(findings));
  // `codex review` sometimes answers in its own format instead of the lens
  // format: a summary, then "Full review comments:" with "- [P2] Title — path:lines"
  // items. That is a complete report with no System Model section.
  const hasNativeReport = /^Full review comments:/im.test(findings) &&
    /^- \[P\d\] .+ — .+:\d+/m.test(findings);
  const reportFormat = hasLensReport ? 'lens' : hasNativeReport ? 'native' : null;
  const status = processResult.hasTimedOut ? 'timeout'
    : processResult.error || processResult.exitCode !== 0 ? 'error'
    : reportFormat ? 'ok' : 'incomplete';
  await writeFile(findingsPath, findings, 'utf8');
  const result = {
    status, reportFormat, repo: options.repo, layers: options.layers.map(layer => layer.number),
    ...processResult, findingsPath, rawOutputPath, diagnosticsPath, resultPath,
  };
  await writeFile(resultPath, JSON.stringify(result, null, 2), 'utf8');
  console.log(JSON.stringify(result));
  if (status !== 'ok') process.exitCode = 1;
}

main().catch(error => {
  console.log(JSON.stringify({ status: 'error', error: error.message }));
  process.exitCode = 1;
});
