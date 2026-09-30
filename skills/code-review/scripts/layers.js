/**
 * Layer registry for the code review skill.
 * Single source of truth for layer definitions, focus areas, and skip guidance.
 *
 * CLI modes:
 *   node layers.js --list          Print layer table (number, name, focus, impact)
 *   node layers.js --triage-help   Print skip guidelines for triage decisions
 *   node layers.js --snapshot --repo <root> --out <dir> [--scope-file <json>]
 *       Write the review diff once: <dir>/diff.patch and <dir>/changed-files.tsv
 *   node layers.js --briefs --out <dir> --context-file <pack> --intent "<summary>"
 *       --group <name>=<lens,lens> [--group ...]
 *       Write one self-contained reviewer brief per group: <dir>/brief-<name>.md
 */

import { execFileSync } from 'node:child_process';
import { readFileSync, writeFileSync, mkdirSync, existsSync } from 'node:fs';
import { join, dirname, isAbsolute } from 'node:path';
import { fileURLToPath } from 'node:url';

const promptsDirectory = join(dirname(fileURLToPath(import.meta.url)), '..', 'prompts');

export const layers = [
  {
    number: 1,
    name: 'Architecture & Boundaries',
    promptFile: 'L1-architecture-boundaries.md',
    impact: 'Highest',
    alwaysRun: true,
    skipGuidance: 'Always run, as its own Fable reviewer — never folded into the orchestrator\'s L0 pass.',
    focusAreas: [
      'Separation of concerns',
      'Mixed responsibilities',
      'Scattered concerns',
      'Over-engineered abstractions',
      'Structural opportunities',
      'File size and complexity',
      'Simplicity',
      'Emergent consolidation',
      'Architectural trajectory',
    ],
  },
  {
    number: 2,
    name: 'Data Flow & Contracts',
    promptFile: 'L2-data-flow-contracts.md',
    impact: 'High',
    alwaysRun: false,
    skipGuidance:
      "Skip if changes don't touch module interfaces, data passing, or cross-boundary communication.",
    focusAreas: [
      'Leaky abstractions',
      'Implicit coupling',
      'Broken or implicit data flow',
      'Interface boundaries',
      'Unnecessary mapping layers',
      'Error contracts',
    ],
  },
  {
    number: 3,
    name: 'Testability',
    promptFile: 'L3-testability.md',
    impact: 'High',
    alwaysRun: false,
    skipGuidance: 'Skip if no new functions, modules, or components are introduced.',
    focusAreas: [
      'Dependency injection',
      'Test seams',
      'Side effects',
      'Test isolation',
      'Boundary clarity',
    ],
  },
  {
    number: 4,
    name: 'Security & Trust Boundaries',
    promptFile: 'L4-security-trust-boundaries.md',
    impact: 'Medium-high',
    alwaysRun: false,
    skipGuidance:
      "Skip if changes don't touch API endpoints, user input handling, auth, or data access.",
    focusAreas: [
      'Authentication & authorization',
      'Trust boundaries',
      'Input sanitization',
      'Secrets handling',
      'Audit logging',
      'Rate limiting & abuse prevention',
    ],
  },
  {
    number: 5,
    name: 'Correctness',
    promptFile: 'L5-correctness.md',
    impact: 'Medium',
    alwaysRun: true,
    skipGuidance: 'Assess every distinct changed behavior; group with related lenses and prioritize consequence as well as complexity.',
    focusAreas: [
      'Logic defects',
      'Unsafe edge cases',
      'Failure modes',
      'Idempotency',
      'Missing await',
      'Unhandled rejections',
      'Concurrent mutations',
      'Cleanup on cancellation',
      'Ordering assumptions',
    ],
  },
  {
    number: 6,
    name: 'Data Safety',
    promptFile: 'L6-data-safety.md',
    impact: 'Medium',
    alwaysRun: false,
    skipGuidance:
      'Skip if no database operations, migrations, transactions, or persisted state changes.',
    focusAreas: [
      'Data integrity',
      'Transactions',
      'Migrations',
      'Backward compatibility',
      'Resource lifetimes',
      'Systemic risks',
    ],
  },
  {
    number: 7,
    name: 'Database & Queries',
    promptFile: 'L7-database-queries.md',
    impact: 'Medium',
    alwaysRun: false,
    skipGuidance: 'Skip if no database queries added or modified.',
    focusAreas: [
      'Join vs separate queries',
      'Missing indexes',
      'SELECT efficiency',
      'Query structure',
      'Knex patterns',
      'Pagination',
    ],
  },
  {
    number: 8,
    name: 'Test Coverage',
    promptFile: 'L8-test-coverage.md',
    impact: 'Medium',
    alwaysRun: false,
    skipGuidance:
      'Skip if changes are purely config, styling, documentation, or trivial refactors.',
    focusAreas: [
      'Missing unit tests',
      'Missing integration tests',
      'Edge cases',
      'Error paths',
      'Happy path gaps',
      'Regression risks',
      'Test quality',
    ],
  },
  {
    number: 9,
    name: 'Performance & Efficiency',
    promptFile: 'L9-performance-efficiency.md',
    impact: 'Medium',
    alwaysRun: false,
    skipGuidance:
      "Skip if changes don't involve data access, loops, rendering, API calls, or hot paths.",
    focusAreas: [
      'Algorithmic complexity',
      'Hot paths',
      'N+1 queries',
      'Pagination',
      'Buffering versus streaming',
      'Payload sizes',
      'Memory usage',
      'Infrastructure cost',
    ],
  },
  {
    number: 10,
    name: 'Observability & Operability',
    promptFile: 'L10-observability-operability.md',
    impact: 'Low-medium',
    alwaysRun: false,
    skipGuidance:
      'Skip if no backend service code, error handling, or operational code changed.',
    focusAreas: [
      'Logging',
      'Metrics',
      'Tracing',
      'Error messages',
      'Feature flags & kill switches',
      'Graceful degradation',
      'Timeouts & retries',
    ],
  },
  {
    number: 11,
    name: 'Code Hygiene & Readability',
    promptFile: 'L11-code-hygiene.md',
    impact: 'Medium',
    alwaysRun: true,
    skipGuidance: 'Always run (skip only for pure config, docs, or dependency bumps).',
    focusAreas: [
      'Unused, stale, dead code (uses knip)',
      'Duplicated / reinvented code',
      'Bug-prone patterns',
      'Naming & grep-ability',
      'Cold-reader experience',
      'Locality of reasoning',
      'Least astonishment',
      'Narrative structure',
    ],
  },
  {
    number: 14,
    name: 'Web Platform (React + Next.js)',
    promptFile: 'L14-web-platform.md',
    extraPromptFiles: ['L13-react-patterns.md'],
    impact: 'High',
    alwaysRun: false,
    skipGuidance:
      'Skip if no web frontend code changed. Carries the React-patterns lens (L13 prompt) for web components, hooks, and client state.',
    focusAreas: [
      'React patterns (effects, memoization, state machines)',
      'Server/client boundaries',
      'Server Action security',
      'Cache leakage',
      'Bundle discipline',
      'Hydration & rendering',
      'XSS surfaces',
      'Web focus contract',
    ],
  },
  {
    number: 15,
    name: 'Mobile Platform (React + RN/Expo)',
    promptFile: 'L15-mobile-platform.md',
    extraPromptFiles: ['L13-react-patterns.md'],
    impact: 'High',
    alwaysRun: false,
    skipGuidance:
      'Skip if no React Native or Expo code changed. Carries the React-patterns lens (L13 prompt) for RN components, hooks, and client state.',
    focusAreas: [
      'React patterns (effects, memoization, state machines)',
      'Lists & rendering',
      'Animations & gestures',
      'Storage security',
      'Platform quirks',
      'Native accessibility',
      'Expo SDK / OTA / notifications',
      'Offline & lifecycle',
      'App Store compliance',
    ],
  },
  {
    number: 16,
    name: 'Design Quality',
    promptFile: 'L16-design-quality.md',
    impact: 'Medium',
    alwaysRun: false,
    skipGuidance: 'Skip if no user-visible UI changes (layout, styling, components, screens).',
    focusAreas: [
      'Token adherence',
      'Hierarchy & spacing',
      'States as designed surfaces',
      'Motion',
      'Mobile feel',
      'Generic-UI red flags',
    ],
  },
];

export function getLayer(number) {
  return layers.find((l) => l.number === number);
}

export function getLayers(numbers) {
  return numbers.map((n) => getLayer(n)).filter(Boolean);
}

function readOption(args, name) {
  const index = args.indexOf(`--${name}`);
  return index === -1 ? undefined : args[index + 1];
}

function readRepeatedOption(args, name) {
  return args.flatMap((arg, index) => (arg === `--${name}` ? [args[index + 1]] : []));
}

function requireOption(args, name) {
  const value = readOption(args, name);
  if (!value) throw new Error(`--${name} is required`);
  return value;
}

function readScopePaths(scopeFile) {
  if (!scopeFile) return [];
  const paths = JSON.parse(readFileSync(scopeFile, 'utf8'));
  if (!Array.isArray(paths) || !paths.length || paths.some((path) => typeof path !== 'string' || !path.trim() || isAbsolute(path))) {
    throw new Error('Scope must be a nonempty JSON array of repository-relative paths');
  }
  return paths;
}

// Split a patch into per-file sections, each with its 1-based line range.
function indexPatchSections(patch, startLine) {
  const lines = patch.split('\n');
  const sections = [];
  lines.forEach((line, index) => {
    if (line.startsWith('diff --git ')) sections.push({ start: startLine + index });
  });
  sections.forEach((section, index) => {
    const next = sections[index + 1];
    section.end = next ? next.start - 1 : startLine + lines.length - 1;
  });
  return sections;
}

// Tracked changes against HEAD (staged + unstaged), then untracked files as new-file patches,
// so reviewers read one file instead of each re-running git diff.
function writeSnapshot(args) {
  const repo = requireOption(args, 'repo');
  const outDirectory = requireOption(args, 'out');
  const scopePaths = readScopePaths(readOption(args, 'scope-file'));
  const git = (gitArgs, { allowExitOne = false } = {}) => {
    try {
      return execFileSync('git', ['-C', repo, ...gitArgs], { encoding: 'utf8', maxBuffer: 1024 * 1024 * 1024 });
    } catch (error) {
      if (allowExitOne && error.status === 1) return error.stdout;
      throw error;
    }
  };
  const hasHead = (() => {
    try { git(['rev-parse', '--verify', '--quiet', 'HEAD']); return true; } catch { return false; }
  })();
  const comparisons = hasHead ? [['HEAD']] : [['--cached'], []];
  const diffOptions = ['--no-color', '--no-ext-diff', '-M'];

  const entries = [];
  const patchParts = [];
  let nextLine = 1;
  const appendPatch = (patch, fileEntries) => {
    if (!patch) return;
    const text = patch.endsWith('\n') ? patch.slice(0, -1) : patch;
    const sections = indexPatchSections(text, nextLine);
    if (sections.length !== fileEntries.length) {
      throw new Error(`Patch sections (${sections.length}) do not match file list (${fileEntries.length})`);
    }
    fileEntries.forEach((entry, index) => entries.push({ ...entry, ...sections[index] }));
    patchParts.push(text);
    nextLine += text.split('\n').length;
  };

  for (const comparison of comparisons) {
    const pathArgs = ['--', ...scopePaths];
    const nameStatus = git(['diff', ...comparison, ...diffOptions, '--name-status', '-z', ...pathArgs]).split('\0').filter(Boolean);
    const fileEntries = [];
    for (let index = 0; index < nameStatus.length;) {
      const status = nameStatus[index++];
      const isRenameOrCopy = /^[RC]/.test(status);
      const path = isRenameOrCopy ? `${nameStatus[index++]} -> ${nameStatus[index++]}` : nameStatus[index++];
      fileEntries.push({ status, path });
    }
    appendPatch(git(['diff', ...comparison, ...diffOptions, ...pathArgs]), fileEntries);
  }

  const untracked = git(['ls-files', '--others', '--exclude-standard', '-z', '--', ...scopePaths]).split('\0').filter(Boolean);
  for (const path of untracked) {
    appendPatch(git(['diff', '--no-index', ...diffOptions, '--', '/dev/null', path], { allowExitOne: true }), [{ status: '??', path }]);
  }

  mkdirSync(outDirectory, { recursive: true });
  const revision = hasHead ? git(['rev-parse', 'HEAD']).trim() : '(no HEAD)';
  writeFileSync(join(outDirectory, 'diff.patch'), patchParts.length ? `${patchParts.join('\n')}\n` : '');
  writeFileSync(
    join(outDirectory, 'changed-files.tsv'),
    `# status\tpath\tdiff.patch lines — base ${revision}, uncommitted changes as of ${new Date().toISOString()}\n` +
      entries.map((entry) => `${entry.status}\t${entry.path}\t${entry.start}-${entry.end}`).join('\n') + '\n',
  );
  console.log(JSON.stringify({ diffPath: join(outDirectory, 'diff.patch'), changedFilesPath: join(outDirectory, 'changed-files.tsv'), files: entries.length, diffLines: nextLine - 1 }));
}

function parseGroup(spec) {
  const [name, lensList] = spec.split('=');
  if (!name || !/^[a-z0-9-]+$/.test(name) || !lensList) throw new Error(`Bad --group "${spec}"; expected name=1,5,6`);
  const groupLayers = lensList.split(',').map((value) => {
    const layer = getLayer(Number(value));
    if (!layer) throw new Error(`Unknown lens ${value} in --group "${spec}"`);
    return layer;
  });
  return { name, groupLayers };
}

// One self-contained brief per reviewer group: rules + common method + lens prompts,
// so no reviewer re-reads prompt files or re-runs the diff.
function writeBriefs(args) {
  const outDirectory = requireOption(args, 'out');
  const contextFile = requireOption(args, 'context-file');
  const intent = requireOption(args, 'intent');
  const diffPath = join(outDirectory, 'diff.patch');
  const changedFilesPath = join(outDirectory, 'changed-files.tsv');
  if (!existsSync(diffPath) || !existsSync(changedFilesPath)) throw new Error('Run --snapshot into the same --out directory first');
  const groups = readRepeatedOption(args, 'group').map(parseGroup);
  if (!groups.length) throw new Error('At least one --group is required');

  const briefPaths = groups.map(({ name, groupLayers }) => {
    const filenames = [...new Set(['common.md', ...groupLayers.flatMap((layer) => [layer.promptFile, ...(layer.extraPromptFiles ?? [])])])];
    const lensNames = groupLayers.map((layer) => `L${layer.number} ${layer.name}`).join(', ');
    const header = [
      `# Code review brief: ${name}`,
      '',
      `Lenses: ${lensNames}. Apply every one, reading shared dependencies once.`,
      `Intent: ${intent}`,
      `Shared context pack: ${contextFile} (read it first).`,
      `Diff snapshot: ${diffPath}. Changed files with their line ranges in the snapshot: ${changedFilesPath}.`,
      'The snapshot is the review revision, untracked files included as new-file patches. Read it at the listed ranges instead of running git diff or git ls-files; read current files and unchanged callers directly for context.',
      'Finding scope: the files named where you were launched; if none are named, every file in changed-files.tsv.',
      'Read code and trace callers before reporting. Do not edit or create files, run session hooks, or touch the CEO board. Do not repeat whole check suites.',
      'Return your report as the text of your final message, in the output format below. Never write report files.',
      '',
      '---',
      '',
    ].join('\n');
    const body = filenames.map((filename) => readFileSync(join(promptsDirectory, filename), 'utf8').trim()).join('\n\n---\n\n');
    const briefPath = join(outDirectory, `brief-${name}.md`);
    writeFileSync(briefPath, `${header}${body}\n`);
    return { name, briefPath, lenses: groupLayers.map((layer) => layer.number) };
  });
  console.log(JSON.stringify(briefPaths, null, 2));
}

// CLI mode
const args = process.argv.slice(2);

if (args.includes('--list')) {
  console.log('| Layer | Name | Focus | Impact |');
  console.log('|-------|------|-------|--------|');
  console.log('| 0 | Approach | Is this the right way to achieve the goal? | Highest |');
  for (const l of layers) {
    console.log(`| ${l.number} | ${l.name} | ${l.focusAreas.slice(0, 3).join(', ')} | ${l.impact} |`);
  }
} else if (args.includes('--triage-help')) {
  for (const l of layers) {
    const prompts = [l.promptFile, ...(l.extraPromptFiles ?? [])].join(' + ');
    console.log(`L${l.number} ${l.name} [${prompts}]: ${l.skipGuidance}`);
  }
  console.log('\nGroup lenses inspecting the same flow; split for distinct risks. When in doubt, run the lens. Critical lenses (L4/L5/L6 whenever selected) get a Codex twin.');
  console.log('Default groups (3-4 reviewers): architecture=1 (always alone) | behavior=2,4,5,6,7,9,10 | tests-hygiene=3,8,11 | platform=14 or 15,16 when UI changed. Drop unselected lenses; split a group only for a documented reason.');
} else if (args.includes('--snapshot')) {
  writeSnapshot(args);
} else if (args.includes('--briefs')) {
  writeBriefs(args);
}
