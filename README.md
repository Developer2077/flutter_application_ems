# ☀️ CER Smart — L'App Intelligente per l'Autoconsumo

![Flutter Version](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)
![License](https://img.shields.io/badge/License-Open%20Source-green)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey)

> **"Sincronizza i tuoi consumi con il Sole."**
> 
> *CER Smart* è un'applicazione mobile sviluppata per l'Hackathon "App per C.E.R." promosso da **EMS – Energia e Mobilità Sostenibile APS**. L'obiettivo è supportare i membri di una Comunità Energetica Rinnovabile (CER) nell'ottimizzazione dell'autoconsumo domestico, suggerendo in modo intelligente i momenti migliori per l'utilizzo degli elettrodomestici.

---

## 🚀 Visione del Progetto

Il progetto offre un prodotto finito, stabile e orientato all'utente. Al cuore dell'applicazione c'è un motore di calcolo locale (**Standalone**) che analizza i dati meteorologici per identificare la **Finestra Migliore** di produzione, garantendo massima privacy e velocità, senza dipendere da server esterni.

---

## 🎯 Funzionalità Principali (Core)

L'applicazione rispetta rigorosamente **tutte le specifiche obbligatorie**:

* 🌤️ **Previsioni Meteo Open Source:** Integrazione con *Open-Meteo API* per identificare irraggiamento e copertura nuvolosa nelle 24-48 ore.
* 🧠 **Algoritmo di Ottimizzazione:** Identifica automaticamente le finestre di produzione solare elevata, escludendo le ore notturne e calcolando lo **Solar Score**.
* 📊 **Dashboard Intelligente:** Schermata principale semplificata che mostra subito il suggerimento operativo e lo stato della produzione (Alta, In arrivo, Assente).
* 💡 **Suggerimenti Elettrodomestici:** Consigli personalizzati per Lavatrice, Lavastoviglie, Forno, Asciugatrice, Ricarica EV e **Luci** (con soglie di attivazione differenziate).
* 🔔 **Sistema di Notifiche Nativo:**
  * **Promemoria Serale:** Pianifica la giornata successiva alle 20:00.
  * **Avvisi Real-time:** Notifiche all'inizio e in chiusura delle fasce ottimali.

---

## 🌟 Funzionalità Avanzate

* **🌍 Localizzazione Intelligente:**
  * Ricerca città con suggerimenti automatici.
  * **Integrazione GPS:** Funzione "Usa posizione attuale" per configurare l'app istantaneamente tramite reverse geocoding (OpenStreetMap).
  * Persistenza completa dei dati geografici (Città, Provincia, Nazione).
* **⚡ Dati Granulari:** Visualizzazione dei **Watt (W)** attesi e dell'irraggiamento (W/m²) per ogni singola fascia oraria.
* **📈 Storico e Statistiche:** Grafici interattivi su risparmio economico e CO₂ evitata.
* **🌙 UI Premium & Accessibilità:**
  * **Massimo Contrasto:** Tema chiaro e scuro ottimizzati per la massima leggibilità in ogni condizione di luce.
  * Layout pulito con focus sulla "Home" e navigazione semplificata.
  * Supporto multilingua nativo (Italiano 🇮🇹 / Inglese 🇬🇧).
* **📱 Widget Android:** Widget 2x2 per monitorare la finestra solare direttamente dalla home dello smartphone.

---

## 🛠️ Architettura e Qualità del Codice

Seguiamo i principi della **Clean Architecture**:
1. **Model-Driven:** Modelli chiari per previsioni (`SolarForecast`), suggerimenti (`ApplianceSuggestion`) e risparmio.
2. **Service Layer:** Servizi isolati per Meteo, Localizzazione, Notifiche e Persistenza.
3. **Resilienza Offline:** Caching automatico dei dati per consultazione senza rete.
4. **Nessun Login:** Accesso immediato e anonimo (GDPR compliant).

---

## 🚀 Installazione e Compilazione

### Prerequisiti
- Flutter SDK (versione >= 3.x)
- Android Studio / Xcode / Visual Studio Code

### Esecuzione Locale
```bash
# 1. Clona la repository
git clone <url-repository>
cd flutter_application_ems

# 2. Installa le dipendenze
flutter pub get

# 3. Avvia l'applicazione (su emulatore o dispositivo fisico)
flutter run
```

### Compilazione Android (APK)
```bash
flutter build apk --release
```

---

## 📦 SBOM (Software Bill of Materials)

| Libreria / Package | Versione | Scopo | Licenza |
|:---|:---|:---|:---|
| `http` | ^1.6.0 | Networking API Open-Meteo | BSD 3-Clause |
| `shared_preferences` | ^2.5.3 | Caching e persistenza | BSD 3-Clause |
| `geolocator` | ^14.0.2 | Localizzazione GPS | MIT |
| `fl_chart` | ^0.70.2 | Grafici interattivi | MIT |
| `flutter_local_notifications` | ^19.2.1 | Notifiche di sistema | BSD 3-Clause |
| `home_widget` | ^0.7.0 | Sincronizzazione Widget | MIT |

---

## 🎥 Video Dimostrativo
*(Inserire qui il link al video di screen recording richiesto dal bando, che mostra il funzionamento completo dell'app con audio esplicativo).*

## 📧 Supporto e Riferimenti
Progetto realizzato per l'Hackathon "App per C.E.R." organizzato da **EMS – Energia e Mobilità Sostenibile APS**.
- Sito: [emsaps.org](https://emsaps.org/)
- Email: [hackathon@emsaps.org](mailto:hackathon@emsaps.org)
