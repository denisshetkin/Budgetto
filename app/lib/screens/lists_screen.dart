import 'package:flutter/material.dart';

import '../models/checklist_entry.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/app_header.dart';
import '../widgets/soft_card.dart';

class ListsScreen extends StatelessWidget {
  const ListsScreen({super.key});

  void _openEditor(BuildContext context, ChecklistEntry? entry) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChecklistEditorScreen(initialEntry: entry),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    AppState appState,
    ChecklistEntry entry,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Удалить список?'),
          content: const Text('Уверен, что хочешь удалить этот список?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Удалить'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      appState.removeChecklist(entry.id);
    }
  }

  String _summary(ChecklistEntry entry) {
    final total = entry.items.length;
    if (total == 0) {
      return 'Пока нет пунктов';
    }
    final done = entry.items.where((item) => item.checked).length;
    return 'Отмечено $done из $total';
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final lists = appState.checklists;
    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            AppHeader(
              title: 'Списки',
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              leading: canPop
                  ? IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back),
                    )
                  : null,
              actions: [
                IconButton(
                  onPressed: () => _openEditor(context, null),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: lists.isEmpty
                    ? Center(
                        child: Text(
                          'Пока нет списков',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      )
                    : ListView.separated(
                        padding: EdgeInsets.zero,
                        itemCount: lists.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final entry = lists[index];
                          return GestureDetector(
                            onTap: () => _openEditor(context, entry),
                            child: SoftCard(
                              child: Row(
                                children: [
                                  Container(
                                    height: 40,
                                    width: 40,
                                    decoration: BoxDecoration(
                                      color: AppColors.surface2,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.fact_check,
                                      color: AppColors.chipBlue,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          entry.title,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _summary(entry),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: AppColors.textSecondary,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () =>
                                        _confirmDelete(context, appState, entry),
                                    icon: Icon(
                                      Icons.delete,
                                      color: AppColors.accentExpense,
                                    ),
                                    iconSize: 22,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints.tightFor(
                                      width: 32,
                                      height: 32,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChecklistEditorScreen extends StatefulWidget {
  const ChecklistEditorScreen({super.key, this.initialEntry});

  final ChecklistEntry? initialEntry;

  @override
  State<ChecklistEditorScreen> createState() => _ChecklistEditorScreenState();
}

class _ChecklistEditorScreenState extends State<ChecklistEditorScreen> {
  final List<_EditableChecklistItem> _items = [];
  late final TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.initialEntry?.title ?? '');
    final initialItems = widget.initialEntry?.items ?? [];
    if (initialItems.isEmpty) {
      _items.add(_createEditableItem());
    } else {
      for (final item in initialItems) {
        _items.add(
          _EditableChecklistItem(
            id: item.id,
            title: item.title,
            checked: item.checked,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    for (final item in _items) {
      item.controller.dispose();
    }
    _titleController.dispose();
    super.dispose();
  }

  String _createItemId() {
    return 'item_${DateTime.now().microsecondsSinceEpoch}';
  }

  String _createListId() {
    return 'list_${DateTime.now().millisecondsSinceEpoch}';
  }

  _EditableChecklistItem _createEditableItem() {
    return _EditableChecklistItem(
      id: _createItemId(),
      title: '',
      checked: false,
    );
  }

  void _addItem() {
    setState(() {
      _items.add(_createEditableItem());
    });
  }

  void _removeItem(int index) {
    setState(() {
      final removed = _items.removeAt(index);
      removed.controller.dispose();
      if (_items.isEmpty) {
        _items.add(_createEditableItem());
      }
    });
  }

  bool _hasUserInput() {
    if (_titleController.text.trim().isNotEmpty) {
      return true;
    }
    for (final item in _items) {
      if (item.controller.text.trim().isNotEmpty) {
        return true;
      }
    }
    return false;
  }

  ChecklistEntry? _buildEntry() {
    final items = <ChecklistItem>[];
    for (final item in _items) {
      final title = item.controller.text.trim();
      if (title.isEmpty) {
        continue;
      }
      items.add(
        ChecklistItem(
          id: item.id,
          title: title,
          checked: item.checked,
        ),
      );
    }

    if (widget.initialEntry == null && !_hasUserInput()) {
      return null;
    }

    final fallbackTitle = widget.initialEntry?.title ?? 'Список';
    final title = _titleController.text.trim().isEmpty
        ? fallbackTitle
        : _titleController.text.trim();

    return ChecklistEntry(
      id: widget.initialEntry?.id ?? _createListId(),
      title: title,
      items: items,
      createdAt: widget.initialEntry?.createdAt ?? DateTime.now(),
    );
  }

  bool _isEntryEqual(ChecklistEntry current, ChecklistEntry initial) {
    if (current.title != initial.title) {
      return false;
    }
    if (current.items.length != initial.items.length) {
      return false;
    }
    for (var i = 0; i < current.items.length; i++) {
      final a = current.items[i];
      final b = initial.items[i];
      if (a.id != b.id || a.title != b.title || a.checked != b.checked) {
        return false;
      }
    }
    return true;
  }

  Future<void> _save({required bool pop}) async {
    final appState = AppStateScope.of(context);
    final entry = _buildEntry();
    if (entry == null) {
      if (pop) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Добавь название или пункт списка')),
        );
      }
      return;
    }

    final initial = widget.initialEntry;
    if (initial == null) {
      appState.addChecklist(entry);
    } else if (!_isEntryEqual(entry, initial)) {
      appState.updateChecklist(entry);
    }

    if (pop && mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<bool> _handleWillPop() async {
    await _save(pop: false);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final canPop = Navigator.of(context).canPop();

    return WillPopScope(
      onWillPop: _handleWillPop,
      child: Scaffold(
        body: SafeArea(
          top: false,
          child: Column(
            children: [
            AppHeader(
              title: widget.initialEntry == null
                  ? 'Новый список'
                  : 'Список',
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              leading: canPop
                  ? IconButton(
                      onPressed: () async {
                        await _save(pop: false);
                          if (mounted) {
                            Navigator.of(context).pop();
                          }
                        },
                        icon: const Icon(Icons.arrow_back),
                      )
                    : null,
                actions: [
                  TextButton(
                    onPressed: () => _save(pop: true),
                    child: const Text('Сохранить'),
                  ),
                ],
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(12, 12, 12, 12 + bottomInset),
                  children: [
                    SoftCard(
                      child: TextField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          hintText: 'Название списка',
                          border: InputBorder.none,
                        ),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SoftCard(
                      child: Column(
                        children: [
                          for (var i = 0; i < _items.length; i++) ...[
                            Row(
                              children: [
                                Checkbox(
                                  value: _items[i].checked,
                                  onChanged: (value) {
                                    if (value == null) {
                                      return;
                                    }
                                    setState(() {
                                      _items[i].checked = value;
                                    });
                                  },
                                ),
                                Expanded(
                                  child: TextField(
                                    controller: _items[i].controller,
                                    decoration: const InputDecoration(
                                      hintText: 'Пункт списка',
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => _removeItem(i),
                                  icon: Icon(
                                    Icons.close,
                                    color: AppColors.accentExpense,
                                  ),
                                  iconSize: 20,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints.tightFor(
                                    width: 28,
                                    height: 28,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _addItem,
                      icon: Icon(
                        Icons.add,
                        color: AppColors.accentIncome,
                      ),
                      label: const Text('Добавить пункт'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditableChecklistItem {
  _EditableChecklistItem({
    required this.id,
    required String title,
    required this.checked,
  }) : controller = TextEditingController(text: title);

  final String id;
  final TextEditingController controller;
  bool checked;
}
