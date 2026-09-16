# Flutter Mobile Structure

```text
apps/mobile/lib/
  app/
    app.dart
    theme/
    router/
  core/
    database/
    network/
    sync/
    errors/
    utils/
  features/
    auth/
      data/
      domain/
      presentation/
    store/
      data/
      domain/
      presentation/
    customers/
      data/
      domain/
      presentation/
    dashboard/
      presentation/
  shared/
    widgets/
    models/
```

## Rules

- Presentation never talks directly to SQLite or HTTP.
- Use cases own business workflows.
- Repositories expose domain-oriented operations.
- SQLite is the local source of truth for the active device.
- A local mutation and its outbox record are committed in the same database transaction.
- Network sync is an adapter behind the same repository boundary.
- UI remains usable when the network is unavailable.
