# NestJS Backend Structure

```text
apps/backend/src/
  main.ts
  app.module.ts
  common/
    auth/
    database/
    errors/
    guards/
    pipes/
  modules/
    auth/
      auth.controller.ts
      auth.service.ts
      auth.repository.ts
      dto/
    stores/
    customers/
    products/
    sales/
    purchases/
    suppliers/
    expenses/
    cash/
    reports/
    sync/
    audit/
```

## Rules

- Controllers handle HTTP concerns only.
- DTOs validate input.
- Guards enforce authentication and store membership.
- Services contain business rules and transaction orchestration.
- Repositories contain PostgreSQL access.
- Financial workflows use one database transaction.
- Never trust client-provided `store_id`, owner identity, role, or financial totals without server-side validation.
