// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Budgetto';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsPremiumTitle => 'Premium';

  @override
  String get settingsPremiumSubtitle => 'Suscripcion y funciones premium';

  @override
  String get settingsBudgetsTitle => 'Presupuestos';

  @override
  String get settingsBudgetsSubtitle => 'Limites y objetivos por categoria';

  @override
  String get settingsPaymentMethodsTitle => 'Metodos de pago';

  @override
  String get settingsPaymentMethodsSubtitle =>
      'Tarjetas y cuentas para transacciones';

  @override
  String get settingsCategoriesTitle => 'Categorias';

  @override
  String get settingsCategoriesSubtitle => 'Editar la lista de categorias';

  @override
  String get settingsTagsTitle => 'Etiquetas';

  @override
  String get settingsTagsSubtitle => 'Agregar y renombrar etiquetas';

  @override
  String get settingsCurrencyTitle => 'Moneda';

  @override
  String get settingsCurrencySubtitle => 'Moneda para mostrar importes';

  @override
  String get settingsCurrencyNotSelected => 'No seleccionada';

  @override
  String get settingsThemeTitle => 'Tema';

  @override
  String get settingsThemeSubtitle => 'Tema claro u oscuro';

  @override
  String get settingsThemeDark => 'Oscuro';

  @override
  String get settingsThemeLight => 'Claro';

  @override
  String get settingsLanguageTitle => 'Idioma';

  @override
  String get settingsLanguageSubtitle => 'Idioma de la interfaz de la app';

  @override
  String get settingsSyncTitle => 'Sincronizacion';

  @override
  String get settingsSyncSubtitle => 'Iniciar sesion y mover el progreso';

  @override
  String get settingsDataTitle => 'Datos';

  @override
  String get settingsDataSubtitle => 'Importar gastos desde CSV';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonDelete => 'Eliminar';

  @override
  String get commonReset => 'Restablecer';

  @override
  String get commonApply => 'Aplicar';

  @override
  String get commonSelect => 'Seleccionar';

  @override
  String get commonEdit => 'Editar';

  @override
  String get commonSave => 'Guardar';

  @override
  String get commonCreate => 'Crear';

  @override
  String get commonAdd => 'Agregar';

  @override
  String get commonNotAvailable => '—';

  @override
  String get themeSettingsSectionTitle => 'Apariencia';

  @override
  String get themeSettingsDescription =>
      'El tema afecta al fondo, las tarjetas y los acentos de la interfaz.';

  @override
  String get languageSettingsDescription =>
      'Elige un idioma fijo para la app o usa el idioma del sistema.';

  @override
  String get languageSystem => 'Sistema';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageRussian => 'Русский';

  @override
  String get languageSpanish => 'Español';

  @override
  String get accessStatusPremiumActive => 'Premium activo';

  @override
  String get accessStatusLocked => 'Acceso bloqueado';

  @override
  String get accessStatusBasic => 'Plan basico';

  @override
  String accessStatusDaysRemaining(int count) {
    return 'Quedan $count d.';
  }

  @override
  String get appShellPlannedPayments => 'Pagos recurrentes';

  @override
  String get appShellReminders => 'Recordatorios';

  @override
  String get appShellShoppingLists => 'Listas de compras';

  @override
  String get appShellImportCsv => 'Importar CSV';

  @override
  String get appShellExportCsv => 'Exportar CSV';

  @override
  String get overviewTitle => 'Resumen';

  @override
  String get overviewRangePickHelp => 'Elige un periodo';

  @override
  String get overviewRangeSave => 'Listo';

  @override
  String get overviewRangeCancel => 'Cancelar';

  @override
  String get overviewExpenses => 'Gastos';

  @override
  String get overviewIncome => 'Ingresos';

  @override
  String get overviewRangeDay => 'Dia';

  @override
  String get overviewRangeWeek => 'Semana';

  @override
  String get overviewRangeMonth => 'Mes';

  @override
  String get overviewRangeYear => 'Año';

  @override
  String get overviewRangePeriod => 'Periodo';

  @override
  String get overviewTotal => 'Total';

  @override
  String get overviewNoTransactions =>
      'No hay transacciones para el periodo seleccionado.';

  @override
  String get homeBalanceTitle => 'Saldo';

  @override
  String get homeCategoriesTitle => 'Categorias';

  @override
  String get searchTitle => 'Busqueda';

  @override
  String get searchHint => 'Buscar por descripcion, categoria o etiqueta';

  @override
  String get searchAll => 'Todo';

  @override
  String get searchFromPlaceholder => 'Desde: fecha y hora';

  @override
  String searchFromValue(Object value) {
    return 'Desde: $value';
  }

  @override
  String get searchToPlaceholder => 'Hasta: fecha y hora';

  @override
  String searchToValue(Object value) {
    return 'Hasta: $value';
  }

  @override
  String get searchTagsEmpty => 'Todavia no hay etiquetas';

  @override
  String get searchNoResults => 'No se encontro nada';

  @override
  String get reportsTitle => 'Informes';

  @override
  String get reportsByCategoryTitle => 'Por categoria';

  @override
  String get reportsByTimeTitle => 'Por tiempo';

  @override
  String get reportsCategoryFood => 'Comida';

  @override
  String get reportsCategoryHousing => 'Vivienda';

  @override
  String get reportsCategoryTransport => 'Transporte';

  @override
  String get listsEmpty => 'Todavia no hay listas';

  @override
  String get listsDeleteTitle => '¿Eliminar lista?';

  @override
  String get listsDeleteMessage => '¿Seguro que quieres eliminar esta lista?';

  @override
  String get listsSummaryEmpty => 'Todavia no hay elementos';

  @override
  String listsSummaryProgress(int done, int total) {
    return 'Marcados $done de $total';
  }

  @override
  String get listsDefaultTitle => 'Lista';

  @override
  String get listsAddTitleOrItemError =>
      'Agrega un titulo o un elemento de la lista';

  @override
  String get listsNewTitle => 'Nueva lista';

  @override
  String get listsEditorTitle => 'Lista';

  @override
  String get listsNameHint => 'Titulo de la lista';

  @override
  String get listsItemHint => 'Elemento de la lista';

  @override
  String get listsAddItem => 'Agregar elemento';

  @override
  String get subscriptionPlanYearlyTitle => 'Anual';

  @override
  String get subscriptionPlanYearlyFallback => '\$14.99 / año';

  @override
  String get subscriptionPlanBestBadge => 'Mejor opcion';

  @override
  String get subscriptionPlanQuarterlyTitle => '3 meses';

  @override
  String get subscriptionPlanQuarterlyFallback => '\$4.99 / 3 meses';

  @override
  String get subscriptionPlanMonthlyTitle => 'Mensual';

  @override
  String get subscriptionPlanMonthlyFallback => '\$1.99 / mes';

  @override
  String get subscriptionDateNotSet => 'no definida';

  @override
  String get subscriptionHeadlineActive => 'Premium esta activo';

  @override
  String get subscriptionHeadlineTrial => 'El trial de Premium esta activo';

  @override
  String get subscriptionHeadlineExpired => 'El periodo de prueba termino';

  @override
  String get subscriptionSubheadActive =>
      'Todas las funciones Premium estan desbloqueadas en este dispositivo.';

  @override
  String subscriptionSubheadTrial(int count) {
    return 'Quedan $count d. de Premium en el trial gratuito.';
  }

  @override
  String get subscriptionSubheadExpired =>
      'Budgetto ahora esta en modo solo lectura. Se necesita una suscripcion para volver a agregar o editar datos.';

  @override
  String get subscriptionUnlimited => 'Ilimitado';

  @override
  String subscriptionUntil(Object date) {
    return 'Hasta $date';
  }

  @override
  String get subscriptionChipFullAccess => 'Acceso completo';

  @override
  String get subscriptionChipPremiumFeatures => 'Funciones Premium';

  @override
  String get subscriptionChipPremiumAfterTrial => 'Premium despues del trial';

  @override
  String get subscriptionChipSubscriptionRequired => 'Suscripcion necesaria';

  @override
  String get subscriptionChipBasicPlan => 'Solo lectura';

  @override
  String get subscriptionHowItWorksTitle => 'Como funciona el acceso';

  @override
  String get subscriptionHowItWorksTrial =>
      'Los primeros 30 dias desbloquean todas las funciones sin limites.';

  @override
  String get subscriptionHowItWorksNoSplit =>
      'Durante el trial puedes agregar, editar y eliminar cualquier dato.';

  @override
  String get subscriptionHowItWorksAfterTrial =>
      'Despues del trial, Budgetto queda en modo solo lectura hasta que haya una suscripcion activa.';

  @override
  String get subscriptionHowItWorksBilling =>
      'Puedes elegir facturacion mensual, de 3 meses o anual en cualquier momento.';

  @override
  String get subscriptionPremiumUnlocksTitle => 'Premium desbloquea';

  @override
  String get subscriptionFeatureCustomCategories =>
      'Crear, editar y reordenar categorias propias.';

  @override
  String get subscriptionFeatureCustomTags =>
      'Crear, editar y reordenar tus propias etiquetas.';

  @override
  String get subscriptionFeatureRecurringPayments =>
      'Pagos recurrentes y operaciones repetidas mas rapidas.';

  @override
  String get subscriptionFeatureReminders =>
      'Recordatorios para facturas y fechas importantes.';

  @override
  String get subscriptionFeatureSharedBudgets =>
      'Presupuestos compartidos para familia o pareja.';

  @override
  String get subscriptionFeatureCsvTools =>
      'Importacion y exportacion de transacciones con CSV.';

  @override
  String get subscriptionStoreUnavailable =>
      'La tienda de pagos no esta disponible ahora mismo. Intentalo mas tarde.';

  @override
  String get subscriptionRestorePurchases => 'Restaurar compras';

  @override
  String get subscriptionRenewalNote =>
      'La suscripcion se renueva automaticamente hasta que el usuario la cancele en la App Store o en Google Play.';

  @override
  String get subscriptionPlanActive => 'Activa';

  @override
  String get premiumRequiredTitle => 'Se necesita Premium';

  @override
  String premiumRequiredMessage(Object feature) {
    return 'Premium desbloquea $feature. Elige un plan para continuar.';
  }

  @override
  String get premiumViewPlans => 'Ver planes';

  @override
  String get premiumOnlyBadge => 'Premium';

  @override
  String get premiumFeatureCustomCategories => 'categorias personalizadas';

  @override
  String get premiumFeatureCustomTags => 'etiquetas personalizadas';

  @override
  String get premiumFeatureRecurringPayments => 'pagos recurrentes';

  @override
  String get premiumFeatureReminders => 'recordatorios';

  @override
  String get premiumFeatureSharedBudgets => 'presupuestos compartidos';

  @override
  String get premiumFeatureCsvTools => 'importacion y exportacion CSV';

  @override
  String get premiumFeatureEditing => 'agregar y editar datos';

  @override
  String get premiumReadOnlyMessage =>
      'Tu periodo de prueba termino. Budgetto ahora funciona en modo solo lectura. Suscribete para volver a agregar, editar y eliminar datos.';

  @override
  String get premiumCategoriesInlineHint =>
      'Las categorias base siguen disponibles. Premium desbloquea tus propias categorias, su edicion y reordenacion.';

  @override
  String get premiumTagsInlineHint =>
      'Las etiquetas base siguen disponibles. Premium desbloquea tus propias etiquetas, su edicion y reordenacion.';

  @override
  String get transactionsBudgetPickerTitle => 'Elige un presupuesto';

  @override
  String get transactionsPersonalBudgetTitle => 'Presupuesto personal';

  @override
  String get transactionsPersonalBudgetSubtitle => 'Solo para ti';

  @override
  String get transactionsDeleteTitle => '¿Eliminar transaccion?';

  @override
  String get transactionsDeleteMessage =>
      '¿Seguro que quieres eliminar esta transaccion?';

  @override
  String get transactionsDeleted => 'Transaccion eliminada';

  @override
  String get transactionsTextTitle => 'Texto';

  @override
  String get transactionsTextHint =>
      'Descripcion, categoria, etiqueta o importe';

  @override
  String get transactionsTypeTitle => 'Tipo de transaccion';

  @override
  String get transactionsTypeAll => 'Todo';

  @override
  String get transactionsTypeExpenses => 'Gastos';

  @override
  String get transactionsTypeIncome => 'Ingresos';

  @override
  String get transactionsPeriodTitle => 'Periodo';

  @override
  String get transactionsQuickLastMonth => 'Ultimo mes';

  @override
  String get transactionsQuickQuarter => 'Trimestre';

  @override
  String get transactionsQuickYear => 'Año';

  @override
  String get transactionsSelectMonth => 'Seleccionar mes';

  @override
  String get transactionsFrom => 'Desde';

  @override
  String get transactionsTo => 'Hasta';

  @override
  String get transactionsChooseDate => 'Elige una fecha';

  @override
  String get transactionsCategoriesTitle => 'Categorias';

  @override
  String get transactionsTagsTitle => 'Etiquetas';

  @override
  String get transactionsTagsEmpty => 'Todavia no hay etiquetas';

  @override
  String get transactionsMethodsTitle => 'Metodos de pago';

  @override
  String get transactionsDisplayTotal => 'Total';

  @override
  String get transactionsDisplayByDate => 'Por fecha';

  @override
  String get transactionsDisplayCategories => 'Categorias';

  @override
  String get transactionsDisplayPayment => 'Pago';

  @override
  String get transactionsDisplayTags => 'Etiquetas';

  @override
  String get transactionsDisplayAuthor => 'Autor';

  @override
  String get transactionsFamilyBudgetFallback => 'Presupuesto compartido';

  @override
  String get transactionsNothingFound => 'No se encontro nada';

  @override
  String get transactionsNoTransactions => 'Todavia no hay transacciones';

  @override
  String get transactionsTitle => 'Transacciones';

  @override
  String get transactionTypeExpense => 'Gasto';

  @override
  String get transactionTypeIncome => 'Ingreso';

  @override
  String get formAmountLabel => 'Importe';

  @override
  String get formDescriptionLabel => 'Descripcion';

  @override
  String get formPaymentLabel => 'Pago';

  @override
  String get formCategoryLabel => 'Categoria';

  @override
  String get formTagsLabel => 'Etiquetas';

  @override
  String get formTagsEmpty => 'Todavia no hay etiquetas';

  @override
  String get formChooseCategoryError => 'Elige una categoria';

  @override
  String get formChoosePaymentError => 'Elige un metodo de pago';

  @override
  String get formAmountPositiveError => 'Introduce un importe mayor que 0';

  @override
  String addTransactionNewTitle(Object type) {
    return 'Nuevo $type';
  }

  @override
  String get addTransactionEditTitle => 'Editar transaccion';

  @override
  String get addTransactionDescriptionHint => 'Por ejemplo, cafe y snack';

  @override
  String get plannedTitle => 'Pagos recurrentes';

  @override
  String get plannedEmpty => 'Todavia no hay pagos recurrentes';

  @override
  String get plannedDeleteTitle => '¿Eliminar registro?';

  @override
  String get plannedDeleteMessage =>
      '¿Seguro que quieres eliminar este registro?';

  @override
  String get plannedDeleted => 'Pago eliminado';

  @override
  String get plannedAddToTransactionsTitle => '¿Agregar a transacciones?';

  @override
  String plannedAddToTransactionsMessage(Object description, Object amount) {
    return '¿Crear una transaccion a partir de \"$description\" por $amount?';
  }

  @override
  String get plannedAddedToTransactions => 'Agregado a transacciones';

  @override
  String get plannedActionAddToTransactions => 'Agregar a transacciones';

  @override
  String plannedScheduledReminder(Object date) {
    return 'Recordatorio: $date';
  }

  @override
  String plannedScheduledDate(Object date) {
    return 'Fecha: $date';
  }

  @override
  String get plannedAddToTransactionsTooltip => 'Agregar a transacciones';

  @override
  String get plannedNotificationsPermissionError =>
      'Permite las notificaciones en los ajustes del dispositivo';

  @override
  String get plannedChooseDateTimeError => 'Elige fecha y hora';

  @override
  String get plannedChooseFutureTimeError => 'Elige una hora en el futuro';

  @override
  String get plannedNewTitle => 'Nuevo registro recurrente';

  @override
  String get plannedEditTitle => 'Editar registro';

  @override
  String get plannedDescriptionHint => 'Por ejemplo, suministros';

  @override
  String get plannedWhenLabel => 'Cuando';

  @override
  String get plannedChooseDateTime => 'Elegir fecha y hora';

  @override
  String get plannedRemindLabel => 'Recordarme';

  @override
  String get remindersTitle => 'Recordatorios';

  @override
  String get remindersEmpty => 'Todavia no hay recordatorios';

  @override
  String get remindersDeleteTitle => '¿Eliminar recordatorio?';

  @override
  String get remindersDeleteMessage =>
      '¿Seguro que quieres eliminar este recordatorio?';

  @override
  String get remindersPermissionError =>
      'Permite las notificaciones en los ajustes del dispositivo';

  @override
  String get remindersNewTitle => 'Crear recordatorio';

  @override
  String get remindersEditTitle => 'Editar recordatorio';

  @override
  String get remindersNameLabel => 'Nombre del recordatorio';

  @override
  String get remindersNameHint => 'Por ejemplo, pago del alquiler';

  @override
  String get remindersNameRequired => 'Este campo es obligatorio';

  @override
  String get remindersFrequencyLabel => 'Frecuencia';

  @override
  String get remindersStartDateLabel => 'Fecha de inicio';

  @override
  String get remindersTimeLabel => 'Hora';

  @override
  String get remindersCommentLabel => 'Comentario';

  @override
  String get remindersCommentHint => 'Comentario';

  @override
  String get remindersChooseFutureTimeError => 'Elige una hora en el futuro';

  @override
  String get reminderFrequencyOnce => 'Una vez';

  @override
  String get reminderFrequencyDaily => 'Cada dia';

  @override
  String get reminderFrequencyWeekly => 'Cada semana';

  @override
  String get reminderFrequencyBiweekly => 'Cada 2 semanas';

  @override
  String get reminderFrequencyFourWeeks => 'Cada 4 semanas';

  @override
  String get reminderFrequencyMonthly => 'Cada mes';

  @override
  String get reminderFrequencyEveryTwoMonths => 'Cada 2 meses';

  @override
  String get reminderFrequencyQuarterly => 'Cada trimestre';

  @override
  String get reminderFrequencyHalfYear => 'Cada medio año';

  @override
  String get reminderFrequencyYearly => 'Cada año';

  @override
  String get dataExportNoTransactions => 'No hay transacciones para exportar';

  @override
  String dataExportMonthLimitMessage(Object month, int count, int limit) {
    return '$month tiene $count transacciones. Limite de exportacion: $limit filas.';
  }

  @override
  String get dataExportNoTransactionsForMonth =>
      'No hay transacciones para el mes seleccionado';

  @override
  String get dataExportColumnDate => 'Fecha';

  @override
  String get dataExportColumnAuthor => 'Quien';

  @override
  String get dataExportColumnMethod => 'Metodo';

  @override
  String get dataExportColumnCategory => 'Categoria';

  @override
  String get dataExportColumnDescription => 'Descripcion';

  @override
  String get dataExportColumnType => 'Tipo';

  @override
  String get dataExportColumnAmount => 'Importe';

  @override
  String dataExportSavedOnDevice(Object path) {
    return 'La exportacion esta disponible en un dispositivo fisico. Archivo guardado: $path';
  }

  @override
  String dataExportShareText(Object month) {
    return 'Exportacion de transacciones de Budgetto para $month';
  }

  @override
  String dataExportFileSaved(Object path) {
    return 'Archivo guardado: $path';
  }

  @override
  String get dataExportPickMonthTitle => 'Elige un mes para exportar';

  @override
  String dataExportPickMonthDescription(int limit) {
    return 'Exporta solo un mes. Maximo $limit filas.';
  }

  @override
  String get dataExportSelectMonthLabel => 'Mes';

  @override
  String get dataExportExportAction => 'Exportar CSV';

  @override
  String get dataExportNoAvailableMonths =>
      'Ahora no hay meses disponibles para exportar';

  @override
  String dataExportMonthCountExceeded(int count) {
    return '$count transacciones, supera el limite';
  }

  @override
  String dataExportMonthCount(int count) {
    return '$count transacciones';
  }

  @override
  String dataExportMonthsLimited(int limit) {
    return 'Los meses con mas de $limit transacciones no estan disponibles para exportar.';
  }

  @override
  String get paymentMethodCashLabel => 'Efectivo';

  @override
  String get paymentMethodCardLabel => 'Tarjeta';

  @override
  String get currencyNameUsd => 'Dolar estadounidense';

  @override
  String get currencyNameEur => 'Euro';

  @override
  String get currencyNameGbp => 'Libra esterlina';

  @override
  String get currencyNameUah => 'Grivna ucraniana';

  @override
  String get currencyNameJpy => 'Yen japones';

  @override
  String get currencyNameRub => 'Rublo ruso';

  @override
  String get syncSettingsGoogleConnected => 'Google conectado';

  @override
  String get syncSettingsSignInCanceled => 'Inicio de sesion cancelado';

  @override
  String get syncSettingsGoogleConnectFailed => 'No se pudo conectar Google';

  @override
  String get syncSettingsStatusEnabled => 'Activada';

  @override
  String get syncSettingsStatusDisabled => 'Desactivada';

  @override
  String get syncSettingsGuest => 'Invitado';

  @override
  String get syncSettingsAccountSectionTitle => 'Cuenta';

  @override
  String get syncSettingsStatusLabel => 'Estado';

  @override
  String get syncSettingsGoogleSignInButton => 'Iniciar sesion con Google';

  @override
  String get syncSettingsGoogleDescription =>
      'Conecta Google para mover tu progreso entre dispositivos.';

  @override
  String get syncSettingsStatusSectionTitle => 'Estado';

  @override
  String get syncSettingsDataStatusLabel => 'Sincronizacion de datos';

  @override
  String get syncSettingsCloudDescription =>
      'La sincronizacion guarda tus datos en la nube y permite un presupuesto compartido.';

  @override
  String get settingsDataFileReadFailed =>
      'No se pudo leer el archivo seleccionado.';

  @override
  String settingsDataImportFailed(Object error) {
    return 'La importacion fallo: $error';
  }

  @override
  String get settingsDataErrorsTitle => 'Corrige los errores del CSV';

  @override
  String get settingsDataValidationFailedNoName =>
      'El archivo no paso la validacion.';

  @override
  String settingsDataValidationFailedWithName(Object fileName) {
    return 'El archivo \"$fileName\" no paso la validacion.';
  }

  @override
  String get settingsDataUnderstoodButton => 'Entendido';

  @override
  String get settingsDataConfirmImportTitle => 'Confirmar importacion';

  @override
  String settingsDataFileLabel(Object fileName) {
    return 'Archivo: $fileName';
  }

  @override
  String settingsDataWillAddCount(int count) {
    return 'Registros que se agregaran: $count';
  }

  @override
  String get settingsDataNewCategories => 'Nuevas categorias';

  @override
  String get settingsDataNewPaymentMethods => 'Nuevos metodos de pago';

  @override
  String get settingsDataNewTags => 'Nuevas etiquetas';

  @override
  String get settingsDataImportConfirmHint =>
      'Las nuevas categorias, metodos de pago, etiquetas y registros se agregaran solo despues de pulsar \"Importar\".';

  @override
  String get settingsDataImportTagHint =>
      'Todos los registros importados tambien recibiran una etiqueta del sistema de importacion para poder filtrarlos y eliminarlos rapidamente.';

  @override
  String get settingsDataCancelButton => 'Cancelar';

  @override
  String get settingsDataImportAction => 'Importar';

  @override
  String settingsDataImportedSuccess(int count, Object tag) {
    return 'Se importaron $count registros. Etiqueta: $tag.';
  }

  @override
  String get settingsDataImportCardTitle => 'Importar gastos desde CSV';

  @override
  String get settingsDataSampleTitle => 'Datos de ejemplo';

  @override
  String get settingsDataCheckingCsv => 'Comprobando CSV...';

  @override
  String get settingsDataChooseCsv => 'Elegir CSV y validar';

  @override
  String get transactionImportErrorEmptyFile =>
      'El archivo esta vacio. Agrega encabezados y filas de datos.';

  @override
  String get transactionImportErrorUnclosedQuote =>
      'El CSV contiene una comilla sin cerrar. Revisa el archivo e intentalo de nuevo.';

  @override
  String get transactionImportErrorReadRows =>
      'No se pudieron leer las filas del CSV.';

  @override
  String transactionImportMissingRequiredColumn(Object column) {
    return 'No se encontro la columna obligatoria \"$column\". Usa la plantilla de las instrucciones.';
  }

  @override
  String get transactionImportErrorNoDataRows =>
      'El archivo no tiene filas de transacciones. Agrega al menos un registro.';

  @override
  String transactionImportErrorRowLimit(int count, int limit) {
    return 'El archivo tiene $count filas, pero el limite actual de importacion es $limit.';
  }

  @override
  String transactionImportErrorInvalidDate(Object value) {
    return 'No se pudo reconocer la fecha \"$value\". Usa una fecha con hora, por ejemplo 2026-02-05 00:53. Los segundos son opcionales y se ignoraran.';
  }

  @override
  String transactionImportErrorInvalidType(Object expense, Object income) {
    return 'El campo de tipo de transaccion no es valido. Usa \"$expense\" o \"$income\".';
  }

  @override
  String get transactionImportErrorOperationRequired =>
      'El campo de operacion no debe estar vacio.';

  @override
  String transactionImportErrorInvalidAmount(Object value) {
    return 'El campo de importe debe ser un numero mayor que 0. Valor actual: \"$value\".';
  }

  @override
  String get transactionImportErrorCategoryRequired =>
      'El campo de categoria no debe estar vacio.';

  @override
  String get transactionImportErrorPaymentMethodRequired =>
      'El campo de metodo de pago no debe estar vacio.';

  @override
  String get transactionImportInstructionPrepareTitle => 'Prepara el archivo';

  @override
  String get transactionImportInstructionFormat => 'Formato del archivo: CSV.';

  @override
  String get transactionImportInstructionEncoding =>
      'Codificacion del archivo: UTF-8.';

  @override
  String transactionImportInstructionHeaderRow(Object headers) {
    return 'Primera fila del archivo: $headers.';
  }

  @override
  String get transactionImportInstructionDelimiter => 'Separador: ;';

  @override
  String transactionImportInstructionMaxRows(int limit) {
    return 'Maximo: $limit filas de datos sin contar el encabezado.';
  }

  @override
  String get transactionImportInstructionColumnsTitle =>
      'Rellena las columnas en la primera fila';

  @override
  String transactionImportInstructionDateColumn(Object column) {
    return '$column: fecha y hora de la transaccion. Formato recomendado: YYYY-MM-DD HH:mm. La importacion tambien acepta valores como 05.02.2026 0:53:29 e ignora los segundos.';
  }

  @override
  String transactionImportInstructionTypeColumn(
    Object column,
    Object expense,
    Object income,
  ) {
    return '$column: usa el valor $expense o $income.';
  }

  @override
  String transactionImportInstructionOperationColumn(
    Object column,
    Object example,
  ) {
    return '$column: texto de la transaccion. Ejemplo: $example.';
  }

  @override
  String transactionImportInstructionAmountColumn(Object column) {
    return '$column: un numero mayor que 0 con el formato 12.50.';
  }

  @override
  String transactionImportInstructionCategoryColumn(Object column) {
    return '$column: nombre de la categoria. Si todavia no existe, se creara tras la confirmacion.';
  }

  @override
  String transactionImportInstructionPaymentMethodColumn(Object column) {
    return '$column: nombre del metodo de pago. Este campo no puede estar vacio. Si todavia no existe, se creara tras la confirmacion.';
  }

  @override
  String transactionImportInstructionTagsColumn(Object column) {
    return '$column: una lista de etiquetas separadas por comas. Este campo puede estar vacio. Las etiquetas que falten se crearan tras la confirmacion.';
  }

  @override
  String get transactionImportInstructionReviewTitle =>
      'Revisa los cambios antes de importar';

  @override
  String get transactionImportInstructionReviewItemOne =>
      'Antes de importar, la app mostrara nuevas categorias, metodos de pago y etiquetas.';

  @override
  String get transactionImportInstructionReviewItemTwo =>
      'Los nuevos elementos y registros se agregaran solo despues de pulsar el boton Importar.';

  @override
  String get transactionImportInstructionReviewItemThree =>
      'Cada registro importado recibira una etiqueta del sistema con el formato import_YYYYMMDD_HHMMSS.';

  @override
  String get transactionImportColumnDate => 'fecha';

  @override
  String get transactionImportColumnType => 'tipo de transaccion';

  @override
  String get transactionImportColumnOperation => 'operacion';

  @override
  String get transactionImportColumnAmount => 'importe';

  @override
  String get transactionImportColumnCategory => 'categoria';

  @override
  String get transactionImportColumnPaymentMethod => 'metodo de pago';

  @override
  String get transactionImportColumnTags => 'etiquetas';

  @override
  String transactionImportLineMessage(int lineNumber, Object message) {
    return 'Linea $lineNumber: $message';
  }

  @override
  String get transactionImportSampleOperationOne => 'Entradas de teatro';

  @override
  String get transactionImportSampleOperationTwo => 'Taxi a casa';

  @override
  String get transactionImportSampleCategoryOne => 'Entretenimiento';

  @override
  String get transactionImportSampleCategoryTwo => 'Transporte';

  @override
  String get transactionImportSamplePaymentMethodOne => 'Tarjeta principal';

  @override
  String get transactionImportSamplePaymentMethodTwo => 'Efectivo';

  @override
  String get transactionImportSampleTagsOne => 'Teatro,Noche';

  @override
  String get notificationChannelPlannedName => 'Registros recurrentes';

  @override
  String get notificationChannelPlannedDescription =>
      'Recordatorios sobre registros recurrentes';

  @override
  String get notificationChannelReminderName => 'Recordatorios';

  @override
  String get notificationChannelReminderDescription =>
      'Recordatorios sobre tareas importantes';

  @override
  String get notificationChannelFamilyName => 'Gastos familiares';

  @override
  String get notificationChannelFamilyDescription =>
      'Notificaciones sobre nuevos gastos en el presupuesto familiar';

  @override
  String get editorColorPickerTitle => 'Elegir un color';

  @override
  String get editorIconColorLabel => 'Color del icono';

  @override
  String get editorIconLabel => 'Icono';

  @override
  String get cardsTitle => 'Tarjetas';

  @override
  String get cardsEmpty => 'Todavia no hay tarjetas';

  @override
  String get cardsDeleteTitle => '¿Eliminar tarjeta?';

  @override
  String get cardsDeleteMessage => '¿Seguro que quieres eliminar esta tarjeta?';

  @override
  String get cardsDeleteSuccess => 'Tarjeta eliminada';

  @override
  String get cardsNewTitle => 'Nueva tarjeta';

  @override
  String get cardsEditTitle => 'Editar tarjeta';

  @override
  String get cardsNameHint => 'Por ejemplo, Sergey WISE';

  @override
  String get tagsEmpty => 'Todavia no hay etiquetas';

  @override
  String get tagsDeleteTitle => '¿Eliminar etiqueta?';

  @override
  String get tagsDeleteMessage => '¿Seguro que quieres eliminar esta etiqueta?';

  @override
  String get tagsDeleteSuccess => 'Etiqueta eliminada';

  @override
  String get tagsNewTitle => 'Nueva etiqueta';

  @override
  String get tagsEditTitle => 'Editar etiqueta';

  @override
  String get tagsNameHint => 'Por ejemplo, Trabajo';

  @override
  String get categoriesDeleteBlockedTitle =>
      'No se puede eliminar la categoria';

  @override
  String get categoriesDeleteBlockedMessage =>
      'Esta categoria ya esta en uso. Crea primero otra categoria para mover alli los registros.';

  @override
  String get categoriesDeleteTitle => '¿Eliminar categoria?';

  @override
  String get categoriesDeleteMessage =>
      '¿Seguro que quieres eliminar esta categoria?';

  @override
  String categoriesDeleteUsedMessage(int transactions, int planned) {
    return 'Esta categoria se usa en $transactions transacciones y $planned registros planificados.';
  }

  @override
  String get categoriesDeleteReplacementHint =>
      'Antes de eliminar, elige la categoria que debe recibir estos registros.';

  @override
  String get categoriesReplacementLabel => 'Nueva categoria';

  @override
  String categoriesDeleteMovedSuccess(Object name) {
    return 'Categoria eliminada, registros movidos a \"$name\".';
  }

  @override
  String get categoriesDeleteSuccess => 'Categoria eliminada';

  @override
  String get categoriesNewTitle => 'Nueva categoria';

  @override
  String get categoriesEditTitle => 'Editar categoria';

  @override
  String get categoriesNameHint => 'Por ejemplo, Deporte';

  @override
  String get budgetsReservedSelfName => 'yo';

  @override
  String get budgetsNotificationsPermissionError =>
      'Permite las notificaciones push en los ajustes del dispositivo';

  @override
  String get budgetsCreateTitle => 'Agregar presupuesto compartido';

  @override
  String get budgetsNameLabel => 'Nombre';

  @override
  String get budgetsNameHint => 'Nombre del presupuesto';

  @override
  String get budgetsMemberNameLabel => 'Tu nombre';

  @override
  String get budgetsMemberNameHint => 'Tu nombre';

  @override
  String get budgetsJoinTitle => 'Unirse con codigo';

  @override
  String get budgetsCodeLabel => 'Codigo del presupuesto';

  @override
  String get budgetsCodeHint => 'Codigo del presupuesto';

  @override
  String get budgetsCodeNotFound => 'Codigo no encontrado';

  @override
  String get budgetsJoinAction => 'Unirse';

  @override
  String get budgetsLeaveTitle => '¿Salir del presupuesto compartido?';

  @override
  String get budgetsLeaveMessage => '¿Seguro que quieres salir?';

  @override
  String get budgetsLeaveAction => 'Salir';

  @override
  String get budgetsSectionTitle => 'Tus presupuestos';

  @override
  String get budgetsPersonalTitle => 'Presupuesto personal';

  @override
  String get budgetsPersonalSubtitle => 'Solo para ti';

  @override
  String get budgetsSettingsSectionTitle =>
      'Ajustes del presupuesto compartido';

  @override
  String get budgetsSavedChanges => 'Cambios guardados';

  @override
  String get budgetsCodeCopied => 'Codigo copiado';

  @override
  String get budgetsCopyCodeTooltip => 'Copiar codigo';

  @override
  String get budgetsPersonalSettingsTitle =>
      'Ajustes personales en este presupuesto';

  @override
  String get budgetsNotificationsTitle => 'Avisarme de nuevos gastos';

  @override
  String get budgetsNotificationsDescription =>
      'Llegara una notificacion push cuando alguien de la familia agregue un nuevo gasto a este presupuesto.';

  @override
  String get budgetsNotificationsPerUserHint =>
      'Este interruptor funciona por separado para cada participante.';

  @override
  String get budgetsMembersTitle => 'Miembros';

  @override
  String get budgetsLeaveButton => 'Salir del presupuesto compartido';

  @override
  String get appStateSharedBudgetName => 'Presupuesto compartido';

  @override
  String get appStatePersonalBudgetName => 'Presupuesto personal';

  @override
  String get appStateCashMethodName => 'Efectivo';

  @override
  String get appStateUnknownUserName => 'Sin nombre';

  @override
  String get appStatePlannedNotificationTitle => 'Registro recurrente';

  @override
  String get appStateFamilyTransactionTitle => 'Nuevo gasto familiar';

  @override
  String get appStateFamilyTransactionBody =>
      'Aparecio un nuevo gasto en el presupuesto familiar';

  @override
  String get appStateBillingUpdateError =>
      'No se pudo actualizar el estado de la compra';

  @override
  String get appStateBillingConnectError => 'No se pudo conectar con la tienda';

  @override
  String get appStateBillingProductUnavailable =>
      'Este plan todavia no esta disponible en la tienda';

  @override
  String get appStateBillingStartPurchaseError =>
      'No se pudo iniciar la compra';

  @override
  String get appStateBillingStoreUnavailable =>
      'La tienda no esta disponible en este momento';

  @override
  String get appStateBillingRestoreError =>
      'No se pudieron restaurar las compras';

  @override
  String get appStateBillingCompletePurchaseError =>
      'No se pudo completar la compra';

  @override
  String get appStateCategoryFood => 'Comida';

  @override
  String get appStateCategoryHome => 'Vivienda';

  @override
  String get appStateCategoryTransport => 'Transporte';

  @override
  String get appStateCategoryShopping => 'Compras';

  @override
  String get appStateCategoryHealth => 'Salud';

  @override
  String get appStateCategoryFun => 'Entretenimiento';

  @override
  String get appStateCategoryEducation => 'Educacion';

  @override
  String get appStateCategoryGifts => 'Regalos';

  @override
  String get appStateCategoryTravel => 'Viajes';

  @override
  String get appStateCategoryOther => 'Otros';

  @override
  String get appStateTagWork => 'Trabajo';

  @override
  String get appStateTagHome => 'Casa';

  @override
  String get appStateTagTravel => 'Viajes';

  @override
  String get appStateTagFamily => 'Familia';

  @override
  String get appStateTagFun => 'Entretenimiento';

  @override
  String get appStateTagEatingOut => 'Comer fuera';
}
