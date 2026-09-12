// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Finance Tracker';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get delete => 'Eliminar';

  @override
  String get edit => 'Editar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get error => 'Error';

  @override
  String get success => 'Éxito';

  @override
  String get loading => 'Cargando...';

  @override
  String get noData => 'No hay datos disponibles';

  @override
  String get all => 'Todos';

  @override
  String get today => 'Hoy';

  @override
  String get yesterday => 'Ayer';

  @override
  String get custom => 'Personalizado';

  @override
  String get date => 'Fecha';

  @override
  String get amount => 'Monto';

  @override
  String get description => 'Descripción';

  @override
  String get notes => 'Notas';

  @override
  String get category => 'Categoría';

  @override
  String get account => 'Cuenta';

  @override
  String get type => 'Tipo';

  @override
  String get name => 'Nombre';

  @override
  String get actions => 'Acciones';

  @override
  String get clear => 'Limpiar';

  @override
  String get filter => 'Filtrar';

  @override
  String get search => 'Buscar';

  @override
  String get status => 'Estado';

  @override
  String get details => 'Detalles';

  @override
  String get done => 'Listo';

  @override
  String get add => 'Agregar';

  @override
  String get retry => 'Reintentar';

  @override
  String get close => 'Cerrar';

  @override
  String get navDashboard => 'Inicio';

  @override
  String get navTransactions => 'Transacciones';

  @override
  String get navBudgets => 'Presupuestos';

  @override
  String get navSubscriptions => 'Suscripciones';

  @override
  String get navAccounts => 'Cuentas';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get netWorth => 'Patrimonio Neto';

  @override
  String get assets => 'Activos';

  @override
  String get liabilities => 'Pasivos';

  @override
  String get net => 'Neto';

  @override
  String get totalIncome => 'Ingresos Totales';

  @override
  String get totalExpense => 'Gastos Totales';

  @override
  String get monthlyCashFlow => 'Flujo de Caja Mensual';

  @override
  String get recentTransactions => 'Transacciones Recientes';

  @override
  String get seeAll => 'Ver todas';

  @override
  String get noRecentTransactions => 'Aún no hay transacciones recientes';

  @override
  String get quickActions => 'Acciones Rápidas';

  @override
  String get addTransaction => 'Agregar Transacción';

  @override
  String get incomeVsExpense => 'Ingresos vs Gastos';

  @override
  String get activeBudgets => 'Presupuestos Activos';

  @override
  String get upcomingSubscriptions => 'Próximas Suscripciones';

  @override
  String get accounts => 'Cuentas';

  @override
  String get addAccount => 'Agregar Cuenta';

  @override
  String get editAccount => 'Editar Cuenta';

  @override
  String get accountName => 'Nombre de Cuenta';

  @override
  String get accountType => 'Tipo de Cuenta';

  @override
  String get initialBalance => 'Saldo Inicial';

  @override
  String get currentBalance => 'Saldo Actual';

  @override
  String get currentDebt => 'DEUDA ACTUAL';

  @override
  String get creditLimit => 'Cupo de Crédito';

  @override
  String get includeInNetWorth => 'Incluir en Patrimonio Neto';

  @override
  String get accountDeleted => 'Cuenta eliminada correctamente';

  @override
  String get confirmDeleteAccount =>
      '¿Estás seguro de que deseas eliminar esta cuenta? Se eliminarán también todas sus transacciones asociadas.';

  @override
  String confirmDeleteAccountNamed(String accountName) {
    return '¿Estás seguro de que deseas eliminar \"$accountName\"? Esta acción no se puede deshacer.';
  }

  @override
  String get noAccountsFound =>
      'No hay cuentas registradas. ¡Crea una para comenzar!';

  @override
  String get noAccountsFoundCreateFirst =>
      'No se encontraron cuentas. Por favor crea una primero.';

  @override
  String get accountNotFound => 'Cuenta no encontrada';

  @override
  String get adjustBalance => 'Ajustar Saldo';

  @override
  String adjustBalanceFor(String accountName) {
    return 'Ajustar saldo de $accountName';
  }

  @override
  String get enterNewReconciledBalance => 'Ingresa el nuevo saldo conciliado:';

  @override
  String get newBalance => 'Nuevo Saldo';

  @override
  String get updateBalance => 'Actualizar Saldo';

  @override
  String get deleteAccountQuestion => '¿Eliminar Cuenta?';

  @override
  String get unarchiveAccount => 'Desarchivar Cuenta';

  @override
  String get archiveAccount => 'Archivar Cuenta';

  @override
  String get creditLimitAndUtilization => 'Límite y Uso de Crédito';

  @override
  String get availableCredit => 'Crédito Disponible';

  @override
  String get totalLimit => 'Límite Total';

  @override
  String availableAmount(String amount) {
    return 'Disponible: $amount';
  }

  @override
  String creditUsedOfTotal(String percentage, String total) {
    return '$percentage usado de $total';
  }

  @override
  String get accountTypeChecking => 'Cuenta Corriente';

  @override
  String get accountTypeSavings => 'Cuenta de Ahorros';

  @override
  String get accountTypeCreditCard => 'Tarjeta de Crédito';

  @override
  String get accountTypeCash => 'Efectivo';

  @override
  String get accountTypeInvestment => 'Inversión';

  @override
  String get accountTypeOther => 'Otro';

  @override
  String get accountTypeBank => 'Cuenta Bancaria';

  @override
  String get accountTypeDigitalWallet => 'Billetera Digital';

  @override
  String get transactions => 'Transacciones';

  @override
  String get newTransaction => 'Nueva Transacción';

  @override
  String get quickTransaction => 'Transacción Rápida';

  @override
  String get transactionDetail => 'Detalle de Transacción';

  @override
  String get income => 'Ingreso';

  @override
  String get expense => 'Gasto';

  @override
  String get transfer => 'Transferencia';

  @override
  String get accountTransfer => 'Transferencia de Cuenta';

  @override
  String get fromAccount => 'Desde Cuenta';

  @override
  String get toAccount => 'Hacia Cuenta';

  @override
  String get sourceAccount => 'Cuenta Origen';

  @override
  String get destinationAccount => 'Cuenta Destino';

  @override
  String get payee => 'Beneficiario / Comercio';

  @override
  String get transactionDeleted => 'Transacción eliminada correctamente';

  @override
  String get confirmDeleteTransaction =>
      '¿Estás seguro de que deseas eliminar esta transacción?';

  @override
  String get confirmDeleteTransactionDetail =>
      'Esto eliminará permanentemente esta transacción y revertirá automáticamente su efecto en el saldo de tu cuenta.';

  @override
  String get deleteTransactionQuestion => '¿Eliminar Transacción?';

  @override
  String get filterAll => 'Todas';

  @override
  String get filterIncome => 'Ingresos';

  @override
  String get filterExpense => 'Gastos';

  @override
  String get filterExpenses => 'Gastos';

  @override
  String get filterTransfer => 'Transferencia';

  @override
  String get filterTransfers => 'Transferencias';

  @override
  String get noTransactionsFound => 'No se encontraron transacciones';

  @override
  String get noCategoriesFound => 'No hay categorías disponibles';

  @override
  String get transactionSaved => 'Transacción guardada correctamente';

  @override
  String get calculator => 'Calculadora';

  @override
  String get enterAmount => 'Ingresa el monto';

  @override
  String get selectCategory => 'Seleccionar Categoría';

  @override
  String get selectAccount => 'Seleccionar Cuenta';

  @override
  String get searchHint => 'Buscar notas o descripciones...';

  @override
  String get netFlow => 'Flujo Neto';

  @override
  String get tapPlusToRecord =>
      'Toca el botón \"+\" para registrar una nueva transacción.';

  @override
  String get toggleNoteAndDate => 'Alternar Nota y Fecha';

  @override
  String get noteOrDescription => 'Nota / Descripción';

  @override
  String get changeDate => 'Cambiar Fecha';

  @override
  String get transferDestinationAccount =>
      'Cuenta Destino de la Transferencia:';

  @override
  String get confirmTransfer => 'Confirmar Transferencia';

  @override
  String get pleaseEnterAmountGreaterThanZero =>
      'Por favor ingresa un monto mayor a 0';

  @override
  String get pleaseSelectAccount => 'Por favor selecciona una cuenta';

  @override
  String get pleaseSelectDifferentDestination =>
      'Por favor selecciona una cuenta de destino diferente';

  @override
  String recordedSuccessfully(String type) {
    return '¡$type registrado con éxito!';
  }

  @override
  String errorSavingTransaction(String error) {
    return 'Error al guardar la transacción: $error';
  }

  @override
  String get unknownAccount => 'Cuenta Desconocida';

  @override
  String get transactionId => 'ID de Transacción';

  @override
  String get budgets => 'Presupuestos';

  @override
  String get budgetsAndGoals => 'Presupuestos y Metas';

  @override
  String get savingsGoals => 'Metas de Ahorro';

  @override
  String get addBudget => 'Agregar Presupuesto';

  @override
  String get editBudget => 'Editar Presupuesto';

  @override
  String get setCategoryBudget => 'Definir Presupuesto de Categoría';

  @override
  String get budgetPeriod => 'PERÍODO DEL PRESUPUESTO';

  @override
  String get expenseCategory => 'Categoría de Gasto';

  @override
  String get monthlySpendingLimit => 'Límite de Gasto Mensual';

  @override
  String get pleaseSelectCategory => 'Por favor selecciona una categoría';

  @override
  String get pleaseEnterBudgetLimit =>
      'Por favor ingresa el límite del presupuesto';

  @override
  String get limitMustBeGreaterThanZero => 'El límite debe ser mayor a 0';

  @override
  String get saveChanges => 'Guardar Cambios';

  @override
  String get setBudget => 'Definir Presupuesto';

  @override
  String get budgetUpdatedSuccess => 'Presupuesto actualizado correctamente';

  @override
  String get budgetSetSuccess => 'Presupuesto definido correctamente';

  @override
  String errorSavingBudget(String error) {
    return 'Error al guardar el presupuesto: $error';
  }

  @override
  String get deleteBudgetLimitQuestion => '¿Eliminar Límite de Presupuesto?';

  @override
  String get confirmDeleteBudgetDetail =>
      '¿Estás seguro de que deseas eliminar este límite de presupuesto? Las transacciones registradas anteriormente no se verán afectadas.';

  @override
  String get previousMonth => 'Mes Anterior';

  @override
  String get nextMonth => 'Mes Siguiente';

  @override
  String get totalMonthlyBudget => 'PRESUPUESTO MENSUAL TOTAL';

  @override
  String percentSpent(int percent) {
    return '$percent% gastado';
  }

  @override
  String ofAmount(String amount) {
    return 'de $amount';
  }

  @override
  String totalBudgetExceededBy(String amount) {
    return 'Presupuesto total excedido por $amount';
  }

  @override
  String amountLeftForMonth(String amount) {
    return '$amount restante para el mes';
  }

  @override
  String get categoryBudgets => 'Presupuestos por Categoría';

  @override
  String configuredCount(int count) {
    return '$count configurados';
  }

  @override
  String get noBudgetsSetForMonth => 'No hay presupuestos para este mes';

  @override
  String get setMonthlyLimitsDesc =>
      'Establece límites mensuales por categoría para controlar tus gastos tocando \"+\"';

  @override
  String get categoryBudget => 'Presupuesto de Categoría';

  @override
  String budgetExceededBy(String amount) {
    return 'Excedido por $amount';
  }

  @override
  String budgetApproachingLimit(int percent) {
    return 'Cerca del límite ($percent%)';
  }

  @override
  String budgetRemainingAmount(String amount) {
    return '$amount restante';
  }

  @override
  String get budgetLimit => 'Límite del Presupuesto';

  @override
  String get spent => 'Gastado';

  @override
  String get remaining => 'Restante';

  @override
  String get overBudget => 'Excedido';

  @override
  String get period => 'Período';

  @override
  String get monthly => 'Mensual';

  @override
  String get weekly => 'Semanal';

  @override
  String get yearly => 'Anual';

  @override
  String get noBudgetsFound => 'No hay presupuestos creados para este mes';

  @override
  String get confirmDeleteBudget =>
      '¿Estás seguro de que deseas eliminar este presupuesto?';

  @override
  String get addSavingsGoal => 'Agregar Meta de Ahorro';

  @override
  String get editSavingsGoal => 'Editar Meta de Ahorro';

  @override
  String get newSavingsGoal => 'Nueva Meta de Ahorro';

  @override
  String get targetAmount => 'Monto Objetivo';

  @override
  String get currentAmount => 'Monto Actual';

  @override
  String get targetDate => 'Fecha Objetivo';

  @override
  String get goalReached => '¡Meta Alcanzada!';

  @override
  String get addFunds => 'Agregar Fondos';

  @override
  String get withdrawFunds => 'Retirar Fondos';

  @override
  String get noSavingsGoals => 'No hay metas de ahorro creadas';

  @override
  String get confirmDeleteGoal =>
      '¿Estás seguro de que deseas eliminar esta meta de ahorro?';

  @override
  String activeCount(int count) {
    return 'Activas ($count)';
  }

  @override
  String completedCount(int count) {
    return 'Completadas ($count)';
  }

  @override
  String get noActiveSavingsGoals => 'No hay metas de ahorro activas';

  @override
  String get savingsGoalsDesc =>
      'Establece metas de ahorro para vacaciones, fondos de emergencia o compras tocando \"+\"';

  @override
  String get noCompletedGoals => 'Aún no hay metas completadas';

  @override
  String get completedGoalsDesc =>
      'Las metas que alcances al 100% se celebrarán aquí';

  @override
  String depositToGoal(String goalName) {
    return 'Depositar en $goalName';
  }

  @override
  String get depositAmount => 'Monto a Depositar';

  @override
  String get pleaseEnterDepositAmount =>
      'Por favor ingresa el monto a depositar';

  @override
  String get amountMustBeGreaterThanZero => 'El monto debe ser mayor a 0';

  @override
  String get deposit => 'Depositar';

  @override
  String depositedIntoGoal(String amount, String goalName) {
    return '¡Se depositaron $amount en $goalName!';
  }

  @override
  String errorDepositingFunds(String error) {
    return 'Error al depositar fondos: $error';
  }

  @override
  String get goalTitle => 'Título de la Meta';

  @override
  String get goalTitleHint =>
      'ej., Fondo de Emergencia, Vacaciones, Nueva Laptop';

  @override
  String get pleaseEnterGoalTitle => 'Por favor ingresa un título para la meta';

  @override
  String get targetSavingsAmount => 'Monto Objetivo de Ahorro';

  @override
  String get pleaseEnterTargetAmount => 'Por favor ingresa el monto objetivo';

  @override
  String get targetAmountMustBeGreaterThanZero =>
      'El monto objetivo debe ser mayor a 0';

  @override
  String get currentSavedAmount => 'Monto Ahorrado Actual';

  @override
  String get pleaseEnterCurrentSavedAmount =>
      'Por favor ingresa el monto ahorrado actual';

  @override
  String get amountCannotBeNegative => 'El monto no puede ser negativo';

  @override
  String get targetDeadlineOptional => 'Fecha Límite Objetivo (Opcional)';

  @override
  String get noDeadlineSet => 'Sin fecha límite definida';

  @override
  String get setDate => 'Definir Fecha';

  @override
  String get selectGoalColor => 'Seleccionar Color de la Meta';

  @override
  String get selectGoalIcon => 'Seleccionar Ícono de la Meta';

  @override
  String get createSavingsGoal => 'Crear Meta de Ahorro';

  @override
  String get savingsGoalUpdatedSuccess =>
      'Meta de ahorro actualizada correctamente';

  @override
  String get savingsGoalCreatedSuccess => 'Meta de ahorro creada correctamente';

  @override
  String errorSavingGoal(String error) {
    return 'Error al guardar la meta: $error';
  }

  @override
  String get deleteSavingsGoalQuestion => '¿Eliminar Meta de Ahorro?';

  @override
  String confirmDeleteSavingsGoalDetail(String goalName) {
    return '¿Estás seguro de que deseas eliminar \"$goalName\"? Las transacciones registradas no se verán afectadas.';
  }

  @override
  String get completedTag => 'COMPLETADA';

  @override
  String targetDeadlineDate(String date) {
    return 'Objetivo: $date';
  }

  @override
  String get noTargetDeadline => 'Sin fecha límite objetivo';

  @override
  String savedAmount(String amount) {
    return '$amount ahorrado';
  }

  @override
  String targetAmountLabel(String amount) {
    return 'Objetivo: $amount';
  }

  @override
  String needMonthlySavings(String amount) {
    return 'Se necesitan ~$amount/mes para alcanzar la meta a tiempo';
  }

  @override
  String get subscriptions => 'Suscripciones';

  @override
  String get subscriptionsAndBills => 'Suscripciones y Facturas';

  @override
  String get addSubscription => 'Agregar Suscripción';

  @override
  String get editSubscription => 'Editar Suscripción';

  @override
  String get createSubscription => 'Crear Suscripción';

  @override
  String get billingCycle => 'Ciclo de Facturación';

  @override
  String get billingDay => 'Día de Cobro';

  @override
  String get nextPayment => 'Próximo Pago';

  @override
  String get monthlyTotal => 'Total Mensual';

  @override
  String get yearlyTotal => 'Total Anual';

  @override
  String get activeSubscriptions => 'Suscripciones Activas';

  @override
  String get cancelSubscription => 'Cancelar Suscripción';

  @override
  String get autoRegister => 'Auto-registrar Transacción';

  @override
  String get confirmDeleteSubscription =>
      '¿Estás seguro de que deseas eliminar esta suscripción?';

  @override
  String get noSubscriptionsFound => 'No hay suscripciones activas';

  @override
  String get freqWeekly => 'Semanal';

  @override
  String get freqBiweekly => 'Quincenal';

  @override
  String get freqMonthly => 'Mensual';

  @override
  String get freqYearly => 'Anual';

  @override
  String get freqAnnual => 'Anual';

  @override
  String pausedCount(int count) {
    return 'Pausadas ($count)';
  }

  @override
  String get monthlySubscriptionCommitment =>
      'COMPROMISO MENSUAL DE SUSCRIPCIONES';

  @override
  String get perMonth => '/mes';

  @override
  String annualProjection(String amount) {
    return 'Proyección Anual: $amount/año';
  }

  @override
  String get noActiveSubscriptions => 'No hay suscripciones activas';

  @override
  String get subscriptionsActiveDesc =>
      'Controla compromisos fijos como Netflix, Spotify o Renta tocando \"+\"';

  @override
  String get noPausedSubscriptions => 'No hay suscripciones pausadas';

  @override
  String get pausedSubscriptionsDesc =>
      'Las suscripciones pausadas aparecerán aquí';

  @override
  String postPaymentQuestion(String subName) {
    return '¿Registrar Pago de $subName?';
  }

  @override
  String confirmPaymentDetail(String amount, String accountName) {
    return 'Esto creará una transacción de gasto real de $amount desde \"$accountName\" y avanzará la siguiente fecha de pago.';
  }

  @override
  String get confirmPayment => 'Confirmar Pago';

  @override
  String paymentRecordedFor(String subName) {
    return '¡Pago registrado para $subName!';
  }

  @override
  String errorPostingPayment(String error) {
    return 'Error al registrar el pago: $error';
  }

  @override
  String get serviceName => 'Nombre del Servicio';

  @override
  String get serviceNameHint => 'ej., Netflix, Spotify, Gimnasio, Renta';

  @override
  String get pleaseEnterServiceName =>
      'Por favor ingresa un nombre de servicio';

  @override
  String get periodicAmount => 'Monto Periódico';

  @override
  String get pleaseEnterPeriodicAmount =>
      'Por favor ingresa el monto periódico';

  @override
  String get billingFrequency => 'Frecuencia de Cobro';

  @override
  String get accountToDebit => 'Cuenta a Debitar';

  @override
  String get nextDueDate => 'Próxima Fecha de Cobro';

  @override
  String get monthlyBillingDay => 'Día Mensual de Cobro:';

  @override
  String billingDayNumber(int day) {
    return 'Día $day';
  }

  @override
  String get autoRegisterTransaction => 'Auto-registrar transacción';

  @override
  String get autoRegisterDesc =>
      'Registrar automáticamente la transacción en la fecha de cobro sin confirmación manual';

  @override
  String get activeCommitment => 'Compromiso Activo';

  @override
  String get activeCommitmentDesc =>
      'Incluir en el gasto mensual estimado y cronogramas de pago';

  @override
  String get subscriptionUpdatedSuccess =>
      'Suscripción actualizada correctamente';

  @override
  String get subscriptionAddedSuccess => 'Suscripción agregada correctamente';

  @override
  String errorSavingSubscription(String error) {
    return 'Error al guardar la suscripción: $error';
  }

  @override
  String get deleteSubscriptionQuestion => '¿Eliminar Suscripción?';

  @override
  String confirmDeleteSubscriptionDetail(String subName) {
    return '¿Estás seguro de que deseas eliminar \"$subName\"? Las transacciones registradas anteriormente no se verán afectadas.';
  }

  @override
  String get pausedTag => 'PAUSADA';

  @override
  String get payAndAdvance => 'Pagar y Avanzar';

  @override
  String get autoRegistersOnDueDate =>
      'Se registra automáticamente en la fecha';

  @override
  String get manualConfirmation => 'Confirmación manual';

  @override
  String overdueDays(int days) {
    return 'Vencida ($days días)';
  }

  @override
  String get dueToday => 'Vence Hoy';

  @override
  String get dueTomorrow => 'Vence Mañana';

  @override
  String dueInDays(int days, String date) {
    return 'Vence en $days días ($date)';
  }

  @override
  String get analytics => 'Analíticas';

  @override
  String get visualAnalytics => 'Analíticas Visuales';

  @override
  String get spendingByCategory => 'Gastos por Categoría';

  @override
  String get incomeByCategory => 'Ingresos por Categoría';

  @override
  String get cashFlowTrend => 'Tendencia de Flujo de Caja';

  @override
  String get monthlyComparison => 'Comparación Mensual';

  @override
  String get noAnalyticsData =>
      'No hay suficientes datos para generar analíticas';

  @override
  String get thisMonth => 'Este Mes';

  @override
  String get lastMonth => 'Mes Pasado';

  @override
  String get last90Days => '90 Días';

  @override
  String get thisYear => 'Este Año';

  @override
  String get allTime => 'Todo el Tiempo';

  @override
  String get monthOverMonthSpendDelta => 'Variación Mensual de Gastos';

  @override
  String momIncreaseDesc(String percent, String amount) {
    return '$percent% más que el mes anterior ($amount)';
  }

  @override
  String momDecreaseDesc(String percent, String amount) {
    return '$percent% menos que el mes anterior ($amount)';
  }

  @override
  String get sixMonthCashFlowComparison =>
      'Comparativa de Flujo de Caja (6 meses)';

  @override
  String get categoryExpenseProportions =>
      'Proporciones de Gastos por Categoría';

  @override
  String get noCashflowData => 'No hay datos de flujo de caja disponibles';

  @override
  String get noExpensesPeriod => 'No hay gastos registrados en este período';

  @override
  String get settings => 'Ajustes';

  @override
  String get preferences => 'Preferencias';

  @override
  String get language => 'Idioma';

  @override
  String get selectLanguage => 'Seleccionar Idioma';

  @override
  String get systemDefault => 'Predeterminado del Sistema';

  @override
  String get spanish => 'Español';

  @override
  String get english => 'English';

  @override
  String get currency => 'Moneda';

  @override
  String get selectCurrency => 'Seleccionar Moneda';

  @override
  String get currencyUsd => 'Dólar Estadounidense (USD - \$)';

  @override
  String get currencyCop => 'Peso Colombiano (COP - \$)';

  @override
  String get dataAndStorage => 'Datos y Almacenamiento';

  @override
  String get cloudBackup => 'Copia de Seguridad en la Nube';

  @override
  String get cloudBackupDesc =>
      'Respalda y restaura tus datos con Google Drive';

  @override
  String get exportCsv => 'Exportar CSV';

  @override
  String get exportCsvDesc =>
      'Exportar transacciones a un archivo CSV de hoja de cálculo';

  @override
  String get exportSuccess => 'Datos exportados correctamente';

  @override
  String get about => 'Acerca de';

  @override
  String get appVersion => 'Versión de la App';

  @override
  String get appDescription =>
      'Rastreador de finanzas personales enfocado en la privacidad y local-first.';

  @override
  String get databaseStatus => 'Base de Datos Local';

  @override
  String get databaseStatusOk => 'Saludable (SQLite)';

  @override
  String get backupAndRestore => 'Copia de Seguridad y Restauración';

  @override
  String get backupAndExport => 'Copia de Seguridad y Exportación';

  @override
  String get googleDriveBackup => 'Copia en Google Drive';

  @override
  String get googleDriveCloudSync =>
      'Sincronización en la Nube con Google Drive';

  @override
  String get syncEncryptedSnapshotsDesc =>
      'Sincroniza copias cifradas en appDataFolder privado';

  @override
  String get googleAccount => 'Cuenta de Google';

  @override
  String get notConnected => 'No conectado';

  @override
  String get connected => 'Conectado';

  @override
  String get signInWithGoogle => 'Iniciar Sesión con Google';

  @override
  String get signOut => 'Cerrar Sesión';

  @override
  String get backupNow => 'Hacer Copia Ahora';

  @override
  String get backUpNow => 'Crear Copia Ahora';

  @override
  String get backingUp => 'Creando copia...';

  @override
  String get restoreNow => 'Restaurar Ahora';

  @override
  String get lastBackup => 'Última Copia';

  @override
  String get availableCloudBackups =>
      'Copias de Seguridad en la Nube Disponibles';

  @override
  String get noCloudBackupsFound =>
      'No se encontraron copias de seguridad en la nube';

  @override
  String get exportLedgerCsv => 'Exportar Movimientos (CSV)';

  @override
  String exportLedgerCsvDesc(int count) {
    return 'Exportar las $count transacciones con cuentas y categorías asociadas';
  }

  @override
  String get csvExportPreview => 'Vista Previa de Exportación CSV';

  @override
  String get exportDatabaseSnapshotJson =>
      'Exportar Copia de Base de Datos (JSON)';

  @override
  String get databaseSnapshotJsonDesc =>
      'Copia completa de la base de datos con suma de verificación SHA-256';

  @override
  String get databaseSnapshotJson => 'JSON de Copia de Base de Datos';

  @override
  String get restore => 'Restaurar';

  @override
  String get restoreCloudBackupQuestion =>
      '¿Restaurar Copia de Seguridad en la Nube?';

  @override
  String confirmRestoreCloudBackupDetail(String backupName) {
    return 'Esto sobrescribirá los datos locales actuales con la copia de $backupName. ¿Estás seguro?';
  }

  @override
  String get restoreData => 'Restaurar Datos';

  @override
  String get cloudBackupCreatedSuccess =>
      '¡Copia de seguridad en la nube creada con éxito!';

  @override
  String get databaseRestoredSuccess =>
      '¡Base de datos restaurada con éxito desde Google Drive!';

  @override
  String get noBackupFound =>
      'No se encontró copia de seguridad en Google Drive';

  @override
  String get backupSuccess =>
      'Copia de seguridad subida con éxito a Google Drive';

  @override
  String get restoreSuccess => 'Datos restaurados con éxito desde Google Drive';

  @override
  String get restoreWarning =>
      'Restaurar reemplazará todos los datos locales actuales con la copia de la nube. ¿Deseas continuar?';

  @override
  String get backupInProgress => 'Creando y subiendo copia cifrada...';

  @override
  String get restoreInProgress => 'Descargando y restaurando datos...';

  @override
  String get autoBackup => 'Copia Automática en la Nube';

  @override
  String get autoBackupDesc =>
      'Hacer copia automáticamente cuando ocurran cambios';

  @override
  String get categoryFoodDining => 'Comida y Restaurantes';

  @override
  String get categoryGroceries => 'Supermercado';

  @override
  String get categoryTransportation => 'Transporte';

  @override
  String get categoryHousing => 'Vivienda y Alquiler';

  @override
  String get categoryUtilities => 'Servicios Públicos';

  @override
  String get categoryEntertainment => 'Entretenimiento';

  @override
  String get categoryHealthcare => 'Salud';

  @override
  String get categoryShopping => 'Compras';

  @override
  String get categoryPersonalCare => 'Cuidado Personal';

  @override
  String get categoryEducation => 'Educación';

  @override
  String get categoryTravel => 'Viajes';

  @override
  String get categoryOtherExpense => 'Otros Gastos';

  @override
  String get categorySalary => 'Salario';

  @override
  String get categoryFreelance => 'Trabajo Independiente';

  @override
  String get categoryInvestments => 'Inversiones';

  @override
  String get categoryOtherIncome => 'Otros Ingresos';

  @override
  String get validationRequired => 'Este campo es requerido';

  @override
  String get validationInvalidAmount =>
      'Por favor ingresa un monto positivo válido';

  @override
  String get validationSameAccount =>
      'La cuenta de origen y destino deben ser diferentes';

  @override
  String get currencyConversion => 'Conversión de Moneda';

  @override
  String get exchangeRate => 'Tasa de Cambio';

  @override
  String get customRate => 'Tasa Personalizada';

  @override
  String get editExchangeRate => 'Editar Tasa de Cambio';

  @override
  String get setCustomRate => 'Definir Tasa Personalizada';

  @override
  String get resetRate => 'Restablecer a Tasa en Vivo';

  @override
  String get debitedAmount => 'Debitado de la cuenta';

  @override
  String get creditedAmount => 'Acreditado a la cuenta';

  @override
  String rateUnitFormat(String from, String rate, String to) {
    return '1 $from = $rate $to';
  }

  @override
  String get refreshRateTooltip => 'Actualizar tasa en tiempo real';

  @override
  String get exchangeRateHint => 'Tasa en vivo de open.er-api.com';

  @override
  String get ratePlaceholder => 'Tasa de cambio (ej. 4150.0)';

  @override
  String get customRateActive => 'Tasa personalizada aplicada';

  @override
  String get originalAmount => 'Monto Original';
}
