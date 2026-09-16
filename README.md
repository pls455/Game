# دَكانة — Dakkana

> كل حساب دَكانتك بإيدك

تطبيق عربي RTL لإدارة الدكاكين والمتاجر الصغيرة، مصمم ليعمل **Offline-first** مع مزامنة آمنة متعددة الأجهزة.

## Stack
- Mobile: Flutter + SQLite
- Backend: NestJS + TypeScript
- Database: PostgreSQL
- API: REST `/api/v1`
- Auth: JWT + Refresh Tokens

## Monorepo
```text
apps/mobile       Flutter application
apps/backend      NestJS API
packages/shared   Shared contracts/constants
 database/        PostgreSQL schema/migrations
 docs/             PRD, architecture, API and sync design
```

## MVP
Authentication, store setup, customers, customer accounts/payments, products, inventory, sales, purchases, suppliers, expenses, cashbox, reports, offline-first sync, backup and PDF statements.

> المشروع بدأ من الصفر. تم استبدال محتوى المشروع القديم الخاص باللعبة بهذا الأساس الجديد.
