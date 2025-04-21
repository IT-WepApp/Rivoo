import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:delivery_app/presentation/providers/locale_provider.dart';

class LanguageSelectionPage extends ConsumerWidget {
  const LanguageSelectionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeNotifier = ref.read(localeProvider.notifier);
    final currentLocale = ref.watch(localeProvider);
    final supportedLanguages = localeNotifier.getSupportedLanguages();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.language),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: supportedLanguages.length,
        itemBuilder: (context, index) {
          final language = supportedLanguages[index];
          final isSelected = language['code'] == currentLocale.languageCode;

          return ListTile(
            leading: Text(
              language['flag']!,
              style: const TextStyle(fontSize: 24),
            ),
            title: Text(language['name']!),
            trailing: isSelected
                ? const Icon(Icons.check, color: Colors.green)
                : null,
            onTap: () {
              localeNotifier.changeLocale(language['code']!);
            },
          );
        },
      ),
    );
  }
}
