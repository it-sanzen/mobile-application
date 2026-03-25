# Sanzen App Self-Improving Eval System
# Inspired by karpathy/autoresearch
# This file is the human-editable configuration (like program.md in autoresearch)

## Philosophy
Like autoresearch constrains experiments to a fixed 5-minute training budget,
this system constrains evaluations to a 2-minute cycle. Each cycle:
1. Evaluates all app functions against the 5 constraints
2. Scores each area (0-10)
3. Generates improvement suggestions
4. Applies fixes when confidence is high
5. Logs everything for human review

## The 5 Eval Constraints

### Constraint 1: App Working Condition
- Backend server starts without errors
- All NestJS modules load correctly
- Database connection is healthy
- No TypeScript compilation errors
- All API endpoints respond (auth, properties, payments, notifications, etc.)

### Constraint 2: All Sections Check (Every Page, Every Backend)
- **Backend Modules:** auth, users, ai-designer, furniture-catalog, room-models,
  design-projects, properties, payments, notifications, company-news,
  unit-updates, timeline, addon-offers, documents, integrations
- **Frontend Pages:** splash, signin, signup, forgot-password, home, profile,
  edit-profile, change-password, documents, notifications, payments,
  addon-offers, property-details, timeline, room-selection, design-studio-webview,
  my-saved-designs, creative-studio, about, help, privacy, language, notification-prefs
- **Admin Panel:** login, dashboard, documents, company-news, unit-updates,
  timeline, properties-manager
- **3D Studio:** app, stage-canvas, sidebar, room-selector, model-renderer

### Constraint 3: UI Quality
- Dark theme consistency across all pages
- Responsive layouts work on different screen sizes
- No overflow/rendering errors in Flutter widgets
- 3D Studio components render correctly
- Admin panel styling is consistent

### Constraint 4: Design Studio Quality
- 3D Studio loads with furniture catalog
- Drag-and-drop furniture placement works
- Transform controls (move, rotate, scale) work
- Save/load design projects work
- Flutter WebView bridge communication works
- Room templates render correctly
- Camera views (dollhouse, top, front, back, left, right) work

### Constraint 5: New Modifications Needed
- Missing error handling in API calls
- Missing loading states in UI
- Missing validation in forms
- Missing tests (unit, integration)
- Performance optimizations needed
- Security improvements needed
- Code quality improvements

## Scoring Rubric
- 10: Perfect - no issues found
- 8-9: Good - minor cosmetic issues only
- 6-7: Acceptable - some non-critical issues
- 4-5: Needs work - functional issues present
- 2-3: Poor - major issues blocking functionality
- 0-1: Broken - section is non-functional

## Self-Improvement Rules
1. Only modify code when confidence > 80%
2. Always log what was changed and why
3. Never modify database schema without human approval
4. Never modify auth/security code without human approval
5. Focus on: error handling, UI polish, missing validations, code quality
6. Keep diffs small and reviewable (like autoresearch's single-file constraint)
