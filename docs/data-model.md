# Data Model (Draft)

## Transaction
- id (string)
- type (income | expense)
- amount (int, minor units)
- categoryId (string)
- date (ISO)
- note (string, optional)
- currencyCode (string, user-selected)
- createdAt (ISO)
- updatedAt (ISO)

## Category
- id (string)
- name (string)
- icon (string)
- color (string)
- isSystem (bool)
- order (int)
- createdAt (ISO)
- updatedAt (ISO)

## Budget
- id (string)
- period (week | month)
- categoryId (string)
- limit (int, minor units)
- createdAt (ISO)
- updatedAt (ISO)

## Settings
- currencyCode (string)
- weekStart (1-7)
- syncEnabled (bool)
- authProvider (apple | google | null)
