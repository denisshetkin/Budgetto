import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('ru'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Budgetto'**
  String get appTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsPremiumTitle.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get settingsPremiumTitle;

  /// No description provided for @settingsPremiumSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Subscription and app access'**
  String get settingsPremiumSubtitle;

  /// No description provided for @settingsBudgetsTitle.
  ///
  /// In en, this message translates to:
  /// **'Budgets'**
  String get settingsBudgetsTitle;

  /// No description provided for @settingsBudgetsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Limits and goals by category'**
  String get settingsBudgetsSubtitle;

  /// No description provided for @settingsPaymentMethodsTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment methods'**
  String get settingsPaymentMethodsTitle;

  /// No description provided for @settingsPaymentMethodsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Cards and accounts for transactions'**
  String get settingsPaymentMethodsSubtitle;

  /// No description provided for @settingsCategoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get settingsCategoriesTitle;

  /// No description provided for @settingsCategoriesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Edit the category list'**
  String get settingsCategoriesSubtitle;

  /// No description provided for @settingsTagsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get settingsTagsTitle;

  /// No description provided for @settingsTagsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add and rename tags'**
  String get settingsTagsSubtitle;

  /// No description provided for @settingsCurrencyTitle.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get settingsCurrencyTitle;

  /// No description provided for @settingsCurrencySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Display currency for amounts'**
  String get settingsCurrencySubtitle;

  /// No description provided for @settingsCurrencyNotSelected.
  ///
  /// In en, this message translates to:
  /// **'Not selected'**
  String get settingsCurrencyNotSelected;

  /// No description provided for @settingsThemeTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsThemeTitle;

  /// No description provided for @settingsThemeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Light or dark theme'**
  String get settingsThemeSubtitle;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguageTitle;

  /// No description provided for @settingsLanguageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'App display language'**
  String get settingsLanguageSubtitle;

  /// No description provided for @settingsSyncTitle.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get settingsSyncTitle;

  /// No description provided for @settingsSyncSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in and move progress'**
  String get settingsSyncSubtitle;

  /// No description provided for @settingsDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get settingsDataTitle;

  /// No description provided for @settingsDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Import expenses from CSV'**
  String get settingsDataSubtitle;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get commonReset;

  /// No description provided for @commonApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get commonApply;

  /// No description provided for @commonSelect.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get commonSelect;

  /// No description provided for @commonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get commonCreate;

  /// No description provided for @commonAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get commonAdd;

  /// No description provided for @commonNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get commonNotAvailable;

  /// No description provided for @themeSettingsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get themeSettingsSectionTitle;

  /// No description provided for @themeSettingsDescription.
  ///
  /// In en, this message translates to:
  /// **'Theme affects the background, cards, and interface accents.'**
  String get themeSettingsDescription;

  /// No description provided for @languageSettingsDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose a fixed app language or use the system language.'**
  String get languageSettingsDescription;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageSystem;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageRussian.
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get languageRussian;

  /// No description provided for @languageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get languageSpanish;

  /// No description provided for @accessStatusPremiumActive.
  ///
  /// In en, this message translates to:
  /// **'Premium active'**
  String get accessStatusPremiumActive;

  /// No description provided for @accessStatusLocked.
  ///
  /// In en, this message translates to:
  /// **'Access locked'**
  String get accessStatusLocked;

  /// No description provided for @accessStatusDaysRemaining.
  ///
  /// In en, this message translates to:
  /// **'{count} d. left'**
  String accessStatusDaysRemaining(int count);

  /// No description provided for @appShellPlannedPayments.
  ///
  /// In en, this message translates to:
  /// **'Recurring payments'**
  String get appShellPlannedPayments;

  /// No description provided for @appShellReminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get appShellReminders;

  /// No description provided for @appShellShoppingLists.
  ///
  /// In en, this message translates to:
  /// **'Shopping lists'**
  String get appShellShoppingLists;

  /// No description provided for @appShellImportCsv.
  ///
  /// In en, this message translates to:
  /// **'Import CSV'**
  String get appShellImportCsv;

  /// No description provided for @appShellExportCsv.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get appShellExportCsv;

  /// No description provided for @overviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overviewTitle;

  /// No description provided for @overviewRangePickHelp.
  ///
  /// In en, this message translates to:
  /// **'Choose a period'**
  String get overviewRangePickHelp;

  /// No description provided for @overviewRangeSave.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get overviewRangeSave;

  /// No description provided for @overviewRangeCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get overviewRangeCancel;

  /// No description provided for @overviewExpenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get overviewExpenses;

  /// No description provided for @overviewIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get overviewIncome;

  /// No description provided for @overviewRangeDay.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get overviewRangeDay;

  /// No description provided for @overviewRangeWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get overviewRangeWeek;

  /// No description provided for @overviewRangeMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get overviewRangeMonth;

  /// No description provided for @overviewRangeYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get overviewRangeYear;

  /// No description provided for @overviewRangePeriod.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get overviewRangePeriod;

  /// No description provided for @overviewTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get overviewTotal;

  /// No description provided for @overviewNoTransactions.
  ///
  /// In en, this message translates to:
  /// **'No transactions for the selected period.'**
  String get overviewNoTransactions;

  /// No description provided for @homeBalanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get homeBalanceTitle;

  /// No description provided for @homeCategoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get homeCategoriesTitle;

  /// No description provided for @searchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchTitle;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by description, category, or tag'**
  String get searchHint;

  /// No description provided for @searchAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get searchAll;

  /// No description provided for @searchFromPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'From: date and time'**
  String get searchFromPlaceholder;

  /// No description provided for @searchFromValue.
  ///
  /// In en, this message translates to:
  /// **'From: {value}'**
  String searchFromValue(Object value);

  /// No description provided for @searchToPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'To: date and time'**
  String get searchToPlaceholder;

  /// No description provided for @searchToValue.
  ///
  /// In en, this message translates to:
  /// **'To: {value}'**
  String searchToValue(Object value);

  /// No description provided for @searchTagsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No tags added yet'**
  String get searchTagsEmpty;

  /// No description provided for @searchNoResults.
  ///
  /// In en, this message translates to:
  /// **'Nothing found'**
  String get searchNoResults;

  /// No description provided for @reportsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reportsTitle;

  /// No description provided for @reportsByCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'By category'**
  String get reportsByCategoryTitle;

  /// No description provided for @reportsByTimeTitle.
  ///
  /// In en, this message translates to:
  /// **'By time'**
  String get reportsByTimeTitle;

  /// No description provided for @reportsCategoryFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get reportsCategoryFood;

  /// No description provided for @reportsCategoryHousing.
  ///
  /// In en, this message translates to:
  /// **'Housing'**
  String get reportsCategoryHousing;

  /// No description provided for @reportsCategoryTransport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get reportsCategoryTransport;

  /// No description provided for @listsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No lists yet'**
  String get listsEmpty;

  /// No description provided for @listsDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete list?'**
  String get listsDeleteTitle;

  /// No description provided for @listsDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this list?'**
  String get listsDeleteMessage;

  /// No description provided for @listsSummaryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No items yet'**
  String get listsSummaryEmpty;

  /// No description provided for @listsSummaryProgress.
  ///
  /// In en, this message translates to:
  /// **'Checked {done} of {total}'**
  String listsSummaryProgress(int done, int total);

  /// No description provided for @listsDefaultTitle.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get listsDefaultTitle;

  /// No description provided for @listsAddTitleOrItemError.
  ///
  /// In en, this message translates to:
  /// **'Add a title or a list item'**
  String get listsAddTitleOrItemError;

  /// No description provided for @listsNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New list'**
  String get listsNewTitle;

  /// No description provided for @listsEditorTitle.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get listsEditorTitle;

  /// No description provided for @listsNameHint.
  ///
  /// In en, this message translates to:
  /// **'List title'**
  String get listsNameHint;

  /// No description provided for @listsItemHint.
  ///
  /// In en, this message translates to:
  /// **'List item'**
  String get listsItemHint;

  /// No description provided for @listsAddItem.
  ///
  /// In en, this message translates to:
  /// **'Add item'**
  String get listsAddItem;

  /// No description provided for @subscriptionPlanYearlyTitle.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get subscriptionPlanYearlyTitle;

  /// No description provided for @subscriptionPlanYearlyFallback.
  ///
  /// In en, this message translates to:
  /// **'\$15 / year'**
  String get subscriptionPlanYearlyFallback;

  /// No description provided for @subscriptionPlanBestBadge.
  ///
  /// In en, this message translates to:
  /// **'Best value'**
  String get subscriptionPlanBestBadge;

  /// No description provided for @subscriptionPlanQuarterlyTitle.
  ///
  /// In en, this message translates to:
  /// **'3 months'**
  String get subscriptionPlanQuarterlyTitle;

  /// No description provided for @subscriptionPlanQuarterlyFallback.
  ///
  /// In en, this message translates to:
  /// **'\$5 / 3 months'**
  String get subscriptionPlanQuarterlyFallback;

  /// No description provided for @subscriptionPlanMonthlyTitle.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get subscriptionPlanMonthlyTitle;

  /// No description provided for @subscriptionPlanMonthlyFallback.
  ///
  /// In en, this message translates to:
  /// **'\$2 / month'**
  String get subscriptionPlanMonthlyFallback;

  /// No description provided for @subscriptionDateNotSet.
  ///
  /// In en, this message translates to:
  /// **'not set'**
  String get subscriptionDateNotSet;

  /// No description provided for @subscriptionHeadlineActive.
  ///
  /// In en, this message translates to:
  /// **'Premium is active'**
  String get subscriptionHeadlineActive;

  /// No description provided for @subscriptionHeadlineTrial.
  ///
  /// In en, this message translates to:
  /// **'The first 30 days include full access'**
  String get subscriptionHeadlineTrial;

  /// No description provided for @subscriptionHeadlineExpired.
  ///
  /// In en, this message translates to:
  /// **'Trial period has ended'**
  String get subscriptionHeadlineExpired;

  /// No description provided for @subscriptionSubheadActive.
  ///
  /// In en, this message translates to:
  /// **'Premium keeps full access to Budgetto after the trial.'**
  String get subscriptionSubheadActive;

  /// No description provided for @subscriptionSubheadTrial.
  ///
  /// In en, this message translates to:
  /// **'{count} d. of full access left before Premium is required.'**
  String subscriptionSubheadTrial(int count);

  /// No description provided for @subscriptionSubheadExpired.
  ///
  /// In en, this message translates to:
  /// **'To keep using Budgetto after the trial, choose a subscription.'**
  String get subscriptionSubheadExpired;

  /// No description provided for @subscriptionUnlimited.
  ///
  /// In en, this message translates to:
  /// **'Unlimited'**
  String get subscriptionUnlimited;

  /// No description provided for @subscriptionUntil.
  ///
  /// In en, this message translates to:
  /// **'Until {date}'**
  String subscriptionUntil(Object date);

  /// No description provided for @subscriptionChipFullAccess.
  ///
  /// In en, this message translates to:
  /// **'Full access'**
  String get subscriptionChipFullAccess;

  /// No description provided for @subscriptionChipPremiumAfterTrial.
  ///
  /// In en, this message translates to:
  /// **'Premium after trial'**
  String get subscriptionChipPremiumAfterTrial;

  /// No description provided for @subscriptionChipSubscriptionRequired.
  ///
  /// In en, this message translates to:
  /// **'Subscription required'**
  String get subscriptionChipSubscriptionRequired;

  /// No description provided for @subscriptionHowItWorksTitle.
  ///
  /// In en, this message translates to:
  /// **'How access works'**
  String get subscriptionHowItWorksTitle;

  /// No description provided for @subscriptionHowItWorksTrial.
  ///
  /// In en, this message translates to:
  /// **'The first 30 days include full access to the entire app.'**
  String get subscriptionHowItWorksTrial;

  /// No description provided for @subscriptionHowItWorksNoSplit.
  ///
  /// In en, this message translates to:
  /// **'During the trial there is no split between basic and Premium features.'**
  String get subscriptionHowItWorksNoSplit;

  /// No description provided for @subscriptionHowItWorksAfterTrial.
  ///
  /// In en, this message translates to:
  /// **'After the trial ends, an active Premium subscription is required to continue using Budgetto.'**
  String get subscriptionHowItWorksAfterTrial;

  /// No description provided for @subscriptionHowItWorksBilling.
  ///
  /// In en, this message translates to:
  /// **'You can choose monthly, quarterly, or yearly billing at any time.'**
  String get subscriptionHowItWorksBilling;

  /// No description provided for @subscriptionStoreUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The payment store is currently unavailable. Try again later.'**
  String get subscriptionStoreUnavailable;

  /// No description provided for @subscriptionRestorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get subscriptionRestorePurchases;

  /// No description provided for @subscriptionRenewalNote.
  ///
  /// In en, this message translates to:
  /// **'The subscription renews automatically until the user cancels it in the App Store or Google Play.'**
  String get subscriptionRenewalNote;

  /// No description provided for @subscriptionPlanActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get subscriptionPlanActive;

  /// No description provided for @transactionsBudgetPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a budget'**
  String get transactionsBudgetPickerTitle;

  /// No description provided for @transactionsPersonalBudgetTitle.
  ///
  /// In en, this message translates to:
  /// **'Personal budget'**
  String get transactionsPersonalBudgetTitle;

  /// No description provided for @transactionsPersonalBudgetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Only for you'**
  String get transactionsPersonalBudgetSubtitle;

  /// No description provided for @transactionsDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete transaction?'**
  String get transactionsDeleteTitle;

  /// No description provided for @transactionsDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this transaction?'**
  String get transactionsDeleteMessage;

  /// No description provided for @transactionsDeleted.
  ///
  /// In en, this message translates to:
  /// **'Transaction deleted'**
  String get transactionsDeleted;

  /// No description provided for @transactionsTextTitle.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get transactionsTextTitle;

  /// No description provided for @transactionsTextHint.
  ///
  /// In en, this message translates to:
  /// **'Description, category, tag, or amount'**
  String get transactionsTextHint;

  /// No description provided for @transactionsTypeTitle.
  ///
  /// In en, this message translates to:
  /// **'Transaction type'**
  String get transactionsTypeTitle;

  /// No description provided for @transactionsTypeAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get transactionsTypeAll;

  /// No description provided for @transactionsTypeExpenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get transactionsTypeExpenses;

  /// No description provided for @transactionsTypeIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get transactionsTypeIncome;

  /// No description provided for @transactionsPeriodTitle.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get transactionsPeriodTitle;

  /// No description provided for @transactionsQuickLastMonth.
  ///
  /// In en, this message translates to:
  /// **'Last month'**
  String get transactionsQuickLastMonth;

  /// No description provided for @transactionsQuickQuarter.
  ///
  /// In en, this message translates to:
  /// **'Quarter'**
  String get transactionsQuickQuarter;

  /// No description provided for @transactionsQuickYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get transactionsQuickYear;

  /// No description provided for @transactionsSelectMonth.
  ///
  /// In en, this message translates to:
  /// **'Select month'**
  String get transactionsSelectMonth;

  /// No description provided for @transactionsFrom.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get transactionsFrom;

  /// No description provided for @transactionsTo.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get transactionsTo;

  /// No description provided for @transactionsChooseDate.
  ///
  /// In en, this message translates to:
  /// **'Choose a date'**
  String get transactionsChooseDate;

  /// No description provided for @transactionsCategoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get transactionsCategoriesTitle;

  /// No description provided for @transactionsTagsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get transactionsTagsTitle;

  /// No description provided for @transactionsTagsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No tags added yet'**
  String get transactionsTagsEmpty;

  /// No description provided for @transactionsMethodsTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment methods'**
  String get transactionsMethodsTitle;

  /// No description provided for @transactionsDisplayTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get transactionsDisplayTotal;

  /// No description provided for @transactionsDisplayByDate.
  ///
  /// In en, this message translates to:
  /// **'By date'**
  String get transactionsDisplayByDate;

  /// No description provided for @transactionsDisplayCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get transactionsDisplayCategories;

  /// No description provided for @transactionsDisplayPayment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get transactionsDisplayPayment;

  /// No description provided for @transactionsDisplayTags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get transactionsDisplayTags;

  /// No description provided for @transactionsDisplayAuthor.
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get transactionsDisplayAuthor;

  /// No description provided for @transactionsFamilyBudgetFallback.
  ///
  /// In en, this message translates to:
  /// **'Shared budget'**
  String get transactionsFamilyBudgetFallback;

  /// No description provided for @transactionsNothingFound.
  ///
  /// In en, this message translates to:
  /// **'Nothing found'**
  String get transactionsNothingFound;

  /// No description provided for @transactionsNoTransactions.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get transactionsNoTransactions;

  /// No description provided for @transactionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactionsTitle;

  /// No description provided for @transactionTypeExpense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get transactionTypeExpense;

  /// No description provided for @transactionTypeIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get transactionTypeIncome;

  /// No description provided for @formAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get formAmountLabel;

  /// No description provided for @formDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get formDescriptionLabel;

  /// No description provided for @formPaymentLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get formPaymentLabel;

  /// No description provided for @formCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get formCategoryLabel;

  /// No description provided for @formTagsLabel.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get formTagsLabel;

  /// No description provided for @formTagsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No tags added yet'**
  String get formTagsEmpty;

  /// No description provided for @formChooseCategoryError.
  ///
  /// In en, this message translates to:
  /// **'Choose a category'**
  String get formChooseCategoryError;

  /// No description provided for @formChoosePaymentError.
  ///
  /// In en, this message translates to:
  /// **'Choose a payment method'**
  String get formChoosePaymentError;

  /// No description provided for @formAmountPositiveError.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount greater than 0'**
  String get formAmountPositiveError;

  /// No description provided for @addTransactionNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New {type}'**
  String addTransactionNewTitle(Object type);

  /// No description provided for @addTransactionEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit transaction'**
  String get addTransactionEditTitle;

  /// No description provided for @addTransactionDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'For example, coffee and snack'**
  String get addTransactionDescriptionHint;

  /// No description provided for @plannedTitle.
  ///
  /// In en, this message translates to:
  /// **'Recurring payments'**
  String get plannedTitle;

  /// No description provided for @plannedEmpty.
  ///
  /// In en, this message translates to:
  /// **'No recurring payments yet'**
  String get plannedEmpty;

  /// No description provided for @plannedDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete entry?'**
  String get plannedDeleteTitle;

  /// No description provided for @plannedDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this entry?'**
  String get plannedDeleteMessage;

  /// No description provided for @plannedDeleted.
  ///
  /// In en, this message translates to:
  /// **'Payment deleted'**
  String get plannedDeleted;

  /// No description provided for @plannedAddToTransactionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Add to transactions?'**
  String get plannedAddToTransactionsTitle;

  /// No description provided for @plannedAddToTransactionsMessage.
  ///
  /// In en, this message translates to:
  /// **'Create a transaction from \"{description}\" for {amount}?'**
  String plannedAddToTransactionsMessage(Object description, Object amount);

  /// No description provided for @plannedAddedToTransactions.
  ///
  /// In en, this message translates to:
  /// **'Added to transactions'**
  String get plannedAddedToTransactions;

  /// No description provided for @plannedActionAddToTransactions.
  ///
  /// In en, this message translates to:
  /// **'Add to transactions'**
  String get plannedActionAddToTransactions;

  /// No description provided for @plannedScheduledReminder.
  ///
  /// In en, this message translates to:
  /// **'Reminder: {date}'**
  String plannedScheduledReminder(Object date);

  /// No description provided for @plannedScheduledDate.
  ///
  /// In en, this message translates to:
  /// **'Date: {date}'**
  String plannedScheduledDate(Object date);

  /// No description provided for @plannedAddToTransactionsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add to transactions'**
  String get plannedAddToTransactionsTooltip;

  /// No description provided for @plannedNotificationsPermissionError.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications in device settings'**
  String get plannedNotificationsPermissionError;

  /// No description provided for @plannedChooseDateTimeError.
  ///
  /// In en, this message translates to:
  /// **'Choose a date and time'**
  String get plannedChooseDateTimeError;

  /// No description provided for @plannedChooseFutureTimeError.
  ///
  /// In en, this message translates to:
  /// **'Choose a time in the future'**
  String get plannedChooseFutureTimeError;

  /// No description provided for @plannedNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New recurring entry'**
  String get plannedNewTitle;

  /// No description provided for @plannedEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit entry'**
  String get plannedEditTitle;

  /// No description provided for @plannedDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'For example, utilities'**
  String get plannedDescriptionHint;

  /// No description provided for @plannedWhenLabel.
  ///
  /// In en, this message translates to:
  /// **'When'**
  String get plannedWhenLabel;

  /// No description provided for @plannedChooseDateTime.
  ///
  /// In en, this message translates to:
  /// **'Choose date and time'**
  String get plannedChooseDateTime;

  /// No description provided for @plannedRemindLabel.
  ///
  /// In en, this message translates to:
  /// **'Remind me'**
  String get plannedRemindLabel;

  /// No description provided for @remindersTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get remindersTitle;

  /// No description provided for @remindersEmpty.
  ///
  /// In en, this message translates to:
  /// **'No reminders yet'**
  String get remindersEmpty;

  /// No description provided for @remindersDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete reminder?'**
  String get remindersDeleteTitle;

  /// No description provided for @remindersDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this reminder?'**
  String get remindersDeleteMessage;

  /// No description provided for @remindersPermissionError.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications in device settings'**
  String get remindersPermissionError;

  /// No description provided for @remindersNewTitle.
  ///
  /// In en, this message translates to:
  /// **'Create reminder'**
  String get remindersNewTitle;

  /// No description provided for @remindersEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit reminder'**
  String get remindersEditTitle;

  /// No description provided for @remindersNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Reminder name'**
  String get remindersNameLabel;

  /// No description provided for @remindersNameHint.
  ///
  /// In en, this message translates to:
  /// **'For example, rent payment'**
  String get remindersNameHint;

  /// No description provided for @remindersNameRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get remindersNameRequired;

  /// No description provided for @remindersFrequencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get remindersFrequencyLabel;

  /// No description provided for @remindersStartDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get remindersStartDateLabel;

  /// No description provided for @remindersTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get remindersTimeLabel;

  /// No description provided for @remindersCommentLabel.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get remindersCommentLabel;

  /// No description provided for @remindersCommentHint.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get remindersCommentHint;

  /// No description provided for @remindersChooseFutureTimeError.
  ///
  /// In en, this message translates to:
  /// **'Choose a time in the future'**
  String get remindersChooseFutureTimeError;

  /// No description provided for @reminderFrequencyOnce.
  ///
  /// In en, this message translates to:
  /// **'Once'**
  String get reminderFrequencyOnce;

  /// No description provided for @reminderFrequencyDaily.
  ///
  /// In en, this message translates to:
  /// **'Every day'**
  String get reminderFrequencyDaily;

  /// No description provided for @reminderFrequencyWeekly.
  ///
  /// In en, this message translates to:
  /// **'Every week'**
  String get reminderFrequencyWeekly;

  /// No description provided for @reminderFrequencyBiweekly.
  ///
  /// In en, this message translates to:
  /// **'Every 2 weeks'**
  String get reminderFrequencyBiweekly;

  /// No description provided for @reminderFrequencyFourWeeks.
  ///
  /// In en, this message translates to:
  /// **'Every 4 weeks'**
  String get reminderFrequencyFourWeeks;

  /// No description provided for @reminderFrequencyMonthly.
  ///
  /// In en, this message translates to:
  /// **'Every month'**
  String get reminderFrequencyMonthly;

  /// No description provided for @reminderFrequencyEveryTwoMonths.
  ///
  /// In en, this message translates to:
  /// **'Every 2 months'**
  String get reminderFrequencyEveryTwoMonths;

  /// No description provided for @reminderFrequencyQuarterly.
  ///
  /// In en, this message translates to:
  /// **'Every quarter'**
  String get reminderFrequencyQuarterly;

  /// No description provided for @reminderFrequencyHalfYear.
  ///
  /// In en, this message translates to:
  /// **'Every half year'**
  String get reminderFrequencyHalfYear;

  /// No description provided for @reminderFrequencyYearly.
  ///
  /// In en, this message translates to:
  /// **'Every year'**
  String get reminderFrequencyYearly;

  /// No description provided for @dataExportNoTransactions.
  ///
  /// In en, this message translates to:
  /// **'No transactions to export'**
  String get dataExportNoTransactions;

  /// No description provided for @dataExportMonthLimitMessage.
  ///
  /// In en, this message translates to:
  /// **'{month} has {count} transactions. Export limit: {limit} rows.'**
  String dataExportMonthLimitMessage(Object month, int count, int limit);

  /// No description provided for @dataExportNoTransactionsForMonth.
  ///
  /// In en, this message translates to:
  /// **'No transactions for the selected month'**
  String get dataExportNoTransactionsForMonth;

  /// No description provided for @dataExportColumnDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dataExportColumnDate;

  /// No description provided for @dataExportColumnAuthor.
  ///
  /// In en, this message translates to:
  /// **'Who'**
  String get dataExportColumnAuthor;

  /// No description provided for @dataExportColumnMethod.
  ///
  /// In en, this message translates to:
  /// **'Method'**
  String get dataExportColumnMethod;

  /// No description provided for @dataExportColumnCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get dataExportColumnCategory;

  /// No description provided for @dataExportColumnDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get dataExportColumnDescription;

  /// No description provided for @dataExportColumnType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get dataExportColumnType;

  /// No description provided for @dataExportColumnAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get dataExportColumnAmount;

  /// No description provided for @dataExportSavedOnDevice.
  ///
  /// In en, this message translates to:
  /// **'Export is available on a physical device. File saved: {path}'**
  String dataExportSavedOnDevice(Object path);

  /// No description provided for @dataExportShareText.
  ///
  /// In en, this message translates to:
  /// **'Budgetto transaction export for {month}'**
  String dataExportShareText(Object month);

  /// No description provided for @dataExportFileSaved.
  ///
  /// In en, this message translates to:
  /// **'File saved: {path}'**
  String dataExportFileSaved(Object path);

  /// No description provided for @dataExportPickMonthTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a month to export'**
  String get dataExportPickMonthTitle;

  /// No description provided for @dataExportPickMonthDescription.
  ///
  /// In en, this message translates to:
  /// **'Exports only one month. Maximum {limit} rows.'**
  String dataExportPickMonthDescription(int limit);

  /// No description provided for @dataExportSelectMonthLabel.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get dataExportSelectMonthLabel;

  /// No description provided for @dataExportExportAction.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get dataExportExportAction;

  /// No description provided for @dataExportNoAvailableMonths.
  ///
  /// In en, this message translates to:
  /// **'No months are currently available for export'**
  String get dataExportNoAvailableMonths;

  /// No description provided for @dataExportMonthCountExceeded.
  ///
  /// In en, this message translates to:
  /// **'{count} transactions, exceeds limit'**
  String dataExportMonthCountExceeded(int count);

  /// No description provided for @dataExportMonthCount.
  ///
  /// In en, this message translates to:
  /// **'{count} transactions'**
  String dataExportMonthCount(int count);

  /// No description provided for @dataExportMonthsLimited.
  ///
  /// In en, this message translates to:
  /// **'Months with more than {limit} transactions are unavailable for export.'**
  String dataExportMonthsLimited(int limit);

  /// No description provided for @paymentMethodCashLabel.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get paymentMethodCashLabel;

  /// No description provided for @paymentMethodCardLabel.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get paymentMethodCardLabel;

  /// No description provided for @currencyNameUsd.
  ///
  /// In en, this message translates to:
  /// **'US Dollar'**
  String get currencyNameUsd;

  /// No description provided for @currencyNameEur.
  ///
  /// In en, this message translates to:
  /// **'Euro'**
  String get currencyNameEur;

  /// No description provided for @currencyNameGbp.
  ///
  /// In en, this message translates to:
  /// **'British Pound'**
  String get currencyNameGbp;

  /// No description provided for @currencyNameUah.
  ///
  /// In en, this message translates to:
  /// **'Ukrainian Hryvnia'**
  String get currencyNameUah;

  /// No description provided for @currencyNameJpy.
  ///
  /// In en, this message translates to:
  /// **'Japanese Yen'**
  String get currencyNameJpy;

  /// No description provided for @currencyNameRub.
  ///
  /// In en, this message translates to:
  /// **'Russian Ruble'**
  String get currencyNameRub;

  /// No description provided for @syncSettingsGoogleConnected.
  ///
  /// In en, this message translates to:
  /// **'Google connected'**
  String get syncSettingsGoogleConnected;

  /// No description provided for @syncSettingsSignInCanceled.
  ///
  /// In en, this message translates to:
  /// **'Sign-in canceled'**
  String get syncSettingsSignInCanceled;

  /// No description provided for @syncSettingsGoogleConnectFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to connect Google'**
  String get syncSettingsGoogleConnectFailed;

  /// No description provided for @syncSettingsStatusEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get syncSettingsStatusEnabled;

  /// No description provided for @syncSettingsStatusDisabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get syncSettingsStatusDisabled;

  /// No description provided for @syncSettingsGuest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get syncSettingsGuest;

  /// No description provided for @syncSettingsAccountSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get syncSettingsAccountSectionTitle;

  /// No description provided for @syncSettingsStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get syncSettingsStatusLabel;

  /// No description provided for @syncSettingsGoogleSignInButton.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get syncSettingsGoogleSignInButton;

  /// No description provided for @syncSettingsGoogleDescription.
  ///
  /// In en, this message translates to:
  /// **'Connect Google to move your progress between devices.'**
  String get syncSettingsGoogleDescription;

  /// No description provided for @syncSettingsStatusSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get syncSettingsStatusSectionTitle;

  /// No description provided for @syncSettingsDataStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Data sync'**
  String get syncSettingsDataStatusLabel;

  /// No description provided for @syncSettingsCloudDescription.
  ///
  /// In en, this message translates to:
  /// **'Sync keeps your data in the cloud and enables a shared budget.'**
  String get syncSettingsCloudDescription;

  /// No description provided for @settingsDataFileReadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to read the selected file.'**
  String get settingsDataFileReadFailed;

  /// No description provided for @settingsDataImportFailed.
  ///
  /// In en, this message translates to:
  /// **'Import failed: {error}'**
  String settingsDataImportFailed(Object error);

  /// No description provided for @settingsDataErrorsTitle.
  ///
  /// In en, this message translates to:
  /// **'Fix CSV errors'**
  String get settingsDataErrorsTitle;

  /// No description provided for @settingsDataValidationFailedNoName.
  ///
  /// In en, this message translates to:
  /// **'The file did not pass validation.'**
  String get settingsDataValidationFailedNoName;

  /// No description provided for @settingsDataValidationFailedWithName.
  ///
  /// In en, this message translates to:
  /// **'The file \"{fileName}\" did not pass validation.'**
  String settingsDataValidationFailedWithName(Object fileName);

  /// No description provided for @settingsDataUnderstoodButton.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get settingsDataUnderstoodButton;

  /// No description provided for @settingsDataConfirmImportTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm import'**
  String get settingsDataConfirmImportTitle;

  /// No description provided for @settingsDataFileLabel.
  ///
  /// In en, this message translates to:
  /// **'File: {fileName}'**
  String settingsDataFileLabel(Object fileName);

  /// No description provided for @settingsDataWillAddCount.
  ///
  /// In en, this message translates to:
  /// **'Entries to add: {count}'**
  String settingsDataWillAddCount(int count);

  /// No description provided for @settingsDataNewCategories.
  ///
  /// In en, this message translates to:
  /// **'New categories'**
  String get settingsDataNewCategories;

  /// No description provided for @settingsDataNewPaymentMethods.
  ///
  /// In en, this message translates to:
  /// **'New payment methods'**
  String get settingsDataNewPaymentMethods;

  /// No description provided for @settingsDataNewTags.
  ///
  /// In en, this message translates to:
  /// **'New tags'**
  String get settingsDataNewTags;

  /// No description provided for @settingsDataImportConfirmHint.
  ///
  /// In en, this message translates to:
  /// **'New categories, payment methods, tags, and entries will be added only after you press \"Import\".'**
  String get settingsDataImportConfirmHint;

  /// No description provided for @settingsDataImportTagHint.
  ///
  /// In en, this message translates to:
  /// **'All imported entries will also receive a system import tag so you can filter and remove them quickly.'**
  String get settingsDataImportTagHint;

  /// No description provided for @settingsDataCancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get settingsDataCancelButton;

  /// No description provided for @settingsDataImportAction.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get settingsDataImportAction;

  /// No description provided for @settingsDataImportedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Imported {count} entries. Tag: {tag}.'**
  String settingsDataImportedSuccess(int count, Object tag);

  /// No description provided for @settingsDataImportCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Import expenses from CSV'**
  String get settingsDataImportCardTitle;

  /// No description provided for @settingsDataSampleTitle.
  ///
  /// In en, this message translates to:
  /// **'Sample data'**
  String get settingsDataSampleTitle;

  /// No description provided for @settingsDataCheckingCsv.
  ///
  /// In en, this message translates to:
  /// **'Checking CSV...'**
  String get settingsDataCheckingCsv;

  /// No description provided for @settingsDataChooseCsv.
  ///
  /// In en, this message translates to:
  /// **'Choose CSV and validate'**
  String get settingsDataChooseCsv;

  /// No description provided for @transactionImportErrorEmptyFile.
  ///
  /// In en, this message translates to:
  /// **'The file is empty. Add headers and data rows.'**
  String get transactionImportErrorEmptyFile;

  /// No description provided for @transactionImportErrorUnclosedQuote.
  ///
  /// In en, this message translates to:
  /// **'The CSV contains an unclosed quote. Check the file and try again.'**
  String get transactionImportErrorUnclosedQuote;

  /// No description provided for @transactionImportErrorReadRows.
  ///
  /// In en, this message translates to:
  /// **'Failed to read CSV rows.'**
  String get transactionImportErrorReadRows;

  /// No description provided for @transactionImportMissingRequiredColumn.
  ///
  /// In en, this message translates to:
  /// **'Required column \"{column}\" was not found. Use the template from the instructions.'**
  String transactionImportMissingRequiredColumn(Object column);

  /// No description provided for @transactionImportErrorNoDataRows.
  ///
  /// In en, this message translates to:
  /// **'The file has no transaction rows. Add at least one entry.'**
  String get transactionImportErrorNoDataRows;

  /// No description provided for @transactionImportErrorRowLimit.
  ///
  /// In en, this message translates to:
  /// **'The file has {count} rows, but the current import limit is {limit}.'**
  String transactionImportErrorRowLimit(int count, int limit);

  /// No description provided for @transactionImportErrorInvalidDate.
  ///
  /// In en, this message translates to:
  /// **'Could not recognize the date \"{value}\". Use a date with time, for example 2026-02-05 00:53. Seconds are optional and will be ignored.'**
  String transactionImportErrorInvalidDate(Object value);

  /// No description provided for @transactionImportErrorInvalidType.
  ///
  /// In en, this message translates to:
  /// **'The transaction type field is invalid. Use \"{expense}\" or \"{income}\".'**
  String transactionImportErrorInvalidType(Object expense, Object income);

  /// No description provided for @transactionImportErrorOperationRequired.
  ///
  /// In en, this message translates to:
  /// **'The operation field must not be empty.'**
  String get transactionImportErrorOperationRequired;

  /// No description provided for @transactionImportErrorInvalidAmount.
  ///
  /// In en, this message translates to:
  /// **'The amount field must be a number greater than 0. Current value: \"{value}\".'**
  String transactionImportErrorInvalidAmount(Object value);

  /// No description provided for @transactionImportErrorCategoryRequired.
  ///
  /// In en, this message translates to:
  /// **'The category field must not be empty.'**
  String get transactionImportErrorCategoryRequired;

  /// No description provided for @transactionImportErrorPaymentMethodRequired.
  ///
  /// In en, this message translates to:
  /// **'The payment method field must not be empty.'**
  String get transactionImportErrorPaymentMethodRequired;

  /// No description provided for @transactionImportInstructionPrepareTitle.
  ///
  /// In en, this message translates to:
  /// **'Prepare the file'**
  String get transactionImportInstructionPrepareTitle;

  /// No description provided for @transactionImportInstructionFormat.
  ///
  /// In en, this message translates to:
  /// **'File format: CSV.'**
  String get transactionImportInstructionFormat;

  /// No description provided for @transactionImportInstructionEncoding.
  ///
  /// In en, this message translates to:
  /// **'File encoding: UTF-8.'**
  String get transactionImportInstructionEncoding;

  /// No description provided for @transactionImportInstructionHeaderRow.
  ///
  /// In en, this message translates to:
  /// **'First row of the file: {headers}.'**
  String transactionImportInstructionHeaderRow(Object headers);

  /// No description provided for @transactionImportInstructionDelimiter.
  ///
  /// In en, this message translates to:
  /// **'Delimiter: ;'**
  String get transactionImportInstructionDelimiter;

  /// No description provided for @transactionImportInstructionMaxRows.
  ///
  /// In en, this message translates to:
  /// **'Maximum: {limit} data rows without the header.'**
  String transactionImportInstructionMaxRows(int limit);

  /// No description provided for @transactionImportInstructionColumnsTitle.
  ///
  /// In en, this message translates to:
  /// **'Fill the columns in the first row'**
  String get transactionImportInstructionColumnsTitle;

  /// No description provided for @transactionImportInstructionDateColumn.
  ///
  /// In en, this message translates to:
  /// **'{column}: the transaction date and time. Recommended format: YYYY-MM-DD HH:mm. The import also accepts values like 05.02.2026 0:53:29 and ignores seconds.'**
  String transactionImportInstructionDateColumn(Object column);

  /// No description provided for @transactionImportInstructionTypeColumn.
  ///
  /// In en, this message translates to:
  /// **'{column}: use the value {expense} or {income}.'**
  String transactionImportInstructionTypeColumn(
    Object column,
    Object expense,
    Object income,
  );

  /// No description provided for @transactionImportInstructionOperationColumn.
  ///
  /// In en, this message translates to:
  /// **'{column}: transaction text. Example: {example}.'**
  String transactionImportInstructionOperationColumn(
    Object column,
    Object example,
  );

  /// No description provided for @transactionImportInstructionAmountColumn.
  ///
  /// In en, this message translates to:
  /// **'{column}: a number greater than 0 in the format 12.50.'**
  String transactionImportInstructionAmountColumn(Object column);

  /// No description provided for @transactionImportInstructionCategoryColumn.
  ///
  /// In en, this message translates to:
  /// **'{column}: category name. If it does not exist yet, it will be created after confirmation.'**
  String transactionImportInstructionCategoryColumn(Object column);

  /// No description provided for @transactionImportInstructionPaymentMethodColumn.
  ///
  /// In en, this message translates to:
  /// **'{column}: payment method name. This field cannot be empty. If it does not exist yet, it will be created after confirmation.'**
  String transactionImportInstructionPaymentMethodColumn(Object column);

  /// No description provided for @transactionImportInstructionTagsColumn.
  ///
  /// In en, this message translates to:
  /// **'{column}: a comma-separated list of tags. This field may be empty. Missing tags will be created after confirmation.'**
  String transactionImportInstructionTagsColumn(Object column);

  /// No description provided for @transactionImportInstructionReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Review changes before import'**
  String get transactionImportInstructionReviewTitle;

  /// No description provided for @transactionImportInstructionReviewItemOne.
  ///
  /// In en, this message translates to:
  /// **'Before import, the app will show new categories, payment methods, and tags.'**
  String get transactionImportInstructionReviewItemOne;

  /// No description provided for @transactionImportInstructionReviewItemTwo.
  ///
  /// In en, this message translates to:
  /// **'New items and entries will be added only after you press the Import button.'**
  String get transactionImportInstructionReviewItemTwo;

  /// No description provided for @transactionImportInstructionReviewItemThree.
  ///
  /// In en, this message translates to:
  /// **'Each imported entry will receive a system tag in the format import_YYYYMMDD_HHMMSS.'**
  String get transactionImportInstructionReviewItemThree;

  /// No description provided for @transactionImportColumnDate.
  ///
  /// In en, this message translates to:
  /// **'date'**
  String get transactionImportColumnDate;

  /// No description provided for @transactionImportColumnType.
  ///
  /// In en, this message translates to:
  /// **'transaction type'**
  String get transactionImportColumnType;

  /// No description provided for @transactionImportColumnOperation.
  ///
  /// In en, this message translates to:
  /// **'operation'**
  String get transactionImportColumnOperation;

  /// No description provided for @transactionImportColumnAmount.
  ///
  /// In en, this message translates to:
  /// **'amount'**
  String get transactionImportColumnAmount;

  /// No description provided for @transactionImportColumnCategory.
  ///
  /// In en, this message translates to:
  /// **'category'**
  String get transactionImportColumnCategory;

  /// No description provided for @transactionImportColumnPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'payment method'**
  String get transactionImportColumnPaymentMethod;

  /// No description provided for @transactionImportColumnTags.
  ///
  /// In en, this message translates to:
  /// **'tags'**
  String get transactionImportColumnTags;

  /// No description provided for @transactionImportLineMessage.
  ///
  /// In en, this message translates to:
  /// **'Line {lineNumber}: {message}'**
  String transactionImportLineMessage(int lineNumber, Object message);

  /// No description provided for @transactionImportSampleOperationOne.
  ///
  /// In en, this message translates to:
  /// **'Theater tickets'**
  String get transactionImportSampleOperationOne;

  /// No description provided for @transactionImportSampleOperationTwo.
  ///
  /// In en, this message translates to:
  /// **'Taxi home'**
  String get transactionImportSampleOperationTwo;

  /// No description provided for @transactionImportSampleCategoryOne.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get transactionImportSampleCategoryOne;

  /// No description provided for @transactionImportSampleCategoryTwo.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get transactionImportSampleCategoryTwo;

  /// No description provided for @transactionImportSamplePaymentMethodOne.
  ///
  /// In en, this message translates to:
  /// **'Main card'**
  String get transactionImportSamplePaymentMethodOne;

  /// No description provided for @transactionImportSamplePaymentMethodTwo.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get transactionImportSamplePaymentMethodTwo;

  /// No description provided for @transactionImportSampleTagsOne.
  ///
  /// In en, this message translates to:
  /// **'Theater,Evening'**
  String get transactionImportSampleTagsOne;

  /// No description provided for @notificationChannelPlannedName.
  ///
  /// In en, this message translates to:
  /// **'Recurring entries'**
  String get notificationChannelPlannedName;

  /// No description provided for @notificationChannelPlannedDescription.
  ///
  /// In en, this message translates to:
  /// **'Reminders about recurring entries'**
  String get notificationChannelPlannedDescription;

  /// No description provided for @notificationChannelReminderName.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get notificationChannelReminderName;

  /// No description provided for @notificationChannelReminderDescription.
  ///
  /// In en, this message translates to:
  /// **'Reminders about important tasks'**
  String get notificationChannelReminderDescription;

  /// No description provided for @notificationChannelFamilyName.
  ///
  /// In en, this message translates to:
  /// **'Family spending'**
  String get notificationChannelFamilyName;

  /// No description provided for @notificationChannelFamilyDescription.
  ///
  /// In en, this message translates to:
  /// **'Notifications about new expenses in the family budget'**
  String get notificationChannelFamilyDescription;

  /// No description provided for @editorColorPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a color'**
  String get editorColorPickerTitle;

  /// No description provided for @editorIconColorLabel.
  ///
  /// In en, this message translates to:
  /// **'Icon color'**
  String get editorIconColorLabel;

  /// No description provided for @editorIconLabel.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get editorIconLabel;

  /// No description provided for @cardsTitle.
  ///
  /// In en, this message translates to:
  /// **'Cards'**
  String get cardsTitle;

  /// No description provided for @cardsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No cards yet'**
  String get cardsEmpty;

  /// No description provided for @cardsDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete card?'**
  String get cardsDeleteTitle;

  /// No description provided for @cardsDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this card?'**
  String get cardsDeleteMessage;

  /// No description provided for @cardsDeleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Card deleted'**
  String get cardsDeleteSuccess;

  /// No description provided for @cardsNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New card'**
  String get cardsNewTitle;

  /// No description provided for @cardsEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit card'**
  String get cardsEditTitle;

  /// No description provided for @cardsNameHint.
  ///
  /// In en, this message translates to:
  /// **'For example, Sergey WISE'**
  String get cardsNameHint;

  /// No description provided for @tagsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No tags yet'**
  String get tagsEmpty;

  /// No description provided for @tagsDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete tag?'**
  String get tagsDeleteTitle;

  /// No description provided for @tagsDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this tag?'**
  String get tagsDeleteMessage;

  /// No description provided for @tagsDeleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Tag deleted'**
  String get tagsDeleteSuccess;

  /// No description provided for @tagsNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New tag'**
  String get tagsNewTitle;

  /// No description provided for @tagsEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit tag'**
  String get tagsEditTitle;

  /// No description provided for @tagsNameHint.
  ///
  /// In en, this message translates to:
  /// **'For example, Work'**
  String get tagsNameHint;

  /// No description provided for @categoriesDeleteBlockedTitle.
  ///
  /// In en, this message translates to:
  /// **'Cannot delete category'**
  String get categoriesDeleteBlockedTitle;

  /// No description provided for @categoriesDeleteBlockedMessage.
  ///
  /// In en, this message translates to:
  /// **'This category is already in use. Create another category first so you can move the entries there.'**
  String get categoriesDeleteBlockedMessage;

  /// No description provided for @categoriesDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete category?'**
  String get categoriesDeleteTitle;

  /// No description provided for @categoriesDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this category?'**
  String get categoriesDeleteMessage;

  /// No description provided for @categoriesDeleteUsedMessage.
  ///
  /// In en, this message translates to:
  /// **'This category is used in {transactions} transactions and {planned} planned entries.'**
  String categoriesDeleteUsedMessage(int transactions, int planned);

  /// No description provided for @categoriesDeleteReplacementHint.
  ///
  /// In en, this message translates to:
  /// **'Before deleting, choose the category that should receive these entries.'**
  String get categoriesDeleteReplacementHint;

  /// No description provided for @categoriesReplacementLabel.
  ///
  /// In en, this message translates to:
  /// **'New category'**
  String get categoriesReplacementLabel;

  /// No description provided for @categoriesDeleteMovedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Category deleted, entries moved to \"{name}\".'**
  String categoriesDeleteMovedSuccess(Object name);

  /// No description provided for @categoriesDeleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Category deleted'**
  String get categoriesDeleteSuccess;

  /// No description provided for @categoriesNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New category'**
  String get categoriesNewTitle;

  /// No description provided for @categoriesEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit category'**
  String get categoriesEditTitle;

  /// No description provided for @categoriesNameHint.
  ///
  /// In en, this message translates to:
  /// **'For example, Sports'**
  String get categoriesNameHint;

  /// No description provided for @budgetsReservedSelfName.
  ///
  /// In en, this message translates to:
  /// **'i'**
  String get budgetsReservedSelfName;

  /// No description provided for @budgetsNotificationsPermissionError.
  ///
  /// In en, this message translates to:
  /// **'Allow push notifications in device settings'**
  String get budgetsNotificationsPermissionError;

  /// No description provided for @budgetsCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Add shared budget'**
  String get budgetsCreateTitle;

  /// No description provided for @budgetsNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get budgetsNameLabel;

  /// No description provided for @budgetsNameHint.
  ///
  /// In en, this message translates to:
  /// **'Budget name'**
  String get budgetsNameHint;

  /// No description provided for @budgetsMemberNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get budgetsMemberNameLabel;

  /// No description provided for @budgetsMemberNameHint.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get budgetsMemberNameHint;

  /// No description provided for @budgetsJoinTitle.
  ///
  /// In en, this message translates to:
  /// **'Join by code'**
  String get budgetsJoinTitle;

  /// No description provided for @budgetsCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Budget code'**
  String get budgetsCodeLabel;

  /// No description provided for @budgetsCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Budget code'**
  String get budgetsCodeHint;

  /// No description provided for @budgetsCodeNotFound.
  ///
  /// In en, this message translates to:
  /// **'Code not found'**
  String get budgetsCodeNotFound;

  /// No description provided for @budgetsJoinAction.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get budgetsJoinAction;

  /// No description provided for @budgetsLeaveTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave shared budget?'**
  String get budgetsLeaveTitle;

  /// No description provided for @budgetsLeaveMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to leave?'**
  String get budgetsLeaveMessage;

  /// No description provided for @budgetsLeaveAction.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get budgetsLeaveAction;

  /// No description provided for @budgetsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Your budgets'**
  String get budgetsSectionTitle;

  /// No description provided for @budgetsPersonalTitle.
  ///
  /// In en, this message translates to:
  /// **'Personal budget'**
  String get budgetsPersonalTitle;

  /// No description provided for @budgetsPersonalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Only for you'**
  String get budgetsPersonalSubtitle;

  /// No description provided for @budgetsSettingsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Shared budget settings'**
  String get budgetsSettingsSectionTitle;

  /// No description provided for @budgetsSavedChanges.
  ///
  /// In en, this message translates to:
  /// **'Changes saved'**
  String get budgetsSavedChanges;

  /// No description provided for @budgetsCodeCopied.
  ///
  /// In en, this message translates to:
  /// **'Code copied'**
  String get budgetsCodeCopied;

  /// No description provided for @budgetsCopyCodeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Copy code'**
  String get budgetsCopyCodeTooltip;

  /// No description provided for @budgetsPersonalSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Personal settings in this budget'**
  String get budgetsPersonalSettingsTitle;

  /// No description provided for @budgetsNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notify me about new expenses'**
  String get budgetsNotificationsTitle;

  /// No description provided for @budgetsNotificationsDescription.
  ///
  /// In en, this message translates to:
  /// **'A push notification will arrive when someone from the family adds a new expense to this budget.'**
  String get budgetsNotificationsDescription;

  /// No description provided for @budgetsNotificationsPerUserHint.
  ///
  /// In en, this message translates to:
  /// **'This toggle works separately for each participant.'**
  String get budgetsNotificationsPerUserHint;

  /// No description provided for @budgetsMembersTitle.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get budgetsMembersTitle;

  /// No description provided for @budgetsLeaveButton.
  ///
  /// In en, this message translates to:
  /// **'Leave shared budget'**
  String get budgetsLeaveButton;

  /// No description provided for @appStateSharedBudgetName.
  ///
  /// In en, this message translates to:
  /// **'Shared budget'**
  String get appStateSharedBudgetName;

  /// No description provided for @appStatePersonalBudgetName.
  ///
  /// In en, this message translates to:
  /// **'Personal budget'**
  String get appStatePersonalBudgetName;

  /// No description provided for @appStateCashMethodName.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get appStateCashMethodName;

  /// No description provided for @appStateUnknownUserName.
  ///
  /// In en, this message translates to:
  /// **'No name'**
  String get appStateUnknownUserName;

  /// No description provided for @appStatePlannedNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Recurring entry'**
  String get appStatePlannedNotificationTitle;

  /// No description provided for @appStateFamilyTransactionTitle.
  ///
  /// In en, this message translates to:
  /// **'New family expense'**
  String get appStateFamilyTransactionTitle;

  /// No description provided for @appStateFamilyTransactionBody.
  ///
  /// In en, this message translates to:
  /// **'A new expense appeared in the family budget'**
  String get appStateFamilyTransactionBody;

  /// No description provided for @appStateBillingUpdateError.
  ///
  /// In en, this message translates to:
  /// **'Failed to update purchase status'**
  String get appStateBillingUpdateError;

  /// No description provided for @appStateBillingConnectError.
  ///
  /// In en, this message translates to:
  /// **'Failed to connect to the store'**
  String get appStateBillingConnectError;

  /// No description provided for @appStateBillingProductUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This plan is not available in the store yet'**
  String get appStateBillingProductUnavailable;

  /// No description provided for @appStateBillingStartPurchaseError.
  ///
  /// In en, this message translates to:
  /// **'Failed to start the purchase'**
  String get appStateBillingStartPurchaseError;

  /// No description provided for @appStateBillingStoreUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The store is currently unavailable'**
  String get appStateBillingStoreUnavailable;

  /// No description provided for @appStateBillingRestoreError.
  ///
  /// In en, this message translates to:
  /// **'Failed to restore purchases'**
  String get appStateBillingRestoreError;

  /// No description provided for @appStateBillingCompletePurchaseError.
  ///
  /// In en, this message translates to:
  /// **'Failed to complete the purchase'**
  String get appStateBillingCompletePurchaseError;

  /// No description provided for @appStateCategoryFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get appStateCategoryFood;

  /// No description provided for @appStateCategoryHome.
  ///
  /// In en, this message translates to:
  /// **'Housing'**
  String get appStateCategoryHome;

  /// No description provided for @appStateCategoryTransport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get appStateCategoryTransport;

  /// No description provided for @appStateCategoryShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get appStateCategoryShopping;

  /// No description provided for @appStateCategoryHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get appStateCategoryHealth;

  /// No description provided for @appStateCategoryFun.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get appStateCategoryFun;

  /// No description provided for @appStateCategoryEducation.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get appStateCategoryEducation;

  /// No description provided for @appStateCategoryGifts.
  ///
  /// In en, this message translates to:
  /// **'Gifts'**
  String get appStateCategoryGifts;

  /// No description provided for @appStateCategoryTravel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get appStateCategoryTravel;

  /// No description provided for @appStateCategoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get appStateCategoryOther;

  /// No description provided for @appStateTagWork.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get appStateTagWork;

  /// No description provided for @appStateTagHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get appStateTagHome;

  /// No description provided for @appStateTagTravel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get appStateTagTravel;

  /// No description provided for @appStateTagFamily.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get appStateTagFamily;

  /// No description provided for @appStateTagFun.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get appStateTagFun;

  /// No description provided for @appStateTagEatingOut.
  ///
  /// In en, this message translates to:
  /// **'Eating out'**
  String get appStateTagEatingOut;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
