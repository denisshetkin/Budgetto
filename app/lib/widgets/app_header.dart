import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
    required this.title,
    this.leading,
    this.actions = const [],
    this.padding,
  });

  final String title;
  final Widget? leading;
  final List<Widget> actions;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final resolvedPadding =
        padding ?? const EdgeInsets.fromLTRB(20, 20, 20, 12);
    final theme = Theme.of(context);
    final overlayStyle = theme.brightness == Brightness.dark
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle.copyWith(
        statusBarColor: AppColors.chrome,
        statusBarBrightness:
            theme.brightness == Brightness.dark ? Brightness.dark : Brightness.light,
        statusBarIconBrightness:
            theme.brightness == Brightness.dark ? Brightness.light : Brightness.dark,
      ),
      child: Container(
        color: AppColors.chrome,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: resolvedPadding,
                child: SizedBox(
                  height: 48,
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (leading != null) leading!,
                            if (title.isNotEmpty) ...[
                              if (leading != null) const SizedBox(width: 12),
                              Flexible(
                                child: Text(
                                  title,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleLarge
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (actions.isNotEmpty)
                        Row(mainAxisSize: MainAxisSize.min, children: actions),
                    ],
                  ),
                ),
              ),
              Container(height: 1, color: AppColors.stroke),
            ],
          ),
        ),
      ),
    );
  }
}
