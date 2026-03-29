# Transaction Import CSV v1

## Format
- File type: `CSV`
- Encoding: `UTF-8`
- Header row: required
- Data row limit: `200`
- Supported delimiters: `;` and `,`

## Required columns
- `date`
- `type`
- `amount`
- `category`

## Optional columns
- `payment_method`
- `note`

## Supported aliases
- `date`: `Дата`
- `type`: `Тип`
- `amount`: `Сумма`
- `category`: `Категория`
- `payment_method`: `Метод`, `Способ оплаты`
- `note`: `Описание`, `Комментарий`

## Date formats
- `2026-03-28`
- `2026-03-28 14:30`
- `28.03.2026`
- `28.03.2026 14:30`

## Amount formats
- `12.50`
- `12,50`

## Notes
- Empty `payment_method` means the default payment method will be used.
- Unknown payment methods block import until fixed.
- Unknown categories are created automatically.
- All imported records receive a generated tag in the format `import_YYYYMMDD_HHMMSS`.

## Example
```csv
date;type;amount;category;payment_method;note
2026-03-28 14:25;expense;12.50;Еда;Revolut;Обед
2026-03-29;expense;48,90;Дом;;Хозяйственные товары
```
