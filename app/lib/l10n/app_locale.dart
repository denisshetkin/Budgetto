import 'package:flutter/widgets.dart';

import 'generated/app_localizations.dart';

const supportedAppLocales = AppLocalizations.supportedLocales;

Locale? parseAppLocale(String? languageCode) {
  if (languageCode == null || languageCode.isEmpty) {
    return null;
  }

  for (final locale in supportedAppLocales) {
    if (locale.languageCode == languageCode) {
      return locale;
    }
  }

  return null;
}

bool areLocalesEqual(Locale? left, Locale? right) {
  if (identical(left, right)) {
    return true;
  }

  if (left == null || right == null) {
    return left == right;
  }

  return left.languageCode == right.languageCode;
}
