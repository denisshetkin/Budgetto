import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/generated/app_localizations.dart';
import '../l10n/l10n.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/app_header.dart';
import '../widgets/soft_card.dart';

class BudgetsScreen extends StatefulWidget {
  const BudgetsScreen({super.key});

  @override
  State<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends State<BudgetsScreen> {
  final TextEditingController _memberNameController = TextEditingController();
  final TextEditingController _familyNameController = TextEditingController();
  bool _memberNameDirty = false;
  bool _familyNameDirty = false;
  bool _familyNotificationsSaving = false;
  bool _showFamilyErrors = false;
  bool _initialized = false;

  Future<void> _toggleFamilyNotifications(
    BuildContext context,
    AppState appState,
    bool value,
  ) async {
    final l10n = context.l10n;
    if (_familyNotificationsSaving) {
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _familyNotificationsSaving = true;
    });
    final success = await appState.setFamilyNotificationsEnabled(value);
    if (!mounted) {
      return;
    }
    setState(() {
      _familyNotificationsSaving = false;
    });
    if (value && !success) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.budgetsNotificationsPermissionError)),
      );
    }
  }

  bool _validateFamilyForm(AppLocalizations l10n) {
    final memberValid =
        _memberNameController.text.trim().isNotEmpty &&
        !_isReservedSelfName(_memberNameController.text, l10n);
    final budgetValid = _familyNameController.text.trim().isNotEmpty;
    setState(() {
      _showFamilyErrors = !memberValid || !budgetValid;
    });
    if (!memberValid || !budgetValid) {
      return false;
    }
    return true;
  }

  InputDecoration _inlineInputDecoration({
    required String hint,
    required bool showError,
  }) {
    return InputDecoration(
      isDense: true,
      hintText: hint,
      hintStyle: TextStyle(
        color: showError ? AppColors.accentExpense : AppColors.textSecondary,
      ),
      border: InputBorder.none,
    );
  }

  bool _isReservedSelfName(String value, AppLocalizations l10n) {
    return value.trim().toLowerCase() == l10n.budgetsReservedSelfName;
  }

  void _openCreateBudget(BuildContext context, AppState appState) {
    final l10n = context.l10n;
    final controller = TextEditingController(text: '');
    final nameController = TextEditingController(
      text: _memberNameController.text,
    );
    var showErrors = false;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            void refresh() => setModalState(() {});
            final budgetError = showErrors && controller.text.trim().isEmpty;
            final nameError =
                showErrors &&
                (nameController.text.trim().isEmpty ||
                    _isReservedSelfName(nameController.text, l10n));
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  16 + MediaQuery.of(context).viewInsets.bottom,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.budgetsCreateTitle,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      SoftCard(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 130,
                              child: Text(
                                l10n.budgetsNameLabel,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                controller: controller,
                                decoration: _inlineInputDecoration(
                                  hint: l10n.budgetsNameHint,
                                  showError: budgetError,
                                ),
                                onChanged: (_) => refresh(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      SoftCard(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 130,
                              child: Text(
                                l10n.budgetsMemberNameLabel,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                controller: nameController,
                                decoration: _inlineInputDecoration(
                                  hint: l10n.budgetsMemberNameHint,
                                  showError: nameError,
                                ),
                                onChanged: (_) => refresh(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () async {
                            showErrors = true;
                            refresh();
                            if (controller.text.trim().isEmpty ||
                                nameController.text.trim().isEmpty ||
                                _isReservedSelfName(
                                  nameController.text,
                                  l10n,
                                )) {
                              return;
                            }
                            Navigator.of(context).pop();
                            await appState.updateDisplayName(
                              nameController.text,
                            );
                            await appState.createFamily(controller.text);
                          },
                          child: Text(l10n.commonCreate),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openJoinBudget(BuildContext context, AppState appState) {
    final l10n = context.l10n;
    final controller = TextEditingController();
    final nameController = TextEditingController(
      text: _memberNameController.text,
    );
    var showErrors = false;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            void refresh() => setModalState(() {});
            final codeError = showErrors && controller.text.trim().isEmpty;
            final nameError =
                showErrors &&
                (nameController.text.trim().isEmpty ||
                    _isReservedSelfName(nameController.text, l10n));
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  16 + MediaQuery.of(context).viewInsets.bottom,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.budgetsJoinTitle,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      SoftCard(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 130,
                              child: Text(
                                l10n.budgetsCodeLabel,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                controller: controller,
                                textCapitalization:
                                    TextCapitalization.characters,
                                decoration: _inlineInputDecoration(
                                  hint: l10n.budgetsCodeHint,
                                  showError: codeError,
                                ),
                                onChanged: (_) => refresh(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      SoftCard(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 130,
                              child: Text(
                                l10n.budgetsMemberNameLabel,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                controller: nameController,
                                decoration: _inlineInputDecoration(
                                  hint: l10n.budgetsMemberNameHint,
                                  showError: nameError,
                                ),
                                onChanged: (_) => refresh(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () async {
                            showErrors = true;
                            refresh();
                            if (controller.text.trim().isEmpty ||
                                nameController.text.trim().isEmpty ||
                                _isReservedSelfName(
                                  nameController.text,
                                  l10n,
                                )) {
                              return;
                            }
                            Navigator.of(context).pop();
                            await appState.updateDisplayName(
                              nameController.text,
                            );
                            final success = await appState.joinFamily(
                              controller.text,
                            );
                            if (!context.mounted) {
                              return;
                            }
                            if (!success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(l10n.budgetsCodeNotFound),
                                ),
                              );
                            }
                          },
                          child: Text(l10n.budgetsJoinAction),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _confirmLeaveBudget(
    BuildContext context,
    AppState appState,
  ) async {
    final l10n = context.l10n;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.budgetsLeaveTitle),
          content: Text(l10n.budgetsLeaveMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.commonCancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.budgetsLeaveAction),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await appState.leaveFamily();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) {
      return;
    }
    final appState = AppStateScope.of(context);
    _memberNameController.text = appState.currentUser.name;
    _familyNameController.text = appState.family?.name ?? '';
    _initialized = true;
  }

  @override
  void dispose() {
    _memberNameController.dispose();
    _familyNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final l10n = context.l10n;
    final family = appState.family;
    final sharedBudgets = appState.availableFamilies;
    if (family != null) {
      if (!_familyNameDirty &&
          _familyNameController.text.trim() != family.name.trim()) {
        _familyNameController.text = family.name;
      }
      if (!_memberNameDirty &&
          _memberNameController.text.trim() !=
              appState.currentUser.name.trim()) {
        _memberNameController.text = appState.currentUser.name;
      }
    }

    return Scaffold(
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            AppHeader(
              title: l10n.settingsBudgetsTitle,
              leading: Navigator.of(context).canPop()
                  ? IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_rounded),
                    )
                  : null,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => _openCreateBudget(context, appState),
                      child: Text(l10n.budgetsCreateTitle),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => _openJoinBudget(context, appState),
                      child: Text(l10n.budgetsJoinTitle),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.budgetsSectionTitle,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _BudgetRow(
                    title: l10n.budgetsPersonalTitle,
                    subtitle: l10n.budgetsPersonalSubtitle,
                    isActive: !appState.isFamilyMode,
                    onTap: () => appState.switchToPersonalBudget(),
                  ),
                  const SizedBox(height: 8),
                  ...sharedBudgets.map((budget) {
                    final isActive = family?.id == budget.id;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _BudgetRow(
                        title: budget.name,
                        subtitle: budget.inviteCode,
                        isActive: isActive,
                        onTap: () => appState.switchToFamilyBudget(budget.id),
                      ),
                    );
                  }),
                  if (family != null) ...[
                    const SizedBox(height: 20),
                    SoftCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.budgetsSettingsSectionTitle,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 12),
                          SoftCard(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 130,
                                  child: Text(
                                    l10n.budgetsNameLabel,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                ),
                                Expanded(
                                  child: TextField(
                                    controller: _familyNameController,
                                    decoration: _inlineInputDecoration(
                                      hint: l10n.budgetsNameHint,
                                      showError:
                                          _showFamilyErrors &&
                                          _familyNameController.text
                                              .trim()
                                              .isEmpty,
                                    ),
                                    onChanged: (_) {
                                      _familyNameDirty = true;
                                      if (_showFamilyErrors) {
                                        setState(() {});
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          SoftCard(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 130,
                                  child: Text(
                                    l10n.budgetsMemberNameLabel,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                ),
                                Expanded(
                                  child: TextField(
                                    controller: _memberNameController,
                                    decoration: _inlineInputDecoration(
                                      hint: l10n.budgetsMemberNameHint,
                                      showError:
                                          _showFamilyErrors &&
                                          (_memberNameController.text
                                                  .trim()
                                                  .isEmpty ||
                                              _isReservedSelfName(
                                                _memberNameController.text,
                                                l10n,
                                              )),
                                    ),
                                    onChanged: (_) {
                                      _memberNameDirty = true;
                                      if (_showFamilyErrors) {
                                        setState(() {});
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: () async {
                                if (!_validateFamilyForm(l10n)) {
                                  return;
                                }
                                if (_familyNameDirty) {
                                  await appState.updateFamilyName(
                                    _familyNameController.text,
                                  );
                                  _familyNameDirty = false;
                                }
                                if (_memberNameDirty) {
                                  await appState.updateDisplayName(
                                    _memberNameController.text,
                                  );
                                  _memberNameDirty = false;
                                }
                                if (!context.mounted) {
                                  return;
                                }
                                setState(() {
                                  _showFamilyErrors = false;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(l10n.budgetsSavedChanges),
                                  ),
                                );
                              },
                              child: Text(l10n.commonApply),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _BudgetInfoRow(
                            title: l10n.budgetsCodeLabel,
                            value: family.inviteCode,
                            trailing: IconButton(
                              onPressed: () {
                                Clipboard.setData(
                                  ClipboardData(text: family.inviteCode),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(l10n.budgetsCodeCopied),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.copy_rounded, size: 18),
                              color: AppColors.textSecondary,
                              tooltip: l10n.budgetsCopyCodeTooltip,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l10n.budgetsPersonalSettingsTitle,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          SoftCard(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l10n.budgetsNotificationsTitle,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        l10n.budgetsNotificationsDescription,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: AppColors.textSecondary,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        l10n.budgetsNotificationsPerUserHint,
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
                                const SizedBox(width: 12),
                                Switch.adaptive(
                                  value: appState.familyNotificationsEnabled,
                                  onChanged: _familyNotificationsSaving
                                      ? null
                                      : (value) => _toggleFamilyNotifications(
                                          context,
                                          appState,
                                          value,
                                        ),
                                ),
                              ],
                            ),
                          ),
                          if (appState.familyMembers.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(
                              l10n.budgetsMembersTitle,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: appState.familyMembers.map((member) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface2,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    member.name,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () =>
                                  _confirmLeaveBudget(context, appState),
                              child: Text(l10n.budgetsLeaveButton),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BudgetRow extends StatelessWidget {
  const _BudgetRow({
    required this.title,
    required this.subtitle,
    required this.isActive,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: EdgeInsets.zero,
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: isActive
            ? Icon(Icons.check_circle, color: AppColors.accentIncome)
            : Icon(Icons.circle_outlined, color: AppColors.textSecondary),
        onTap: onTap,
      ),
    );
  }
}

class _BudgetInfoRow extends StatelessWidget {
  const _BudgetInfoRow({required this.title, this.value, this.trailing});

  final String title;
  final String? value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.bodyMedium),
        ),
        Text(
          value ?? context.l10n.commonNotAvailable,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
        if (trailing != null) ...[const SizedBox(width: 6), trailing!],
      ],
    );
  }
}
