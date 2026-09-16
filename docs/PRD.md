# Product Requirements Document

## Product
دَكانة — Dakkana
Tagline: كل حساب دَكانتك بإيدك

## Target
Small shop owners and staff in Gaza and similar low-connectivity environments. Arabic RTL is the default.

## Core jobs
- Record a sale in seconds.
- Record credit sales and customer payments.
- Know what is owed by customers and owed to suppliers.
- Track stock from inventory movements, not editable magic balances.
- Track purchases, expenses and cashbox.
- Continue working without internet.
- Sync safely when connectivity returns.

## UX principles
- Mobile-first, simple language, large touch targets.
- Quick actions on home: + بيعة, + تسديد, + مصروف, + شراء.
- Numeric keyboard for money and quantities.
- Recent/favorite products and fast search.
- Clear states: عليه / إله, not accounting jargon.
- Never block a valid offline transaction because the network is unavailable.

## MVP boundaries
Included: auth, store, customers/accounts, payments, products/inventory, sales, purchases/suppliers, expenses, cashbox, basic reports, offline sync, backup, PDF statement.
Excluded initially: AI, payroll, advanced accounting, e-commerce, loyalty, multi-country tax engine, complex ERP.

## Acceptance principles
- Duplicate network delivery cannot duplicate a financial event.
- Every financial event is attributable to store, user, device and client transaction id.
- Posted financial records are not edited in place.
- Local data remains usable during outages.
- Sync failures are retryable and visible without losing the local record.
