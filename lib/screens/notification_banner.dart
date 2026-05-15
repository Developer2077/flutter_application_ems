import 'package:flutter/material.dart';

/// Tipo di banner di notifica in-app.
enum NotificationBannerType {
  /// La fascia di alta produzione è iniziata.
  windowStarted,

  /// La fascia di alta produzione sta per finire.
  windowEnding,

  /// Suggerimento serale per il giorno dopo.
  eveningSuggestion,

  /// Produzione alta in corso.
  highProduction,
}

/// Banner di notifica in-app animato, mostrato in cima alla dashboard.
///
/// Si auto-elimina dopo [autoDismissDuration] secondi oppure può
/// essere chiuso manualmente dall'utente.
class NotificationBanner extends StatefulWidget {
  const NotificationBanner({
    super.key,
    required this.type,
    required this.title,
    required this.body,
    required this.onDismiss,
    this.autoDismissDuration = const Duration(seconds: 12),
  });

  final NotificationBannerType type;
  final String title;
  final String body;
  final VoidCallback onDismiss;
  final Duration autoDismissDuration;

  @override
  State<NotificationBanner> createState() => _NotificationBannerState();
}

class _NotificationBannerState extends State<NotificationBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);

    _controller.forward();

    // Auto-dismiss dopo la durata specificata.
    Future.delayed(widget.autoDismissDuration, () {
      if (mounted) _dismiss();
    });
  }

  void _dismiss() {
    _controller.reverse().then((_) {
      if (mounted) widget.onDismiss();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    // Colori solidi dal tema per accessibilità daltonici.
    final (icon, bgColor, fgColor) = switch (widget.type) {
      NotificationBannerType.windowStarted => (
          Icons.wb_sunny,
          scheme.primaryContainer,
          scheme.onPrimaryContainer,
        ),
      NotificationBannerType.windowEnding => (
          Icons.hourglass_bottom,
          scheme.tertiaryContainer,
          scheme.onTertiaryContainer,
        ),
      NotificationBannerType.eveningSuggestion => (
          Icons.nightlight_round,
          scheme.secondaryContainer,
          scheme.onSecondaryContainer,
        ),
      NotificationBannerType.highProduction => (
          Icons.bolt,
          scheme.primaryContainer,
          scheme.onPrimaryContainer,
        ),
    };

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Semantics(
          liveRegion: true,
          label: '${widget.title}: ${widget.body}',
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: bgColor,
              border: Border.all(color: fgColor.withAlpha(50), width: 1.5),
            ),
            child: Material(
              color: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon, color: fgColor, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(widget.title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: fgColor, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text(widget.body,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: fgColor.withAlpha(220))),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _dismiss,
                      child: Icon(Icons.close, color: fgColor.withAlpha(180), size: 20),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
