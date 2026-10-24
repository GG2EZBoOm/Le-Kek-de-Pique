# Le Kek de Pique

3D-Poker (Texas Hold'em No-Limit) mit eigener C++/Direct3D-11-Engine – Karriere, Sit & Go,
Mehrtisch-Turniere, Multiplayer, Charakter-Editor und Errungenschaften.

## Spielen

1. Oben auf **Code → Download ZIP** klicken und den Ordner `spiel` entpacken.
2. `LeKekDePique.exe` starten (Windows 10/11, Grafikkarte mit Direct3D 11).

## Neue Schauplätze

- **Hindenburg:** Im Luftschiff-Salon geht die Pokerrunde während Brand, Sinkflug und Absturz weiter.
  Brennende Außenhaut, Rauch und seitlich abgelöste Hüllenteile; der Salon bleibt intakt.
  Propeller laufen aus, die Crew reagiert auf den Absturz, Lampen schwingen und die Feuerwehr
  rückt mit Wasserstrahlen an. Das Wrack bleibt liegen; der Absturz beginnt nicht erneut.
- **Geisterbahn:** Eine Fahrt durch Friedhof, Krypta, Spinnenhöhle, Spuksalon, Hexenküche und Jahrmarkt-Finale.
  Geister nähern sich dem Wagen, Skelette kommen aus Särgen und eine große Spinne lässt sich herunter.
- **Weißeritztalbahn bei Nacht:** Zusätzlich zur Tagfahrt mit Disco-Pokerwagen.
  In beiden Varianten begleitet der Schaffner endgültig ausgeschiedene Spieler zum Ausgang und kickt sie hinaus.
- **Rave-Demo Berlin:** Poker auf dem Oberdeck eines fahrenden Sound-Trucks, mit DJ, Partylicht,
  Passanten am Straßenrand, weiteren Trucks und Berliner Stadtkulisse. Synchron wechselnde RGB-Leisten
  am inneren Tischrand und vier Nebelmaschinen an den Ecken ergänzen das Licht.
  Der eigene dreiminütige Synthwave-Track „Neon im Rückspiegel“ läuft auf Kek Sound System.
- **Kekisch kolumbianisches Kartell:** Poolvilla mit Marmorsalon, Lounges, Küstenblick,
  animierten erwachsenen Gästen und passender Dekoration an allen sechs Tischplätzen.
  Kellner und Wache laufen durch freie Gänge; Brunnen, Poolwasser, Palmen und Vorhänge bewegen
  sich. Vögel und ein Motorboot beleben die Küste.

Endgültig ausgeschiedene Spieler werden im Partyschuppen vom SEK abgeholt, starten beim Rave
mit einem Raketenstuhl, verschwinden in der Geisterbahn im Dunkeln oder bekommen in der Villa
Besuch vom Gangster. Ein verfügbarer Nachkauf wird vorher angeboten.
Im Charaktereditor stehen jetzt 200 zusätzliche Gegenstände bereit: 90 direkt, 60 als
Errungenschaftsbelohnung und 50 ausschließlich aus Truhen. Karten-Hover animiert die Figur
auch für die Mitspieler.

Alle Szenen lassen sich im freien Spiel und in Turnieren auswählen. Das kompakte Spielpaket enthält die drei Original-Introvideos;
die bisherigen fünf Radiosender sind unverändert enthalten, dazu kommt Kek Sound System (AAC 128 kbit/s).

## Truhen und Preisgeld

Nach mindestens einer beendeten Hand gibt es beim Verlassen des Tisches eine Fundchance,
die mit der aktiven Zeit am Tisch steigt. Eine Sitzung erhält genau einen Wurf; ein
Verbindungsabbruch setzt die gesammelte Zeit nicht zurück. Truhen kosten nichts und benötigen
keine Schlüssel. Im Hauptmenü unter **TRUHEN** stehen Inhalte, Chancen und Ausrüstungsvorschau.

- **Normal, episch und legendär:** insgesamt 50 exklusive Teile (25 Hüte, 10 Brillen, 15 Accessoires)
  oder Bankguthaben; doppelte Teile werden in Bankguthaben umgewandelt.
- **Sechs-Spieler-Turniere:** Platz 1 erhält 50 %, Platz 2 erhält 30 % und Platz 3 erhält 20 %
  des Preisgeldpools. Freies Spiel behält seine normalen Tischchips ohne Turnierpreisgeld.

## Szenenklang und Voice-Chat

Musik, Geräusche und Stimmen nutzen je nach Schauplatz unterschiedliche Raumakustik.
Im Freien ist der Klang offener, Innenräume bekommen passende Reflexionen und Hall.
Stimmen kommen aus der Richtung des jeweiligen Sitzplatzes; Menüsounds bleiben davon getrennt.

Unter **OPTIONEN → VOICE-CHAT** lassen sich das Mikrofon, Aus, Push-to-Talk oder Sprachaktivierung
wählen. Push-to-Talk nutzt wahlweise B, N oder U. Mikrofonpegel, Empfindlichkeit und Sprachlautstärke
sind einstellbar. Das Mikrofon ist anfangs aus; der Mikrofontest zeigt nur den Pegel und sendet nichts.
Die Übertragung verwendet Opus mit 48 kHz und 64 kbit/s, einen Jitterpuffer und
Paketverlustbehandlung. UDP ist bevorzugt; bei blockiertem UDP wird TCP verwendet.
Die Ausweichverbindung kann bei Paketverlusten mehr Verzögerung verursachen.
Stimmen bleiben am eigenen Tisch, während in der Lobby alle Teilnehmer miteinander sprechen können.

## Intros

Beim Start laufen Kekish Games, das Engine-Intro und das Spielintro mit ihren Originaltonspuren.
**Leertaste oder Esc** überspringt jeweils das laufende Video. Mit `--skip-intros` geht es direkt weiter.

## Updates

Beim Start vergleicht das Spiel seine Dateien mit diesem Repo und lädt Neuerungen automatisch
herunter; danach startet es neu. Ohne Internet startet es mit dem vorhandenen Stand.
Mit `LeKekDePique.exe --noupdate` lässt sich der Abgleich abschalten.

## Multiplayer

- **Hosten:** Multiplayer → Hosten (Standard-Port 47123). Beim ersten Mal fragt die
  Windows-Firewall – dort „Zugriff zulassen“ wählen.
- **Beitreten im selben Netz:** die angezeigte IPv4-Adresse eingeben, z. B. `192.168.178.20`
  oder mit Port `192.168.178.20:47123`.
- **Übers Internet:** Port 47123 (TCP und für Voice zusätzlich UDP) im Router auf den Host-PC weiterleiten und die öffentliche
  IPv4-Adresse weitergeben – oder ein gemeinsames VPN (z. B. Radmin VPN) nutzen – oder den
  eigenständigen Server auf einem VPS laufen lassen: `LeKekServer.exe --port 47123`.
- **Später Beitritt:** Im Modus Freies Spiel mit aktiviertem Nachkauf können neue Spieler
  laufenden Partien beitreten. Der Einstieg erfolgt zur nächsten Hand auf einem freien oder KI-Platz.
- **Wiedereinstieg:** Nach versehentlichem Verlassen oder Verbindungsabbruch bleiben eigener Platz,
  Chips und Karten erhalten; die Verbindung wird automatisch erneut versucht. Der Server muss weiterlaufen.
  Turniere bleiben für neue Teilnehmer nach dem Start geschlossen, Rückkehrer dürfen ihren Platz übernehmen.
- **Gemeinsames Radio:** Jeder menschliche Spieler kann den Sender für die gesamte Runde umschalten.
  Alle Teilnehmer benötigen die aktuelle Spielversion (Netzprotokoll 10).

## Mitwirkende

Geräusche von Chips, Karten und Dampfzug: ZapSplat – https://www.zapsplat.com
Radiomusik: AudioHero (https://www.audiohero.com) über ZapSplat – https://www.zapsplat.com
Sender Kekwelle und Nachtschicht: Foureye, Kulluh, Dark Harmonics, Pioxonaq und ZapSplat – https://www.zapsplat.com
(Geräusche und Musik sind fest ins Spiel eingebaut und dürfen nicht herausgelöst oder einzeln weitergegeben werden.)
Voice-Codec: Opus 1.6.1 – Lizenzhinweise in `spiel/licenses/Opus.txt`.
