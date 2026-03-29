import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../services/data_export.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/app_header.dart';
import '../widgets/soft_card.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  static const List<_PlanConfig> _plans = [
    _PlanConfig(
      productId: AppState.yearlySubscriptionProductId,
      title: 'Годовой',
      fallbackPrice: '\$15 / год',
      badge: 'Лучшая цена',
    ),
    _PlanConfig(
      productId: AppState.quarterlySubscriptionProductId,
      title: '3 месяца',
      fallbackPrice: '\$5 / 3 месяца',
    ),
    _PlanConfig(
      productId: AppState.monthlySubscriptionProductId,
      title: 'Месячный',
      fallbackPrice: '\$2 / месяц',
    ),
  ];

  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'не задана';
    }
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day.$month.${date.year}';
  }

  String _headline(AppState appState) {
    if (appState.hasPremiumAccess) {
      return 'Premium уже активен';
    }
    if (appState.isTrialActive) {
      return 'Первые 30 дней без ограничений';
    }
    return 'Пробный период закончился';
  }

  String _subhead(AppState appState) {
    if (appState.hasPremiumAccess) {
      return 'Все функции Budgetto остаются доступны без ограничений.';
    }
    if (appState.isTrialActive) {
      return 'Осталось ${appState.trialDaysRemaining} д. до включения подписки.';
    }
    return 'Чтобы продолжить пользоваться приложением, выбери подписку.';
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      body: SafeArea(
        top: false,
        child: AnimatedBuilder(
          animation: appState,
          builder: (context, _) {
            return Column(
              children: [
                AppHeader(
                  title: 'Premium',
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                  leading: canPop
                      ? IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back),
                        )
                      : Icon(
                          Icons.workspace_premium_outlined,
                          size: 30,
                          color: AppColors.accentTotal,
                        ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                    children: [
                      SoftCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _headline(appState),
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _subhead(appState),
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _InfoChip(
                                  icon: Icons.timer_outlined,
                                  label: appState.hasPremiumAccess
                                      ? 'Без ограничений'
                                      : 'До ${_formatDate(appState.trialEndsAt)}',
                                ),
                                _InfoChip(
                                  icon: Icons.cloud_sync_outlined,
                                  label: 'Sync и backup',
                                ),
                                _InfoChip(
                                  icon: Icons.bar_chart_outlined,
                                  label: 'Расширенные отчеты',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      SoftCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Что входит в Premium',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 12),
                            const _BenefitRow(
                              icon: Icons.sync_rounded,
                              text: 'Синхронизация между устройствами',
                            ),
                            const SizedBox(height: 10),
                            const _BenefitRow(
                              icon: Icons.cloud_done_outlined,
                              text: 'Резервное копирование данных',
                            ),
                            const SizedBox(height: 10),
                            const _BenefitRow(
                              icon: Icons.insights_outlined,
                              text: 'Расширенные отчеты и аналитика',
                            ),
                            const SizedBox(height: 10),
                            const _BenefitRow(
                              icon: Icons.notifications_active_outlined,
                              text: 'Напоминания и planned-функции без лимитов',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._plans.map((plan) {
                        final product = appState.subscriptionProducts
                            .where((item) => item.id == plan.productId)
                            .cast<ProductDetails?>()
                            .firstOrNull;
                        final isCurrent =
                            appState.hasPremiumAccess &&
                            product?.id == plan.productId;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _PlanCard(
                            title: plan.title,
                            badge: plan.badge,
                            price: product?.price ?? plan.fallbackPrice,
                            enabled:
                                !appState.hasPremiumAccess &&
                                !appState.purchasePending &&
                                product != null,
                            current: isCurrent,
                            onTap: product == null
                                ? null
                                : () => appState.purchaseSubscription(
                                    plan.productId,
                                  ),
                          ),
                        );
                      }),
                      if (appState.billingError != null) ...[
                        SoftCard(
                          child: Text(
                            appState.billingError!,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.accentExpense),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (!appState.storeAvailable) ...[
                        SoftCard(
                          child: Text(
                            'Магазин платежей сейчас недоступен. Экспорт данных остается доступным.',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: appState.purchasePending
                              ? null
                              : () => appState.restorePurchases(),
                          icon: const Icon(Icons.restore_rounded),
                          label: const Text('Восстановить покупки'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => DataExport.exportTransactionsCsv(
                            context,
                            appState,
                          ),
                          icon: const Icon(Icons.ios_share),
                          label: const Text('Export my data'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Подписка продлевается автоматически, пока пользователь не отменит ее в App Store или Google Play.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (appState.purchasePending)
                  const LinearProgressIndicator(minHeight: 3),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.price,
    required this.enabled,
    required this.current,
    this.badge,
    this.onTap,
  });

  final String title;
  final String price;
  final String? badge;
  final bool enabled;
  final bool current;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (badge != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface2,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: AppColors.stroke),
                        ),
                        child: Text(
                          badge!,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: AppColors.accentTotal,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  price,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          FilledButton(
            onPressed: current ? null : (enabled ? onTap : null),
            child: Text(current ? 'Активен' : 'Выбрать'),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.accentDisplay),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.accentDisplay),
        const SizedBox(width: 10),
        Expanded(child: Text(text)),
      ],
    );
  }
}

class _PlanConfig {
  const _PlanConfig({
    required this.productId,
    required this.title,
    required this.fallbackPrice,
    this.badge,
  });

  final String productId;
  final String title;
  final String fallbackPrice;
  final String? badge;
}
