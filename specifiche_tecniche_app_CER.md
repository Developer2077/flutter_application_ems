EMS – Energia e Mobilità Sostenibile APS

**SPECIFICHE TECNICHE DELL’APPLICAZIONE**

Hackathon “App per C.E.R.” – Comunità Energetiche Rinnovabili

# **1\. Obiettivo dell’applicazione**

L’applicazione deve supportare i membri di una **Comunità Energetica Rinnovabile (CER)** nell’ottimizzazione dei propri consumi energetici domestici, integrando dati di **previsioni meteorologiche** per identificare i momenti di picco nella produzione di energia solare e suggerire di conseguenza i momenti migliori per l’utilizzo degli apparecchi domestici.

# **2\. Piattaforma e tecnologia**

## **2.1 Framework**

L’applicazione deve essere sviluppata obbligatoriamente con **Flutter**, il framework open source di Google per lo sviluppo multipiattaforma.

## **2.2 Piattaforme target**

L’applicazione deve essere compilata e funzionante sulle seguenti piattaforme:

* **Android** – file eseguibile .apk

È facoltativo invece per le seguenti:

* **Windows** – eseguibile .exe

* **Linux** – eseguibile .deb, o .AppImage o equivalente

* **web app**

* **iOS** – file eseguibile .ipa

* **macOS** – eseguibile .dmg o .app

| Nota sulla compilazione multipiattaforma I Partecipanti sono responsabili della compilazione. È sufficiente che l’app sia funzionante: non è richiesta la pubblicazione sugli store ufficiali. |
| :---- |

# **3\. Funzionalità obbligatorie**

L’applicazione deve implementare le seguenti funzionalità minime:

## **3.1 Integrazione previsioni meteorologiche**

L’app deve integrare dati di previsione meteo opensource per:

* Evidenziare le **fasce orarie di massima produzione** solare attesa, almeno per le successive 24 ore.

* Aggiornare le previsioni automaticamente a intervalli regolari

L’app deve funzionare interamente in standalone, non deve essere un frontend per un backend che gira su un server esterno

## **3.3 Dashboard principale**

La schermata principale deve mostrare in modo chiaro e immediato:

* Suggerimento del **momento ottimale** per l’utilizzo di elettrodomestici ad alto consumo

## **3.4 Notifiche e suggerimenti**

L’app deve essere in grado di notificare o segnalare all’utente:

* L’inizio e la fine di una fascia di alta produzione solare

* Il momento consigliato per avviare elettrodomestici energivori (es. lavatrici, lavastoviglie, carica veicoli elettrici, ecc.), con anticipo sufficiente, ovvero almeno la sera prima.

La modalità di notifica (push, in-app, badge, ecc.) è a discrezione del team.

# **4\. Funzionalità facoltative (bonus)**

Le seguenti funzionalità non sono obbligatorie ma verranno valutate positivamente dalla giuria:

* **Storico dei consumi**: grafici e statistiche di produzione su base giornaliera, settimanale, mensile

* **Calcolo del risparmio**: stima del risparmio economico e ambientale (CO₂ evitata) grazie all’ottimizzazione dei consumi

* **Supporto multilingua**

* **Tema scuro/chiaro**: supporto alla modalità dark mode, anche gestita automaticamente

* **Widget**: widget per la schermata home del dispositivo mobile

# **5\. Requisiti tecnici**

## **5.1 Autenticazione**

L’applicazione **non deve necessariamente richiedere autenticazione utente**. Nel caso l’implementazione di login, registrazione o gestione di account deve essere facoltativo.

## **5.2 Connettività**

L’app richiede connessione a Internet per il recupero dei dati meteo e dei dati energetici. È consigliata la gestione degli stati offline con messaggi appropriati all’utente.

## **5.3 Licenze di dipendenze**

Tutte le librerie e i pacchetti utilizzati devono essere rilasciati sotto licenza Open Source. È vietato l’uso di codice proprietario di terzi. Ogni dipendenza deve essere dichiarata nel file pubspec.yaml e nell’[SBOM](https://en.wikipedia.org/wiki/Software_supply_chain) da includere nel README.md

## **5.4 Qualità del codice**

Non sono imposti standard specifici di qualità, ma la giuria valuterà positivamente:

* Struttura del codice leggibile e organizzata

* Presenza di commenti esplicativi

# **6\. Materiali da consegnare**

Entro la deadline comunicata dall’organizzatore, ogni team deve caricare sulla propria repository Github (in caso di upload su repository privata, il team dovrà concedere il permesso di visualizzazione all’account dell’organizzatore “[https://github.com/emsaps](https://github.com/emsaps)” o “[https://github.com/Wolfbanus](https://github.com/Wolfbanus)” ):

1. **Codice sorgente**: cartella del progetto Flutter completa, codice commentato, README.md, SBOM;

2. **Eseguibili compilati** per le piattaforme specificate nell’articolo 2.2

3. **Video dimostrativo**: registrazione dello schermo (screen recording) che mostri l’app in uso, con audio esplicativo. Il video deve coprire l’intero funzionamento dell’app.

| Formato consigliato per il video Risoluzione minima 720p. Formati accettati: .mp4, .mov, .mkv. È sufficiente registrare lo schermo di un simulatore o emulatore, non è necessario un dispositivo fisico. Tool consigliati: OBS Studio (tutte le piattaforme). |
| :---- |

# **7\. Criteri di valutazione**

I progetti saranno valutati dalla giuria secondo le seguenti categorie e pesi:

| Categoria | Note |
| :---- | :---- |
| Funzionalità | L’app fa quello che promette |
| Utilità per la CER | Concretamente utile per l’utente CER |
| Usabilità | Interfaccia intuitiva e accessibile anche per chi ha disabilità visive (es. ipovedenti) |
| Originalità | Soluzioni creative o inaspettate |
| Qualità tecnica | Codice pulito, ottimizzato e ben strutturato |

# **8\. Supporto e riferimenti**

Per domande tecniche o chiarimenti sulle specifiche, è possibile contattare l’organizzatore tramite:

* Sito web: [https://emsaps.org/](https://emsaps.org/) 

* Email: [hackathon@emsaps.org](mailto:hackathon@emsaps.org) 

* Linktree: [https://linksta.cc/@EMS](https://linksta.cc/@EMS) 