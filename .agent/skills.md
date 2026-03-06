# Project Skills & Guidelines

This file contains project-specific instructions and context for the AI assistant to follow while working on this project.

## 1. Project Context
*   **Project Name:** Sanzen-app (Sanzen Smart Compliance Agent & Learning Hub)
*   **Description:** A compliance and learning management platform (ERP) that includes web/mobile applications and a robust backend. 

## 2. Tech Stack Setup

### Frontend (Mobile ERP App)
*   **Framework:** Flutter (Dart)
*   **State Management:** flutter_bloc, cubit
*   **Routing:** go_router
*   **Network/API:** dio, http
*   **Local Storage:** hive, flutter_secure_storage
*   **Code Generation:** freezed, json_serializable, injectable

### Backend (API Server)
*   **Framework:** Node.js with NestJS (TypeScript)
*   **Database ORM:** Prisma
*   **Database:** PostgreSQL
*   **Caching & Queues:** Redis (ioredis), Bull
*   **Authentication:** Passport (JWT, Local), bcryptjs
*   **Real-time:** Socket.IO
*   **Emailing:** @nestjs-modules/mailer (Nodemailer)

### Design / UI
*   Contains custom SVG assets and color definitions in the `UI` folder.

## 3. Core Directives for the AI Assistant
*   **Continuous Change Tracking (CRITICAL):** The AI assistant MUST actively monitor, track, and document all changes made to the application (by the user or the assistant). 
*   **Proactive Updates:** Whenever a new feature is added, a bug is fixed, or the architectural flow changes, the assistant should be aware of it and apply updates where necessary. Keep track of Flutter UI/Bloc changes as well as NestJS backend logic.
*   **Summarization & Logging:** Be prepared to provide the user with a recap of what was changed during the session, or systematically document changes in relevant project files if requested.

## 4. Custom Workflows
*   (Add step-by-step instructions for tasks like deploying the app, running tests, or adding a new feature here as they are developed)
