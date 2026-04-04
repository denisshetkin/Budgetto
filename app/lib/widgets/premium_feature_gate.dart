import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../screens/subscription_screen.dart';
import '../theme/app_colors.dart';
import 'soft_card.dart';

Future<void> openSubscriptionPlans(BuildContext context) {
  return Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => const SubscriptionScreen()));
}

Future<void> showPremiumFeatureSheet(
  BuildContext context, {
  required String featureName,
  String? message,
}) {
  final l10n = context.l10n;
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surface1,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.premiumRequiredTitle,
                style: Theme.of(
                  sheetContext,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                message ?? l10n.premiumRequiredMessage(featureName),
                style: Theme.of(sheetContext).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    openSubscriptionPlans(context);
                  },
                  child: Text(l10n.premiumViewPlans),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<void> showReadOnlyAfterTrialSheet(BuildContext context) {
  final l10n = context.l10n;
  return showPremiumFeatureSheet(
    context,
    featureName: l10n.premiumFeatureEditing,
    message: l10n.premiumReadOnlyMessage,
  );
}

class PremiumFeatureCard extends StatelessWidget {
  const PremiumFeatureCard({
    super.key,
    required this.featureName,
    this.message,
  });

  final String featureName;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.premiumRequiredTitle,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            message ?? l10n.premiumRequiredMessage(featureName),
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: () => openSubscriptionPlans(context),
            icon: const Icon(Icons.workspace_premium_outlined),
            label: Text(l10n.premiumViewPlans),
          ),
        ],
      ),
    );
  }
}

class ReadOnlyAccessCard extends StatelessWidget {
  const ReadOnlyAccessCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return PremiumFeatureCard(
      featureName: l10n.premiumFeatureEditing,
      message: l10n.premiumReadOnlyMessage,
    );
  }
}
