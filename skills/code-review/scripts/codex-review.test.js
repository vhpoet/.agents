import test from 'node:test';
import assert from 'node:assert/strict';
import { spawn } from 'node:child_process';
import { mkdtemp, mkdir, writeFile, readFile, rm, realpath } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { fileURLToPath } from 'node:url';

const script = fileURLToPath(new URL('./codex-review.js', import.meta.url));

async function fixture(t, mode = 'clean') {
  const root = await mkdtemp(join(tmpdir(), 'review-wrapper-test-'));
  t.after(() => rm(root, { recursive: true, force: true }));
  const bin = join(root, 'bin');
  const repo = join(root, 'repo with spaces');
  await mkdir(bin);
  await mkdir(repo);
  const contextPath = join(root, 'context.md');
  const context = 'Appetite: Never double-charge.\nChecks: payment tests passed.\nUntracked: src/new flow.ts';
  await writeFile(contextPath, context);
  const scopePath = join(root, 'scope.json');
  const scope = ['src/new flow.ts', 'src/$(literal).ts'];
  await writeFile(scopePath, JSON.stringify(scope));
  if (mode !== 'missing') {
    await writeFile(join(bin, 'codex'), `#!${process.execPath}
const fs = require('node:fs');
let prompt = '';
process.stdin.setEncoding('utf8');
process.stdin.on('data', part => { prompt += part; });
process.stdin.on('end', () => {
  fs.writeFileSync(process.env.REVIEW_CAPTURE, JSON.stringify({prompt, cwd: process.cwd(), args: process.argv.slice(2)}));
  const mode = process.env.REVIEW_MODE;
  const clean = '## System Model\\nTest subsystem.\\n\\nNo issues found.';
  if (mode === 'timeout') {
    process.on('SIGTERM', () => {});
    setInterval(() => {}, 1000);
    return;
  }
  if (mode === 'signal') { process.kill(process.pid, 'SIGTERM'); return; }
  if (mode === 'empty') return;
  if (mode === 'noise') { console.log('Starting review...'); return; }
  if (mode === 'failure') {
    console.log(clean);
    console.error('Authentication failed');
    process.exitCode = 7;
    return;
  }
  if (mode === 'finding') {
    console.log('## System Model\\nTest subsystem.\\n### Duplicate charge\\n**Where**: payment.ts:3\\n**Issue**: Retry charges twice.');
    return;
  }
  console.error('progress only');
  console.log(clean);
});
`, { mode: 0o755 });
  }
  const capture = join(root, 'capture.json');
  const args = ['--repo', repo, '--layers', '4,5,6', '--intent', 'Payment change', '--context-file', contextPath, '--scope-file', scopePath];
  async function run(extra = [], capturePath = capture) {
    return await new Promise((resolve, reject) => {
      const child = spawn(process.execPath, [script, ...args, ...extra], {
        env: { ...process.env, PATH: bin, TMPDIR: root, REVIEW_MODE: mode, REVIEW_CAPTURE: capturePath },
        stdio: ['ignore', 'pipe', 'pipe'],
      });
      let stdout = '';
      let stderr = '';
      child.stdout.on('data', data => { stdout += data; });
      child.stderr.on('data', data => { stderr += data; });
      child.on('error', reject);
      child.on('close', code => {
        try { resolve({ code, result: JSON.parse(stdout), stderr }); }
        catch (error) { reject(new Error(`${error.message}: ${stdout} ${stderr}`)); }
      });
    });
  }
  return { root, repo, args, context, scope, capture, run };
}

test('transfers shared context, grouped lenses, scope and complete diff instructions', async t => {
  const f = await fixture(t);
  const { code, result } = await f.run();
  assert.equal(code, 0);
  assert.equal(result.status, 'ok');
  assert.deepEqual(result.layers, [4, 5, 6]);
  const captured = JSON.parse(await readFile(f.capture, 'utf8'));
  assert.equal(captured.cwd, await realpath(f.repo));
  assert.deepEqual(captured.args, ['review', '-']);
  assert.ok(captured.prompt.includes(f.context));
  assert.ok(captured.prompt.includes(JSON.stringify(f.scope)));
  for (const phrase of ['Security & Trust Boundaries', 'Correctness', 'Data Safety', 'Disposition', 'git diff HEAD', 'git ls-files --others --exclude-standard', 'git diff --cached']) {
    assert.ok(captured.prompt.includes(phrase), phrase);
  }
  assert.equal(captured.prompt.split('## Your Task').length - 1, 1);
  assert.match(await readFile(result.findingsPath, 'utf8'), /No issues found/);
  assert.doesNotMatch(await readFile(result.findingsPath, 'utf8'), /progress only/);
  assert.deepEqual(JSON.parse(await readFile(result.resultPath, 'utf8')), result);
});

test('concurrent reviews have isolated, durable result files', async t => {
  const f = await fixture(t);
  const [first, second] = await Promise.all([f.run([], join(f.root, 'first.json')), f.run([], join(f.root, 'second.json'))]);
  assert.equal(first.result.status, 'ok');
  assert.equal(second.result.status, 'ok');
  assert.notEqual(first.result.resultPath, second.result.resultPath);
  for (const { result } of [first, second]) assert.match(await readFile(result.findingsPath, 'utf8'), /No issues found/);
});

for (const [mode, expected] of [['finding', 'ok'], ['failure', 'error'], ['missing', 'error'], ['signal', 'error'], ['empty', 'incomplete'], ['noise', 'incomplete'], ['timeout', 'timeout']]) {
  test(`${mode} is classified as ${expected}`, async t => {
    const f = await fixture(t, mode);
    const { code, result } = await f.run(mode === 'timeout' ? ['--timeout', '200'] : []);
    assert.equal(result.status, expected);
    assert.equal(code, expected === 'ok' ? 0 : 1);
    if (mode === 'failure') {
      assert.equal(result.exitCode, 7);
      assert.match(await readFile(result.diagnosticsPath, 'utf8'), /Authentication failed/);
    }
    if (mode === 'timeout') {
      assert.equal(result.hasTimedOut, true);
      assert.equal(result.signal, 'SIGKILL');
    }
  });
}

test('deduplicates companion prompts in grouped platform reviews', async t => {
  const f = await fixture(t);
  f.args[f.args.indexOf('--layers') + 1] = '14,15,14';
  const { result } = await f.run();
  assert.deepEqual(result.layers, [14, 15]);
  const { prompt } = JSON.parse(await readFile(f.capture, 'utf8'));
  assert.equal(prompt.split('Companion lens: React Patterns').length - 1, 1);
});

test('invalid inputs fail before starting Codex', async t => {
  const f = await fixture(t);
  const { result, code } = await f.run(['--timeout', 'nope']);
  assert.equal(code, 1);
  assert.equal(result.status, 'error');
  assert.match(result.error, /timeout/);
  await assert.rejects(readFile(f.capture), { code: 'ENOENT' });
});
