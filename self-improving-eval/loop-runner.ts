/**
 * Sanzen Self-Improving Loop Runner
 * ==================================
 * This is the "train.py" equivalent from autoresearch.
 * It runs the eval, reads the improvement prompt, and applies changes.
 *
 * The loop:
 * 1. Run eval-engine → get scores
 * 2. Read improvement-prompt.md → understand weakest areas
 * 3. Apply safe, high-confidence fixes
 * 4. Re-eval → compare scores
 * 5. Keep improvements or revert
 * 6. Generate new improvement prompt for next cycle
 *
 * Run: npx ts-node loop-runner.ts
 */

import * as fs from 'fs';
import * as path from 'path';
import { execSync } from 'child_process';

const ROOT = path.resolve(__dirname, '..');
const EVAL_DIR = path.resolve(__dirname);
const RESULTS_FILE = path.join(EVAL_DIR, 'eval-results.json');
const PROMPT_FILE = path.join(EVAL_DIR, 'improvement-prompt.md');
const CHANGELOG = path.join(EVAL_DIR, 'changelog.md');

interface LoopReport {
  cycle: number;
  timestamp: string;
  beforeScore: string;
  afterScore: string;
  delta: string;
  appliedFixes: string[];
  skippedFixes: string[];
  promptVersion: number;
}

function getLastScore(): { percentage: string; promptVersion: number } | null {
  if (!fs.existsSync(RESULTS_FILE)) return null;
  try {
    const data = JSON.parse(fs.readFileSync(RESULTS_FILE, 'utf-8'));
    if (data.runs && data.runs.length > 0) {
      const last = data.runs[data.runs.length - 1];
      return { percentage: last.percentage, promptVersion: last.promptVersion };
    }
  } catch { }
  return null;
}

function runEval(): string {
  try {
    const result = execSync(`npx ts-node "${path.join(EVAL_DIR, 'eval-engine.ts')}"`, {
      cwd: ROOT,
      timeout: 60000,
      encoding: 'utf-8',
      stdio: ['pipe', 'pipe', 'pipe'],
    });
    return result;
  } catch (e: any) {
    return e.stdout || e.message;
  }
}

function readImprovementPrompt(): string {
  if (!fs.existsSync(PROMPT_FILE)) return '';
  return fs.readFileSync(PROMPT_FILE, 'utf-8');
}

function appendChangelog(report: LoopReport) {
  let log = '';
  if (fs.existsSync(CHANGELOG)) {
    log = fs.readFileSync(CHANGELOG, 'utf-8');
  } else {
    log = '# Sanzen Self-Improving Eval Changelog\n\n';
  }

  log += `## Cycle ${report.cycle} - ${report.timestamp}\n`;
  log += `- Score: ${report.beforeScore}% → ${report.afterScore}% (${report.delta})\n`;
  log += `- Prompt Version: v${report.promptVersion}\n`;

  if (report.appliedFixes.length > 0) {
    log += `- Applied:\n`;
    report.appliedFixes.forEach(f => { log += `  - ${f}\n`; });
  }

  if (report.skippedFixes.length > 0) {
    log += `- Skipped (needs human approval):\n`;
    report.skippedFixes.forEach(f => { log += `  - ${f}\n`; });
  }

  log += '\n';
  fs.writeFileSync(CHANGELOG, log);
}

// ─── Safe Auto-Fixes ─────────────────────────────────────────────────────────
// These are fixes that can be applied without human review.
// Following autoresearch's principle: keep diffs small and reviewable.

interface AutoFix {
  name: string;
  description: string;
  check: () => boolean; // Returns true if fix is needed
  apply: () => boolean; // Returns true if fix was applied successfully
  confidence: number;   // 0-100, only apply if > 80
  requiresHuman: boolean;
}

function getAutoFixes(): AutoFix[] {
  return [
    {
      name: 'gitignore-uploads',
      description: 'Ensure uploads/ directory is gitignored',
      confidence: 95,
      requiresHuman: false,
      check: () => {
        const gitignore = path.join(ROOT, '.gitignore');
        if (!fs.existsSync(gitignore)) return true;
        const content = fs.readFileSync(gitignore, 'utf-8');
        return !content.includes('uploads/');
      },
      apply: () => {
        const gitignore = path.join(ROOT, '.gitignore');
        let content = fs.existsSync(gitignore) ? fs.readFileSync(gitignore, 'utf-8') : '';
        if (!content.includes('uploads/')) {
          content += '\n# Uploaded files\nbackend/uploads/\n';
          fs.writeFileSync(gitignore, content);
          return true;
        }
        return false;
      },
    },
    {
      name: 'gitignore-env',
      description: 'Ensure .env files are gitignored',
      confidence: 99,
      requiresHuman: false,
      check: () => {
        const gitignore = path.join(ROOT, '.gitignore');
        if (!fs.existsSync(gitignore)) return true;
        const content = fs.readFileSync(gitignore, 'utf-8');
        return !content.includes('.env');
      },
      apply: () => {
        const gitignore = path.join(ROOT, '.gitignore');
        let content = fs.existsSync(gitignore) ? fs.readFileSync(gitignore, 'utf-8') : '';
        if (!content.includes('.env')) {
          content += '\n# Environment files\n.env\n.env.local\n';
          fs.writeFileSync(gitignore, content);
          return true;
        }
        return false;
      },
    },
    {
      name: 'gitignore-eval-results',
      description: 'Gitignore eval results (they regenerate)',
      confidence: 90,
      requiresHuman: false,
      check: () => {
        const gitignore = path.join(ROOT, '.gitignore');
        if (!fs.existsSync(gitignore)) return true;
        const content = fs.readFileSync(gitignore, 'utf-8');
        return !content.includes('eval-results.json');
      },
      apply: () => {
        const gitignore = path.join(ROOT, '.gitignore');
        let content = fs.existsSync(gitignore) ? fs.readFileSync(gitignore, 'utf-8') : '';
        if (!content.includes('eval-results.json')) {
          content += '\n# Eval system (auto-generated)\nself-improving-eval/eval-results.json\nself-improving-eval/improvement-prompt.md\nself-improving-eval/changelog.md\n';
          fs.writeFileSync(gitignore, content);
          return true;
        }
        return false;
      },
    },
    {
      name: 'missing-env-example',
      description: 'Create .env.example if missing (safe - no secrets)',
      confidence: 85,
      requiresHuman: false,
      check: () => {
        return !fs.existsSync(path.join(ROOT, 'backend', '.env.example'));
      },
      apply: () => {
        const envExample = `# Sanzen Backend Environment Variables
# Copy this file to .env and fill in the values

PORT=3000
API_PREFIX=api/v1

# Database
DATABASE_URL=postgresql://user:password@host:5432/sanzen_db?schema=sanzenapp

# JWT
JWT_SECRET=your_jwt_secret_here
JWT_REFRESH_SECRET=your_refresh_secret_here
JWT_EXPIRATION=1d
JWT_REFRESH_EXPIRATION=7d

# Mail (optional)
MAIL_HOST=smtp.example.com
MAIL_PORT=587
MAIL_USER=
MAIL_PASS=
MAIL_FROM=noreply@sanzen.ae

# Admin
ADMIN_API_KEY=your_admin_key

# AI Services
STABILITY_API_KEY=your_stability_key
BACKEND_URL=http://127.0.0.1:3000
`;
        fs.writeFileSync(path.join(ROOT, 'backend', '.env.example'), envExample);
        return true;
      },
    },
  ];
}

// ─── Main Loop ───────────────────────────────────────────────────────────────

function runLoop() {
  console.log('\n🔄 Starting Self-Improving Loop Cycle...\n');

  // Step 1: Run initial eval
  console.log('Step 1: Running eval...');
  runEval();
  const beforeScore = getLastScore();

  if (!beforeScore) {
    console.log('❌ Could not get initial score. Aborting.');
    return;
  }
  console.log(`  Before score: ${beforeScore.percentage}%\n`);

  // Step 2: Read improvement prompt
  console.log('Step 2: Reading improvement prompt...');
  const prompt = readImprovementPrompt();
  console.log(`  Prompt v${beforeScore.promptVersion} loaded (${prompt.length} chars)\n`);

  // Step 3: Apply safe auto-fixes
  console.log('Step 3: Applying safe auto-fixes...');
  const fixes = getAutoFixes();
  const appliedFixes: string[] = [];
  const skippedFixes: string[] = [];

  for (const fix of fixes) {
    if (fix.check()) {
      if (fix.confidence > 80 && !fix.requiresHuman) {
        console.log(`  ✓ Applying: ${fix.name} (confidence: ${fix.confidence}%)`);
        if (fix.apply()) {
          appliedFixes.push(`${fix.name}: ${fix.description}`);
        }
      } else {
        console.log(`  ⏸ Skipping: ${fix.name} (confidence: ${fix.confidence}%, needs human: ${fix.requiresHuman})`);
        skippedFixes.push(`${fix.name}: ${fix.description}`);
      }
    }
  }

  console.log(`  Applied: ${appliedFixes.length}, Skipped: ${skippedFixes.length}\n`);

  // Step 4: Re-eval after fixes
  console.log('Step 4: Re-evaluating after fixes...');
  const evalOutput = runEval();
  const afterScore = getLastScore();

  if (!afterScore) {
    console.log('❌ Could not get post-fix score.');
    return;
  }

  const delta = (parseFloat(afterScore.percentage) - parseFloat(beforeScore.percentage)).toFixed(1);
  const deltaStr = parseFloat(delta) >= 0 ? `+${delta}%` : `${delta}%`;

  console.log(`\n${'═'.repeat(50)}`);
  console.log(`  CYCLE RESULT: ${beforeScore.percentage}% → ${afterScore.percentage}% (${deltaStr})`);
  console.log(`${'═'.repeat(50)}\n`);

  // Step 5: Log to changelog
  const report: LoopReport = {
    cycle: beforeScore.promptVersion,
    timestamp: new Date().toISOString(),
    beforeScore: beforeScore.percentage,
    afterScore: afterScore.percentage,
    delta: deltaStr,
    appliedFixes,
    skippedFixes,
    promptVersion: afterScore.promptVersion,
  };
  appendChangelog(report);

  console.log(`Changelog updated → ${CHANGELOG}`);
  console.log(`Next cycle will use improvement-prompt.md v${afterScore.promptVersion}`);
}

// ─── Run ─────────────────────────────────────────────────────────────────────

runLoop();
