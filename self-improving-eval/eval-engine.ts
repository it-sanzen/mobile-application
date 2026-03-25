/**
 * Sanzen App Self-Improving Eval Engine
 * ======================================
 * Inspired by karpathy/autoresearch
 *
 * This is the "prepare.py" equivalent - the immutable evaluation foundation.
 * It checks all 5 constraints, scores each area, and logs results.
 *
 * Run: npx ts-node eval-engine.ts
 */

import * as fs from 'fs';
import * as path from 'path';
import { execSync } from 'child_process';

// ─── Types ───────────────────────────────────────────────────────────────────

interface ConstraintResult {
  name: string;
  score: number; // 0-10
  maxScore: number;
  issues: string[];
  suggestions: string[];
  details: Record<string, CheckResult>;
}

interface CheckResult {
  name: string;
  passed: boolean;
  severity: 'critical' | 'warning' | 'info';
  message: string;
}

interface EvalRun {
  timestamp: string;
  runId: string;
  duration_ms: number;
  overallScore: number;
  maxPossibleScore: number;
  percentage: string;
  constraints: ConstraintResult[];
  improvementsSuggested: string[];
  improvementsApplied: string[];
  promptVersion: number;
}

// ─── Paths ───────────────────────────────────────────────────────────────────

const ROOT = path.resolve(__dirname, '..');
const BACKEND = path.join(ROOT, 'backend');
const FRONTEND = path.join(ROOT, 'frontend');
const STUDIO_3D = path.join(ROOT, '3d-studio-web');
const ADMIN = path.join(ROOT, 'admin-panel');
const EVAL_DIR = path.join(ROOT, 'self-improving-eval');
const RESULTS_FILE = path.join(EVAL_DIR, 'eval-results.json');
const PROMPT_FILE = path.join(EVAL_DIR, 'improvement-prompt.md');

// ─── Utility ─────────────────────────────────────────────────────────────────

function fileExists(p: string): boolean {
  return fs.existsSync(p);
}

function dirExists(p: string): boolean {
  return fs.existsSync(p) && fs.statSync(p).isDirectory();
}

function tryExec(cmd: string, cwd?: string): { success: boolean; output: string } {
  try {
    const output = execSync(cmd, {
      cwd: cwd || ROOT,
      timeout: 30000,
      encoding: 'utf-8',
      stdio: ['pipe', 'pipe', 'pipe'],
    });
    return { success: true, output: output.trim() };
  } catch (e: any) {
    return { success: false, output: e.stderr?.toString() || e.message };
  }
}

function check(name: string, passed: boolean, severity: CheckResult['severity'], message: string): CheckResult {
  return { name, passed, severity, message };
}

// ─── Constraint 1: App Working Condition ─────────────────────────────────────

function evalConstraint1_AppCondition(): ConstraintResult {
  const details: Record<string, CheckResult> = {};
  const issues: string[] = [];
  const suggestions: string[] = [];

  // Check backend package.json exists
  details['backend_pkg'] = check(
    'Backend package.json',
    fileExists(path.join(BACKEND, 'package.json')),
    'critical',
    fileExists(path.join(BACKEND, 'package.json')) ? 'Found' : 'MISSING - backend cannot run'
  );

  // Check node_modules
  details['backend_modules'] = check(
    'Backend node_modules',
    dirExists(path.join(BACKEND, 'node_modules')),
    'critical',
    dirExists(path.join(BACKEND, 'node_modules')) ? 'Installed' : 'MISSING - run npm install'
  );

  // Check Prisma schema
  details['prisma_schema'] = check(
    'Prisma schema',
    fileExists(path.join(BACKEND, 'prisma', 'schema.prisma')),
    'critical',
    fileExists(path.join(BACKEND, 'prisma', 'schema.prisma')) ? 'Found' : 'MISSING'
  );

  // Check .env file
  const hasEnv = fileExists(path.join(BACKEND, '.env'));
  details['env_file'] = check(
    'Backend .env',
    hasEnv,
    'critical',
    hasEnv ? 'Found' : 'MISSING - app cannot connect to DB'
  );
  if (!hasEnv) issues.push('.env file missing - database and auth will not work');

  // TypeScript compilation check
  const tscResult = tryExec('npx tsc --noEmit 2>&1 | head -20', BACKEND);
  details['typescript'] = check(
    'TypeScript compilation',
    tscResult.success,
    'critical',
    tscResult.success ? 'No errors' : `Errors found: ${tscResult.output.substring(0, 200)}`
  );
  if (!tscResult.success) {
    issues.push('TypeScript compilation errors detected');
    suggestions.push('Fix TypeScript errors in backend');
  }

  // Check main.ts entry point
  details['main_entry'] = check(
    'Backend main.ts',
    fileExists(path.join(BACKEND, 'src', 'main.ts')),
    'critical',
    fileExists(path.join(BACKEND, 'src', 'main.ts')) ? 'Found' : 'MISSING'
  );

  // Check app.module.ts
  details['app_module'] = check(
    'AppModule',
    fileExists(path.join(BACKEND, 'src', 'app.module.ts')),
    'critical',
    fileExists(path.join(BACKEND, 'src', 'app.module.ts')) ? 'Found' : 'MISSING'
  );

  // Check Prisma client generation
  const prismaClient = dirExists(path.join(BACKEND, 'node_modules', '.prisma'));
  details['prisma_client'] = check(
    'Prisma client generated',
    prismaClient,
    'warning',
    prismaClient ? 'Generated' : 'Not generated - run npx prisma generate'
  );
  if (!prismaClient) suggestions.push('Run npx prisma generate');

  // Score calculation
  const checks = Object.values(details);
  const criticalPassed = checks.filter(c => c.severity === 'critical' && c.passed).length;
  const criticalTotal = checks.filter(c => c.severity === 'critical').length;
  const warningPassed = checks.filter(c => c.severity === 'warning' && c.passed).length;
  const warningTotal = checks.filter(c => c.severity === 'warning').length;

  const score = Math.round(
    ((criticalPassed / Math.max(criticalTotal, 1)) * 8 +
      (warningPassed / Math.max(warningTotal, 1)) * 2)
  );

  return { name: 'App Working Condition', score, maxScore: 10, issues, suggestions, details };
}

// ─── Constraint 2: All Sections Check ────────────────────────────────────────

function evalConstraint2_AllSections(): ConstraintResult {
  const details: Record<string, CheckResult> = {};
  const issues: string[] = [];
  const suggestions: string[] = [];

  // Backend modules check
  const backendModules = [
    'auth', 'modules/users', 'modules/ai-designer', 'modules/furniture-catalog',
    'modules/room-models', 'modules/design-projects', 'modules/properties',
    'modules/payments', 'modules/notifications', 'modules/company-news',
    'modules/unit-updates', 'modules/timeline', 'modules/addon-offers',
    'modules/documents',
  ];

  for (const mod of backendModules) {
    const modPath = path.join(BACKEND, 'src', mod);
    const exists = dirExists(modPath);
    const shortName = mod.replace('modules/', '');
    details[`backend_${shortName}`] = check(
      `Backend: ${shortName}`,
      exists,
      'critical',
      exists ? 'Module exists' : `Module directory missing: ${mod}`
    );
    if (!exists) issues.push(`Backend module missing: ${mod}`);

    // Check for service and controller files
    if (exists) {
      const files = fs.readdirSync(modPath);
      const hasService = files.some(f => f.endsWith('.service.ts'));
      const hasController = files.some(f => f.endsWith('.controller.ts'));
      const hasModule = files.some(f => f.endsWith('.module.ts'));

      if (!hasService) {
        details[`backend_${shortName}_service`] = check(
          `${shortName} service`, false, 'warning', 'Missing service file'
        );
        suggestions.push(`Add service file to ${shortName} module`);
      }
      if (!hasController) {
        details[`backend_${shortName}_controller`] = check(
          `${shortName} controller`, false, 'warning', 'Missing controller file'
        );
      }
      if (!hasModule) {
        details[`backend_${shortName}_module`] = check(
          `${shortName} module`, false, 'warning', 'Missing module file'
        );
      }
    }
  }

  // Frontend pages check
  const frontendPages: Record<string, string> = {
    'splash': 'features/auth/presentation/pages/splash_page.dart',
    'sign_in': 'features/auth/presentation/pages/sign_in_page.dart',
    'sign_up': 'features/auth/presentation/pages/sign_up_page.dart',
    'forgot_password': 'features/auth/presentation/pages/forgot_password_page.dart',
    'home': 'features/home/presentation/pages/home_page.dart',
    'profile': 'features/home/presentation/pages/profile_page.dart',
    'edit_profile': 'features/home/presentation/pages/edit_profile_page.dart',
    'change_password': 'features/home/presentation/pages/change_password_page.dart',
    'documents': 'features/home/presentation/pages/documents_page.dart',
    'notifications': 'features/home/presentation/pages/notifications_page.dart',
    'payments': 'features/home/presentation/pages/payments_page.dart',
    'property_details': 'features/home/presentation/pages/property_details_page.dart',
    'timeline': 'features/home/presentation/pages/view_timeline_page.dart',
    'room_selection': 'features/design_studio/presentation/pages/room_selection_page.dart',
    'design_studio_webview': 'features/design_studio/presentation/pages/design_studio_webview_page.dart',
    'my_saved_designs': 'features/design_studio/presentation/pages/my_saved_designs_page.dart',
    'properties': 'features/properties/presentation/pages/properties_page.dart',
  };

  for (const [name, relPath] of Object.entries(frontendPages)) {
    const fullPath = path.join(FRONTEND, 'lib', relPath);
    const exists = fileExists(fullPath);
    details[`flutter_${name}`] = check(
      `Flutter: ${name}`,
      exists,
      exists ? 'info' : 'warning',
      exists ? 'Page exists' : `Page missing: ${relPath}`
    );
    if (!exists) issues.push(`Flutter page missing: ${name}`);
  }

  // 3D Studio components (in src/ or src/components/)
  const studioComponents = [
    { file: 'App.tsx', dir: 'src' },
    { file: 'StageCanvas.tsx', dir: 'src/components' },
    { file: 'Sidebar.tsx', dir: 'src/components' },
    { file: 'RoomSelector.tsx', dir: 'src/components' },
    { file: 'Model.tsx', dir: 'src/components' },
  ];
  for (const comp of studioComponents) {
    const compPath = path.join(STUDIO_3D, comp.dir, comp.file);
    const exists = fileExists(compPath);
    details[`studio_${comp.file}`] = check(
      `3D Studio: ${comp.file}`,
      exists,
      'warning',
      exists ? 'Component exists' : `Missing: ${comp.dir}/${comp.file}`
    );
    if (!exists) issues.push(`3D Studio component missing: ${comp.dir}/${comp.file}`);
  }

  // Admin panel pages
  const adminPages = ['Login.jsx', 'Dashboard.jsx', 'PropertiesManager.jsx', 'CompanyNewsManager.jsx'];
  for (const page of adminPages) {
    const pagePath = path.join(ADMIN, 'src', 'pages', page);
    const exists = fileExists(pagePath);
    details[`admin_${page}`] = check(
      `Admin: ${page}`,
      exists,
      'info',
      exists ? 'Page exists' : `Missing: ${page}`
    );
  }

  // Score
  const checks = Object.values(details);
  const passed = checks.filter(c => c.passed).length;
  const total = checks.length;
  const score = Math.round((passed / Math.max(total, 1)) * 10);

  return { name: 'All Sections Check', score, maxScore: 10, issues, suggestions, details };
}

// ─── Constraint 3: UI Quality ────────────────────────────────────────────────

function evalConstraint3_UIQuality(): ConstraintResult {
  const details: Record<string, CheckResult> = {};
  const issues: string[] = [];
  const suggestions: string[] = [];

  // Check theme file exists
  const themeFile = path.join(FRONTEND, 'lib', 'core', 'theme');
  details['theme_dir'] = check(
    'Theme directory',
    dirExists(themeFile),
    'warning',
    dirExists(themeFile) ? 'Found' : 'Missing theme directory'
  );

  // Check for dark theme consistency - scan for hardcoded colors
  const libDir = path.join(FRONTEND, 'lib');
  if (dirExists(libDir)) {
    const colorHardcodeCheck = tryExec(
      `grep -r "Color(0x" "${libDir}" --include="*.dart" -l 2>/dev/null | wc -l`
    );
    const hardcodedFiles = parseInt(colorHardcodeCheck.output) || 0;
    details['hardcoded_colors'] = check(
      'Hardcoded colors',
      hardcodedFiles < 5,
      'warning',
      `${hardcodedFiles} files with hardcoded colors (prefer theme constants)`
    );
    if (hardcodedFiles >= 5) {
      suggestions.push(`Refactor ${hardcodedFiles} files to use theme color constants instead of hardcoded values`);
    }
  }

  // Check for overflow-prone patterns in Flutter
  const overflowCheck = tryExec(
    `grep -r "Row(" "${libDir}" --include="*.dart" -l 2>/dev/null | wc -l`
  );
  const rowFiles = parseInt(overflowCheck.output) || 0;
  // This is just an indicator - not all Rows overflow
  details['row_usage'] = check(
    'Row widget usage',
    true,
    'info',
    `${rowFiles} files use Row widgets - verify they handle overflow`
  );

  // Check localization files
  const l10nFile = path.join(FRONTEND, 'lib', 'core', 'localization', 'app_localizations.dart');
  details['localization'] = check(
    'Localization',
    fileExists(l10nFile),
    'warning',
    fileExists(l10nFile) ? 'Found' : 'Missing localization file'
  );

  // Check 3D Studio CSS/styling
  const studioIndex = path.join(STUDIO_3D, 'index.html');
  details['studio_index'] = check(
    '3D Studio index.html',
    fileExists(studioIndex),
    'warning',
    fileExists(studioIndex) ? 'Found' : 'Missing'
  );

  // Check admin panel uses Tailwind
  const adminTailwind = path.join(ADMIN, 'tailwind.config.js');
  const adminTailwindCjs = path.join(ADMIN, 'tailwind.config.cjs');
  const hasTailwind = fileExists(adminTailwind) || fileExists(adminTailwindCjs);
  details['admin_tailwind'] = check(
    'Admin Tailwind config',
    hasTailwind,
    'info',
    hasTailwind ? 'Found' : 'Missing Tailwind config'
  );

  // Check for missing image assets
  const assetsDir = path.join(FRONTEND, 'assets');
  details['assets_dir'] = check(
    'Flutter assets directory',
    dirExists(assetsDir),
    'info',
    dirExists(assetsDir) ? 'Found' : 'Missing assets directory'
  );

  // Score
  const checks = Object.values(details);
  const passed = checks.filter(c => c.passed).length;
  const total = checks.length;
  const score = Math.round((passed / Math.max(total, 1)) * 10);

  return { name: 'UI Quality', score, maxScore: 10, issues, suggestions, details };
}

// ─── Constraint 4: Design Studio Quality ─────────────────────────────────────

function evalConstraint4_DesignStudio(): ConstraintResult {
  const details: Record<string, CheckResult> = {};
  const issues: string[] = [];
  const suggestions: string[] = [];

  // Check 3D studio web directory
  details['studio_dir'] = check(
    '3D Studio directory',
    dirExists(STUDIO_3D),
    'critical',
    dirExists(STUDIO_3D) ? 'Found' : 'MISSING - 3D Studio not set up'
  );

  // Check package.json and dependencies
  const studioPkg = path.join(STUDIO_3D, 'package.json');
  details['studio_pkg'] = check(
    'Studio package.json',
    fileExists(studioPkg),
    'critical',
    fileExists(studioPkg) ? 'Found' : 'MISSING'
  );

  if (fileExists(studioPkg)) {
    const pkg = JSON.parse(fs.readFileSync(studioPkg, 'utf-8'));
    const deps = { ...pkg.dependencies, ...pkg.devDependencies };

    const requiredDeps = ['three', '@react-three/fiber', '@react-three/drei', 'react', 'vite'];
    for (const dep of requiredDeps) {
      details[`studio_dep_${dep}`] = check(
        `Dependency: ${dep}`,
        !!deps[dep],
        dep === 'three' ? 'critical' : 'warning',
        deps[dep] ? `${dep}@${deps[dep]}` : `Missing: ${dep}`
      );
      if (!deps[dep]) issues.push(`3D Studio missing dependency: ${dep}`);
    }
  }

  // Check key source files
  const studioSrcFiles = [
    'src/App.tsx', 'src/components/StageCanvas.tsx', 'src/components/Sidebar.tsx',
    'src/components/RoomSelector.tsx', 'src/components/Model.tsx', 'src/components/ProceduralRoom.tsx',
    'src/services/api.ts', 'src/services/flutter-bridge.ts', 'src/services/types.ts',
  ];

  for (const file of studioSrcFiles) {
    const filePath = path.join(STUDIO_3D, file);
    const exists = fileExists(filePath);
    details[`studio_file_${file.replace(/[\/\.]/g, '_')}`] = check(
      `File: ${file}`,
      exists,
      file.includes('App') || file.includes('Stage') ? 'critical' : 'warning',
      exists ? 'Found' : `Missing: ${file}`
    );
    if (!exists) issues.push(`3D Studio file missing: ${file}`);
  }

  // Check Flutter WebView bridge integration
  const webviewPage = path.join(FRONTEND, 'lib', 'features', 'design_studio', 'presentation', 'pages', 'design_studio_webview_page.dart');
  details['flutter_webview'] = check(
    'Flutter WebView page',
    fileExists(webviewPage),
    'critical',
    fileExists(webviewPage) ? 'Found' : 'MISSING - cannot embed 3D Studio in Flutter'
  );

  // Check built output exists for backend serving
  const builtStudio = path.join(BACKEND, 'public', '3d-studio');
  details['studio_build'] = check(
    'Built 3D Studio in backend/public',
    dirExists(builtStudio),
    'warning',
    dirExists(builtStudio) ? 'Build output present' : 'Not built - run npm run build in 3d-studio-web'
  );

  // Check furniture seed data
  const seedFile = path.join(BACKEND, 'prisma', 'seed-furniture.ts');
  details['furniture_seed'] = check(
    'Furniture seed data',
    fileExists(seedFile),
    'info',
    fileExists(seedFile) ? 'Found' : 'No seed data file'
  );

  // Score
  const checks = Object.values(details);
  const criticalPassed = checks.filter(c => c.severity === 'critical' && c.passed).length;
  const criticalTotal = checks.filter(c => c.severity === 'critical').length;
  const otherPassed = checks.filter(c => c.severity !== 'critical' && c.passed).length;
  const otherTotal = checks.filter(c => c.severity !== 'critical').length;

  const score = Math.round(
    ((criticalPassed / Math.max(criticalTotal, 1)) * 7 +
      (otherPassed / Math.max(otherTotal, 1)) * 3)
  );

  return { name: 'Design Studio Quality', score, maxScore: 10, issues, suggestions, details };
}

// ─── Constraint 5: New Modifications Needed ──────────────────────────────────

function evalConstraint5_Modifications(): ConstraintResult {
  const details: Record<string, CheckResult> = {};
  const issues: string[] = [];
  const suggestions: string[] = [];

  // Check for TODO/FIXME comments in codebase
  const todoCheck = tryExec(
    `grep -r "TODO\\|FIXME\\|HACK\\|XXX" "${path.join(BACKEND, 'src')}" --include="*.ts" -c 2>/dev/null || echo "0"`
  );
  const todoCount = parseInt(todoCheck.output.split('\n').reduce((sum, line) => {
    const parts = line.split(':');
    return sum + (parseInt(parts[parts.length - 1]) || 0);
  }, 0).toString()) || 0;
  details['todos'] = check(
    'TODO/FIXME comments',
    todoCount < 10,
    'info',
    `${todoCount} TODO/FIXME comments found in backend`
  );
  if (todoCount > 10) suggestions.push(`Address ${todoCount} TODO/FIXME comments in backend`);

  // Check for missing error handling (try-catch) in services
  const serviceFiles = tryExec(
    `find "${path.join(BACKEND, 'src')}" -name "*.service.ts" 2>/dev/null`
  );
  if (serviceFiles.success) {
    const files = serviceFiles.output.split('\n').filter(Boolean);
    let missingTryCatch = 0;
    for (const file of files) {
      const content = fs.readFileSync(file, 'utf-8');
      const asyncMethods = (content.match(/async\s+\w+/g) || []).length;
      const tryCatches = (content.match(/try\s*{/g) || []).length;
      if (asyncMethods > tryCatches + 2) missingTryCatch++;
    }
    details['error_handling'] = check(
      'Error handling in services',
      missingTryCatch < 3,
      'warning',
      `${missingTryCatch} services may need better error handling`
    );
    if (missingTryCatch >= 3) suggestions.push('Add try-catch blocks to async service methods');
  }

  // Check for test files
  const backendTests = tryExec(
    `find "${BACKEND}" -name "*.spec.ts" -o -name "*.test.ts" 2>/dev/null | wc -l`
  );
  const testCount = parseInt(backendTests.output) || 0;
  details['tests'] = check(
    'Test files',
    testCount > 5,
    'warning',
    `${testCount} test files found`
  );
  if (testCount < 5) suggestions.push('Add unit and integration tests');

  // Check for validation DTOs
  const dtoCheck = tryExec(
    `find "${path.join(BACKEND, 'src')}" -name "*.dto.ts" 2>/dev/null | wc -l`
  );
  const dtoCount = parseInt(dtoCheck.output) || 0;
  details['dto_validation'] = check(
    'DTO validation files',
    dtoCount > 5,
    'warning',
    `${dtoCount} DTO files found`
  );
  if (dtoCount < 5) suggestions.push('Add more DTO validation for API inputs');

  // Check for rate limiting
  const rateLimitCheck = tryExec(
    `grep -r "Throttle\\|RateLimit\\|rate-limit" "${path.join(BACKEND, 'src')}" --include="*.ts" -l 2>/dev/null | wc -l`
  );
  const hasRateLimit = parseInt(rateLimitCheck.output) > 0;
  details['rate_limiting'] = check(
    'Rate limiting',
    hasRateLimit,
    'warning',
    hasRateLimit ? 'Rate limiting found' : 'No rate limiting detected'
  );
  if (!hasRateLimit) suggestions.push('Add rate limiting to API endpoints');

  // Check for CORS configuration
  const corsCheck = tryExec(
    `grep -r "enableCors\\|cors" "${path.join(BACKEND, 'src', 'main.ts')}" 2>/dev/null`
  );
  details['cors'] = check(
    'CORS configuration',
    corsCheck.success && corsCheck.output.length > 0,
    'warning',
    corsCheck.output.length > 0 ? 'CORS configured' : 'No CORS config found'
  );

  // Check for helmet/security middleware
  const helmetCheck = tryExec(
    `grep -r "helmet\\|security" "${path.join(BACKEND, 'package.json')}" 2>/dev/null`
  );
  details['security_middleware'] = check(
    'Security middleware',
    helmetCheck.output.includes('helmet'),
    'info',
    helmetCheck.output.includes('helmet') ? 'Helmet found' : 'No Helmet.js for security headers'
  );
  if (!helmetCheck.output.includes('helmet')) suggestions.push('Add helmet.js for security headers');

  // Check for .env.example
  details['env_example'] = check(
    '.env.example',
    fileExists(path.join(BACKEND, '.env.example')),
    'info',
    fileExists(path.join(BACKEND, '.env.example')) ? 'Found' : 'Missing .env.example for team onboarding'
  );

  // Score - inverse: fewer suggestions = higher score
  const totalSuggestions = suggestions.length;
  const score = Math.max(0, 10 - totalSuggestions);

  return { name: 'Modifications Needed', score, maxScore: 10, issues, suggestions, details };
}

// ─── Main Eval Runner ────────────────────────────────────────────────────────

function runEval(): EvalRun {
  const startTime = Date.now();
  const runId = `eval_${Date.now()}`;

  console.log('\n╔══════════════════════════════════════════════════════════╗');
  console.log('║   SANZEN APP SELF-IMPROVING EVAL ENGINE v1.0            ║');
  console.log('║   Inspired by karpathy/autoresearch                     ║');
  console.log('╚══════════════════════════════════════════════════════════╝\n');

  // Run all 5 constraints
  const constraints: ConstraintResult[] = [
    evalConstraint1_AppCondition(),
    evalConstraint2_AllSections(),
    evalConstraint3_UIQuality(),
    evalConstraint4_DesignStudio(),
    evalConstraint5_Modifications(),
  ];

  const overallScore = constraints.reduce((sum, c) => sum + c.score, 0);
  const maxPossibleScore = constraints.reduce((sum, c) => sum + c.maxScore, 0);
  const percentage = ((overallScore / maxPossibleScore) * 100).toFixed(1);

  // Print results
  console.log('┌──────────────────────────────────────────┬───────┐');
  console.log('│ Constraint                               │ Score │');
  console.log('├──────────────────────────────────────────┼───────┤');
  for (const c of constraints) {
    const name = c.name.padEnd(40);
    const score = `${c.score}/${c.maxScore}`.padStart(5);
    const bar = '█'.repeat(c.score) + '░'.repeat(c.maxScore - c.score);
    console.log(`│ ${name} │ ${score} │ ${bar}`);
  }
  console.log('├──────────────────────────────────────────┼───────┤');
  console.log(`│ ${'OVERALL'.padEnd(40)} │ ${`${overallScore}/${maxPossibleScore}`.padStart(5)} │ ${percentage}%`);
  console.log('└──────────────────────────────────────────┴───────┘');

  // Print issues
  const allIssues = constraints.flatMap(c => c.issues);
  if (allIssues.length > 0) {
    console.log('\n⚠ Issues Found:');
    allIssues.forEach((issue, i) => console.log(`  ${i + 1}. ${issue}`));
  }

  // Print suggestions
  const allSuggestions = constraints.flatMap(c => c.suggestions);
  if (allSuggestions.length > 0) {
    console.log('\n💡 Improvement Suggestions:');
    allSuggestions.forEach((s, i) => console.log(`  ${i + 1}. ${s}`));
  }

  const duration_ms = Date.now() - startTime;

  // Get current prompt version
  let promptVersion = 1;
  if (fileExists(RESULTS_FILE)) {
    try {
      const results = JSON.parse(fs.readFileSync(RESULTS_FILE, 'utf-8'));
      if (results.runs && results.runs.length > 0) {
        promptVersion = results.runs[results.runs.length - 1].promptVersion + 1;
      }
    } catch { }
  }

  const run: EvalRun = {
    timestamp: new Date().toISOString(),
    runId,
    duration_ms,
    overallScore,
    maxPossibleScore,
    percentage,
    constraints,
    improvementsSuggested: allSuggestions,
    improvementsApplied: [],
    promptVersion,
  };

  // Save results
  try {
    let results = { version: '1.0.0', created: '2026-03-15', description: 'Sanzen Eval Results', runs: [] as EvalRun[] };
    if (fileExists(RESULTS_FILE)) {
      results = JSON.parse(fs.readFileSync(RESULTS_FILE, 'utf-8'));
    }
    // Keep last 100 runs
    results.runs = [...results.runs.slice(-99), run];
    fs.writeFileSync(RESULTS_FILE, JSON.stringify(results, null, 2));
    console.log(`\n✓ Results saved to ${RESULTS_FILE}`);
  } catch (e) {
    console.error('Failed to save results:', e);
  }

  console.log(`\nEval completed in ${duration_ms}ms | Score: ${percentage}% | Run: ${runId}\n`);

  return run;
}

// ─── Self-Improvement: Generate Updated Prompt ───────────────────────────────

function generateImprovedPrompt(run: EvalRun): string {
  const weakest = [...run.constraints].sort((a, b) => a.score - b.score);
  const weakestConstraint = weakest[0];

  let prompt = `# Self-Improving Eval Prompt v${run.promptVersion}\n`;
  prompt += `# Auto-generated at ${run.timestamp}\n`;
  prompt += `# Previous score: ${run.percentage}%\n\n`;

  prompt += `## Priority Focus\n`;
  prompt += `Weakest area: **${weakestConstraint.name}** (${weakestConstraint.score}/${weakestConstraint.maxScore})\n\n`;

  if (weakestConstraint.issues.length > 0) {
    prompt += `### Critical Issues to Fix\n`;
    weakestConstraint.issues.forEach(i => {
      prompt += `- [ ] ${i}\n`;
    });
    prompt += '\n';
  }

  prompt += `## All Suggestions (by priority)\n`;
  run.improvementsSuggested.forEach((s, i) => {
    prompt += `${i + 1}. ${s}\n`;
  });

  prompt += `\n## Scoring History\n`;
  prompt += `Current: ${run.percentage}%\n`;
  prompt += `Target: 100%\n`;
  prompt += `Gap: ${(100 - parseFloat(run.percentage)).toFixed(1)}%\n`;

  prompt += `\n## Next Eval Constraints to Improve\n`;
  weakest.slice(0, 3).forEach(c => {
    prompt += `- ${c.name}: ${c.score}/${c.maxScore} → target ${c.maxScore}/${c.maxScore}\n`;
  });

  return prompt;
}

// ─── Entry Point ─────────────────────────────────────────────────────────────

const run = runEval();
const improvedPrompt = generateImprovedPrompt(run);
fs.writeFileSync(PROMPT_FILE, improvedPrompt);
console.log(`Updated improvement prompt → ${PROMPT_FILE}`);
