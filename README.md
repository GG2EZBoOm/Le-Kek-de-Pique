# Le Kek de Pique

3D-Poker (Texas Hold'em No-Limit) mit eigener C++/Direct3D-11-Engine – Karriere, Sit & Go,
Mehrtisch-Turniere, Multiplayer, Charakter-Editor und Errungenschaften.

## Deutsch / English

Im Hauptmenü oben rechts **ENGLISH** wählen oder **Optionen → Sprache / Language → English**.
Die Auswahl wird lokal gespeichert. Menüs, Pokeranzeigen, Dialoge, Emotes, Gegenstände,
Errungenschaften, Truhen und Szenenbeschriftungen sind übersetzt. Deutsch bleibt auswählbar.
Englische Untertitel übersetzen die Texteinblendungen im originalen Spielintro.
Die Sprache wird vom Hauptmenü aus gewechselt, bevor man an einem Tisch Platz nimmt.
Multiplayer-Spieler können unterschiedliche Sprachen verwenden; Namen und Chat bleiben unverändert.

**English quick start:** Download the ZIP with **Code → Download ZIP**, extract `spiel`,
and run `LeKekDePique.exe` on Windows 10/11 with a Direct3D 11 graphics card.
Select **ENGLISH** in the top-right corner of the main menu. Your preference is saved.
Choose **Quick Game**, **Career**, **Tournaments**, or **Multiplayer**. Customize your avatar
under **Your Character**, and open free reward crates under **Crates**.
In multiplayer, host a game or connect to a host's address (default port 47123).
Voice chat is configured under **Options → Voice-Chat**; the microphone starts off.
Use **Space** to inspect your cards, hold the **right mouse button** to look around,
**G** for emotes, **V** to change camera, and **Esc** for the menu.
**Space / Esc** also skip intros and crate-opening animations.
All human players can change the shared radio station. Strobe lights can be disabled locally.
Seven radio stations are included. New: **Neon Gridlines**, ten full-length electronic
tracks with 26 minutes of music, encoded as stereo AAC at 128 kbit/s.
Late joining is available in Free Play with rebuys enabled; disconnected players can reclaim
their existing stacks while the server is running. Sit & Go allows bankroll buy-ins and rebuys
at the same price; rebuys increase the prize pool. Only large multi-table tournaments prohibit
rebuys and re-entry. Eliminated tournament players return as spectators and can switch tables.
Game progress, equipment and chat are independent of language.
The original game intro has English subtitles for its German title cards.
All 16 equippable items available from legendary crates now feature bespoke animated effects:
orbiting stars, phoenix embers, moving wings, spinning propellers, shimmering gems and a miniature
vault that opens. Rare knives retain their inspect animations with colored inlay and blade effects.
Effects appear on equipped characters and in the animated crate previews, and react to winning a hand.

## Spieler-Stufen / Player levels

1000 Spieler-Stufen mit XP-Fortschrittsbalken im Hauptmenü und Meldungen beim Aufstieg.
Abgeschlossene Hände geben 10 XP, gewonnene Pots 25 XP und Turniersiege 250 XP.
Der Fortschritt wird gespeichert; ältere Spielstände erhalten XP für ihre gespeicherten Hände,
Pots und Turniersiege. Jeder Aufstieg kostet 50 XP mehr als der vorherige:
100 XP von Stufe 1 auf 2, dann 150 XP, 200 XP und so weiter bis Stufe 1000.
Jeder neue Stufenaufstieg bringt zusätzlich 1.000 $ auf die Bankroll. Mehrere Stufen auf einmal
werden einzeln vergütet; der Bonus wird zusammen mit dem XP-Fortschritt gespeichert.

1000 player levels with an XP bar in the main menu and level-up notifications.
Earn 10 XP per completed hand, 25 XP per pot won and 250 XP per tournament win.
Progress is saved; existing saves receive credit for recorded hands, pots and tournament wins.
Each level-up costs 50 XP more than the previous one: 100 XP from level 1 to 2,
then 150 XP, 200 XP and so on up to level 1000.
Each new level-up adds $1,000 to your bankroll, including every level in a multi-level jump.
The bonus is saved together with your XP progress.

## Spielen

1. Oben auf **Code → Download ZIP** klicken und den Ordner `spiel` entpacken.
2. `LeKekDePique.exe` starten (Windows 10/11, Grafikkarte mit Direct3D 11).

## Neue Schauplätze

Im Mehrtisch-Turnier können ausgeschiedene Zuschauer mit **TISCH WECHSELN** jeden laufenden Tisch
auswählen. Die Liste zeigt Schauplatz, Spielerzahl und Hand; verdeckte Karten bleiben verborgen.
Die Auswahl bleibt bei Wiederverbindung erhalten. Wird ein Tisch aufgelöst, folgt die Ansicht
automatisch einem noch laufenden Tisch. Nur große Turniere erlauben keinen Nachkauf.
Sit & Go erlaubt Bankroll-Einsatz und Nachkauf zum gleichen Buy-in; Nachkäufe erhöhen das Preisgeld.
Eine Wiederverbindung übernimmt den bestehenden Spielstand; ausgeschiedene Spieler bleiben Zuschauer.

- **Sojus-Kapsel:** Poker in einer engen, gekrümmten Kabine mit weißer Polsterung, grüner Druckluke,
  zwei kleinen Bullaugen, Doppelkonsole, Staupolstern und blauen technischen Sitzen.
  Alle Tischfiguren tragen weiße Raumanzüge mit blauen Nähten, Druckanschlüssen und offener Helmhaube.
  Ausgerüstete Hüte, Brillen, Ketten und weitere Accessoires bleiben über dem Anzug sichtbar;
  beim Szenenwechsel kommt die ursprüngliche Kleidung zurück.
  Die Kapsel fliegt vom Orbit durch den glühenden Wiedereintritt zum Fallschirmabstieg,
  bremst kurz vor dem Boden und bleibt nach der Landung stehen. Zwei laufende Displays zeigen
  Flugbahn, Höhe, Fluglage und Kabinendaten; analoge Zeiger und Statuslampen folgen der Flugphase.
  Lüfter drehen sich, Gurte und Spiralkabel reagieren auf den Flug, Wolken ziehen außen vorbei.
  Der Fallschirm entfaltet sich vollständig außerhalb der Kabine; nach der Landung treibt er
  erst zur Seite und sinkt dann zu Boden. Ein Bergungswagen kommt an, öffnet seine Türen und
  zwei Helfer gehen zur Kapsel. Flugphasen haben eigene Geräusche und dezente Bewegung.
  Ausgeschiedene Figuren werden durch die geöffnete
  Luke hinausgezogen; ein verfügbarer Nachkauf hat Vorrang. Host und Gäste benötigen die aktuelle Version.
- **Die Pyramide:** Sandsteinkammer mit Fackeln, Reliefs und sechs goldverzierten Sarkophagen.
  Gespielt wird direkt auf einem kantigen Sarkophagdeckel mit Pharaonenmotiv, ohne Filz oder Polsterbande.
  Endgültig ausgeschiedene Figuren werden von einer bandagierten Mumie abgeholt; beide kehren
  in den geöffneten Sarkophag zurück, bevor sich der Deckel schließt. Ein möglicher Nachkauf hat Vorrang.
  Musik, Geräusche und Voice-Chat erhalten den Hall der steinernen Grabkammer.
- **Hindenburg:** Im Luftschiff-Salon geht die Pokerrunde während Brand, Sinkflug und Absturz weiter.
  Brennende Außenhaut, Rauch und seitlich abgelöste Hüllenteile; der Salon bleibt intakt.
  Propeller laufen aus, die Crew reagiert auf den Absturz, Lampen schwingen und die Feuerwehr
  rückt mit Wasserstrahlen an. Das Wrack bleibt liegen; der Absturz beginnt nicht erneut.
- **Geisterbahn:** Eine Fahrt durch Friedhof, Krypta, Spinnenhöhle, Spuksalon, Hexenküche und Jahrmarkt-Finale.
  Geister nähern sich dem Wagen, Skelette kommen aus Särgen und eine große Spinne lässt sich herunter.
- **Weißeritztalbahn bei Nacht:** Zusätzlich zur Tagfahrt mit Disco-Pokerwagen.
  Die Nachtfahrt analysiert Bass und Lautstärke der abgespielten Musik: gemeinsame, weich wechselnde
  RGB-Farben, kurze weiße Strobe-Gruppen mit dunklen Pausen und vier Nebelmaschinen im Pokerwagen.
  Die Lichtsteuerung folgt dem tatsächlich gehörten Ton und schaltet die Strobes bei Stille ab.
  Unter **Optionen → Strobe-Lichter** kann jeder Spieler die Blitze nur für sich ausschalten;
  die Einstellung wird gespeichert und wirkt sofort, auch im Multiplayer.
  In beiden Varianten begleitet der Schaffner endgültig ausgeschiedene Spieler zum Ausgang und kickt sie hinaus.
- **Rave-Demo Berlin:** Poker auf dem Oberdeck eines fahrenden Sound-Trucks, mit DJ, Partylicht,
  einer geschwungenen Straße und Begleittrucks, die dem Straßenverlauf folgen. Zuschauer bleiben
  am Straßenrand, tanzen, jubeln und filmen mit dem Handy. Schaufenster, Cafés, Bushaltestellen,
  Park, U-Bahn-Platz und Fahrräder sorgen für Abwechslung. Räder, Fahnen, Baumkronen und
  Plattenteller bewegen sich; Lautsprechermembranen und Licht reagieren auf die Musik.
  Schwenkende Scheinwerfer, synchron wechselnde RGB-Leisten am Tisch, Strobes und vier
  Nebelmaschinen ergänzen die Bühne. Strobes lassen sich weiterhin lokal abschalten.
  Der eigene dreiminütige Synthwave-Track „Neon im Rückspiegel“ läuft auf Kek Sound System.
- **Paketzentrum:** Die Halle ist rundum eingerichtet und beleuchtet. Hinter dem Tisch liegen
  drei Verladetore, Packplätze und Paketstapel. Ein Gabelstapler mit Fahrer transportiert eine
  Palette, hebt die Last an den Haltepunkten und trägt ein rotierendes Warnlicht; am Packtisch
  arbeitet ein weiterer Mitarbeiter. Die bestehenden Förderbänder laufen weiter.
- **Kekisch kolumbianisches Kartell:** Poolvilla mit Marmorsalon, Lounges, Küstenblick,
  animierten erwachsenen Gästen und passender Dekoration an allen sechs Tischplätzen.
  Kellner und Wache laufen durch freie Gänge; Brunnen, Poolwasser, Palmen und Vorhänge bewegen
  sich. Vögel und ein Motorboot beleben die Küste.

Endgültig ausgeschiedene Spieler werden im Partyschuppen vom SEK abgeholt, starten beim Rave
mit einem Raketenstuhl, verschwinden in der Geisterbahn im Dunkeln oder bekommen in der Villa
Besuch vom Gangster. Ein verfügbarer Nachkauf wird vorher angeboten.
Im Charaktereditor stehen jetzt 208 zusätzliche Gegenstände bereit: 90 direkt, 60 als
Errungenschaftsbelohnung und 58 ausschließlich aus Truhen. Karten-Hover animiert die Figur
auch für die Mitspieler.

Alle **16 ausrüstbaren Inhalte der legendären Truhe** einschließlich der vier seltenen Messer
haben eigene Effekte und überarbeitete Materialien. Kosmos-Krone mit kreisenden Sternringen,
Phönix mit beweglichen Feuerflügeln, Kristall-Palast mit schwebenden Prismen, Luftschiffe mit
rotierenden Propellern und Dampf, Drachen mit Glutatem, Pfau mit beweglichen Schmuckfedern,
Kartenfächer und ein sich öffnender Mini-Tresor. Brillen funkeln, Messer tragen farbige Energieadern
und Klingenreflexe. Gewinne verstärken die Reaktionen; dieselben Modelle und Effekte sind in der
Truhenvorschau und an den Figuren sichtbar. Die Effekte benötigen keine zusätzlichen Texturpakete.

Eigene Emotes über **G** oder **1–8** animieren jetzt auch die eigene Figur. Laufende
Karten- und Setzgesten werden zuerst beendet; danach startet das gewählte Emote.
Mit **V** lässt sich die Figur in der Übersicht betrachten.

**D, SB und BB** zeigen die Tischpositionen dauerhaft an. Eigene gefoldete Karten bleiben
bis zur nächsten Hand sichtbar; die mögliche Kombination wird mit dem Board aktualisiert.
Wechselnde Turnierschauplätze wechseln nach der abgeschlossenen Hand und ihren Animationen,
bevor am neuen Schauplatz die nächsten Karten ausgeteilt werden.

Die **Kürbisbong · Halloween** ist ein exklusiver Fund aus epischen Truhen. Bei einem gewonnenen
Pot pfeifen Mini-Lok und Dampflok-Orden mit Rauch; Radar, Propeller, Discokugel, UFO und weitere
passende Teile reagieren mit kurzen Animationen. Doppelte Nebenpot-Gewinne lösen keinen zweiten
Pfiff aus. Automatisches Chipspielen am Pier bleibt stumm; Menüs spielen keine Szenengeräusche ab.

Die 200 zusätzlichen Ausrüstungsstücke wurden überarbeitet: plastische, geschlossene Formen,
abgerundete Konturen, neue Tierfiguren und detailliertere Miniaturen. Brillen haben verbundene
Fassungen, Gläser, Nasenauflagen und Bügel; Anhänger sitzen an Ketten aus einzelnen Gliedern.
Stoff, Metall, Glas und farbige Figuren erhalten passende Oberflächen. Die Modelle werden
direkt im Spiel erzeugt und benötigen keine zusätzlichen Texturpakete.

Alle Szenen lassen sich im freien Spiel und in Turnieren auswählen. Das kompakte Spielpaket enthält die drei Original-Introvideos;
alle sieben Radiosender sind als Stereo-AAC mit 128 kbit/s enthalten.
Neu: **Neon Gridlines** mit zehn vollständigen Electronic-Tracks und knapp 26 Minuten Musik.
Den Sender unter **Optionen → Radio** oder direkt am Radio wählen; auch im Multiplayer verfügbar.
Die sechs bisherigen Sender bleiben unverändert.

## Truhen und Preisgeld

Nach mindestens einer beendeten Hand gibt es beim Verlassen des Tisches eine Fundchance,
die mit der aktiven Zeit am Tisch steigt. Eine Sitzung erhält genau einen Wurf; ein
Verbindungsabbruch setzt die gesammelte Zeit nicht zurück. Truhen kosten nichts und benötigen
keine Schlüssel. Im Hauptmenü unter **TRUHEN** stehen Inhalte, Chancen und Ausrüstungsvorschau.
Der Tresor zeigt drei plastische 3D-Truhen mit Leder, Metallbeschlägen und beweglichen
Verschlüssen. Die neue Öffnungssequenz fährt mit der Kamera an die Truhe heran: Die
Verschlüsse springen einzeln auf, der Scharnierdeckel federt nach und Licht strömt heraus.
Eine Reihe echter 3D-Gegenstände bremst mit synchronen Klickgeräuschen bis zum Gewinn ab.
Anschließend wird die Belohnung mit einer Drehung, Partikeln und eigenen Klängen groß
enthüllt. Eine Galerie zeigt die möglichen Gegenstände als 3D-Miniaturen.
**Leertaste, Esc oder Überspringen** kürzen die Animation ab; der Gewinn ist bereits
gespeichert und wird beim Überspringen nicht erneut ausgewürfelt. Gegenstände lassen
sich direkt an der eigenen Figur ansehen.

- **Normal, episch und legendär:** insgesamt 58 exklusive Teile (27 Hüte, 11 Brillen, 20 Accessoires)
  oder Bankguthaben; doppelte Teile werden in Bankguthaben umgewandelt.
- **Neue Funde:** Swag-Brille, Papiertüte und Strumpfmaske. Sehr selten gibt es Karambit,
  Butterfly, Huntsman oder Shadow Daggers. Die ausgerüsteten Messer liegen auf dem Tisch;
  die Figur nimmt sie gelegentlich für eine eigene Inspektion in die Hand. Das Butterfly
  hat separat gelagerte Klinge und Griffe, die Shadow Daggers eine beidhändige Animation.
  Geformte Klingenschliffe, feine Metallmuster, Griffstrukturen und Schrauben ergänzen die
  neuen Modelle. Das Butterfly hat einzeln bewegte Fingergelenke, Griffwechsel zwischen
  Daumen und Zeigefinger, eine Rolle, eine aufgefächerte Inspektionspose und eine Fangbewegung.
  Die Klinge passt beim Falten in die Griffe. Das Karambit wechselt für Drehungen
  an den Ring. Die Oberflächen werden im Spiel erzeugt. Im Editor lässt
  sich die Animation mit **MESSER ANSEHEN** starten.
- **Messerchance je Öffnung:** normal 0,2 %, episch 0,6 %, legendär 1,5 %; die vier Arten
  sind gleich wahrscheinlich. Diese Chance ist in der Ausrüstungsquote enthalten.
  Doppelte Messer geben 12.000 $ Bankguthaben. Bestehende Gegenstände bleiben erhalten.
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

- **Voraktionen:** Während andere Spieler dran sind, rechts unten Fold, Check oder Raise
  mit einem genauen Gesamteinsatz vormerken. Auswahl erneut anklicken oder mit AUFHEBEN
  löschen. Check bleibt kostenlos; ein inzwischen unzulässiger Raise wird verworfen.
  Gilt jeweils für den nächsten Zug in derselben Setzrunde, im Einzel- und Mehrspieler.
  Für die serverseitige Prüfung müssen Host und Mitspieler die aktuelle Version verwenden.

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
  Alle Teilnehmer benötigen die aktuelle Spielversion (Netzprotokoll 12).

## Mitwirkende

Geräusche von Chips, Karten und Dampfzug: ZapSplat – https://www.zapsplat.com
Radiomusik: AudioHero (https://www.audiohero.com) über ZapSplat – https://www.zapsplat.com
Sender Kekwelle und Nachtschicht: Foureye, Kulluh, Dark Harmonics, Pioxonaq und ZapSplat – https://www.zapsplat.com
(Geräusche und Musik sind fest ins Spiel eingebaut und dürfen nicht herausgelöst oder einzeln weitergegeben werden.)
Voice-Codec: Opus 1.6.1 – Lizenzhinweise in `spiel/licenses/Opus.txt`.
