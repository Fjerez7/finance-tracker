---
id: research-00001-evaluacion-de-arquitectura-y-stack-tecnologico
type: research
code: "00001"
slug: evaluacion-de-arquitectura-y-stack-tecnologico
title: Architecture and Technology Stack Evaluation for Personal Finance App
description: Evaluation of frontend, backend, database, and offline synchronization options for a cross-platform personal finance application.
status: investigating
created: 2026-08-30
updated: 2026-08-30
authors: []
tags:
  - architecture
  - flutter
  - provider
  - spring-boot
  - postgresql
  - sqlite
  - offline-first
  - finance-tracker
related: []
supersedes: []
superseded_by: null
aliases:
  - "RESEARCH 00001: Architecture and Technology Stack Evaluation for Personal Finance App"
---

# RESEARCH 00001: Architecture and Technology Stack Evaluation for Personal Finance App

## 1. Context & Motivation

Building a robust, responsive, and secure personal finance application requires a clear evaluation of frontend, backend, data persistence, and synchronization architectures. Personal finance users expect fast local interactions, seamless multi-platform accessibility (mobile, desktop, and web), uninterrupted offline transaction logging, and reliable server-side persistence for analytics, multi-device backup, and secure financial data management.

This research document evaluates the target technology stack:
1. **Frontend:** Flutter utilizing standard `Provider` state management.
2. **Backend:** Spring Boot (Java) providing enterprise-grade RESTful APIs and sync services.
3. **Storage & Data Sync:** Local SQLite persistence paired with server-side PostgreSQL.
4. **Offline & Multi-platform Strategy:** Local-first caching, event-driven queueing, and eventual consistency sync.

## 2. Research Questions

- [x] **Question 1 (Frontend):** How suitable is Flutter with standard `Provider` state management for cross-platform personal finance UI workflows, forms, and chart visualizations?
- [x] **Question 2 (Backend):** Does Spring Boot provide the required scalability, security features, and ecosystem maturity for personal finance APIs and sync workloads?
- [x] **Question 3 (Database & Offline):** How should PostgreSQL (backend) and SQLite (client) interact to enable seamless offline-first operation and data consistency?
- [x] **Question 4 (Cross-Platform & Synchronization):** What synchronization and conflict resolution strategies best accommodate distributed financial ledger updates?

## 3. Options & Prototypes (Spikes)

### 3.1. Frontend Architecture: Flutter with Provider

- **Overview:**
  Flutter offers a single codebase targeting Android, iOS, Web, and Desktop. Using standard `Provider` (and `ChangeNotifier`) provides an idiomatic, lightweight, and maintainable state management layer without the boilerplate overhead of heavier state architectures, making it ideal for standard personal finance CRUD operations, budgets, and balance calculations.

- **Prototype / Spike Findings:**
  - `ChangeNotifierProvider` and `Consumer` cleanly decouple UI widgets from financial calculation domain models.
  - Multi-platform compilation delivers high-performance 60/120fps UI rendering across Android and iOS, with solid desktop and web parity.
  - Local database binding (via `sqflite` or `drift` over SQLite) integrates directly with Provider view models.

- **Pros:**
  - Single Dart codebase for iOS, Android, Desktop, and Web.
  - Standard `Provider` has a minimal learning curve, low boilerplate, and native Flutter community support.
  - Excellent ecosystem for financial charts (e.g., `fl_chart`), secure storage (`flutter_secure_storage`), and biometrics (`local_auth`).
  - Rich UI component library adhering to Material Design 3.

- **Cons:**
  - Web bundle sizes can be larger than pure HTML/JS solutions.
  - Complex nested state trees in larger apps require disciplined ViewModel separation.

---

### 3.2. Backend Architecture: Spring Boot

- **Overview:**
  Spring Boot (Java 21 LTS / 17+) is chosen as the foundational backend framework. It provides production-ready security (Spring Security with OAuth2/JWT), robust data access (Spring Data JPA / Hibernate), transactional integrity (essential for financial records), and battle-tested validation layers.

- **Prototype / Spike Findings:**
  - REST controllers paired with Spring Data JPA provide rapid development for ledger entries, categories, budgets, and sync endpoints.
  - Transaction management (`@Transactional` with ACID guarantees) guarantees no corrupted financial state during batch syncs or multi-account transfers.
  - Seamless integration with Flyway / Liquibase for versioned database migrations.

- **Pros:**
  - Enterprise-grade maturity, type safety, and ecosystem stability.
  - Comprehensive security framework supporting biometric tokens, JWT rotation, and fine-grained authorization.
  - Built-in connection pooling (HikariCP), observability (Micrometer / Actuator), and Docker containerization.
  - Exceptional concurrency performance on modern JDKs (Virtual Threads / Project Loom).

- **Cons:**
  - Higher memory footprint and cold start time compared to minimal Go or Rust runtimes.
  - Framework conventions require structured architectural layering (Controller, Service, Repository, DTO).

---

### 3.3. Database Architecture: Client-Side SQLite vs Server-Side PostgreSQL

- **Overview:**
  Personal finance applications cannot rely exclusively on a cloud database due to network intermittency and the need for immediate UI feedback. A hybrid model is investigated:
  - **Client Persistence:** SQLite (via Flutter `sqflite` or `drift`) for instant offline read/write access.
  - **Server Persistence:** PostgreSQL for relational integrity, JSONB support (flexible transaction metadata), and robust reporting/aggregations.

- **Sync & Conflict Resolution Strategy:**
  - **Client Local Write:** Every transaction, expense, or budget modification is written immediately to the local SQLite database with a `sync_status = 'PENDING'` and a monotonic `updated_at` UTC timestamp.
  - **Sync Queue:** An offline-aware background sync service batches pending changes and posts them to Spring Boot's `/api/v1/sync` endpoint when connectivity is available.
  - **Conflict Handling:** Last-Write-Wins (LWW) with client-generated UUID primary keys prevents ID collisions across devices. For budget updates, delta-based merges ensure concurrent modifications across devices do not overwrite independent transactions.

- **Pros:**
  - True offline-first capability: users can log expenses anywhere, anytime.
  - Sub-millisecond local queries for charts and transaction histories.
  - PostgreSQL provides bulletproof durability, index optimization, and advanced analytics on the backend.

- **Cons:**
  - Requires maintaining matching schema definitions across Dart (client) and Java/PostgreSQL (server).
  - Sync edge cases (e.g., clock drift, deleted records / soft deletes) must be explicitly managed with tombstones.

---

## 4. Evaluation Matrix

| Criteria | Flutter (Provider) + SQLite (Client) | Spring Boot + PostgreSQL (Server) | Full-Stack Assessment / Synergy |
| :--- | :--- | :--- | :--- |
| **Performance** | High (native 60/120fps, sub-ms local reads) | High (HikariCP, indexing, low latency REST) | Excellent end-to-end responsiveness |
| **Developer Experience** | High (Hot Reload, straightforward Provider API) | High (Spring Initializr, JPA, robust tooling) | High synergy with typed models |
| **Offline Capabilities** | Excellent (full local SQLite storage) | N/A (serves as synchronization target) | Best-in-class local-first architecture |
| **Cross-Platform Support** | iOS, Android, Web, macOS, Windows, Linux | Cloud/Container agnostic (Linux/Docker) | Complete multi-platform coverage |
| **Ecosystem & Maturity** | Extensive (rich package catalog, active community) | Industry benchmark (decades of enterprise usage) | Highly reliable and future-proof |
| **Maintenance Cost** | Low (single codebase, minimal boilerplate) | Moderate (standardized Spring conventions) | Low long-term technical debt |

---

## 5. Recommendation & Next Steps

### 5.1. Recommended Architectural Direction

1. **Client Tier:**
   - Framework: **Flutter (Dart)**
   - State Management: **Provider** (`ChangeNotifierProvider`, `ChangeNotifier`) for UI-to-state separation.
   - Local Persistence: **SQLite** (via `sqflite` or `drift`) implementing a local-first repository pattern.
   - Secure Storage: `flutter_secure_storage` for storing JWT access and refresh tokens.

2. **Backend Tier:**
   - Framework: **Spring Boot 3.x (Java 21)**
   - API Pattern: RESTful JSON with OpenAPI / Swagger documentation.
   - Security: Spring Security with Stateless JWT Authentication and refresh token rotation.
   - Persistence: Spring Data JPA on **PostgreSQL 16+**.
   - Database Migrations: **Flyway** for version-controlled relational schema migrations.

3. **Data Synchronization Protocol:**
   - UUIDv4 identifiers generated on the client to eliminate primary key negotiation during offline creation.
   - Soft-delete strategy using `deleted_at` timestamps (tombstones) to propagate deletions accurately.
   - Incremental pull/push sync mechanism based on high-water mark timestamps (`since_timestamp`).

### 5.2. Follow-up RFC

- **Follow-up RFC:** `rfc-00001-personal-finance-core-architecture` (to establish the domain schema, sync protocol specifications, and baseline API contracts).
