import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import '../models/appliance_suggestion.dart';
import '../models/solar_forecast.dart';
import 'notification_banner.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    required this.cityController,
    required this.forecast,
    required this.loading,
    required this.errorMessage,
    required this.lastUpdated,
    required this.onSearch,
    required this.onOpenForecast,
    this.tomorrowForecast,
    this.activeBanner,
    this.onDismissBanner,
    this.scrollController,
  });

  final TextEditingController cityController;
  final SolarForecast? forecast;
  final SolarForecast? tomorrowForecast;
  final bool loading;
  final String? errorMessage;
  final DateTime? lastUpdated;
  final VoidCallback onSearch;
  final VoidCallback onOpenForecast;
  final BannerData? activeBanner;
  final VoidCallback? onDismissBanner;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final theme = Theme.of(context);
    final localizations = MaterialLocalizations.of(context);

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.all(20),
      children: [
        // Banner notifica in-app animato
        if (activeBanner != null)
          NotificationBanner(
            type: activeBanner!.type,
            title: activeBanner!.title,
            body: activeBanner!.body,
            onDismiss: onDismissBanner ?? () {},
          ),
        _CompactSearchHeader(
          strings: strings,
          controller: cityController,
          onSearch: onSearch,
          loading: loading,
          forecast: forecast,
        ),
        const SizedBox(height: 16),
        if (loading)
          const _LoadingCard()
        else ...[
          if (errorMessage != null)
            _MessageCard(
              icon: Icons.cloud_off_outlined,
              title: strings.errorPrefix,
              body: errorMessage!,
            ),
          if (errorMessage != null) const SizedBox(height: 16),
          if (forecast == null)
            _MessageCard(
              icon: Icons.location_on_outlined,
              title: strings.noForecastTitle,
              body: strings.noForecastBody,
            )
          else ...[
            if (forecast!.isOffline) ...[
              Card(
                color: theme.colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.offline_bolt_outlined, color: theme.colorScheme.onErrorContainer),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Sei offline. Sto mostrando i dati dell\'ultimo aggiornamento riuscito.',
                          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onErrorContainer),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            // Nuova Super-Card "Stato Attuale"
            _HeroStatusCard(forecast: forecast!, strings: strings),
            const SizedBox(height: 16),
            // Griglia elettrodomestici in primo piano
            _AppliancesCard(forecast: forecast!, strings: strings),
            const SizedBox(height: 16),
            // Banner serale contestuale
            if (_isEvening() && tomorrowForecast?.bestWindow != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _EveningBanner(
                  forecast: tomorrowForecast!,
                  strings: strings,
                ),
              ),
            // Metriche secondarie (temperature, etc)
            _MetricsGrid(forecast: forecast!, strings: strings),
            const SizedBox(height: 16),
            // Carosello scorrevole dei suggerimenti (Tutorial non intrusivi)
            _TipsCarousel(strings: strings),
            const SizedBox(height: 16),
            _UpdatedCard(
              strings: strings,
              value: lastUpdated == null
                  ? strings.offlineMessage
                  : '${localizations.formatShortDate(lastUpdated!)} ${localizations.formatTimeOfDay(TimeOfDay.fromDateTime(lastUpdated!))}',
            ),
          ],
        ],
      ],
    );
  }

  bool _isEvening() {
    final hour = DateTime.now().hour;
    return hour >= 18 || hour < 6;
  }
}

// ── Dati per il banner di notifica ──
class BannerData {
  const BannerData({required this.type, required this.title, required this.body});
  final NotificationBannerType type;
  final String title;
  final String body;
}



// ── Punto verde pulsante ──
class _PulsingDot extends StatefulWidget {
  const _PulsingDot({required this.color});
  final Color color;
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 0.3, end: 1.0).animate(_ctrl),
      child: Container(width: 12, height: 12, decoration: BoxDecoration(shape: BoxShape.circle, color: widget.color)),
    );
  }
}

// ── Griglia elettrodomestici – punto 3.3 ──
class _AppliancesCard extends StatelessWidget {
  const _AppliancesCard({required this.forecast, required this.strings});
  final SolarForecast forecast;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final suggestions = ApplianceSuggestion.fromForecast(forecast);
    if (suggestions.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.kitchen_outlined, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(strings.appliancesTitle, style: theme.textTheme.titleLarge),
            ]),
            const SizedBox(height: 6),
            Text(strings.appliancesSubtitle, style: theme.textTheme.bodySmall),
            const SizedBox(height: 14),
            LayoutBuilder(
              builder: (context, constraints) {
                // Calcoliamo la larghezza per 2 colonne considerando lo spazio tra le card
                final double spacing = 10;
                final double itemWidth = (constraints.maxWidth - spacing) / 2;
                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: suggestions.map((s) => _ApplianceTile(
                    suggestion: s, 
                    strings: strings,
                    width: itemWidth,
                  )).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ApplianceTile extends StatelessWidget {
  const _ApplianceTile({
    required this.suggestion, 
    required this.strings,
    required this.width,
  });
  final ApplianceSuggestion suggestion;
  final AppStrings strings;
  final double width;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final statusText = switch (suggestion.level) {
      RecommendationLevel.optimal => strings.startNow,
      RecommendationLevel.good => strings.scheduleAt(_fmt(suggestion.windowStart)),
      RecommendationLevel.poor => strings.notRecommended,
    };

    return Container(
      width: width,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: suggestion.background(scheme),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: suggestion.color(scheme).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(suggestion.icon, color: suggestion.color(scheme), size: 28),
          const SizedBox(height: 8),
          Text(
            strings.applianceName(suggestion.type.name), 
            style: theme.textTheme.labelLarge,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            statusText, 
            style: theme.textTheme.bodySmall?.copyWith(
              color: suggestion.color(scheme), 
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ── Banner serale per domani – punto 3.4 ──
class _EveningBanner extends StatelessWidget {
  const _EveningBanner({required this.forecast, required this.strings});
  final SolarForecast forecast;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final best = forecast.bestWindow!;
    final fg = theme.colorScheme.onTertiaryContainer;
    return Semantics(
      label: strings.eveningSuggestionBody(_fmt(best.start), _fmt(best.end)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: theme.colorScheme.tertiaryContainer,
          border: Border.all(color: fg.withAlpha(40)),
        ),
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Icon(Icons.nightlight_round, color: fg, size: 32),
            const SizedBox(width: 14),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(strings.eveningSuggestionTitle,
                  style: theme.textTheme.titleSmall?.copyWith(color: fg, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(strings.eveningSuggestionBody(_fmt(best.start), _fmt(best.end)),
                  style: theme.textTheme.bodySmall?.copyWith(color: fg.withAlpha(220))),
              ],
            )),
          ],
        ),
      ),
    );
  }
}


// ── Widget esistenti (inalterati) ──

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();
  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(children: [const CircularProgressIndicator(), const SizedBox(height: 12), Text(strings.loading)])));
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({required this.icon, required this.title, required this.body});
  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(child: Padding(padding: const EdgeInsets.all(20), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: theme.colorScheme.primary), const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: theme.textTheme.titleMedium), const SizedBox(height: 6), Text(body, style: theme.textTheme.bodyMedium),
      ])),
    ])));
  }
}

class _CompactSearchHeader extends StatefulWidget {
  const _CompactSearchHeader({
    required this.strings,
    required this.controller,
    required this.onSearch,
    required this.loading,
    this.forecast,
  });

  final AppStrings strings;
  final TextEditingController controller;
  final VoidCallback onSearch;
  final bool loading;
  final SolarForecast? forecast;

  @override
  State<_CompactSearchHeader> createState() => _CompactSearchHeaderState();
}

class _CompactSearchHeaderState extends State<_CompactSearchHeader> {
  bool _hasCity = false;

  @override
  void initState() {
    super.initState();
    _hasCity = widget.controller.text.trim().isNotEmpty;
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final newHasCity = widget.controller.text.trim().isNotEmpty;
    if (newHasCity != _hasCity) {
      setState(() { _hasCity = newHasCity; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitle = widget.forecast?.locationSubtitle ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          elevation: 0,
          color: theme.colorScheme.surfaceContainerHighest,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: TextField(
              controller: widget.controller,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => widget.onSearch(),
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              decoration: InputDecoration(
                hintText: widget.strings.searchHint,
                labelText: _hasCity ? widget.strings.searchLabel : null,
                labelStyle: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                floatingLabelBehavior: FloatingLabelBehavior.auto,
                prefixIcon: Icon(Icons.place_outlined, color: theme.colorScheme.primary, size: 26),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_hasCity)
                      IconButton(
                        icon: Icon(Icons.clear, color: theme.colorScheme.onSurfaceVariant, size: 24),
                        tooltip: 'Cambia località',
                        onPressed: () {
                          widget.controller.clear();
                          widget.onSearch(); // This will clear the forecast in home.dart
                        },
                      ),
                    IconButton(
                      icon: widget.loading
                          ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.primary))
                          : Icon(Icons.search, color: theme.colorScheme.primary),
                      onPressed: widget.loading ? null : widget.onSearch,
                    ),
                  ],
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
        ),
        // Dettagli località sotto la barra di ricerca
        if (_hasCity && subtitle.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 4),
            child: Text(subtitle, style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            )),
          ),
      ],
    );
  }
}

class _HeroStatusCard extends StatelessWidget {
  const _HeroStatusCard({required this.forecast, required this.strings});
  final SolarForecast forecast;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final best = forecast.bestWindow;
    final isHigh = forecast.isCurrentlyHighProduction;
    final timeUntil = forecast.timeUntilNextWindow;
    final soon = timeUntil != null && timeUntil.inHours < 3 && !isHigh;
    // Distinguiamo chiaramente: il best window è la finestra con le migliori
    // prestazioni, ma potrebbe essere nel futuro. Lo stato in tempo reale
    // dipende solo da isHigh.

    final Color statusBg;
    final IconData statusIcon;
    final String statusLabel;

    if (isHigh) {
      statusBg = const Color(0xFF2E7D32);
      statusIcon = Icons.wb_sunny;
      statusLabel = strings.productionStatusHigh;
    } else if (soon) {
      statusBg = const Color(0xFFE65100);
      statusIcon = Icons.hourglass_top;
      statusLabel = '${strings.productionStatusSoon} (${strings.countdown(timeUntil.inHours, timeUntil.inMinutes % 60)})';
    } else {
      statusBg = theme.colorScheme.surfaceContainerHighest;
      statusIcon = Icons.nightlight_round;
      statusLabel = strings.productionStatusNone;
    }

    final statusFg = isHigh || soon ? Colors.white : theme.colorScheme.onSurface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Status badge in tempo reale ──
        Semantics(
          label: statusLabel,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: statusBg,
              boxShadow: isHigh || soon ? [
                BoxShadow(color: statusBg.withOpacity(0.25), blurRadius: 12, offset: const Offset(0, 6))
              ] : null,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Row(
              children: [
                Icon(statusIcon, color: statusFg, size: 24),
                const SizedBox(width: 12),
                Expanded(child: Text(statusLabel, style: theme.textTheme.titleSmall?.copyWith(color: statusFg, fontWeight: FontWeight.w700))),
                if (isHigh) _PulsingDot(color: statusFg),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // ── Card informativa: miglior finestra della giornata ──
        if (best == null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(strings.noWindowAvailable, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(strings.noWindowBody, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          )
        else
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(strings.bestMoment, style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary)),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Icon(Icons.schedule, color: theme.colorScheme.primary, size: 22),
                      const SizedBox(width: 8),
                      Text('${_fmt(best.start)} – ${_fmt(best.end)}',
                        style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      _InfoChip(icon: Icons.bolt, label: '${best.averageRadiation.toStringAsFixed(0)} W/m²'),
                      _InfoChip(icon: Icons.star_outline, label: 'Score: ${best.averageScore.toStringAsFixed(0)}'),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(
          theme.brightness == Brightness.light ? 0.9 : 0.4,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 4),
          Text(label, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  const _MetricsGrid({required this.forecast, required this.strings});
  final SolarForecast forecast;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    // Calcolo stimato: rad(W/m²) / 1000 * 3kWp * ore_luce * 0.18 (efficienza) * 0.75 (perdite varie)
    // Molto semplificato. L'idea è avere un numero indicativo.
    final avg = forecast.bestWindow?.averageRadiation ?? 0;
    final kwh = (avg / 1000 * 3.0 * forecast.daylightHours * 0.18 * 0.75).toStringAsFixed(1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(spacing: 12, runSpacing: 12, children: [
          _MetricTile(icon: Icons.wb_sunny_outlined, title: strings.daylightHours, value: forecast.daylightHours.toString()),
          _MetricTile(icon: Icons.bar_chart_outlined, title: strings.topWindowsTitle, value: forecast.windows.length.toString()),
          if (forecast.sunrise != null)
            _MetricTile(icon: Icons.brightness_6_outlined, title: strings.sunriseLabel, value: _fmt(forecast.sunrise!)),
          if (forecast.sunset != null)
            _MetricTile(icon: Icons.brightness_4_outlined, title: strings.sunsetLabel, value: _fmt(forecast.sunset!)),
        ]),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.solar_power_outlined, color: Theme.of(context).colorScheme.primary, size: 28),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(strings.estimatedProduction, style: Theme.of(context).textTheme.labelLarge),
                      const SizedBox(height: 4),
                      Text(strings.estimatedKwh(kwh), style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 2),
                      Text(strings.productionAssumption, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.icon, required this.title, required this.value});
  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(width: (MediaQuery.of(context).size.width - 52) / 2, child: Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [Icon(icon, color: theme.colorScheme.primary), const SizedBox(height: 10), Text(title, style: theme.textTheme.labelLarge), const SizedBox(height: 4), Text(value, style: theme.textTheme.headlineSmall)],
    ))));
  }
}

class _TipsCarousel extends StatelessWidget {
  const _TipsCarousel({required this.strings});
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text('Consigli utili', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: ListView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            children: [
              _TipCard(
                icon: Icons.info_outline,
                title: strings.radiationExplainTitle,
                body: strings.radiationExplainBody,
              ),
              const SizedBox(width: 12),
              _TipCard(
                icon: Icons.notifications_active_outlined,
                title: strings.notificationsEnabled,
                body: strings.notificationsInfo,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard({required this.icon, required this.title, required this.body});
  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(
          theme.brightness == Brightness.light ? 0.95 : 0.5,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: theme.colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis)),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(child: Text(body, style: theme.textTheme.bodySmall, maxLines: 4, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}

class _UpdatedCard extends StatelessWidget {
  const _UpdatedCard({required this.strings, required this.value});
  final AppStrings strings;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(child: Padding(padding: const EdgeInsets.all(20), child: Row(children: [
      Icon(Icons.schedule_outlined, color: theme.colorScheme.primary), const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(strings.lastUpdated, style: theme.textTheme.titleMedium), const SizedBox(height: 6), Text(value, style: theme.textTheme.bodyMedium),
      ])),
    ])));
  }
}

String _fmt(DateTime dt) => '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
