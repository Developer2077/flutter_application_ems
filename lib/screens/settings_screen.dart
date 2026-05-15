import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../services/notification_service.dart';
import 'location_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.locale,
    required this.themeMode,
    required this.onLocaleToggle,
    required this.onThemeModeChanged,
    required this.onLocationChanged,
  });

  final Locale locale;
  final ThemeMode themeMode;
  final VoidCallback onLocaleToggle;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final VoidCallback onLocationChanged;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final theme = Theme.of(context);
    final isItalian = locale.languageCode == 'it';

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _HeaderCard(strings: strings, theme: theme),
        const SizedBox(height: 16),
        _LocationLinkCard(strings: strings, onLocationChanged: onLocationChanged),
        const SizedBox(height: 24),
        _LanguageCard(
          strings: strings,
          isItalian: isItalian,
          onToggle: onLocaleToggle,
        ),
        const SizedBox(height: 16),
        _ThemeCard(
          strings: strings,
          themeMode: themeMode,
          onChanged: onThemeModeChanged,
        ),
        const SizedBox(height: 16),
        _FeaturesCard(strings: strings),
        const SizedBox(height: 16),
        _TestNotificationCard(strings: strings),
      ],
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.strings, required this.theme});

  final AppStrings strings;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.secondaryContainer,
            theme.colorScheme.primaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(22),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.settingsTitle,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  strings.settingsSubtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer.withOpacity(
                      0.92,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Icon(
            Icons.settings_outlined,
            size: 46,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ],
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  const _LanguageCard({
    required this.strings,
    required this.isItalian,
    required this.onToggle,
  });

  final AppStrings strings;
  final bool isItalian;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.languageSectionTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              children: [
                ChoiceChip(
                  label: const Text('IT'),
                  selected: isItalian,
                  onSelected: (_) {
                    if (!isItalian) {
                      onToggle();
                    }
                  },
                ),
                ChoiceChip(
                  label: const Text('EN'),
                  selected: !isItalian,
                  onSelected: (_) {
                    if (isItalian) {
                      onToggle();
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text('${strings.languageCurrent}: ${isItalian ? 'IT' : 'EN'}'),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  const _ThemeCard({
    required this.strings,
    required this.themeMode,
    required this.onChanged,
  });

  final AppStrings strings;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.themeSectionTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ChoiceChip(
                  label: Text(strings.themeSystem),
                  selected: themeMode == ThemeMode.system,
                  onSelected: (_) => onChanged(ThemeMode.system),
                ),
                ChoiceChip(
                  label: Text(strings.themeLight),
                  selected: themeMode == ThemeMode.light,
                  onSelected: (_) => onChanged(ThemeMode.light),
                ),
                ChoiceChip(
                  label: Text(strings.themeDark),
                  selected: themeMode == ThemeMode.dark,
                  onSelected: (_) => onChanged(ThemeMode.dark),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '${strings.themeCurrent}: ${switch (themeMode) {
                ThemeMode.system => strings.themeSystem,
                ThemeMode.light => strings.themeLight,
                ThemeMode.dark => strings.themeDark,
              }}',
            ),
          ],
        ),
      ),
    );
  }
}

class _FeaturesCard extends StatelessWidget {
  const _FeaturesCard({required this.strings});

  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.featuresSectionTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            _FeatureRow(
              icon: Icons.wb_sunny_outlined,
              text: strings.featureOne,
            ),
            _FeatureRow(icon: Icons.bolt_outlined, text: strings.featureTwo),
            _FeatureRow(
              icon: Icons.notifications_active_outlined,
              text: strings.featureThree,
            ),
            _FeatureRow(
              icon: Icons.brightness_6_outlined,
              text: strings.featureFour,
            ),
            _FeatureRow(
              icon: Icons.translate_outlined,
              text: strings.featureFive,
            ),
            _FeatureRow(
              icon: Icons.notifications_outlined,
              text: strings.featureSix,
            ),

          ],
        ),
      ),
    );
  }
}



class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _LocationLinkCard extends StatelessWidget {
  const _LocationLinkCard({required this.strings, required this.onLocationChanged});
  final AppStrings strings;
  final VoidCallback onLocationChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => LocationScreen(onLocationChanged: onLocationChanged),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(Icons.place, color: theme.colorScheme.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(strings.savedLocationTitle, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(strings.changeLocation, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: theme.colorScheme.onSurface.withAlpha(100)),
            ],
          ),
        ),
      ),
    );
  }
}

class _TestNotificationCard extends StatelessWidget {
  const _TestNotificationCard({required this.strings});
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.notifications_active_outlined,
                    color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(strings.notificationsEnabled,
                    style: theme.textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: 10),
            Text(strings.notificationsInfo),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () async {
                  await NotificationService.instance.showInstant(
                    title: '☀️ CER Smart — Test',
                    body: strings.testNotificationBody,
                    id: 9999,
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(strings.testNotificationSent)),
                    );
                  }
                },
                icon: const Icon(Icons.send_outlined),
                label: Text(strings.testNotification),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
