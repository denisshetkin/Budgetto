import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:intl/intl.dart';

import '../l10n/l10n.dart';
import '../l10n/generated/app_localizations.dart';
import '../services/data_export.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/app_header.dart';
import '../widgets/soft_card.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  String _formatDate(DateTime? date, String localeTag, AppLocalizations l10n) {
    if (date == null) {
      return l10n.subscriptionDateNotSet;
    }
    return DateFormat.yMd(localeTag).format(date);
  }

  String _headline(AppState appState, AppLocalizations l10n) {
    if (appState.hasPremiumAccess) {
      return l10n.subscriptionHeadlineActive;
    }
    if (appState.isTrialActive) {
      return l10n.subscriptionHeadlineTrial;
    }
    return l10n.subscriptionHeadlineExpired;
  }

  String _subhead(AppState appState, AppLocalizations l10n) {
    if (appState.hasPremiumAccess) {
      return l10n.subscriptionSubheadActive;
    }
    if (appState.isTrialActive) {
      return l10n.subscriptionSubheadTrial(appState.trialDaysRemaining);
    }
    return l10n.subscriptionSubheadExpired;
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final canPop = Navigator.of(context).canPop();
    final l10n = context.l10n;
    final localeTag = Localizations.localeOf(context).toLanguageTag();
    final plans = [
      _PlanConfig(
        productId: AppState.yearlySubscriptionProductId,
        title: l10n.subscriptionPlanYearlyTitle,
        fallbackPrice: l10n.subscriptionPlanYearlyFallback,
        badge: l10n.subscriptionPlanBestBadge,
      ),
      _PlanConfig(
        productId: AppState.quarterlySubscriptionProductId,
        title: l10n.subscriptionPlanQuarterlyTitle,
        fallbackPrice: l10n.subscriptionPlanQuarterlyFallback,
      ),
      _PlanConfig(
        productId: AppState.monthlySubscriptionProductId,
        title: l10n.subscriptionPlanMonthlyTitle,
        fallbackPrice: l10n.subscriptionPlanMonthlyFallback,
      ),
    ];

    return Scaffold(
      body: SafeArea(
        top: false,
        child: AnimatedBuilder(
          animation: appState,
          builder: (context, _) {
            return Column(
              children: [
                AppHeader(
                  title: l10n.settingsPremiumTitle,
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
                              _headline(appState, l10n),
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _subhead(appState, l10n),
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
                                      ? l10n.subscriptionUnlimited
                                      : l10n.subscriptionUntil(
                                          _formatDate(
                                            appState.trialEndsAt,
                                            localeTag,
                                            l10n,
                                          ),
                                        ),
                                ),
                                _InfoChip(
                                  icon: Icons.cloud_sync_outlined,
                                  label: l10n.subscriptionSyncBackup,
                                ),
                                _InfoChip(
                                  icon: Icons.bar_chart_outlined,
                                  label: l10n.subscriptionExtendedReports,
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
                              l10n.subscriptionIncludedTitle,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 12),
                            _BenefitRow(
                              icon: Icons.sync_rounded,
                              text: l10n.subscriptionBenefitSync,
                            ),
                            const SizedBox(height: 10),
                            _BenefitRow(
                              icon: Icons.cloud_done_outlined,
                              text: l10n.subscriptionBenefitBackup,
                            ),
                            const SizedBox(height: 10),
                            _BenefitRow(
                              icon: Icons.insights_outlined,
                              text: l10n.subscriptionBenefitReports,
                            ),
                            const SizedBox(height: 10),
                            _BenefitRow(
                              icon: Icons.notifications_active_outlined,
                              text: l10n.subscriptionBenefitReminders,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...plans.map((plan) {
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
                            activeLabel: l10n.subscriptionPlanActive,
                            selectLabel: l10n.commonSelect,
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
                            l10n.subscriptionStoreUnavailable,
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
                          label: Text(l10n.subscriptionRestorePurchases),
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
                          label: Text(l10n.subscriptionExportMyData),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.subscriptionRenewalNote,
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
    required this.activeLabel,
    required this.selectLabel,
    this.badge,
    this.onTap,
  });

  final String title;
  final String price;
  final String? badge;
  final bool enabled;
  final bool current;
  final String activeLabel;
  final String selectLabel;
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
            child: Text(current ? activeLabel : selectLabel),
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
