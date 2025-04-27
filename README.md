# QB Admin Support System

## English

### Features
- Modern and intuitive admin panel interface with customizable settings page
- Support ticket system with real-time updates
- Customizable notifications for all ticket actions
- Individual sound settings for each admin
- Anti-spam protection with configurable cooldown
- Multi-language support (English and German)
- Ticket status tracking (pending/accepted)
- Admin assignment system
- Location-based features (teleport/waypoint)
- Customizable chat messages and notifications
- Individual admin notification toggles
- Admin visibility settings (show/hide admin names in notifications)
- Smart notification system to prevent duplicate messages
- Configurable admin status display
- German flag styling in the interface
- Enhanced credits section
- Improved error handling and stability

### Commands
- `/support [message]` - Create a support ticket
- `/ap` - Open the admin panel (admin only)
- `/noadmin` - Toggle admin notifications (admin only)

### How it Works
#### For Players
1. Create a ticket using `/support [your message]`
2. Wait for an admin to accept your ticket
3. Receive notifications about ticket status changes
4. Get informed when an admin accepts your ticket
5. See consolidated messages when no admins are available

#### For Admins
1. Access the admin panel using `/ap`
2. View all active tickets in real-time
3. Accept tickets to claim them
4. Use various ticket management options:
   - Teleport to player
   - Set waypoint
   - Accept/Unassign tickets
   - Delete resolved tickets
5. Toggle notification mode with `/noadmin`
6. Customize personal notification settings in the admin panel
7. Configure visibility settings for admin names
8. Access the settings page for additional customization

### Installation
1. Copy the `qb-adminsupport` folder to your server's `resources/[qb]` directory
2. Add `ensure qb-adminsupport` to your `server.cfg`
3. Configure admin permissions in your `server.cfg`:
   ```cfg
   add_ace group.admin command allow # Allows admin group to use admin commands
   ```
4. Adjust settings in `config.lua` if needed
5. Restart your server

### Dependencies
- QBCore Framework
- oxmysql

---

## Deutsch

### Funktionen
- Modernes und intuitives Admin-Panel Interface mit anpassbarer Einstellungsseite
- Support-Ticket-System mit Echtzeit-Updates
- Anpassbare Benachrichtigungen für alle Ticket-Aktionen
- Individuelle Sound-Einstellungen für jeden Admin
- Anti-Spam-Schutz mit konfigurierbarer Abklingzeit
- Mehrsprachige Unterstützung (Deutsch und Englisch)
- Ticket-Status-Verfolgung (ausstehend/angenommen)
- Admin-Zuweisungssystem
- Standortbasierte Funktionen (Teleport/Wegpunkt)
- Anpassbare Chat-Nachrichten und Benachrichtigungen
- Individuelle Admin-Benachrichtigungseinstellungen
- Admin-Sichtbarkeitseinstellungen (Admin-Namen in Benachrichtigungen anzeigen/verbergen)
- Intelligentes Benachrichtigungssystem zur Vermeidung von Duplikaten
- Konfigurierbare Admin-Status-Anzeige
- Deutsche Flaggen-Stilisierung im Interface
- Erweiterter Credits-Bereich
- Verbesserte Fehlerbehandlung und Stabilität

### Befehle
- `/support [Nachricht]` - Support-Ticket erstellen
- `/ap` - Admin-Panel öffnen (nur Admins)
- `/noadmin` - Admin-Benachrichtigungen umschalten (nur Admins)

### Funktionsweise
#### Für Spieler
1. Ticket mit `/support [deine Nachricht]` erstellen
2. Warten auf Admin-Annahme
3. Benachrichtigungen über Ticket-Status-Änderungen erhalten
4. Information bei Ticket-Annahme durch einen Admin
5. Zusammengefasste Nachrichten, wenn keine Admins verfügbar sind

#### Für Admins
1. Admin-Panel mit `/ap` öffnen
2. Alle aktiven Tickets in Echtzeit einsehen
3. Tickets annehmen und zuweisen
4. Verschiedene Verwaltungsoptionen nutzen:
   - Zum Spieler teleportieren
   - Wegpunkt setzen
   - Tickets annehmen/abgeben
   - Erledigte Tickets löschen
5. Benachrichtigungsmodus mit `/noadmin` umschalten
6. Persönliche Benachrichtigungseinstellungen im Admin-Panel anpassen
7. Sichtbarkeitseinstellungen für Admin-Namen konfigurieren
8. Zugriff auf die Einstellungsseite für zusätzliche Anpassungen

### Installation
1. `qb-adminsupport` Ordner in das `resources/[qb]` Verzeichnis kopieren
2. `ensure qb-adminsupport` zur `server.cfg` hinzufügen
3. Admin-Berechtigungen in der `server.cfg` konfigurieren:
   ```cfg
   add_ace group.admin command allow # Erlaubt der Admin-Gruppe die Nutzung von Admin-Befehlen
   ```
4. Bei Bedarf Einstellungen in `config.lua` anpassen
5. Server neu starten

### Abhängigkeiten
- QBCore Framework
- oxmysql

## Configuration

You can modify the following settings in `config.lua`:

- Command names
- Required permissions
- Notification settings
- UI refresh intervals
- Default language
- Admin visibility options
- Sound settings
- Chat message formatting

## Localization

The resource supports multiple languages through the locale system. Available languages:

- English (en.lua)
- German (de.lua)

To add a new language:
1. Create a new file in the `locales` folder (e.g., `fr.lua` for French)
2. Copy the structure from an existing locale file
3. Translate all strings to your target language
4. Update the `Config.Language` in `config.lua` to use your language code

## License and Credits

This resource was created by 0le and is released under the MIT License. See the [LICENSE.md](LICENSE.md) file for the full license text.

### Credits
- Original Creator: 0le
- License: MIT
- Year: 2025