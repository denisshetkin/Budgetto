import 'package:flutter/material.dart';

import '../models/category_entry.dart';
import '../models/family_group.dart';
import '../models/payment_method.dart';
import '../models/transaction_entry.dart';
import '../models/user_profile.dart';

enum PeriodFilter { week, month }

class AppState extends ChangeNotifier {
  AppState() {
    _paymentMethods.add(
      const PaymentMethod(
        id: 'cash',
        name: 'Наличные',
        type: PaymentMethodType.cash,
        icon: Icons.payments_outlined,
        color: Color(0xFF9AD27A),
      ),
    );

    _paymentMethods.addAll([
      const PaymentMethod(
        id: 'card_wise',
        name: 'Sergey WISE',
        type: PaymentMethodType.card,
        icon: Icons.credit_card,
        color: Color(0xFF6C8BF5),
      ),
      const PaymentMethod(
        id: 'card_revolut',
        name: 'Revolut',
        type: PaymentMethodType.card,
        icon: Icons.credit_card,
        color: Color(0xFF7BD3C2),
      ),
      const PaymentMethod(
        id: 'card_tink',
        name: 'Tinkoff Black',
        type: PaymentMethodType.card,
        icon: Icons.credit_card,
        color: Color(0xFFF4B266),
      ),
    ]);

    _categories.addAll([
      CategoryEntry(
        id: 'food',
        name: 'Еда',
        icon: Icons.restaurant_outlined,
        color: _categoryPalette[0],
      ),
      CategoryEntry(
        id: 'home',
        name: 'Жилье',
        icon: Icons.home_outlined,
        color: _categoryPalette[1],
      ),
      CategoryEntry(
        id: 'transport',
        name: 'Транспорт',
        icon: Icons.directions_car_outlined,
        color: _categoryPalette[2],
      ),
      CategoryEntry(
        id: 'shopping',
        name: 'Покупки',
        icon: Icons.shopping_bag_outlined,
        color: _categoryPalette[3],
      ),
      CategoryEntry(
        id: 'health',
        name: 'Здоровье',
        icon: Icons.favorite_border,
        color: _categoryPalette[4],
      ),
      CategoryEntry(
        id: 'fun',
        name: 'Развлечения',
        icon: Icons.movie_outlined,
        color: _categoryPalette[5],
      ),
      CategoryEntry(
        id: 'education',
        name: 'Образование',
        icon: Icons.school_outlined,
        color: _categoryPalette[6],
      ),
      CategoryEntry(
        id: 'gifts',
        name: 'Подарки',
        icon: Icons.card_giftcard_outlined,
        color: _categoryPalette[7],
      ),
      CategoryEntry(
        id: 'travel',
        name: 'Путешествия',
        icon: Icons.flight_outlined,
        color: _categoryPalette[8],
      ),
      CategoryEntry(
        id: 'other',
        name: 'Прочее',
        icon: Icons.more_horiz,
        color: _categoryPalette[9],
      ),
    ]);

    _seedTransactions();
  }

  String? _currencyCode;
  final List<TransactionEntry> _transactions = [];
  final List<PaymentMethod> _paymentMethods = [];
  final List<CategoryEntry> _categories = [];
  UserProfile _currentUser = const UserProfile(id: 'local', name: 'Я');
  FamilyGroup? _family;
  bool _syncEnabled = false;

  String? get currencyCode => _currencyCode;
  UserProfile get currentUser => _currentUser;
  FamilyGroup? get family => _family;
  bool get isFamilyMode => _family != null;
  bool get syncEnabled => _syncEnabled;

  List<TransactionEntry> get transactions => List.unmodifiable(_transactions);
  List<PaymentMethod> get paymentMethods => List.unmodifiable(_paymentMethods);
  List<CategoryEntry> get categories => List.unmodifiable(_categories);

  void setCurrency(String code) {
    _currencyCode = code;
    notifyListeners();
  }

  void setUserName(String name) {
    _currentUser = _currentUser.copyWith(name: name.trim().isEmpty ? 'Я' : name.trim());
    notifyListeners();
  }

  void setSyncEnabled(bool value) {
    _syncEnabled = value;
    notifyListeners();
  }

  void createFamily(String name) {
    final id = 'fam_${DateTime.now().millisecondsSinceEpoch}';
    final code = _createInviteCode();
    _family = FamilyGroup(
      id: id,
      name: name.trim().isEmpty ? 'Семейный бюджет' : name.trim(),
      memberIds: [_currentUser.id],
      inviteCode: code,
    );
    _syncEnabled = true;
    notifyListeners();
  }

  void joinFamily(String code) {
    final normalized = code.trim().toUpperCase();
    if (normalized.isEmpty) {
      return;
    }
    _family = FamilyGroup(
      id: 'fam_$normalized',
      name: 'Семейный бюджет',
      memberIds: [_currentUser.id],
      inviteCode: normalized,
    );
    _syncEnabled = true;
    notifyListeners();
  }

  void leaveFamily() {
    _family = null;
    notifyListeners();
  }

  void addTransaction(TransactionEntry entry) {
    _transactions.insert(0, entry);
    notifyListeners();
  }

  void updateTransaction(TransactionEntry entry) {
    final index = _transactions.indexWhere((item) => item.id == entry.id);
    if (index == -1) {
      return;
    }
    _transactions[index] = entry;
    notifyListeners();
  }

  void removeTransaction(String id) {
    _transactions.removeWhere((entry) => entry.id == id);
    notifyListeners();
  }

  void addCard({required String name, required IconData icon, required Color color}) {
    final id = 'card_${DateTime.now().millisecondsSinceEpoch}';
    _paymentMethods.add(
      PaymentMethod(
        id: id,
        name: name,
        type: PaymentMethodType.card,
        icon: icon,
        color: color,
      ),
    );
    notifyListeners();
  }

  void updateCard({required String id, required String name, required IconData icon, required Color color}) {
    final index = _paymentMethods.indexWhere((method) => method.id == id);
    if (index == -1) {
      return;
    }

    final updated = PaymentMethod(
      id: id,
      name: name,
      type: PaymentMethodType.card,
      icon: icon,
      color: color,
    );

    _paymentMethods[index] = updated;

    for (var i = 0; i < _transactions.length; i++) {
      final entry = _transactions[i];
      if (entry.paymentMethod.id == id) {
        _transactions[i] = TransactionEntry(
          id: entry.id,
          type: entry.type,
          amount: entry.amount,
          categoryId: entry.categoryId,
          categoryName: entry.categoryName,
          categoryIcon: entry.categoryIcon,
          categoryColor: entry.categoryColor,
          date: entry.date,
          paymentMethod: updated,
          note: entry.note,
          createdByUserId: entry.createdByUserId,
        );
      }
    }

    notifyListeners();
  }

  void removeCard(String id) {
    _paymentMethods.removeWhere((method) => method.id == id);
    notifyListeners();
  }

  void reorderCard(int oldIndex, int newIndex) {
    final cards = _paymentMethods.where((method) => method.type == PaymentMethodType.card).toList();
    if (oldIndex < 0 || oldIndex >= cards.length) {
      return;
    }
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    if (newIndex < 0 || newIndex >= cards.length) {
      return;
    }
    final item = cards.removeAt(oldIndex);
    cards.insert(newIndex, item);
    final others = _paymentMethods.where((method) => method.type != PaymentMethodType.card).toList();
    _paymentMethods
      ..clear()
      ..addAll(others)
      ..addAll(cards);
    notifyListeners();
  }

  void addCategory({
    required String name,
    required IconData icon,
    required Color color,
  }) {
    final id = 'cat_${DateTime.now().millisecondsSinceEpoch}';
    _categories.add(
      CategoryEntry(id: id, name: name, icon: icon, color: color),
    );
    notifyListeners();
  }

  void updateCategory({
    required String id,
    required String name,
    required IconData icon,
    required Color color,
  }) {
    final index = _categories.indexWhere((category) => category.id == id);
    if (index == -1) {
      return;
    }

    final updated = CategoryEntry(
      id: id,
      name: name,
      icon: icon,
      color: color,
    );

    _categories[index] = updated;

    for (var i = 0; i < _transactions.length; i++) {
      final entry = _transactions[i];
      if (entry.categoryId == id) {
        _transactions[i] = TransactionEntry(
          id: entry.id,
          type: entry.type,
          amount: entry.amount,
          categoryId: updated.id,
          categoryName: updated.name,
          categoryIcon: updated.icon,
          categoryColor: updated.color,
          date: entry.date,
          paymentMethod: entry.paymentMethod,
          note: entry.note,
          createdByUserId: entry.createdByUserId,
        );
      }
    }

    notifyListeners();
  }

  void removeCategory(String id) {
    _categories.removeWhere((category) => category.id == id);
    notifyListeners();
  }

  void reorderCategory(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= _categories.length) {
      return;
    }
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    if (newIndex < 0 || newIndex >= _categories.length) {
      return;
    }
    final item = _categories.removeAt(oldIndex);
    _categories.insert(newIndex, item);
    notifyListeners();
  }

  String currencySymbol() {
    switch (_currencyCode) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'UAH':
        return '₴';
      case 'RUB':
        return '₽';
      case 'JPY':
        return '¥';
      default:
        return _currencyCode ?? '';
    }
  }

  double totalForPeriod(PeriodFilter filter, TransactionType type) {
    final now = DateTime.now();
    final start = _periodStart(now, filter);
    return _transactions
        .where((entry) => entry.type == type && !entry.date.isBefore(start))
        .fold(0.0, (sum, entry) => sum + entry.amount);
  }

  double balanceForPeriod(PeriodFilter filter) {
    final income = totalForPeriod(filter, TransactionType.income);
    final expense = totalForPeriod(filter, TransactionType.expense);
    return income - expense;
  }

  static DateTime _periodStart(DateTime now, PeriodFilter filter) {
    if (filter == PeriodFilter.month) {
      return DateTime(now.year, now.month);
    }

    final weekday = now.weekday;
    final start = now.subtract(Duration(days: weekday - DateTime.monday));
    return DateTime(start.year, start.month, start.day);
  }

  CategoryEntry _categoryById(String id) {
    return _categories.firstWhere((category) => category.id == id);
  }

  PaymentMethod _methodById(String id) {
    return _paymentMethods.firstWhere((method) => method.id == id);
  }

  void _seedTransactions() {
    final now = DateTime.now();
    final food = _categoryById('food');
    final home = _categoryById('home');
    final transport = _categoryById('transport');
    final fun = _categoryById('fun');
    final cash = _methodById('cash');
    final wise = _methodById('card_wise');
    final revolut = _methodById('card_revolut');

    _transactions.addAll([
      TransactionEntry(
        id: 'seed_1',
        type: TransactionType.expense,
        amount: 12.5,
        categoryId: food.id,
        categoryName: food.name,
        categoryIcon: food.icon,
        categoryColor: food.color,
        date: now.subtract(const Duration(hours: 2)),
        paymentMethod: cash,
        note: 'Кофе',
        createdByUserId: _currentUser.id,
      ),
      TransactionEntry(
        id: 'seed_2',
        type: TransactionType.expense,
        amount: 58.0,
        categoryId: home.id,
        categoryName: home.name,
        categoryIcon: home.icon,
        categoryColor: home.color,
        date: now.subtract(const Duration(hours: 6)),
        paymentMethod: wise,
        note: 'Интернет',
        createdByUserId: _currentUser.id,
      ),
      TransactionEntry(
        id: 'seed_3',
        type: TransactionType.expense,
        amount: 7.2,
        categoryId: transport.id,
        categoryName: transport.name,
        categoryIcon: transport.icon,
        categoryColor: transport.color,
        date: now.subtract(const Duration(days: 1, hours: 3)),
        paymentMethod: revolut,
        note: 'Метро',
        createdByUserId: _currentUser.id,
      ),
      TransactionEntry(
        id: 'seed_4',
        type: TransactionType.income,
        amount: 1200,
        categoryId: fun.id,
        categoryName: fun.name,
        categoryIcon: fun.icon,
        categoryColor: fun.color,
        date: now.subtract(const Duration(days: 2, hours: 4)),
        paymentMethod: wise,
        note: 'Фриланс',
        createdByUserId: _currentUser.id,
      ),
      TransactionEntry(
        id: 'seed_5',
        type: TransactionType.expense,
        amount: 34.0,
        categoryId: food.id,
        categoryName: food.name,
        categoryIcon: food.icon,
        categoryColor: food.color,
        date: now.subtract(const Duration(days: 8, hours: 2)),
        paymentMethod: revolut,
        note: 'Ужин',
        createdByUserId: _currentUser.id,
      ),
      TransactionEntry(
        id: 'seed_6',
        type: TransactionType.expense,
        amount: 19.9,
        categoryId: transport.id,
        categoryName: transport.name,
        categoryIcon: transport.icon,
        categoryColor: transport.color,
        date: now.subtract(const Duration(days: 9, hours: 1)),
        paymentMethod: cash,
        note: 'Такси',
        createdByUserId: _currentUser.id,
      ),
      TransactionEntry(
        id: 'seed_7',
        type: TransactionType.expense,
        amount: 220.0,
        categoryId: home.id,
        categoryName: home.name,
        categoryIcon: home.icon,
        categoryColor: home.color,
        date: now.subtract(const Duration(days: 35, hours: 5)),
        paymentMethod: wise,
        note: 'Коммуналка',
        createdByUserId: _currentUser.id,
      ),
      TransactionEntry(
        id: 'seed_8',
        type: TransactionType.income,
        amount: 900,
        categoryId: fun.id,
        categoryName: fun.name,
        categoryIcon: fun.icon,
        categoryColor: fun.color,
        date: now.subtract(const Duration(days: 40, hours: 3)),
        paymentMethod: wise,
        note: 'Проект',
        createdByUserId: _currentUser.id,
      ),
    ]);
  }

  String _createInviteCode() {
    final raw = DateTime.now().millisecondsSinceEpoch.toRadixString(36).toUpperCase();
    return raw.length > 6 ? raw.substring(raw.length - 6) : raw.padLeft(6, '0');
  }
}

class AppStateScope extends InheritedNotifier<AppState> {
  const AppStateScope({
    super.key,
    required super.notifier,
    required super.child,
  });

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    if (scope == null) {
      throw FlutterError('AppStateScope not found');
    }
    return scope.notifier!;
  }
}

const List<Color> _categoryPalette = [
  Color(0xFFFF8C8C),
  Color(0xFFF4B266),
  Color(0xFFF2D16B),
  Color(0xFF9AD27A),
  Color(0xFF6CBAD9),
  Color(0xFF8C9BFF),
  Color(0xFFC08CFF),
  Color(0xFFFF9FD2),
  Color(0xFF7BD3C2),
  Color(0xFFB0B7C3),
];
