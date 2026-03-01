# Sync Plan (Optional)

## Behavior
- Sync is disabled by default
- User enables sync in Settings
- Auth providers: Apple or Google only
- After successful auth, sync runs in background

## Conflict strategy
- Last-write-wins on a per-entity basis
- Store updatedAt for every entity

## MVP constraints
- Offline-first with local DB as source of truth
- Sync layer can be added after local MVP
