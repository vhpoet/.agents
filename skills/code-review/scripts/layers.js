/**
 * Layer registry for the code review skill.
 * Single source of truth for layer definitions, focus areas, and skip guidance.
 *
 * CLI modes:
 *   node layers.js --list          Print layer table (number, name, focus, impact)
 *   node layers.js --triage-help   Print skip guidelines for triage decisions
 */

export const layers = [
  {
    number: 1,
    name: 'Architecture & Boundaries',
    promptFile: 'L1-architecture-boundaries.md',
    impact: 'Highest',
    alwaysRun: true,
    skipGuidance: 'Always run.',
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
    skipGuidance: 'Always run.',
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
    name: 'Code Hygiene',
    promptFile: 'L11-code-hygiene.md',
    impact: 'Low',
    alwaysRun: true,
    skipGuidance: 'Always run.',
    focusAreas: [
      'Unused, stale, dead code (uses knip)',
      'Duplicated code',
      'Reinvented existing code',
      'Messy or smelly code',
      'Bug-prone patterns',
      'Naming',
    ],
  },
  {
    number: 12,
    name: 'Readability & Comprehension',
    promptFile: 'L12-readability.md',
    impact: 'Medium',
    alwaysRun: true,
    skipGuidance: 'Always run (skip only for pure config, docs, or dependency bumps).',
    focusAreas: [
      'Cold-reader experience',
      'Locality of reasoning',
      'Least astonishment',
      'Narrative structure',
      'Single level of abstraction',
      'Working memory budget',
      'File-to-concept mapping',
    ],
  },
  {
    number: 13,
    name: 'React Patterns',
    promptFile: 'L13-react-patterns.md',
    impact: 'High',
    alwaysRun: false,
    skipGuidance:
      'Skip if no React or React Native component, hook, or client state code changed.',
    focusAreas: [
      'Effect discipline',
      'Memoization posture (React Compiler)',
      'Component & hook structure',
      'UI state machine',
      'Redux / RTK Query',
      'Boundary validation',
      'Forms',
      'Accessibility fundamentals',
    ],
  },
  {
    number: 14,
    name: 'Web Platform (Next.js)',
    promptFile: 'L14-web-platform.md',
    impact: 'High',
    alwaysRun: false,
    skipGuidance: 'Skip if no Next.js or web frontend code changed.',
    focusAreas: [
      'Server/client boundaries',
      'Server Action security',
      'Cache leakage',
      'Bundle discipline',
      'App Router stores',
      'Hydration & rendering',
      'XSS surfaces',
      'Web focus contract',
    ],
  },
  {
    number: 15,
    name: 'Mobile Platform (RN/Expo)',
    promptFile: 'L15-mobile-platform.md',
    impact: 'High',
    alwaysRun: false,
    skipGuidance: 'Skip if no React Native or Expo code changed.',
    focusAreas: [
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
    console.log(`L${l.number} ${l.name} [${l.promptFile}]: ${l.skipGuidance}`);
  }
  console.log('\nWhen in doubt, run the layer.');
}
