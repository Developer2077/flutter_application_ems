import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppStrings {
  AppStrings(this.locale);

  final Locale locale;

  static const supportedLocales = <Locale>[Locale('it'), Locale('en')];

  static const LocalizationsDelegate<AppStrings> delegate =
      _AppStringsDelegate();

  static AppStrings of(BuildContext context) {
    return Localizations.of<AppStrings>(context, AppStrings)!;
  }

  bool get isItalian => locale.languageCode == 'it';

  String get appTitle => 'CER Smart';

  String get navDashboard => isItalian ? 'Dashboard' : 'Dashboard';
  String get navForecast => isItalian ? '24 ore' : '24h';
  String get navSettings => isItalian ? 'Impostazioni' : 'Settings';

  String get dashboardTitle => isItalian ? 'Panoramica CER' : 'CER overview';
  String get dashboardSubtitle => isItalian
      ? 'Ottimizza l\'uso degli elettrodomestici in base all\'energia solare gratuita disponibile oggi.'
      : 'Optimize the use of appliances based on the free solar energy available today.';
  String get searchSectionTitle =>
      isItalian ? 'Cerca la località' : 'Search the location';
  String get searchSectionSubtitle => isItalian
      ? 'Analizza le prossime 24 ore per trovare le migliori finestre di produzione.'
      : 'Analyze the next 24 hours to find the best production windows.';
  String get searchLabel => isItalian ? 'Comune o città' : 'City or town';
  String get searchHint =>
      isItalian ? 'Es. Bologna, Milano, Roma' : 'e.g. Bologna, Milan, Rome';
  String get searchButton => isItalian ? 'Analizza' : 'Analyze';
  String get refreshButton => isItalian ? 'Aggiorna' : 'Refresh';
  String get openForecastButton =>
      isItalian ? 'Apri fasce 24h' : 'Open 24h view';
  String get openDashboardButton =>
      isItalian ? 'Torna alla dashboard' : 'Back to dashboard';
  String get languageButton => isItalian ? 'EN' : 'IT';
  String get themeButton => isItalian ? 'Tema' : 'Theme';
  String get themeSystem => isItalian ? 'Sistema' : 'System';
  String get themeLight => isItalian ? 'Chiaro' : 'Light';
  String get themeDark => isItalian ? 'Scuro' : 'Dark';
  String get recommendationTitle =>
      isItalian ? 'Suggerimento principale' : 'Main recommendation';
  String get alertsTitle => isItalian ? 'Avvisi in-app' : 'In-app alerts';
  String get windowsTitle =>
      isItalian ? 'Fasce di alta produzione' : 'High production windows';
  String get timelineTitle =>
      isItalian ? 'Timeline delle 24 ore' : '24-hour timeline';
  String get summaryTitle =>
      isItalian ? 'Stato meteo 24 ore' : '24-hour weather status';
  String get bestMoment =>
      isItalian ? 'Momento consigliato' : 'Recommended moment';
  String get bestHour => isItalian ? 'Ora migliore' : 'Best hour';
  String get bestWindow => isItalian ? 'Finestra migliore' : 'Best window';
  String get daylightHours => isItalian ? 'Ore di luce' : 'Daylight hours';
  String get productionLabel =>
      isItalian ? 'Produzione attesa' : 'Expected production';
  String get cloudCover => isItalian ? 'Copertura nuvolosa' : 'Cloud cover';
  String get radiationLabel => isItalian ? 'Irraggiamento' : 'Radiation';
  String get solarScoreLabel => isItalian ? 'Indice solare' : 'Solar score';
  String get locationLabel =>
      isItalian ? 'Località selezionata' : 'Selected location';
  String get autoRefresh => isItalian
      ? 'Aggiornamento automatico ogni 30 minuti'
      : 'Auto refresh every 30 minutes';
  String get lastUpdated => isItalian ? 'Ultimo aggiornamento' : 'Last updated';
  String get offlineMessage =>
      isItalian ? 'Nessun dato disponibile' : 'No data available';
  String get emptyState => isItalian
      ? 'Inserisci un comune per ottenere la previsione.'
      : 'Enter a city to get the forecast.';
  String get errorPrefix => isItalian ? 'Errore' : 'Error';
  String get loading => isItalian ? 'Analisi in corso...' : 'Analyzing...';
  String get goodForAppliances => isItalian
      ? 'Ideale per carichi energivori'
      : 'Ideal for energy-heavy appliances';
  String get nightExcludedTitle =>
      isItalian ? 'La notte è esclusa' : 'Night is excluded';
  String get nightExcludedBody => isItalian
      ? 'La produzione solare notturna è nulla o trascurabile, quindi il motore considera solo le ore diurne.'
      : 'Night-time solar production is zero or negligible, so the engine only considers daylight hours.';
  String get daylightOnlyTitle =>
      isItalian ? 'Solo ore utili' : 'Useful hours only';
  String get daylightOnlyBody => isItalian
      ? 'Le finestre consigliate vengono calcolate dalle ore con sole disponibile e buona qualità di irraggiamento.'
      : 'Recommended windows are calculated from hours with available sun and good irradiation quality.';
  String get noDaylightTitle => isItalian
      ? 'Sole assente o non sufficiente'
      : 'Sun is absent or insufficient';
  String get noDaylightBody => isItalian
      ? 'In questo momento i pannelli non producono energia (è notte o il cielo è completamente coperto).'
      : 'Right now panels are not producing energy (it is night or the sky is completely overcast).';
  String get noForecastTitle =>
      isItalian ? 'Ancora nessuna località' : 'No location selected yet';
  String get noForecastBody => isItalian
      ? 'Inserisci un comune e avvia l\'analisi per vedere le fasce utili.'
      : 'Enter a city and start the analysis to see useful windows.';
  String get settingsTitle =>
      isItalian ? 'Impostazioni e info' : 'Settings and info';
  String get settingsSubtitle => isItalian
      ? 'Lingua, tema e una panoramica rapida delle funzioni già pronte.'
      : 'Language, theme, and a quick overview of the ready-to-use features.';
  String get languageSectionTitle => isItalian ? 'Lingua' : 'Language';
  String get themeSectionTitle => isItalian ? 'Tema' : 'Theme';
  String get featuresSectionTitle =>
      isItalian ? 'Funzioni attive' : 'Active features';
  String get evaluationSectionTitle =>
      isItalian ? 'Pensate per la valutazione' : 'Built for evaluation';
  String get utilityBody => isItalian
      ? 'La dashboard mostra subito le finestre diurne migliori per lavatrice, lavastoviglie e ricarica EV.'
      : 'The dashboard immediately shows the best daylight windows for laundry, dishwasher, and EV charging.';
  String get usabilityBody => isItalian
      ? 'La navigazione è divisa in aree chiare e il testo evidenzia le ore di sole e quelle escluse.'
      : 'Navigation is split into clear areas and the text highlights daylight hours and excluded hours.';
  String get technicalBody => isItalian
      ? 'La logica è separata tra shell, schermate e servizio meteo, così il codice resta leggibile e mantenibile.'
      : 'Logic is separated between the shell, screens, and weather service so the code stays readable and maintainable.';
  String get standaloneTitle => isItalian ? 'Standalone' : 'Standalone';
  String get standaloneBody => isItalian
      ? 'L\'app recupera direttamente i dati meteo e non dipende da un backend esterno.'
      : 'The app fetches weather data directly and does not depend on an external backend.';
  String get usabilityTitle => isItalian ? 'Usabilità' : 'Usability';
  String get utilityTitle => isItalian ? 'Utilità CER' : 'CER utility';
  String get technicalTitle =>
      isItalian ? 'Qualità tecnica' : 'Technical quality';
  String get visibleFeaturesTitle =>
      isItalian ? 'Funzionalità in evidenza' : 'Highlighted features';
  String get refreshInfo => isItalian
      ? 'Aggiornamento automatico e manuale con stato chiaro di caricamento e errore.'
      : 'Automatic and manual refresh with a clear loading and error state.';
  String get dayNightRule => isItalian
      ? 'Le ore notturne vengono escluse dal ranking per evitare consigli incoerenti.'
      : 'Night hours are excluded from ranking to avoid inconsistent advice.';
  String get criteriaIntro => isItalian
      ? 'Il layout evidenzia subito il suggerimento, le fasce e le impostazioni principali.'
      : 'The layout surfaces the recommendation, time windows, and main settings right away.';
  String get themeCurrent => isItalian ? 'Tema attuale' : 'Current theme';
  String get languageCurrent =>
      isItalian ? 'Lingua attuale' : 'Current language';
  String get supportNote => isItalian
      ? 'Supporto multilingua e tema chiaro/scuro sempre disponibili.'
      : 'Multilingual support and light/dark theme are always available.';
  String get currentForecast =>
      isItalian ? 'Previsione corrente' : 'Current forecast';
  String get currentTabDashboard =>
      isItalian ? 'Vista principale' : 'Main view';
  String get currentTabForecast =>
      isItalian ? 'Dettaglio 24 ore' : '24-hour detail';
  String get currentTabSettings => isItalian ? 'Preferenze' : 'Preferences';
  String get hourlyLabel => isItalian ? 'Ora' : 'Hour';
  String get daylightLabel => isItalian ? 'Diurno' : 'Daylight';
  String get nightLabel => isItalian ? 'Notte' : 'Night';
  String get scoreLabel => isItalian ? 'Score' : 'Score';
  String get sunriseLabel => isItalian ? 'Alba' : 'Sunrise';
  String get sunsetLabel => isItalian ? 'Tramonto' : 'Sunset';
  String get scoreExplanationTitle => isItalian ? 'Cos\'è il Solar Score?' : 'What is the Solar Score?';
  String get scoreExplanationBody => isItalian
      ? 'È un indice intelligente calcolato combinando la potenza dei raggi solari (W/m²) e la copertura nuvolosa. Un punteggio alto indica cielo sereno e sole forte: il momento perfetto per i grandi elettrodomestici!'
      : 'It is a smart index calculated by combining solar radiation (W/m²) and cloud cover. A high score means clear skies and strong sun: the perfect time for heavy appliances!';
  String get topWindowsTitle =>
      isItalian ? 'Finestre migliori' : 'Best windows';
  String get featureOne =>
      isItalian ? 'Previsioni meteo 24h' : '24h weather forecast';
  String get featureTwo => isItalian
      ? 'Suggerimento per carichi energivori'
      : 'Heavy-load recommendation';
  String get featureThree => isItalian ? 'Avvisi in-app' : 'In-app alerts';
  String get featureFour =>
      isItalian ? 'Tema chiaro/scuro' : 'Light/dark theme';
  String get featureFive => isItalian ? 'Supporto IT/EN' : 'IT/EN support';
  String windowAlert(String start, String end) => isItalian
      ? 'Fascia migliore prevista tra $start e $end.'
      : 'Best window expected between $start and $end.';
  String applianceAlert(String time) => isItalian
      ? 'Programma lavatrice, lavastoviglie o ricarica EV con anticipo, idealmente prima delle $time.'
      : 'Schedule laundry, dishwasher, or EV charging in advance, ideally before $time.';
  String get sunsetTip => isItalian
      ? 'Controlla la fascia serale per organizzare i consumi di domani.'
      : 'Check the evening window to plan tomorrow\'s consumption.';

  // ── Nuove stringhe per 3.3 Dashboard e 3.4 Notifiche ──

  // Momento ottimale (card hero)
  String get optimalMomentTitle =>
      isItalian ? 'Momento Ottimale' : 'Optimal Moment';
  String get optimalMomentSubtitle => isItalian
      ? 'Fascia migliore per elettrodomestici energivori'
      : 'Best window for energy-heavy appliances';
  String get windowActive =>
      isItalian ? 'IN CORSO' : 'ACTIVE NOW';
  String get windowSoon =>
      isItalian ? 'TRA POCO' : 'COMING SOON';
  String get noWindowAvailable =>
      isItalian ? 'Nessuna fascia disponibile' : 'No window available';
  String get noWindowBody => isItalian
      ? 'Nelle prossime ore non ci sono finestre di produzione solare elevata.'
      : 'No high solar production windows are available in the coming hours.';
  String countdown(int hours, int minutes) => isItalian
      ? 'Tra ${hours}h ${minutes}min'
      : 'In ${hours}h ${minutes}min';

  // Card elettrodomestici
  String get appliancesTitle =>
      isItalian ? 'Elettrodomestici' : 'Appliances';
  String get appliancesSubtitle => isItalian
      ? 'Orario consigliato per ogni apparecchio'
      : 'Recommended time for each appliance';
  String applianceName(String type) => switch (type) {
        'washingMachine' => isItalian ? 'Lavatrice' : 'Washing machine',
        'dishwasher' => isItalian ? 'Lavastoviglie' : 'Dishwasher',
        'evCharger' => isItalian ? 'Ricarica EV' : 'EV charger',
        'dryer' => isItalian ? 'Asciugatrice' : 'Dryer',
        'oven' => isItalian ? 'Forno' : 'Oven',
        'lights' => isItalian ? 'Luci' : 'Lights',
        _ => type,
      };
  String get startNow => isItalian ? 'Avvia ora!' : 'Start now!';
  String scheduleAt(String time) => isItalian
      ? 'Programma alle $time'
      : 'Schedule at $time';
  String get notRecommended =>
      isItalian ? 'Non consigliato ora' : 'Not recommended now';

  // Stato produzione in tempo reale
  String get productionStatusHigh =>
      isItalian ? 'Produzione alta in corso' : 'High production active';
  String get productionStatusSoon =>
      isItalian ? 'Prossimo picco tra poco' : 'Next peak coming soon';
  String get productionStatusNone =>
      isItalian ? 'Nessuna produzione solare' : 'No solar production';

  // Banner serale
  String get eveningSuggestionTitle =>
      isItalian ? 'Programma per domani!' : 'Plan for tomorrow!';
  String eveningSuggestionBody(String start, String end) => isItalian
      ? 'Domani il picco solare è previsto tra le $start e le $end. Programma lavatrice o lavastoviglie in anticipo!'
      : 'Tomorrow\'s solar peak is expected between $start and $end. Schedule laundry or dishwasher in advance!';

  // Notifiche in-app
  String get windowStartedTitle =>
      isItalian ? 'Fascia solare iniziata!' : 'Solar window started!';
  String get windowStartedBody => isItalian
      ? 'Avvia ora i tuoi elettrodomestici energivori.'
      : 'Start your energy-heavy appliances now.';
  String get windowEndingTitle =>
      isItalian ? 'Fascia in chiusura' : 'Window closing';
  String get windowEndingBody => isItalian
      ? 'La fascia di alta produzione sta per terminare.'
      : 'The high production window is about to end.';

  // Notifiche push
  String get notificationsEnabled =>
      isItalian ? 'Notifiche attive' : 'Notifications enabled';
  String get notificationsInfo => isItalian
      ? 'Riceverai avvisi all\'inizio e fine delle fasce solari, e suggerimenti serali per il giorno dopo.'
      : 'You\'ll receive alerts at the start and end of solar windows, and evening suggestions for the next day.';
  String get featureSix => isItalian
      ? 'Notifiche push programmate'
      : 'Scheduled push notifications';

  // ── Statistiche e storico (punto 4) ──
  String get navStatistics => isItalian ? 'Statistiche' : 'Statistics';
  String get statisticsTitle =>
      isItalian ? 'Statistiche e risparmio' : 'Statistics & savings';
  String get statisticsSubtitle => isItalian
      ? 'Storico produzione solare e impatto ambientale.'
      : 'Solar production history and environmental impact.';
  String get weeklySavings =>
      isItalian ? 'Risparmio settimanale' : 'Weekly savings';
  String get monthlySavings =>
      isItalian ? 'Risparmio mensile' : 'Monthly savings';
  String get weeklyChart =>
      isItalian ? 'Produzione ultimi 7 giorni' : 'Production last 7 days';
  String get monthlyChart =>
      isItalian ? 'Produzione ultimi 30 giorni' : 'Production last 30 days';
  String get savedLabel => isItalian ? 'Risparmiato' : 'Saved';
  String get chartUnit =>
      isItalian ? 'Irraggiamento medio (W/m²)' : 'Average radiation (W/m²)';
  String get noHistoryYet => isItalian
      ? 'Nessun dato storico registrato. I dati si accumuleranno giorno dopo giorno.'
      : 'No history recorded yet. Data will accumulate day by day.';
  String get currentTabStatistics =>
      isItalian ? 'Statistiche' : 'Statistics';

  // Test notifiche
  String get testNotification =>
      isItalian ? 'Invia notifica di test' : 'Send test notification';
  String get testNotificationSent =>
      isItalian ? 'Notifica di test inviata!' : 'Test notification sent!';
  String get testNotificationBody => isItalian
      ? 'Se vedi questa notifica, le notifiche push funzionano correttamente.'
      : 'If you see this notification, push notifications are working correctly.';

  // ── Spiegazione irraggiamento e kWh ──
  String get radiationExplainTitle =>
      isItalian ? 'Cos\'è l\'irraggiamento?' : 'What is irradiation?';
  String get radiationExplainBody => isItalian
      ? 'L\'irraggiamento solare (W/m²) indica quanta energia dal sole colpisce i pannelli. '
        'Più questo numero è alto, più corrente gratuita hai a disposizione.\n\n'
        '• Sotto 100 W/m²: Produzione quasi nulla.\n'
        '• 100 - 400 W/m²: Ok per luci e TV.\n'
        '• Sopra 400 W/m²: Perfetto per lavatrice, forno o auto elettrica!'
      : 'Solar irradiation (W/m²) indicates how much sun energy hits the panels. '
        'The higher this number, the more free electricity you have.\n\n'
        '• Under 100 W/m²: Almost no production.\n'
        '• 100 - 400 W/m²: Ok for lights and TV.\n'
        '• Over 400 W/m²: Perfect for washing machine, oven or EV!';
  String get estimatedProduction =>
      isItalian ? 'Produzione stimata' : 'Estimated production';
  String estimatedKwh(String kwh) =>
      isItalian ? '~$kwh kWh oggi' : '~$kwh kWh today';
  String get productionAssumption => isItalian
      ? 'Stima basata su impianto da 3 kWp (pannelli ~10 m², efficienza 18%)'
      : 'Estimate based on a 3 kWp system (panels ~10 m², 18% efficiency)';

  // ── Località salvata ──
  String get savedLocationTitle =>
      isItalian ? 'La tua località' : 'Your location';
  String get savedLocationSubtitle => isItalian
      ? 'Salva la tua città per ricevere notifiche automatiche e caricare le previsioni all\'avvio.'
      : 'Save your city to receive automatic notifications and load forecasts on startup.';
  String get saveLocation =>
      isItalian ? 'Salva come località preferita' : 'Save as preferred location';
  String get locationSaved =>
      isItalian ? 'Località salvata!' : 'Location saved!';
  String get locationRemoved =>
      isItalian ? 'Località rimossa' : 'Location removed';
  String get removeLocation =>
      isItalian ? 'Rimuovi' : 'Remove';
  String get noSavedLocation =>
      isItalian ? 'Nessuna località salvata' : 'No saved location';
  String get autoLoadEnabled => isItalian
      ? 'Le previsioni si caricano automaticamente all\'avvio.'
      : 'Forecasts load automatically on startup.';
  String savedLocationInfo(String name) => isItalian
      ? 'Riceverai notifiche per $name.'
      : 'You\'ll receive notifications for $name.';
  String get changeLocation =>
      isItalian ? 'Cambia località' : 'Change location';
  String get useCurrentLocation =>
      isItalian ? 'Usa posizione attuale' : 'Use current location';
}


class _AppStringsDelegate extends LocalizationsDelegate<AppStrings> {
  const _AppStringsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppStrings.supportedLocales.any(
      (supported) => supported.languageCode == locale.languageCode,
    );
  }

  @override
  Future<AppStrings> load(Locale locale) {
    return SynchronousFuture<AppStrings>(AppStrings(locale));
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppStrings> old) => false;
}
