# Smart Wallet

Cross-platform budget app (iOS + Android) inspired by Monefy UX, with a soft dark theme and a faster, cleaner flow.

## Goals
- Fast income/expense entry
- Clear balance and period overview
- Editable categories
- Weekly/monthly budgets
- Reports by time and categories
- Optional sync (Apple/Google)

## Current status
Flutter scaffold created in `app/`. Initial dark UI skeleton is in progress.

## Tech stack
- Flutter (UI)
- Local DB: SQLite (Drift or Isar)
- Sync: Firebase Auth (Apple/Google) + Firestore (optional, post-MVP)

## Docs
- Product requirements: `docs/requirements.md`
- UX structure: `docs/ux.md`
- Design system (dark): `docs/design-system.md`
- Data model: `docs/data-model.md`
- Sync plan: `docs/sync.md`
