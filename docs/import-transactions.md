# Transaction Import CSV v2

## Format
- File type: `CSV`
- Encoding: `UTF-8`
- Delimiter: `;`
- Data row limit: `500`

## Header row
- `дата;тип операции;операция;сумма;категория;способ оплаты;теги`

## Columns
- `дата`: `YYYY-MM-DD HH:mm`, also accepts `05.02.2026 0:53:29`
- `тип операции`: `Расход` or `Доход`
- `операция`: transaction text like `Билеты в театр`
- `сумма`: positive number like `12.50`
- `категория`: category name
- `способ оплаты`: payment method name
- `теги`: comma-separated tag names, may be empty

## Import behavior
- Unknown categories are created after user confirmation.
- Unknown payment methods are created after user confirmation.
- Unknown tags are created after user confirmation.
- All imported records receive a generated tag in the format `import_YYYYMMDD_HHMMSS`.

## Example
```csv
дата;тип операции;операция;сумма;категория;способ оплаты;теги
2026-03-28 14:25;Расход;Билеты в театр;12.50;Развлечения;Основная карта;Театр,Вечер
05.02.2026 0:53:29;Расход;Такси домой;48.90;Транспорт;Наличные;
```
