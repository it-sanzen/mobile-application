/**
 * Sanzen Watch Loop - Runs eval every 2 minutes
 * ================================================
 * Like autoresearch's overnight experiment runner,
 * this continuously evaluates and improves the app.
 *
 * Run: npx ts-node watch-loop.ts
 * Stop: Ctrl+C
 */

import { execSync } from 'child_process';
import * as path from 'path';
import * as fs from 'fs';

const EVAL_DIR = path.resolve(__dirname);
const RESULTS_FILE = path.join(EVAL_DIR, 'eval-results.json');
const INTERVAL_MS = 2 * 60 * 1000; // 2 minutes

let cycleCount = 0;

function formatTime(ms: number): string {
  const s = Math.floor(ms / 1000);
  const m = Math.floor(s / 60);
  const h = Math.floor(m / 60);
  return `${h}h ${m % 60}m ${s % 60}s`;
}

function getScoreHistory(): string[] {
  try {
    const data = JSON.parse(fs.readFileSync(RESULTS_FILE, 'utf-8'));
    return data.runs.slice(-10).map((r: any) => r.percentage + '%');
  } catch { return []; }
}

function runCycle() {
  cycleCount++;
  const startTime = Date.now();
  const elapsed = formatTime(cycleCount * INTERVAL_MS);

  console.log(`\n${'═'.repeat(60)}`);
  console.log(`  CYCLE #${cycleCount} | Elapsed: ${elapsed} | ${new Date().toLocaleTimeString()}`);
  console.log(`${'═'.repeat(60)}`);

  try {
    const output = execSync(`npx ts-node "${path.join(EVAL_DIR, 'loop-runner.ts')}"`, {
      cwd: path.resolve(EVAL_DIR, '..'),
      timeout: 90000,
      encoding: 'utf-8',
      stdio: ['pipe', 'pipe', 'pipe'],
    });
    console.log(output);
  } catch (e: any) {
    console.log(e.stdout || '');
    if (e.stderr) console.error('Errors:', e.stderr.substring(0, 500));
  }

  // Print score trend
  const history = getScoreHistory();
  if (history.length > 1) {
    console.log(`  Score trend: ${history.join(' → ')}`);
  }

  console.log(`  Next cycle in ${INTERVAL_MS / 1000}s (${new Date(Date.now() + INTERVAL_MS).toLocaleTimeString()})`);
}

// ─── Start ───────────────────────────────────────────────────────────────────

console.log('╔══════════════════════════════════════════════════════════╗');
console.log('║   SANZEN SELF-IMPROVING WATCH LOOP                      ║');
console.log('║   Running eval every 2 minutes                          ║');
console.log('║   Press Ctrl+C to stop                                  ║');
console.log('╚══════════════════════════════════════════════════════════╝');

// Run immediately, then every 2 minutes
runCycle();
setInterval(runCycle, INTERVAL_MS);
