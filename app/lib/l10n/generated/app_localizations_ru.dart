// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Budgetto';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settingsPremiumTitle => 'Premium';

  @override
  String get settingsPremiumSubtitle => 'Подписка и доступ к приложению';

  @override
  String get settingsBudgetsTitle => 'Бюджеты';

  @override
  String get settingsBudgetsSubtitle => 'Лимиты и цели по категориям';

  @override
  String get settingsPaymentMethodsTitle => 'Способы оплаты';

  @override
  String get settingsPaymentMethodsSubtitle => 'Карты и счета для операций';

  @override
  String get settingsCategoriesTitle => 'Категории';

  @override
  String get settingsCategoriesSubtitle => 'Редактировать список категорий';

  @override
  String get settingsTagsTitle => 'Теги';

  @override
  String get settingsTagsSubtitle => 'Добавить и переименовать теги';

  @override
  String get settingsCurrencyTitle => 'Валюта';

  @override
  String get settingsCurrencySubtitle => 'Валюта отображения суммы';

  @override
  String get settingsCurrencyNotSelected => 'Не выбрана';

  @override
  String get settingsThemeTitle => 'Тема';

  @override
  String get settingsThemeSubtitle => 'Темная или светлая тема';

  @override
  String get settingsThemeDark => 'Темная';

  @override
  String get settingsThemeLight => 'Светлая';

  @override
  String get settingsLanguageTitle => 'Язык';

  @override
  String get settingsLanguageSubtitle => 'Язык интерфейса приложения';

  @override
  String get settingsSyncTitle => 'Синхронизация';

  @override
  String get settingsSyncSubtitle => 'Вход и перенос прогресса';

  @override
  String get settingsDataTitle => 'Данные';

  @override
  String get settingsDataSubtitle => 'Импорт затрат из CSV';

  @override
  String get commonCancel => 'Отмена';

  @override
  String get commonDelete => 'Удалить';

  @override
  String get commonReset => 'Сбросить';

  @override
  String get commonApply => 'Применить';

  @override
  String get commonSelect => 'Выбрать';

  @override
  String get commonEdit => 'Редактировать';

  @override
  String get commonSave => 'Сохранить';

  @override
  String get commonCreate => 'Создать';

  @override
  String get commonAdd => 'Добавить';

  @override
  String get commonNotAvailable => '—';

  @override
  String get themeSettingsSectionTitle => 'Оформление';

  @override
  String get themeSettingsDescription =>
      'Тема влияет на фон, карточки и оттенки интерфейса.';

  @override
  String get languageSettingsDescription =>
      'Выбери фиксированный язык приложения или используй системный язык.';

  @override
  String get languageSystem => 'Системный';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageRussian => 'Русский';

  @override
  String get languageSpanish => 'Español';

  @override
  String get accessStatusPremiumActive => 'Premium активен';

  @override
  String get accessStatusLocked => 'Доступ закрыт';

  @override
  String accessStatusDaysRemaining(int count) {
    return 'Осталось $count д.';
  }

  @override
  String get appShellPlannedPayments => 'Регулярные платежи';

  @override
  String get appShellReminders => 'Напоминания';

  @override
  String get appShellShoppingLists => 'Списки покупок';

  @override
  String get appShellImportCsv => 'Импорт CSV';

  @override
  String get appShellExportCsv => 'Экспорт CSV';

  @override
  String get overviewTitle => 'Обзор';

  @override
  String get overviewRangePickHelp => 'Выберите период';

  @override
  String get overviewRangeSave => 'Готово';

  @override
  String get overviewRangeCancel => 'Отмена';

  @override
  String get overviewExpenses => 'Расходы';

  @override
  String get overviewIncome => 'Доходы';

  @override
  String get overviewRangeDay => 'День';

  @override
  String get overviewRangeWeek => 'Неделя';

  @override
  String get overviewRangeMonth => 'Месяц';

  @override
  String get overviewRangeYear => 'Год';

  @override
  String get overviewRangePeriod => 'Период';

  @override
  String get overviewTotal => 'Итого';

  @override
  String get overviewNoTransactions => 'Нет операций за выбранный период.';

  @override
  String get homeBalanceTitle => 'Баланс';

  @override
  String get homeCategoriesTitle => 'Категории';

  @override
  String get searchTitle => 'Поиск';

  @override
  String get searchHint => 'Поиск по описанию, категории или тегу';

  @override
  String get searchAll => 'Все';

  @override
  String get searchFromPlaceholder => 'От: дата и время';

  @override
  String searchFromValue(Object value) {
    return 'От: $value';
  }

  @override
  String get searchToPlaceholder => 'До: дата и время';

  @override
  String searchToValue(Object value) {
    return 'До: $value';
  }

  @override
  String get searchTagsEmpty => 'Теги пока не добавлены';

  @override
  String get searchNoResults => 'Ничего не найдено';

  @override
  String get reportsTitle => 'Отчеты';

  @override
  String get reportsByCategoryTitle => 'По категориям';

  @override
  String get reportsByTimeTitle => 'По времени';

  @override
  String get reportsCategoryFood => 'Еда';

  @override
  String get reportsCategoryHousing => 'Жилье';

  @override
  String get reportsCategoryTransport => 'Транспорт';

  @override
  String get listsEmpty => 'Пока нет списков';

  @override
  String get listsDeleteTitle => 'Удалить список?';

  @override
  String get listsDeleteMessage => 'Уверен, что хочешь удалить этот список?';

  @override
  String get listsSummaryEmpty => 'Пока нет пунктов';

  @override
  String listsSummaryProgress(int done, int total) {
    return 'Отмечено $done из $total';
  }

  @override
  String get listsDefaultTitle => 'Список';

  @override
  String get listsAddTitleOrItemError => 'Добавь название или пункт списка';

  @override
  String get listsNewTitle => 'Новый список';

  @override
  String get listsEditorTitle => 'Список';

  @override
  String get listsNameHint => 'Название списка';

  @override
  String get listsItemHint => 'Пункт списка';

  @override
  String get listsAddItem => 'Добавить пункт';

  @override
  String get subscriptionPlanYearlyTitle => 'Годовой';

  @override
  String get subscriptionPlanYearlyFallback => '\$15 / год';

  @override
  String get subscriptionPlanBestBadge => 'Лучшая цена';

  @override
  String get subscriptionPlanQuarterlyTitle => '3 месяца';

  @override
  String get subscriptionPlanQuarterlyFallback => '\$5 / 3 месяца';

  @override
  String get subscriptionPlanMonthlyTitle => 'Месячный';

  @override
  String get subscriptionPlanMonthlyFallback => '\$2 / месяц';

  @override
  String get subscriptionDateNotSet => 'не задана';

  @override
  String get subscriptionHeadlineActive => 'Premium активен';

  @override
  String get subscriptionHeadlineTrial => 'Первые 30 дней дают полный доступ';

  @override
  String get subscriptionHeadlineExpired => 'Пробный период закончился';

  @override
  String get subscriptionSubheadActive =>
      'Premium сохраняет полный доступ к Budgetto после пробного периода.';

  @override
  String subscriptionSubheadTrial(int count) {
    return 'Осталось $count д. полного доступа до того, как потребуется Premium.';
  }

  @override
  String get subscriptionSubheadExpired =>
      'Чтобы продолжить пользоваться Budgetto после пробного периода, выбери подписку.';

  @override
  String get subscriptionUnlimited => 'Без ограничений';

  @override
  String subscriptionUntil(Object date) {
    return 'До $date';
  }

  @override
  String get subscriptionChipFullAccess => 'Полный доступ';

  @override
  String get subscriptionChipPremiumAfterTrial => 'Premium после trial';

  @override
  String get subscriptionChipSubscriptionRequired => 'Нужна подписка';

  @override
  String get subscriptionHowItWorksTitle => 'Как работает доступ';

  @override
  String get subscriptionHowItWorksTrial =>
      'Первые 30 дней дают полный доступ ко всему приложению.';

  @override
  String get subscriptionHowItWorksNoSplit =>
      'Во время trial у приложения нет разделения на базовые и Premium-функции.';

  @override
  String get subscriptionHowItWorksAfterTrial =>
      'После окончания trial нужна активная подписка Premium, чтобы продолжить пользоваться Budgetto.';

  @override
  String get subscriptionHowItWorksBilling =>
      'В любой момент можно выбрать месячный, квартальный или годовой тариф.';

  @override
  String get subscriptionStoreUnavailable =>
      'Магазин платежей сейчас недоступен. Попробуй позже.';

  @override
  String get subscriptionRestorePurchases => 'Восстановить покупки';

  @override
  String get subscriptionRenewalNote =>
      'Подписка продлевается автоматически, пока пользователь не отменит ее в App Store или Google Play.';

  @override
  String get subscriptionPlanActive => 'Активен';

  @override
  String get transactionsBudgetPickerTitle => 'Выбери бюджет';

  @override
  String get transactionsPersonalBudgetTitle => 'Личный бюджет';

  @override
  String get transactionsPersonalBudgetSubtitle => 'Только для тебя';

  @override
  String get transactionsDeleteTitle => 'Удалить операцию?';

  @override
  String get transactionsDeleteMessage =>
      'Уверен, что хочешь удалить эту операцию?';

  @override
  String get transactionsDeleted => 'Операция удалена';

  @override
  String get transactionsTextTitle => 'Текст';

  @override
  String get transactionsTextHint => 'Описание, категория, тег или сумма';

  @override
  String get transactionsTypeTitle => 'Тип операций';

  @override
  String get transactionsTypeAll => 'Все';

  @override
  String get transactionsTypeExpenses => 'Расходы';

  @override
  String get transactionsTypeIncome => 'Доходы';

  @override
  String get transactionsPeriodTitle => 'Период';

  @override
  String get transactionsQuickLastMonth => 'Последний месяц';

  @override
  String get transactionsQuickQuarter => 'Квартал';

  @override
  String get transactionsQuickYear => 'Год';

  @override
  String get transactionsSelectMonth => 'Выбрать месяц';

  @override
  String get transactionsFrom => 'От';

  @override
  String get transactionsTo => 'До';

  @override
  String get transactionsChooseDate => 'Выбери дату';

  @override
  String get transactionsCategoriesTitle => 'Категории';

  @override
  String get transactionsTagsTitle => 'Теги';

  @override
  String get transactionsTagsEmpty => 'Теги пока не добавлены';

  @override
  String get transactionsMethodsTitle => 'Способы оплаты';

  @override
  String get transactionsDisplayTotal => 'Итого';

  @override
  String get transactionsDisplayByDate => 'По датам';

  @override
  String get transactionsDisplayCategories => 'Категории';

  @override
  String get transactionsDisplayPayment => 'Оплата';

  @override
  String get transactionsDisplayTags => 'Теги';

  @override
  String get transactionsDisplayAuthor => 'Автор';

  @override
  String get transactionsFamilyBudgetFallback => 'Общий бюджет';

  @override
  String get transactionsNothingFound => 'Ничего не найдено';

  @override
  String get transactionsNoTransactions => 'Пока нет операций';

  @override
  String get transactionsTitle => 'Операции';

  @override
  String get transactionTypeExpense => 'Расход';

  @override
  String get transactionTypeIncome => 'Доход';

  @override
  String get formAmountLabel => 'Сумма';

  @override
  String get formDescriptionLabel => 'Описание';

  @override
  String get formPaymentLabel => 'Оплата';

  @override
  String get formCategoryLabel => 'Категория';

  @override
  String get formTagsLabel => 'Теги';

  @override
  String get formTagsEmpty => 'Теги пока не добавлены';

  @override
  String get formChooseCategoryError => 'Выберите категорию';

  @override
  String get formChoosePaymentError => 'Выберите способ оплаты';

  @override
  String get formAmountPositiveError => 'Введите сумму больше 0';

  @override
  String addTransactionNewTitle(Object type) {
    return 'Новый $type';
  }

  @override
  String get addTransactionEditTitle => 'Редактировать';

  @override
  String get addTransactionDescriptionHint => 'Например, кофе и перекус';

  @override
  String get plannedTitle => 'Регулярные платежи';

  @override
  String get plannedEmpty => 'Пока нет регулярных платежей';

  @override
  String get plannedDeleteTitle => 'Удалить запись?';

  @override
  String get plannedDeleteMessage => 'Уверен, что хочешь удалить эту запись?';

  @override
  String get plannedDeleted => 'Платеж удален';

  @override
  String get plannedAddToTransactionsTitle => 'Добавить в операции?';

  @override
  String plannedAddToTransactionsMessage(Object description, Object amount) {
    return 'Создать операцию из записи «$description» на сумму $amount?';
  }

  @override
  String get plannedAddedToTransactions => 'Добавлено в операции';

  @override
  String get plannedActionAddToTransactions => 'Добавить в операции';

  @override
  String plannedScheduledReminder(Object date) {
    return 'Напоминание: $date';
  }

  @override
  String plannedScheduledDate(Object date) {
    return 'Дата: $date';
  }

  @override
  String get plannedAddToTransactionsTooltip => 'Добавить в операции';

  @override
  String get plannedNotificationsPermissionError =>
      'Разрешите уведомления в настройках устройства';

  @override
  String get plannedChooseDateTimeError => 'Выберите дату и время';

  @override
  String get plannedChooseFutureTimeError => 'Выберите время в будущем';

  @override
  String get plannedNewTitle => 'Новая регулярная запись';

  @override
  String get plannedEditTitle => 'Редактировать запись';

  @override
  String get plannedDescriptionHint => 'Например, коммуналка';

  @override
  String get plannedWhenLabel => 'Когда';

  @override
  String get plannedChooseDateTime => 'Выбрать дату и время';

  @override
  String get plannedRemindLabel => 'Напомнить';

  @override
  String get remindersTitle => 'Напоминания';

  @override
  String get remindersEmpty => 'Пока нет напоминаний';

  @override
  String get remindersDeleteTitle => 'Удалить напоминание?';

  @override
  String get remindersDeleteMessage =>
      'Уверен, что хочешь удалить это напоминание?';

  @override
  String get remindersPermissionError =>
      'Разрешите уведомления в настройках устройства';

  @override
  String get remindersNewTitle => 'Создать напоминание';

  @override
  String get remindersEditTitle => 'Редактировать напоминание';

  @override
  String get remindersNameLabel => 'Имя напоминания';

  @override
  String get remindersNameHint => 'Например, оплата аренды';

  @override
  String get remindersNameRequired => 'Обязательное поле для заполнения';

  @override
  String get remindersFrequencyLabel => 'Периодичность';

  @override
  String get remindersStartDateLabel => 'Дата начала';

  @override
  String get remindersTimeLabel => 'Время';

  @override
  String get remindersCommentLabel => 'Комментарий';

  @override
  String get remindersCommentHint => 'Комментарий';

  @override
  String get remindersChooseFutureTimeError => 'Выберите время в будущем';

  @override
  String get reminderFrequencyOnce => 'Один раз';

  @override
  String get reminderFrequencyDaily => 'Каждый день';

  @override
  String get reminderFrequencyWeekly => 'Каждую неделю';

  @override
  String get reminderFrequencyBiweekly => 'Каждые 2 недели';

  @override
  String get reminderFrequencyFourWeeks => 'Каждые 4 недели';

  @override
  String get reminderFrequencyMonthly => 'Каждый месяц';

  @override
  String get reminderFrequencyEveryTwoMonths => 'Каждые 2 месяца';

  @override
  String get reminderFrequencyQuarterly => 'Каждый квартал';

  @override
  String get reminderFrequencyHalfYear => 'Каждые полгода';

  @override
  String get reminderFrequencyYearly => 'Каждый год';

  @override
  String get dataExportNoTransactions => 'Нет операций для экспорта';

  @override
  String dataExportMonthLimitMessage(Object month, int count, int limit) {
    return 'В месяце $month найдено $count операций. Лимит экспорта: $limit строк.';
  }

  @override
  String get dataExportNoTransactionsForMonth =>
      'Нет операций за выбранный месяц';

  @override
  String get dataExportColumnDate => 'Дата';

  @override
  String get dataExportColumnAuthor => 'Кто';

  @override
  String get dataExportColumnMethod => 'Метод';

  @override
  String get dataExportColumnCategory => 'Категория';

  @override
  String get dataExportColumnDescription => 'Описание';

  @override
  String get dataExportColumnType => 'Тип';

  @override
  String get dataExportColumnAmount => 'Сумма';

  @override
  String dataExportSavedOnDevice(Object path) {
    return 'Экспорт доступен на устройстве. Файл сохранен: $path';
  }

  @override
  String dataExportShareText(Object month) {
    return 'Экспорт операций Budgetto за $month';
  }

  @override
  String dataExportFileSaved(Object path) {
    return 'Файл сохранен: $path';
  }

  @override
  String get dataExportPickMonthTitle => 'Выбери месяц для экспорта';

  @override
  String dataExportPickMonthDescription(int limit) {
    return 'Экспортирует только один месяц. Максимум $limit строк.';
  }

  @override
  String get dataExportSelectMonthLabel => 'Месяц';

  @override
  String get dataExportExportAction => 'Экспортировать CSV';

  @override
  String get dataExportNoAvailableMonths =>
      'Сейчас нет месяцев, доступных для экспорта';

  @override
  String dataExportMonthCountExceeded(int count) {
    return '$count операций, превышает лимит';
  }

  @override
  String dataExportMonthCount(int count) {
    return '$count операций';
  }

  @override
  String dataExportMonthsLimited(int limit) {
    return 'Месяцы с количеством операций больше $limit недоступны для экспорта.';
  }

  @override
  String get paymentMethodCashLabel => 'Кеш';

  @override
  String get paymentMethodCardLabel => 'Карта';

  @override
  String get currencyNameUsd => 'Доллар США';

  @override
  String get currencyNameEur => 'Евро';

  @override
  String get currencyNameGbp => 'Фунт стерлингов';

  @override
  String get currencyNameUah => 'Гривна';

  @override
  String get currencyNameJpy => 'Йена';

  @override
  String get currencyNameRub => 'Рубль';

  @override
  String get syncSettingsGoogleConnected => 'Google подключен';

  @override
  String get syncSettingsSignInCanceled => 'Вход отменен';

  @override
  String get syncSettingsGoogleConnectFailed => 'Не удалось подключить Google';

  @override
  String get syncSettingsStatusEnabled => 'Включена';

  @override
  String get syncSettingsStatusDisabled => 'Выключена';

  @override
  String get syncSettingsGuest => 'Гость';

  @override
  String get syncSettingsAccountSectionTitle => 'Аккаунт';

  @override
  String get syncSettingsStatusLabel => 'Статус';

  @override
  String get syncSettingsGoogleSignInButton => 'Войти через Google';

  @override
  String get syncSettingsGoogleDescription =>
      'Подключи Google, чтобы переносить прогресс между устройствами.';

  @override
  String get syncSettingsStatusSectionTitle => 'Статус';

  @override
  String get syncSettingsDataStatusLabel => 'Синхронизация данных';

  @override
  String get syncSettingsCloudDescription =>
      'Синхронизация нужна для хранения данных в облаке и совместного бюджета.';

  @override
  String get settingsDataFileReadFailed =>
      'Не удалось прочитать выбранный файл.';

  @override
  String settingsDataImportFailed(Object error) {
    return 'Импорт не удался: $error';
  }

  @override
  String get settingsDataErrorsTitle => 'Исправь ошибки в CSV';

  @override
  String get settingsDataValidationFailedNoName => 'Файл не прошел валидацию.';

  @override
  String settingsDataValidationFailedWithName(Object fileName) {
    return 'Файл \"$fileName\" не прошел валидацию.';
  }

  @override
  String get settingsDataUnderstoodButton => 'Понятно';

  @override
  String get settingsDataConfirmImportTitle => 'Подтвердить импорт';

  @override
  String settingsDataFileLabel(Object fileName) {
    return 'Файл: $fileName';
  }

  @override
  String settingsDataWillAddCount(int count) {
    return 'Будет добавлено записей: $count';
  }

  @override
  String get settingsDataNewCategories => 'Новые категории';

  @override
  String get settingsDataNewPaymentMethods => 'Новые способы оплаты';

  @override
  String get settingsDataNewTags => 'Новые теги';

  @override
  String get settingsDataImportConfirmHint =>
      'Новые категории, способы оплаты, теги и сами записи будут добавлены только после нажатия кнопки \"Импортировать\".';

  @override
  String get settingsDataImportTagHint =>
      'Все импортированные записи также получат системный тег импорта, чтобы их можно было быстро отфильтровать и удалить.';

  @override
  String get settingsDataCancelButton => 'Отмена';

  @override
  String get settingsDataImportAction => 'Импортировать';

  @override
  String settingsDataImportedSuccess(int count, Object tag) {
    return 'Импортировано $count записей. Тег: $tag.';
  }

  @override
  String get settingsDataImportCardTitle => 'Импорт затрат из CSV';

  @override
  String get settingsDataSampleTitle => 'Пример данных в документе';

  @override
  String get settingsDataCheckingCsv => 'Проверяем CSV...';

  @override
  String get settingsDataChooseCsv => 'Выбрать CSV и проверить';

  @override
  String get transactionImportErrorEmptyFile =>
      'Файл пустой. Добавь заголовки и строки данных.';

  @override
  String get transactionImportErrorUnclosedQuote =>
      'CSV содержит незакрытую кавычку. Проверь файл и попробуй снова.';

  @override
  String get transactionImportErrorReadRows =>
      'Не удалось прочитать строки CSV.';

  @override
  String transactionImportMissingRequiredColumn(Object column) {
    return 'Не найдена обязательная колонка \"$column\". Используй шаблон из инструкции.';
  }

  @override
  String get transactionImportErrorNoDataRows =>
      'В файле нет строк с операциями. Добавь хотя бы одну запись.';

  @override
  String transactionImportErrorRowLimit(int count, int limit) {
    return 'В файле $count строк, а лимит импорта сейчас $limit.';
  }

  @override
  String transactionImportErrorInvalidDate(Object value) {
    return 'Не удалось распознать дату \"$value\". Используй дату со временем, например 2026-02-05 00:53. Секунды можно указывать, они будут проигнорированы.';
  }

  @override
  String transactionImportErrorInvalidType(Object expense, Object income) {
    return 'Поле типа операции заполнено неверно. Используй значение \"$expense\" или \"$income\".';
  }

  @override
  String get transactionImportErrorOperationRequired =>
      'Поле \"операция\" не должно быть пустым.';

  @override
  String transactionImportErrorInvalidAmount(Object value) {
    return 'Поле \"сумма\" должно быть числом больше 0. Сейчас: \"$value\".';
  }

  @override
  String get transactionImportErrorCategoryRequired =>
      'Поле \"категория\" не должно быть пустым.';

  @override
  String get transactionImportErrorPaymentMethodRequired =>
      'Поле \"способ оплаты\" не должно быть пустым.';

  @override
  String get transactionImportInstructionPrepareTitle => 'Подготовь файл';

  @override
  String get transactionImportInstructionFormat => 'Формат файла: CSV.';

  @override
  String get transactionImportInstructionEncoding => 'Кодировка файла: UTF-8.';

  @override
  String transactionImportInstructionHeaderRow(Object headers) {
    return 'Первая строка файла: $headers.';
  }

  @override
  String get transactionImportInstructionDelimiter => 'Разделитель: ;';

  @override
  String transactionImportInstructionMaxRows(int limit) {
    return 'Максимум: $limit строк данных без заголовка.';
  }

  @override
  String get transactionImportInstructionColumnsTitle =>
      'Заполни колонки в первой строке';

  @override
  String transactionImportInstructionDateColumn(Object column) {
    return '$column: дата и время операции. Рекомендуемый формат: YYYY-MM-DD HH:mm. Импорт также принимает записи вида 05.02.2026 0:53:29 и игнорирует секунды.';
  }

  @override
  String transactionImportInstructionTypeColumn(
    Object column,
    Object expense,
    Object income,
  ) {
    return '$column: значение $expense или $income.';
  }

  @override
  String transactionImportInstructionOperationColumn(
    Object column,
    Object example,
  ) {
    return '$column: текст операции. Пример: $example.';
  }

  @override
  String transactionImportInstructionAmountColumn(Object column) {
    return '$column: число больше 0 в формате 12.50.';
  }

  @override
  String transactionImportInstructionCategoryColumn(Object column) {
    return '$column: название категории. Если категории нет, она будет создана после подтверждения.';
  }

  @override
  String transactionImportInstructionPaymentMethodColumn(Object column) {
    return '$column: название способа оплаты. Поле не может быть пустым. Если способа оплаты нет, он будет создан после подтверждения.';
  }

  @override
  String transactionImportInstructionTagsColumn(Object column) {
    return '$column: список тегов через запятую. Поле можно оставить пустым. Если тегов нет, они будут созданы после подтверждения.';
  }

  @override
  String get transactionImportInstructionReviewTitle =>
      'Проверь изменения перед импортом';

  @override
  String get transactionImportInstructionReviewItemOne =>
      'Перед импортом приложение покажет новые категории, способы оплаты и теги.';

  @override
  String get transactionImportInstructionReviewItemTwo =>
      'Новые элементы и записи будут добавлены только после нажатия кнопки Импортировать.';

  @override
  String get transactionImportInstructionReviewItemThree =>
      'Каждая импортированная запись получит системный тег формата import_YYYYMMDD_HHMMSS.';

  @override
  String get transactionImportColumnDate => 'дата';

  @override
  String get transactionImportColumnType => 'тип операции';

  @override
  String get transactionImportColumnOperation => 'операция';

  @override
  String get transactionImportColumnAmount => 'сумма';

  @override
  String get transactionImportColumnCategory => 'категория';

  @override
  String get transactionImportColumnPaymentMethod => 'способ оплаты';

  @override
  String get transactionImportColumnTags => 'теги';

  @override
  String transactionImportLineMessage(int lineNumber, Object message) {
    return 'Строка $lineNumber: $message';
  }

  @override
  String get transactionImportSampleOperationOne => 'Билеты в театр';

  @override
  String get transactionImportSampleOperationTwo => 'Такси домой';

  @override
  String get transactionImportSampleCategoryOne => 'Развлечения';

  @override
  String get transactionImportSampleCategoryTwo => 'Транспорт';

  @override
  String get transactionImportSamplePaymentMethodOne => 'Основная карта';

  @override
  String get transactionImportSamplePaymentMethodTwo => 'Наличные';

  @override
  String get transactionImportSampleTagsOne => 'Театр,Вечер';

  @override
  String get notificationChannelPlannedName => 'Регулярные платежи';

  @override
  String get notificationChannelPlannedDescription =>
      'Напоминания о регулярных платежах';

  @override
  String get notificationChannelReminderName => 'Напоминания';

  @override
  String get notificationChannelReminderDescription =>
      'Напоминания о важных делах';

  @override
  String get notificationChannelFamilyName => 'Семейные траты';

  @override
  String get notificationChannelFamilyDescription =>
      'Уведомления о новых расходах в семейном бюджете';

  @override
  String get editorColorPickerTitle => 'Выбор цвета';

  @override
  String get editorIconColorLabel => 'Цвет иконки';

  @override
  String get editorIconLabel => 'Иконка';

  @override
  String get cardsTitle => 'Карты';

  @override
  String get cardsEmpty => 'Пока нет карт';

  @override
  String get cardsDeleteTitle => 'Удалить карту?';

  @override
  String get cardsDeleteMessage => 'Уверен, что хочешь удалить эту карту?';

  @override
  String get cardsDeleteSuccess => 'Карта удалена';

  @override
  String get cardsNewTitle => 'Новая карта';

  @override
  String get cardsEditTitle => 'Редактировать карту';

  @override
  String get cardsNameHint => 'Например, Сергей WISE';

  @override
  String get tagsEmpty => 'Пока нет тегов';

  @override
  String get tagsDeleteTitle => 'Удалить тег?';

  @override
  String get tagsDeleteMessage => 'Уверен, что хочешь удалить этот тег?';

  @override
  String get tagsDeleteSuccess => 'Тег удален';

  @override
  String get tagsNewTitle => 'Новый тег';

  @override
  String get tagsEditTitle => 'Редактировать тег';

  @override
  String get tagsNameHint => 'Например, Работа';

  @override
  String get categoriesDeleteBlockedTitle => 'Нельзя удалить категорию';

  @override
  String get categoriesDeleteBlockedMessage =>
      'Эта категория уже используется. Сначала создай другую категорию, чтобы перенести в нее записи.';

  @override
  String get categoriesDeleteTitle => 'Удалить категорию?';

  @override
  String get categoriesDeleteMessage =>
      'Уверен, что хочешь удалить эту категорию?';

  @override
  String categoriesDeleteUsedMessage(int transactions, int planned) {
    return 'Категория используется в $transactions операциях и $planned запланированных записях.';
  }

  @override
  String get categoriesDeleteReplacementHint =>
      'Перед удалением выбери категорию, в которую нужно перенести эти записи.';

  @override
  String get categoriesReplacementLabel => 'Новая категория';

  @override
  String categoriesDeleteMovedSuccess(Object name) {
    return 'Категория удалена, записи перенесены в \"$name\".';
  }

  @override
  String get categoriesDeleteSuccess => 'Категория удалена';

  @override
  String get categoriesNewTitle => 'Новая категория';

  @override
  String get categoriesEditTitle => 'Редактировать категорию';

  @override
  String get categoriesNameHint => 'Например, Спорт';

  @override
  String get budgetsReservedSelfName => 'я';

  @override
  String get budgetsNotificationsPermissionError =>
      'Разрешите push-уведомления в настройках устройства';

  @override
  String get budgetsCreateTitle => 'Добавить общий бюджет';

  @override
  String get budgetsNameLabel => 'Название';

  @override
  String get budgetsNameHint => 'Название бюджета';

  @override
  String get budgetsMemberNameLabel => 'Ваше имя';

  @override
  String get budgetsMemberNameHint => 'Ваше имя';

  @override
  String get budgetsJoinTitle => 'Присоединиться по коду';

  @override
  String get budgetsCodeLabel => 'Код бюджета';

  @override
  String get budgetsCodeHint => 'Код бюджета';

  @override
  String get budgetsCodeNotFound => 'Код не найден';

  @override
  String get budgetsJoinAction => 'Присоединиться';

  @override
  String get budgetsLeaveTitle => 'Покинуть общий бюджет?';

  @override
  String get budgetsLeaveMessage => 'Вы уверены, что хотите выйти?';

  @override
  String get budgetsLeaveAction => 'Выйти';

  @override
  String get budgetsSectionTitle => 'Ваши бюджеты';

  @override
  String get budgetsPersonalTitle => 'Личный бюджет';

  @override
  String get budgetsPersonalSubtitle => 'Только для тебя';

  @override
  String get budgetsSettingsSectionTitle => 'Настройки общего бюджета';

  @override
  String get budgetsSavedChanges => 'Изменения сохранены';

  @override
  String get budgetsCodeCopied => 'Код скопирован';

  @override
  String get budgetsCopyCodeTooltip => 'Скопировать код';

  @override
  String get budgetsPersonalSettingsTitle => 'Личные настройки в этом бюджете';

  @override
  String get budgetsNotificationsTitle => 'Уведомлять меня о новых тратах';

  @override
  String get budgetsNotificationsDescription =>
      'Пуш придет, когда кто-то из семьи добавит новый расход в этот бюджет.';

  @override
  String get budgetsNotificationsPerUserHint =>
      'У остальных участников этот переключатель работает отдельно.';

  @override
  String get budgetsMembersTitle => 'Участники';

  @override
  String get budgetsLeaveButton => 'Покинуть общий бюджет';

  @override
  String get appStateSharedBudgetName => 'Общий бюджет';

  @override
  String get appStatePersonalBudgetName => 'Личный бюджет';

  @override
  String get appStateCashMethodName => 'Наличные';

  @override
  String get appStateUnknownUserName => 'Без имени';

  @override
  String get appStatePlannedNotificationTitle => 'Регулярная запись';

  @override
  String get appStateFamilyTransactionTitle => 'Новая трата в семье';

  @override
  String get appStateFamilyTransactionBody =>
      'В семейном бюджете появилась новая трата';

  @override
  String get appStateBillingUpdateError => 'Не удалось обновить статус покупки';

  @override
  String get appStateBillingConnectError => 'Не удалось подключить магазин';

  @override
  String get appStateBillingProductUnavailable =>
      'Тариф пока недоступен в магазине';

  @override
  String get appStateBillingStartPurchaseError => 'Не удалось начать покупку';

  @override
  String get appStateBillingStoreUnavailable => 'Магазин сейчас недоступен';

  @override
  String get appStateBillingRestoreError => 'Не удалось восстановить покупки';

  @override
  String get appStateBillingCompletePurchaseError =>
      'Не удалось завершить покупку';

  @override
  String get appStateCategoryFood => 'Еда';

  @override
  String get appStateCategoryHome => 'Жилье';

  @override
  String get appStateCategoryTransport => 'Транспорт';

  @override
  String get appStateCategoryShopping => 'Покупки';

  @override
  String get appStateCategoryHealth => 'Здоровье';

  @override
  String get appStateCategoryFun => 'Развлечения';

  @override
  String get appStateCategoryEducation => 'Образование';

  @override
  String get appStateCategoryGifts => 'Подарки';

  @override
  String get appStateCategoryTravel => 'Путешествия';

  @override
  String get appStateCategoryOther => 'Прочее';

  @override
  String get appStateTagWork => 'Работа';

  @override
  String get appStateTagHome => 'Дом';

  @override
  String get appStateTagTravel => 'Путешествия';

  @override
  String get appStateTagFamily => 'Семья';

  @override
  String get appStateTagFun => 'Развлечения';

  @override
  String get appStateTagEatingOut => 'Еда вне дома';
}
