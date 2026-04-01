// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Budgetto';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsPremiumTitle => 'Premium';

  @override
  String get settingsPremiumSubtitle => 'Subscription and app access';

  @override
  String get settingsBudgetsTitle => 'Budgets';

  @override
  String get settingsBudgetsSubtitle => 'Limits and goals by category';

  @override
  String get settingsPaymentMethodsTitle => 'Payment methods';

  @override
  String get settingsPaymentMethodsSubtitle =>
      'Cards and accounts for transactions';

  @override
  String get settingsCategoriesTitle => 'Categories';

  @override
  String get settingsCategoriesSubtitle => 'Edit the category list';

  @override
  String get settingsTagsTitle => 'Tags';

  @override
  String get settingsTagsSubtitle => 'Add and rename tags';

  @override
  String get settingsCurrencyTitle => 'Currency';

  @override
  String get settingsCurrencySubtitle => 'Display currency for amounts';

  @override
  String get settingsCurrencyNotSelected => 'Not selected';

  @override
  String get settingsThemeTitle => 'Theme';

  @override
  String get settingsThemeSubtitle => 'Light or dark theme';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsLanguageTitle => 'Language';

  @override
  String get settingsLanguageSubtitle => 'App display language';

  @override
  String get settingsSyncTitle => 'Sync';

  @override
  String get settingsSyncSubtitle => 'Sign in and move progress';

  @override
  String get settingsDataTitle => 'Data';

  @override
  String get settingsDataSubtitle => 'Import expenses from CSV';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonReset => 'Reset';

  @override
  String get commonApply => 'Apply';

  @override
  String get commonSelect => 'Select';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonSave => 'Save';

  @override
  String get commonCreate => 'Create';

  @override
  String get commonAdd => 'Add';

  @override
  String get commonNotAvailable => '—';

  @override
  String get themeSettingsSectionTitle => 'Appearance';

  @override
  String get themeSettingsDescription =>
      'Theme affects the background, cards, and interface accents.';

  @override
  String get languageSettingsDescription =>
      'Choose a fixed app language or use the system language.';

  @override
  String get languageSystem => 'System';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageRussian => 'Russian';

  @override
  String get languageSpanish => 'Spanish';

  @override
  String get accessStatusPremiumActive => 'Premium active';

  @override
  String get accessStatusLocked => 'Access locked';

  @override
  String accessStatusDaysRemaining(int count) {
    return '$count d. left';
  }

  @override
  String get appShellPlannedPayments => 'Recurring payments';

  @override
  String get appShellReminders => 'Reminders';

  @override
  String get appShellShoppingLists => 'Shopping lists';

  @override
  String get appShellImportCsv => 'Import CSV';

  @override
  String get appShellExportCsv => 'Export CSV';

  @override
  String get overviewTitle => 'Overview';

  @override
  String get overviewRangePickHelp => 'Choose a period';

  @override
  String get overviewRangeSave => 'Done';

  @override
  String get overviewRangeCancel => 'Cancel';

  @override
  String get overviewExpenses => 'Expenses';

  @override
  String get overviewIncome => 'Income';

  @override
  String get overviewRangeDay => 'Day';

  @override
  String get overviewRangeWeek => 'Week';

  @override
  String get overviewRangeMonth => 'Month';

  @override
  String get overviewRangeYear => 'Year';

  @override
  String get overviewRangePeriod => 'Period';

  @override
  String get overviewTotal => 'Total';

  @override
  String get overviewNoTransactions =>
      'No transactions for the selected period.';

  @override
  String get homeBalanceTitle => 'Balance';

  @override
  String get homeCategoriesTitle => 'Categories';

  @override
  String get searchTitle => 'Search';

  @override
  String get searchHint => 'Search by description, category, or tag';

  @override
  String get searchAll => 'All';

  @override
  String get searchFromPlaceholder => 'From: date and time';

  @override
  String searchFromValue(Object value) {
    return 'From: $value';
  }

  @override
  String get searchToPlaceholder => 'To: date and time';

  @override
  String searchToValue(Object value) {
    return 'To: $value';
  }

  @override
  String get searchTagsEmpty => 'No tags added yet';

  @override
  String get searchNoResults => 'Nothing found';

  @override
  String get reportsTitle => 'Reports';

  @override
  String get reportsByCategoryTitle => 'By category';

  @override
  String get reportsByTimeTitle => 'By time';

  @override
  String get reportsCategoryFood => 'Food';

  @override
  String get reportsCategoryHousing => 'Housing';

  @override
  String get reportsCategoryTransport => 'Transport';

  @override
  String get listsEmpty => 'No lists yet';

  @override
  String get listsDeleteTitle => 'Delete list?';

  @override
  String get listsDeleteMessage => 'Are you sure you want to delete this list?';

  @override
  String get listsSummaryEmpty => 'No items yet';

  @override
  String listsSummaryProgress(int done, int total) {
    return 'Checked $done of $total';
  }

  @override
  String get listsDefaultTitle => 'List';

  @override
  String get listsAddTitleOrItemError => 'Add a title or a list item';

  @override
  String get listsNewTitle => 'New list';

  @override
  String get listsEditorTitle => 'List';

  @override
  String get listsNameHint => 'List title';

  @override
  String get listsItemHint => 'List item';

  @override
  String get listsAddItem => 'Add item';

  @override
  String get subscriptionPlanYearlyTitle => 'Yearly';

  @override
  String get subscriptionPlanYearlyFallback => '\$15 / year';

  @override
  String get subscriptionPlanBestBadge => 'Best value';

  @override
  String get subscriptionPlanQuarterlyTitle => '3 months';

  @override
  String get subscriptionPlanQuarterlyFallback => '\$5 / 3 months';

  @override
  String get subscriptionPlanMonthlyTitle => 'Monthly';

  @override
  String get subscriptionPlanMonthlyFallback => '\$2 / month';

  @override
  String get subscriptionDateNotSet => 'not set';

  @override
  String get subscriptionHeadlineActive => 'Premium is active';

  @override
  String get subscriptionHeadlineTrial =>
      'The first 30 days include full access';

  @override
  String get subscriptionHeadlineExpired => 'Trial period has ended';

  @override
  String get subscriptionSubheadActive =>
      'Premium keeps full access to Budgetto after the trial.';

  @override
  String subscriptionSubheadTrial(int count) {
    return '$count d. of full access left before Premium is required.';
  }

  @override
  String get subscriptionSubheadExpired =>
      'To keep using Budgetto after the trial, choose a subscription.';

  @override
  String get subscriptionUnlimited => 'Unlimited';

  @override
  String subscriptionUntil(Object date) {
    return 'Until $date';
  }

  @override
  String get subscriptionChipFullAccess => 'Full access';

  @override
  String get subscriptionChipPremiumAfterTrial => 'Premium after trial';

  @override
  String get subscriptionChipSubscriptionRequired => 'Subscription required';

  @override
  String get subscriptionHowItWorksTitle => 'How access works';

  @override
  String get subscriptionHowItWorksTrial =>
      'The first 30 days include full access to the entire app.';

  @override
  String get subscriptionHowItWorksNoSplit =>
      'During the trial there is no split between basic and Premium features.';

  @override
  String get subscriptionHowItWorksAfterTrial =>
      'After the trial ends, an active Premium subscription is required to continue using Budgetto.';

  @override
  String get subscriptionHowItWorksBilling =>
      'You can choose monthly, quarterly, or yearly billing at any time.';

  @override
  String get subscriptionStoreUnavailable =>
      'The payment store is currently unavailable. Try again later.';

  @override
  String get subscriptionRestorePurchases => 'Restore purchases';

  @override
  String get subscriptionRenewalNote =>
      'The subscription renews automatically until the user cancels it in the App Store or Google Play.';

  @override
  String get subscriptionPlanActive => 'Active';

  @override
  String get transactionsBudgetPickerTitle => 'Choose a budget';

  @override
  String get transactionsPersonalBudgetTitle => 'Personal budget';

  @override
  String get transactionsPersonalBudgetSubtitle => 'Only for you';

  @override
  String get transactionsDeleteTitle => 'Delete transaction?';

  @override
  String get transactionsDeleteMessage =>
      'Are you sure you want to delete this transaction?';

  @override
  String get transactionsDeleted => 'Transaction deleted';

  @override
  String get transactionsTextTitle => 'Text';

  @override
  String get transactionsTextHint => 'Description, category, tag, or amount';

  @override
  String get transactionsTypeTitle => 'Transaction type';

  @override
  String get transactionsTypeAll => 'All';

  @override
  String get transactionsTypeExpenses => 'Expenses';

  @override
  String get transactionsTypeIncome => 'Income';

  @override
  String get transactionsPeriodTitle => 'Period';

  @override
  String get transactionsQuickLastMonth => 'Last month';

  @override
  String get transactionsQuickQuarter => 'Quarter';

  @override
  String get transactionsQuickYear => 'Year';

  @override
  String get transactionsSelectMonth => 'Select month';

  @override
  String get transactionsFrom => 'From';

  @override
  String get transactionsTo => 'To';

  @override
  String get transactionsChooseDate => 'Choose a date';

  @override
  String get transactionsCategoriesTitle => 'Categories';

  @override
  String get transactionsTagsTitle => 'Tags';

  @override
  String get transactionsTagsEmpty => 'No tags added yet';

  @override
  String get transactionsMethodsTitle => 'Payment methods';

  @override
  String get transactionsDisplayTotal => 'Total';

  @override
  String get transactionsDisplayByDate => 'By date';

  @override
  String get transactionsDisplayCategories => 'Categories';

  @override
  String get transactionsDisplayPayment => 'Payment';

  @override
  String get transactionsDisplayTags => 'Tags';

  @override
  String get transactionsDisplayAuthor => 'Author';

  @override
  String get transactionsFamilyBudgetFallback => 'Shared budget';

  @override
  String get transactionsNothingFound => 'Nothing found';

  @override
  String get transactionsNoTransactions => 'No transactions yet';

  @override
  String get transactionsTitle => 'Transactions';

  @override
  String get transactionTypeExpense => 'Expense';

  @override
  String get transactionTypeIncome => 'Income';

  @override
  String get formAmountLabel => 'Amount';

  @override
  String get formDescriptionLabel => 'Description';

  @override
  String get formPaymentLabel => 'Payment';

  @override
  String get formCategoryLabel => 'Category';

  @override
  String get formTagsLabel => 'Tags';

  @override
  String get formTagsEmpty => 'No tags added yet';

  @override
  String get formChooseCategoryError => 'Choose a category';

  @override
  String get formChoosePaymentError => 'Choose a payment method';

  @override
  String get formAmountPositiveError => 'Enter an amount greater than 0';

  @override
  String addTransactionNewTitle(Object type) {
    return 'New $type';
  }

  @override
  String get addTransactionEditTitle => 'Edit transaction';

  @override
  String get addTransactionDescriptionHint => 'For example, coffee and snack';

  @override
  String get plannedTitle => 'Recurring payments';

  @override
  String get plannedEmpty => 'No recurring payments yet';

  @override
  String get plannedDeleteTitle => 'Delete entry?';

  @override
  String get plannedDeleteMessage =>
      'Are you sure you want to delete this entry?';

  @override
  String get plannedDeleted => 'Payment deleted';

  @override
  String get plannedAddToTransactionsTitle => 'Add to transactions?';

  @override
  String plannedAddToTransactionsMessage(Object description, Object amount) {
    return 'Create a transaction from \"$description\" for $amount?';
  }

  @override
  String get plannedAddedToTransactions => 'Added to transactions';

  @override
  String get plannedActionAddToTransactions => 'Add to transactions';

  @override
  String plannedScheduledReminder(Object date) {
    return 'Reminder: $date';
  }

  @override
  String plannedScheduledDate(Object date) {
    return 'Date: $date';
  }

  @override
  String get plannedAddToTransactionsTooltip => 'Add to transactions';

  @override
  String get plannedNotificationsPermissionError =>
      'Allow notifications in device settings';

  @override
  String get plannedChooseDateTimeError => 'Choose a date and time';

  @override
  String get plannedChooseFutureTimeError => 'Choose a time in the future';

  @override
  String get plannedNewTitle => 'New recurring entry';

  @override
  String get plannedEditTitle => 'Edit entry';

  @override
  String get plannedDescriptionHint => 'For example, utilities';

  @override
  String get plannedWhenLabel => 'When';

  @override
  String get plannedChooseDateTime => 'Choose date and time';

  @override
  String get plannedRemindLabel => 'Remind me';

  @override
  String get remindersTitle => 'Reminders';

  @override
  String get remindersEmpty => 'No reminders yet';

  @override
  String get remindersDeleteTitle => 'Delete reminder?';

  @override
  String get remindersDeleteMessage =>
      'Are you sure you want to delete this reminder?';

  @override
  String get remindersPermissionError =>
      'Allow notifications in device settings';

  @override
  String get remindersNewTitle => 'Create reminder';

  @override
  String get remindersEditTitle => 'Edit reminder';

  @override
  String get remindersNameLabel => 'Reminder name';

  @override
  String get remindersNameHint => 'For example, rent payment';

  @override
  String get remindersNameRequired => 'This field is required';

  @override
  String get remindersFrequencyLabel => 'Frequency';

  @override
  String get remindersStartDateLabel => 'Start date';

  @override
  String get remindersTimeLabel => 'Time';

  @override
  String get remindersCommentLabel => 'Comment';

  @override
  String get remindersCommentHint => 'Comment';

  @override
  String get remindersChooseFutureTimeError => 'Choose a time in the future';

  @override
  String get reminderFrequencyOnce => 'Once';

  @override
  String get reminderFrequencyDaily => 'Every day';

  @override
  String get reminderFrequencyWeekly => 'Every week';

  @override
  String get reminderFrequencyBiweekly => 'Every 2 weeks';

  @override
  String get reminderFrequencyFourWeeks => 'Every 4 weeks';

  @override
  String get reminderFrequencyMonthly => 'Every month';

  @override
  String get reminderFrequencyEveryTwoMonths => 'Every 2 months';

  @override
  String get reminderFrequencyQuarterly => 'Every quarter';

  @override
  String get reminderFrequencyHalfYear => 'Every half year';

  @override
  String get reminderFrequencyYearly => 'Every year';

  @override
  String get dataExportNoTransactions => 'No transactions to export';

  @override
  String dataExportMonthLimitMessage(Object month, int count, int limit) {
    return '$month has $count transactions. Export limit: $limit rows.';
  }

  @override
  String get dataExportNoTransactionsForMonth =>
      'No transactions for the selected month';

  @override
  String get dataExportColumnDate => 'Date';

  @override
  String get dataExportColumnAuthor => 'Who';

  @override
  String get dataExportColumnMethod => 'Method';

  @override
  String get dataExportColumnCategory => 'Category';

  @override
  String get dataExportColumnDescription => 'Description';

  @override
  String get dataExportColumnType => 'Type';

  @override
  String get dataExportColumnAmount => 'Amount';

  @override
  String dataExportSavedOnDevice(Object path) {
    return 'Export is available on a physical device. File saved: $path';
  }

  @override
  String dataExportShareText(Object month) {
    return 'Budgetto transaction export for $month';
  }

  @override
  String dataExportFileSaved(Object path) {
    return 'File saved: $path';
  }

  @override
  String get dataExportPickMonthTitle => 'Choose a month to export';

  @override
  String dataExportPickMonthDescription(int limit) {
    return 'Exports only one month. Maximum $limit rows.';
  }

  @override
  String get dataExportSelectMonthLabel => 'Month';

  @override
  String get dataExportExportAction => 'Export CSV';

  @override
  String get dataExportNoAvailableMonths =>
      'No months are currently available for export';

  @override
  String dataExportMonthCountExceeded(int count) {
    return '$count transactions, exceeds limit';
  }

  @override
  String dataExportMonthCount(int count) {
    return '$count transactions';
  }

  @override
  String dataExportMonthsLimited(int limit) {
    return 'Months with more than $limit transactions are unavailable for export.';
  }

  @override
  String get paymentMethodCashLabel => 'Cash';

  @override
  String get paymentMethodCardLabel => 'Card';

  @override
  String get currencyNameUsd => 'US Dollar';

  @override
  String get currencyNameEur => 'Euro';

  @override
  String get currencyNameGbp => 'British Pound';

  @override
  String get currencyNameUah => 'Ukrainian Hryvnia';

  @override
  String get currencyNameJpy => 'Japanese Yen';

  @override
  String get currencyNameRub => 'Russian Ruble';

  @override
  String get syncSettingsGoogleConnected => 'Google connected';

  @override
  String get syncSettingsSignInCanceled => 'Sign-in canceled';

  @override
  String get syncSettingsGoogleConnectFailed => 'Failed to connect Google';

  @override
  String get syncSettingsStatusEnabled => 'Enabled';

  @override
  String get syncSettingsStatusDisabled => 'Disabled';

  @override
  String get syncSettingsGuest => 'Guest';

  @override
  String get syncSettingsAccountSectionTitle => 'Account';

  @override
  String get syncSettingsStatusLabel => 'Status';

  @override
  String get syncSettingsGoogleSignInButton => 'Sign in with Google';

  @override
  String get syncSettingsGoogleDescription =>
      'Connect Google to move your progress between devices.';

  @override
  String get syncSettingsStatusSectionTitle => 'Status';

  @override
  String get syncSettingsDataStatusLabel => 'Data sync';

  @override
  String get syncSettingsCloudDescription =>
      'Sync keeps your data in the cloud and enables a shared budget.';

  @override
  String get settingsDataFileReadFailed => 'Failed to read the selected file.';

  @override
  String settingsDataImportFailed(Object error) {
    return 'Import failed: $error';
  }

  @override
  String get settingsDataErrorsTitle => 'Fix CSV errors';

  @override
  String get settingsDataValidationFailedNoName =>
      'The file did not pass validation.';

  @override
  String settingsDataValidationFailedWithName(Object fileName) {
    return 'The file \"$fileName\" did not pass validation.';
  }

  @override
  String get settingsDataUnderstoodButton => 'OK';

  @override
  String get settingsDataConfirmImportTitle => 'Confirm import';

  @override
  String settingsDataFileLabel(Object fileName) {
    return 'File: $fileName';
  }

  @override
  String settingsDataWillAddCount(int count) {
    return 'Entries to add: $count';
  }

  @override
  String get settingsDataNewCategories => 'New categories';

  @override
  String get settingsDataNewPaymentMethods => 'New payment methods';

  @override
  String get settingsDataNewTags => 'New tags';

  @override
  String get settingsDataImportConfirmHint =>
      'New categories, payment methods, tags, and entries will be added only after you press \"Import\".';

  @override
  String get settingsDataImportTagHint =>
      'All imported entries will also receive a system import tag so you can filter and remove them quickly.';

  @override
  String get settingsDataCancelButton => 'Cancel';

  @override
  String get settingsDataImportAction => 'Import';

  @override
  String settingsDataImportedSuccess(int count, Object tag) {
    return 'Imported $count entries. Tag: $tag.';
  }

  @override
  String get settingsDataImportCardTitle => 'Import expenses from CSV';

  @override
  String get settingsDataSampleTitle => 'Sample data';

  @override
  String get settingsDataCheckingCsv => 'Checking CSV...';

  @override
  String get settingsDataChooseCsv => 'Choose CSV and validate';

  @override
  String get transactionImportErrorEmptyFile =>
      'The file is empty. Add headers and data rows.';

  @override
  String get transactionImportErrorUnclosedQuote =>
      'The CSV contains an unclosed quote. Check the file and try again.';

  @override
  String get transactionImportErrorReadRows => 'Failed to read CSV rows.';

  @override
  String transactionImportMissingRequiredColumn(Object column) {
    return 'Required column \"$column\" was not found. Use the template from the instructions.';
  }

  @override
  String get transactionImportErrorNoDataRows =>
      'The file has no transaction rows. Add at least one entry.';

  @override
  String transactionImportErrorRowLimit(int count, int limit) {
    return 'The file has $count rows, but the current import limit is $limit.';
  }

  @override
  String transactionImportErrorInvalidDate(Object value) {
    return 'Could not recognize the date \"$value\". Use a date with time, for example 2026-02-05 00:53. Seconds are optional and will be ignored.';
  }

  @override
  String transactionImportErrorInvalidType(Object expense, Object income) {
    return 'The transaction type field is invalid. Use \"$expense\" or \"$income\".';
  }

  @override
  String get transactionImportErrorOperationRequired =>
      'The operation field must not be empty.';

  @override
  String transactionImportErrorInvalidAmount(Object value) {
    return 'The amount field must be a number greater than 0. Current value: \"$value\".';
  }

  @override
  String get transactionImportErrorCategoryRequired =>
      'The category field must not be empty.';

  @override
  String get transactionImportErrorPaymentMethodRequired =>
      'The payment method field must not be empty.';

  @override
  String get transactionImportInstructionPrepareTitle => 'Prepare the file';

  @override
  String get transactionImportInstructionFormat => 'File format: CSV.';

  @override
  String get transactionImportInstructionEncoding => 'File encoding: UTF-8.';

  @override
  String transactionImportInstructionHeaderRow(Object headers) {
    return 'First row of the file: $headers.';
  }

  @override
  String get transactionImportInstructionDelimiter => 'Delimiter: ;';

  @override
  String transactionImportInstructionMaxRows(int limit) {
    return 'Maximum: $limit data rows without the header.';
  }

  @override
  String get transactionImportInstructionColumnsTitle =>
      'Fill the columns in the first row';

  @override
  String transactionImportInstructionDateColumn(Object column) {
    return '$column: the transaction date and time. Recommended format: YYYY-MM-DD HH:mm. The import also accepts values like 05.02.2026 0:53:29 and ignores seconds.';
  }

  @override
  String transactionImportInstructionTypeColumn(
    Object column,
    Object expense,
    Object income,
  ) {
    return '$column: use the value $expense or $income.';
  }

  @override
  String transactionImportInstructionOperationColumn(
    Object column,
    Object example,
  ) {
    return '$column: transaction text. Example: $example.';
  }

  @override
  String transactionImportInstructionAmountColumn(Object column) {
    return '$column: a number greater than 0 in the format 12.50.';
  }

  @override
  String transactionImportInstructionCategoryColumn(Object column) {
    return '$column: category name. If it does not exist yet, it will be created after confirmation.';
  }

  @override
  String transactionImportInstructionPaymentMethodColumn(Object column) {
    return '$column: payment method name. This field cannot be empty. If it does not exist yet, it will be created after confirmation.';
  }

  @override
  String transactionImportInstructionTagsColumn(Object column) {
    return '$column: a comma-separated list of tags. This field may be empty. Missing tags will be created after confirmation.';
  }

  @override
  String get transactionImportInstructionReviewTitle =>
      'Review changes before import';

  @override
  String get transactionImportInstructionReviewItemOne =>
      'Before import, the app will show new categories, payment methods, and tags.';

  @override
  String get transactionImportInstructionReviewItemTwo =>
      'New items and entries will be added only after you press the Import button.';

  @override
  String get transactionImportInstructionReviewItemThree =>
      'Each imported entry will receive a system tag in the format import_YYYYMMDD_HHMMSS.';

  @override
  String get transactionImportColumnDate => 'date';

  @override
  String get transactionImportColumnType => 'transaction type';

  @override
  String get transactionImportColumnOperation => 'operation';

  @override
  String get transactionImportColumnAmount => 'amount';

  @override
  String get transactionImportColumnCategory => 'category';

  @override
  String get transactionImportColumnPaymentMethod => 'payment method';

  @override
  String get transactionImportColumnTags => 'tags';

  @override
  String transactionImportLineMessage(int lineNumber, Object message) {
    return 'Line $lineNumber: $message';
  }

  @override
  String get transactionImportSampleOperationOne => 'Theater tickets';

  @override
  String get transactionImportSampleOperationTwo => 'Taxi home';

  @override
  String get transactionImportSampleCategoryOne => 'Entertainment';

  @override
  String get transactionImportSampleCategoryTwo => 'Transport';

  @override
  String get transactionImportSamplePaymentMethodOne => 'Main card';

  @override
  String get transactionImportSamplePaymentMethodTwo => 'Cash';

  @override
  String get transactionImportSampleTagsOne => 'Theater,Evening';

  @override
  String get notificationChannelPlannedName => 'Recurring entries';

  @override
  String get notificationChannelPlannedDescription =>
      'Reminders about recurring entries';

  @override
  String get notificationChannelReminderName => 'Reminders';

  @override
  String get notificationChannelReminderDescription =>
      'Reminders about important tasks';

  @override
  String get notificationChannelFamilyName => 'Family spending';

  @override
  String get notificationChannelFamilyDescription =>
      'Notifications about new expenses in the family budget';

  @override
  String get editorColorPickerTitle => 'Choose a color';

  @override
  String get editorIconColorLabel => 'Icon color';

  @override
  String get editorIconLabel => 'Icon';

  @override
  String get cardsTitle => 'Cards';

  @override
  String get cardsEmpty => 'No cards yet';

  @override
  String get cardsDeleteTitle => 'Delete card?';

  @override
  String get cardsDeleteMessage => 'Are you sure you want to delete this card?';

  @override
  String get cardsDeleteSuccess => 'Card deleted';

  @override
  String get cardsNewTitle => 'New card';

  @override
  String get cardsEditTitle => 'Edit card';

  @override
  String get cardsNameHint => 'For example, Sergey WISE';

  @override
  String get tagsEmpty => 'No tags yet';

  @override
  String get tagsDeleteTitle => 'Delete tag?';

  @override
  String get tagsDeleteMessage => 'Are you sure you want to delete this tag?';

  @override
  String get tagsDeleteSuccess => 'Tag deleted';

  @override
  String get tagsNewTitle => 'New tag';

  @override
  String get tagsEditTitle => 'Edit tag';

  @override
  String get tagsNameHint => 'For example, Work';

  @override
  String get categoriesDeleteBlockedTitle => 'Cannot delete category';

  @override
  String get categoriesDeleteBlockedMessage =>
      'This category is already in use. Create another category first so you can move the entries there.';

  @override
  String get categoriesDeleteTitle => 'Delete category?';

  @override
  String get categoriesDeleteMessage =>
      'Are you sure you want to delete this category?';

  @override
  String categoriesDeleteUsedMessage(int transactions, int planned) {
    return 'This category is used in $transactions transactions and $planned planned entries.';
  }

  @override
  String get categoriesDeleteReplacementHint =>
      'Before deleting, choose the category that should receive these entries.';

  @override
  String get categoriesReplacementLabel => 'New category';

  @override
  String categoriesDeleteMovedSuccess(Object name) {
    return 'Category deleted, entries moved to \"$name\".';
  }

  @override
  String get categoriesDeleteSuccess => 'Category deleted';

  @override
  String get categoriesNewTitle => 'New category';

  @override
  String get categoriesEditTitle => 'Edit category';

  @override
  String get categoriesNameHint => 'For example, Sports';

  @override
  String get budgetsReservedSelfName => 'i';

  @override
  String get budgetsNotificationsPermissionError =>
      'Allow push notifications in device settings';

  @override
  String get budgetsCreateTitle => 'Add shared budget';

  @override
  String get budgetsNameLabel => 'Name';

  @override
  String get budgetsNameHint => 'Budget name';

  @override
  String get budgetsMemberNameLabel => 'Your name';

  @override
  String get budgetsMemberNameHint => 'Your name';

  @override
  String get budgetsJoinTitle => 'Join by code';

  @override
  String get budgetsCodeLabel => 'Budget code';

  @override
  String get budgetsCodeHint => 'Budget code';

  @override
  String get budgetsCodeNotFound => 'Code not found';

  @override
  String get budgetsJoinAction => 'Join';

  @override
  String get budgetsLeaveTitle => 'Leave shared budget?';

  @override
  String get budgetsLeaveMessage => 'Are you sure you want to leave?';

  @override
  String get budgetsLeaveAction => 'Leave';

  @override
  String get budgetsSectionTitle => 'Your budgets';

  @override
  String get budgetsPersonalTitle => 'Personal budget';

  @override
  String get budgetsPersonalSubtitle => 'Only for you';

  @override
  String get budgetsSettingsSectionTitle => 'Shared budget settings';

  @override
  String get budgetsSavedChanges => 'Changes saved';

  @override
  String get budgetsCodeCopied => 'Code copied';

  @override
  String get budgetsCopyCodeTooltip => 'Copy code';

  @override
  String get budgetsPersonalSettingsTitle => 'Personal settings in this budget';

  @override
  String get budgetsNotificationsTitle => 'Notify me about new expenses';

  @override
  String get budgetsNotificationsDescription =>
      'A push notification will arrive when someone from the family adds a new expense to this budget.';

  @override
  String get budgetsNotificationsPerUserHint =>
      'This toggle works separately for each participant.';

  @override
  String get budgetsMembersTitle => 'Members';

  @override
  String get budgetsLeaveButton => 'Leave shared budget';

  @override
  String get appStateSharedBudgetName => 'Shared budget';

  @override
  String get appStatePersonalBudgetName => 'Personal budget';

  @override
  String get appStateCashMethodName => 'Cash';

  @override
  String get appStateUnknownUserName => 'No name';

  @override
  String get appStatePlannedNotificationTitle => 'Recurring entry';

  @override
  String get appStateFamilyTransactionTitle => 'New family expense';

  @override
  String get appStateFamilyTransactionBody =>
      'A new expense appeared in the family budget';

  @override
  String get appStateBillingUpdateError => 'Failed to update purchase status';

  @override
  String get appStateBillingConnectError => 'Failed to connect to the store';

  @override
  String get appStateBillingProductUnavailable =>
      'This plan is not available in the store yet';

  @override
  String get appStateBillingStartPurchaseError =>
      'Failed to start the purchase';

  @override
  String get appStateBillingStoreUnavailable =>
      'The store is currently unavailable';

  @override
  String get appStateBillingRestoreError => 'Failed to restore purchases';

  @override
  String get appStateBillingCompletePurchaseError =>
      'Failed to complete the purchase';

  @override
  String get appStateCategoryFood => 'Food';

  @override
  String get appStateCategoryHome => 'Housing';

  @override
  String get appStateCategoryTransport => 'Transport';

  @override
  String get appStateCategoryShopping => 'Shopping';

  @override
  String get appStateCategoryHealth => 'Health';

  @override
  String get appStateCategoryFun => 'Entertainment';

  @override
  String get appStateCategoryEducation => 'Education';

  @override
  String get appStateCategoryGifts => 'Gifts';

  @override
  String get appStateCategoryTravel => 'Travel';

  @override
  String get appStateCategoryOther => 'Other';

  @override
  String get appStateTagWork => 'Work';

  @override
  String get appStateTagHome => 'Home';

  @override
  String get appStateTagTravel => 'Travel';

  @override
  String get appStateTagFamily => 'Family';

  @override
  String get appStateTagFun => 'Entertainment';

  @override
  String get appStateTagEatingOut => 'Eating out';
}
