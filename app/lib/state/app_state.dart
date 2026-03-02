import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/category_entry.dart';
import '../models/family_group.dart';
import '../models/payment_method.dart';
import '../models/transaction_entry.dart';
import '../models/user_profile.dart';

enum PeriodFilter { week, month }

class AppState extends ChangeNotifier {
  AppState() {
    _seedDefaults();
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _categoriesSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _methodsSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _transactionsSub;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _budgetSub;
  String? _budgetId;
  bool _initialized = false;
  String? _currencyCode;
  final List<TransactionEntry> _transactions = [];
  final List<PaymentMethod> _paymentMethods = [];
  final List<CategoryEntry> _categories = [];
  final List<UserProfile> _familyMembers = [];
  final Map<String, String> _memberNames = {};
  UserProfile _currentUser = const UserProfile(id: 'local', name: '');
  FamilyGroup? _family;
  bool _syncEnabled = false;

  bool get isReady => _initialized;
  String? get currencyCode => _currencyCode;
  UserProfile get currentUser => _currentUser;
  FamilyGroup? get family => _family;
  bool get isFamilyMode => _family != null;
  bool get syncEnabled => _syncEnabled;

  List<TransactionEntry> get transactions => List.unmodifiable(_transactions);
  List<PaymentMethod> get paymentMethods => List.unmodifiable(_paymentMethods);
  List<CategoryEntry> get categories => List.unmodifiable(_categories);
  List<UserProfile> get familyMembers => List.unmodifiable(_familyMembers);

  String? memberName(String? userId) {
    if (userId == null) {
      return null;
    }
    if (userId == _currentUser.id) {
      final name = _currentUser.name.trim();
      return name.isEmpty ? null : name;
    }
    final name = _memberNames[userId]?.trim() ?? '';
    return name.isEmpty ? null : name;
  }

  void setCurrency(String code) {
    _currencyCode = code;
    _updateBudgetField({'currencyCode': code});
    notifyListeners();
  }

  Future<void> updateDisplayName(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return;
    }
    _currentUser = _currentUser.copyWith(name: trimmed);
    _memberNames[_currentUser.id] = trimmed;
    await _updateUserField({'name': trimmed});
    if (_family != null) {
      if (_budgetId != null) {
        await _db.collection('budgets').doc(_budgetId).set({
          'membersUpdatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      await _loadFamilyMembers(_family!.memberIds);
    }
    notifyListeners();
  }

  void setSyncEnabled(bool value) {
    _syncEnabled = value;
    notifyListeners();
  }

  Future<void> createFamily(String name) async {
    final user = await _ensureSignedIn();
    final id = 'fam_${DateTime.now().millisecondsSinceEpoch}';
    final code = _createInviteCode();
    final familyName = name.trim().isEmpty ? 'Семейный бюджет' : name.trim();
    await _db.collection('budgets').doc(id).set({
      'name': familyName,
      'type': 'family',
      'ownerId': user.uid,
      'memberIds': [user.uid],
      'inviteCode': code,
      'currencyCode': _currencyCode,
      'createdAt': FieldValue.serverTimestamp(),
    });
    await _updateUserField({
      'currentBudgetId': id,
      'currentBudgetType': 'family',
    });
    _family = FamilyGroup(
      id: id,
      name: familyName,
      memberIds: [user.uid],
      inviteCode: code,
    );
    await _startSync(id);
    _syncEnabled = true;
    notifyListeners();
  }

  Future<void> updateFamilyName(String name) async {
    if (_family == null || _budgetId == null) {
      return;
    }
    final trimmed = name.trim().isEmpty ? 'Семейный бюджет' : name.trim();
    _family = _family!.copyWith(name: trimmed);
    await _db.collection('budgets').doc(_budgetId).set({
      'name': trimmed,
    }, SetOptions(merge: true));
    notifyListeners();
  }

  Future<bool> joinFamily(String code) async {
    final normalized = code.trim().toUpperCase();
    if (normalized.isEmpty) {
      return false;
    }
    final user = await _ensureSignedIn();
    final query = await _db
        .collection('budgets')
        .where('inviteCode', isEqualTo: normalized)
        .limit(1)
        .get();
    if (query.docs.isEmpty) {
      return false;
    }
    final doc = query.docs.first;
    final data = doc.data();
    await doc.reference.update({
      'memberIds': FieldValue.arrayUnion([user.uid]),
    });
    await _updateUserField({
      'currentBudgetId': doc.id,
      'currentBudgetType': 'family',
    });
    _family = FamilyGroup(
      id: doc.id,
      name: (data['name'] as String?) ?? 'Семейный бюджет',
      memberIds: List<String>.from(data['memberIds'] ?? [user.uid]),
      inviteCode: normalized,
    );
    await _startSync(doc.id);
    _syncEnabled = true;
    notifyListeners();
    return true;
  }

  Future<void> leaveFamily() async {
    final user = await _ensureSignedIn();
    if (_family != null && _budgetId != null) {
      await _db.collection('budgets').doc(_budgetId).update({
        'memberIds': FieldValue.arrayRemove([user.uid]),
      });
    }
    _family = null;
    final personalId = await _ensurePersonalBudget(user);
    await _updateUserField({
      'currentBudgetId': personalId,
      'currentBudgetType': 'personal',
    });
    await _startSync(personalId);
    notifyListeners();
  }

  void addTransaction(TransactionEntry entry) {
    _transactions.insert(0, entry);
    notifyListeners();
    _saveTransactionRemote(entry);
  }

  void updateTransaction(TransactionEntry entry) {
    final index = _transactions.indexWhere((item) => item.id == entry.id);
    if (index == -1) {
      return;
    }
    _transactions[index] = entry;
    notifyListeners();
    _saveTransactionRemote(entry);
  }

  void removeTransaction(String id) {
    _transactions.removeWhere((entry) => entry.id == id);
    notifyListeners();
    _deleteTransactionRemote(id);
  }

  Future<void> clearTransactions() async {
    _transactions.clear();
    notifyListeners();
    if (!_syncEnabled || _budgetId == null) {
      return;
    }
    final collection = _db
        .collection('budgets')
        .doc(_budgetId)
        .collection('transactions');
    var snapshot = await collection.limit(500).get();
    while (snapshot.docs.isNotEmpty) {
      final batch = _db.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      snapshot = await collection.limit(500).get();
    }
  }

  void addCard({
    required String name,
    required IconData icon,
    required Color color,
  }) {
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
    _savePaymentMethodRemote(_paymentMethods.last);
  }

  void updateCard({
    required String id,
    required String name,
    required IconData icon,
    required Color color,
  }) {
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
    _savePaymentMethodRemote(updated);
    _updateTransactionsForMethod(updated);
  }

  void removeCard(String id) {
    _paymentMethods.removeWhere((method) => method.id == id);
    notifyListeners();
    _deletePaymentMethodRemote(id);
  }

  void reorderCard(int oldIndex, int newIndex) {
    final cards = _paymentMethods
        .where((method) => method.type == PaymentMethodType.card)
        .toList();
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
    final others = _paymentMethods
        .where((method) => method.type != PaymentMethodType.card)
        .toList();
    _paymentMethods
      ..clear()
      ..addAll(others)
      ..addAll(cards);
    notifyListeners();
    _persistMethodOrder();
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
    _saveCategoryRemote(_categories.last);
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

    final updated = CategoryEntry(id: id, name: name, icon: icon, color: color);

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
    _saveCategoryRemote(updated);
    _updateTransactionsForCategory(updated);
  }

  void removeCategory(String id) {
    _categories.removeWhere((category) => category.id == id);
    notifyListeners();
    _deleteCategoryRemote(id);
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
    _persistCategoryOrder();
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

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    final user = await _ensureSignedIn();
    await _ensureUserDocument(user);
    final budgetId = await _ensurePersonalBudget(user);
    await _startSync(budgetId);
    _initialized = true;
    notifyListeners();
  }

  Future<User> _ensureSignedIn() async {
    final current = _auth.currentUser;
    if (current != null) {
      final provider = current.providerData.isNotEmpty
          ? current.providerData.first.providerId
          : null;
      _currentUser = _currentUser.copyWith(
        id: current.uid,
        provider: current.isAnonymous ? 'anonymous' : provider,
      );
      return current;
    }
    final credential = await _auth.signInAnonymously();
    final user = credential.user!;
    _currentUser = _currentUser.copyWith(id: user.uid, provider: 'anonymous');
    return user;
  }

  Future<void> _ensureUserDocument(User user) async {
    final ref = _db.collection('users').doc(user.uid);
    final snap = await ref.get();
    if (!snap.exists) {
      await ref.set({
        'name': _currentUser.name,
        'provider': _currentUser.provider,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<String> _ensurePersonalBudget(User user) async {
    final userRef = _db.collection('users').doc(user.uid);
    final userSnap = await userRef.get();
    final data = userSnap.data();
    final personalId = data?['personalBudgetId'] as String?;
    if (personalId != null) {
      return personalId;
    }

    final budgetId = _db.collection('budgets').doc().id;
    await _db.collection('budgets').doc(budgetId).set({
      'name': 'Личный бюджет',
      'type': 'personal',
      'ownerId': user.uid,
      'memberIds': [user.uid],
      'inviteCode': null,
      'currencyCode': _currencyCode,
      'createdAt': FieldValue.serverTimestamp(),
    });
    await userRef.set({
      'personalBudgetId': budgetId,
      'currentBudgetId': budgetId,
      'currentBudgetType': 'personal',
    }, SetOptions(merge: true));
    return budgetId;
  }

  Future<void> _startSync(String budgetId) async {
    await _cancelSync();
    _budgetId = budgetId;
    _syncEnabled = true;

    _budgetSub = _db.collection('budgets').doc(budgetId).snapshots().listen((
      snap,
    ) {
      if (!snap.exists) {
        return;
      }
      final data = snap.data()!;
      _currencyCode = data['currencyCode'] as String? ?? _currencyCode;
      final type = data['type'] as String? ?? 'personal';
      if (type == 'family') {
        final memberIds = List<String>.from(data['memberIds'] ?? []);
        _family = FamilyGroup(
          id: snap.id,
          name: data['name'] as String? ?? 'Семейный бюджет',
          memberIds: memberIds,
          inviteCode: data['inviteCode'] as String? ?? '',
        );
        _loadFamilyMembers(memberIds);
      } else {
        _family = null;
        _familyMembers.clear();
        _memberNames.clear();
      }
      notifyListeners();
    });

    await _seedRemoteIfEmpty(budgetId);

    _categoriesSub = _db
        .collection('budgets')
        .doc(budgetId)
        .collection('categories')
        .orderBy('order')
        .snapshots()
        .listen((snap) {
          final list = snap.docs.map(_categoryFromDoc).toList();
          _categories
            ..clear()
            ..addAll(list);
          notifyListeners();
        });

    _methodsSub = _db
        .collection('budgets')
        .doc(budgetId)
        .collection('paymentMethods')
        .orderBy('order')
        .snapshots()
        .listen((snap) {
          final list = snap.docs.map(_methodFromDoc).toList();
          _paymentMethods
            ..clear()
            ..addAll(list);
          notifyListeners();
        });

    _transactionsSub = _db
        .collection('budgets')
        .doc(budgetId)
        .collection('transactions')
        .orderBy('date', descending: true)
        .snapshots()
        .listen((snap) {
          final list = snap.docs.map(_transactionFromDoc).toList();
          _transactions
            ..clear()
            ..addAll(list);
          notifyListeners();
        });
  }

  Future<void> _cancelSync() async {
    await _categoriesSub?.cancel();
    await _methodsSub?.cancel();
    await _transactionsSub?.cancel();
    await _budgetSub?.cancel();
    _categoriesSub = null;
    _methodsSub = null;
    _transactionsSub = null;
    _budgetSub = null;
  }

  Future<void> _loadFamilyMembers(List<String> memberIds) async {
    if (memberIds.isEmpty) {
      _familyMembers.clear();
      _memberNames.clear();
      return;
    }
    final chunks = <List<String>>[];
    for (var i = 0; i < memberIds.length; i += 10) {
      chunks.add(
        memberIds.sublist(
          i,
          i + 10 > memberIds.length ? memberIds.length : i + 10,
        ),
      );
    }
    final List<UserProfile> loaded = [];
    for (final chunk in chunks) {
      final snap = await _db
          .collection('users')
          .where(FieldPath.documentId, whereIn: chunk)
          .get();
      for (final doc in snap.docs) {
        loaded.add(
          UserProfile(
            id: doc.id,
            name: (doc.data()['name'] as String?) ?? 'Без имени',
            provider: doc.data()['provider'] as String?,
          ),
        );
      }
    }
    _familyMembers
      ..clear()
      ..addAll(loaded);
    _memberNames
      ..clear()
      ..addEntries(loaded.map((member) => MapEntry(member.id, member.name)));
    notifyListeners();
  }

  Future<void> _seedRemoteIfEmpty(String budgetId) async {
    final categoryRef = _db
        .collection('budgets')
        .doc(budgetId)
        .collection('categories');
    final categorySnap = await categoryRef.limit(1).get();
    if (categorySnap.docs.isEmpty) {
      for (var i = 0; i < _categories.length; i++) {
        final category = _categories[i];
        await categoryRef.doc(category.id).set({
          'name': category.name,
          'icon': _iconToMap(category.icon),
          'color': category.color.value,
          'order': i,
        });
      }
    }

    final methodRef = _db
        .collection('budgets')
        .doc(budgetId)
        .collection('paymentMethods');
    final methodSnap = await methodRef.limit(1).get();
    if (methodSnap.docs.isEmpty) {
      for (var i = 0; i < _paymentMethods.length; i++) {
        final method = _paymentMethods[i];
        await methodRef.doc(method.id).set({
          'name': method.name,
          'type': method.type.name,
          'icon': _iconToMap(method.icon),
          'color': method.color.value,
          'order': i,
        });
      }
    }

    final txRef = _db
        .collection('budgets')
        .doc(budgetId)
        .collection('transactions');
    final txSnap = await txRef.limit(1).get();
    if (txSnap.docs.isEmpty) {
      for (final entry in _transactions) {
        await txRef.doc(entry.id).set(_transactionToMap(entry));
      }
    }
  }

  CategoryEntry _categoryFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return CategoryEntry(
      id: doc.id,
      name: data['name'] as String? ?? '',
      icon: _iconFromMap(data['icon'] as Map<String, dynamic>?),
      color: Color(
        (data['color'] as num?)?.toInt() ?? _categoryPalette.first.value,
      ),
    );
  }

  PaymentMethod _methodFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return PaymentMethod(
      id: doc.id,
      name: data['name'] as String? ?? '',
      type: _methodTypeFromString(data['type'] as String?),
      icon: _iconFromMap(data['icon'] as Map<String, dynamic>?),
      color: Color(
        (data['color'] as num?)?.toInt() ?? _categoryPalette.first.value,
      ),
    );
  }

  TransactionEntry _transactionFromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    final createdByUserId = data['createdByUserId'] as String?;
    final method = PaymentMethod(
      id: data['paymentMethodId'] as String? ?? 'cash',
      name: data['paymentMethodName'] as String? ?? 'Наличные',
      type: _methodTypeFromString(data['paymentMethodType'] as String?),
      icon: _iconFromMap(data['paymentMethodIcon'] as Map<String, dynamic>?),
      color: Color((data['paymentMethodColor'] as num?)?.toInt() ?? 0xFF9AD27A),
    );
    return TransactionEntry(
      id: doc.id,
      type: _transactionTypeFromString(data['type'] as String?),
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      categoryId: data['categoryId'] as String? ?? '',
      categoryName: data['categoryName'] as String? ?? '',
      categoryIcon: _iconFromMap(data['categoryIcon'] as Map<String, dynamic>?),
      categoryColor: Color(
        (data['categoryColor'] as num?)?.toInt() ??
            _categoryPalette.first.value,
      ),
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      paymentMethod: method,
      note: data['note'] as String?,
      createdByUserId: createdByUserId,
    );
  }

  Map<String, dynamic> _transactionToMap(TransactionEntry entry) {
    return {
      'type': entry.type.name,
      'amount': entry.amount,
      'categoryId': entry.categoryId,
      'categoryName': entry.categoryName,
      'categoryIcon': _iconToMap(entry.categoryIcon),
      'categoryColor': entry.categoryColor.value,
      'date': Timestamp.fromDate(entry.date),
      'paymentMethodId': entry.paymentMethod.id,
      'paymentMethodName': entry.paymentMethod.name,
      'paymentMethodType': entry.paymentMethod.type.name,
      'paymentMethodIcon': _iconToMap(entry.paymentMethod.icon),
      'paymentMethodColor': entry.paymentMethod.color.value,
      'note': entry.note,
      'createdByUserId': entry.createdByUserId,
    };
  }

  Map<String, dynamic> _iconToMap(IconData icon) {
    return {
      'code': icon.codePoint,
      'family': icon.fontFamily,
      'package': icon.fontPackage,
    };
  }

  IconData _iconFromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return Icons.circle;
    }
    return IconData(
      (map['code'] as num?)?.toInt() ?? Icons.circle.codePoint,
      fontFamily: map['family'] as String? ?? 'MaterialIcons',
      fontPackage: map['package'] as String?,
    );
  }

  TransactionType _transactionTypeFromString(String? raw) {
    return raw == 'income' ? TransactionType.income : TransactionType.expense;
  }

  PaymentMethodType _methodTypeFromString(String? raw) {
    return raw == 'cash' ? PaymentMethodType.cash : PaymentMethodType.card;
  }

  Future<void> _updateUserField(Map<String, dynamic> data) async {
    if (_currentUser.id == 'local') {
      return;
    }
    await _db
        .collection('users')
        .doc(_currentUser.id)
        .set(data, SetOptions(merge: true));
  }

  Future<void> _updateBudgetField(Map<String, dynamic> data) async {
    if (!_syncEnabled || _budgetId == null) {
      return;
    }
    await _db
        .collection('budgets')
        .doc(_budgetId)
        .set(data, SetOptions(merge: true));
  }

  Future<void> _saveCategoryRemote(CategoryEntry category) async {
    if (!_syncEnabled || _budgetId == null) {
      return;
    }
    await _db
        .collection('budgets')
        .doc(_budgetId)
        .collection('categories')
        .doc(category.id)
        .set({
          'name': category.name,
          'icon': _iconToMap(category.icon),
          'color': category.color.value,
          'order': _categories.indexWhere((item) => item.id == category.id),
        }, SetOptions(merge: true));
  }

  Future<void> _deleteCategoryRemote(String id) async {
    if (!_syncEnabled || _budgetId == null) {
      return;
    }
    await _db
        .collection('budgets')
        .doc(_budgetId)
        .collection('categories')
        .doc(id)
        .delete();
  }

  Future<void> _savePaymentMethodRemote(PaymentMethod method) async {
    if (!_syncEnabled || _budgetId == null) {
      return;
    }
    await _db
        .collection('budgets')
        .doc(_budgetId)
        .collection('paymentMethods')
        .doc(method.id)
        .set({
          'name': method.name,
          'type': method.type.name,
          'icon': _iconToMap(method.icon),
          'color': method.color.value,
          'order': _paymentMethods.indexWhere((item) => item.id == method.id),
        }, SetOptions(merge: true));
  }

  Future<void> _deletePaymentMethodRemote(String id) async {
    if (!_syncEnabled || _budgetId == null) {
      return;
    }
    await _db
        .collection('budgets')
        .doc(_budgetId)
        .collection('paymentMethods')
        .doc(id)
        .delete();
  }

  Future<void> _saveTransactionRemote(TransactionEntry entry) async {
    if (!_syncEnabled || _budgetId == null) {
      return;
    }
    await _db
        .collection('budgets')
        .doc(_budgetId)
        .collection('transactions')
        .doc(entry.id)
        .set(_transactionToMap(entry), SetOptions(merge: true));
  }

  Future<void> _deleteTransactionRemote(String id) async {
    if (!_syncEnabled || _budgetId == null) {
      return;
    }
    await _db
        .collection('budgets')
        .doc(_budgetId)
        .collection('transactions')
        .doc(id)
        .delete();
  }

  Future<void> _persistCategoryOrder() async {
    if (!_syncEnabled || _budgetId == null) {
      return;
    }
    final batch = _db.batch();
    for (var i = 0; i < _categories.length; i++) {
      final category = _categories[i];
      final ref = _db
          .collection('budgets')
          .doc(_budgetId)
          .collection('categories')
          .doc(category.id);
      batch.set(ref, {'order': i}, SetOptions(merge: true));
    }
    await batch.commit();
  }

  Future<void> _persistMethodOrder() async {
    if (!_syncEnabled || _budgetId == null) {
      return;
    }
    final batch = _db.batch();
    for (var i = 0; i < _paymentMethods.length; i++) {
      final method = _paymentMethods[i];
      final ref = _db
          .collection('budgets')
          .doc(_budgetId)
          .collection('paymentMethods')
          .doc(method.id);
      batch.set(ref, {'order': i}, SetOptions(merge: true));
    }
    await batch.commit();
  }

  Future<void> _updateTransactionsForCategory(CategoryEntry category) async {
    if (!_syncEnabled || _budgetId == null) {
      return;
    }
    final query = await _db
        .collection('budgets')
        .doc(_budgetId)
        .collection('transactions')
        .where('categoryId', isEqualTo: category.id)
        .get();
    final batch = _db.batch();
    for (final doc in query.docs) {
      batch.set(doc.reference, {
        'categoryName': category.name,
        'categoryIcon': _iconToMap(category.icon),
        'categoryColor': category.color.value,
      }, SetOptions(merge: true));
    }
    await batch.commit();
  }

  Future<void> _updateTransactionsForMethod(PaymentMethod method) async {
    if (!_syncEnabled || _budgetId == null) {
      return;
    }
    final query = await _db
        .collection('budgets')
        .doc(_budgetId)
        .collection('transactions')
        .where('paymentMethodId', isEqualTo: method.id)
        .get();
    final batch = _db.batch();
    for (final doc in query.docs) {
      batch.set(doc.reference, {
        'paymentMethodName': method.name,
        'paymentMethodType': method.type.name,
        'paymentMethodIcon': _iconToMap(method.icon),
        'paymentMethodColor': method.color.value,
      }, SetOptions(merge: true));
    }
    await batch.commit();
  }

  void _seedDefaults() {
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
    final raw = DateTime.now().millisecondsSinceEpoch
        .toRadixString(36)
        .toUpperCase();
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
