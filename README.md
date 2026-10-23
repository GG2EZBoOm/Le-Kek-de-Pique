# Le Kek de Pique

3D-Poker (Texas Hold'em No-Limit) mit eigener C++/Direct3D-11-Engine – Karriere, Sit & Go,
Mehrtisch-Turniere, Multiplayer, Charakter-Editor und Errungenschaften.

## Spielen

1. Oben auf **Code → Download ZIP** klicken und den Ordner `spiel` entpacken.
2. `LeKekDePique.exe` starten (Windows 10/11, Grafikkarte mit Direct3D 11).

## Neue Schauplätze

- **Hindenburg:** Im Luftschiff-Salon geht die Pokerrunde während Brand, Sinkflug und Absturz weiter.
- **Geisterbahn:** Eine Fahrt durch Friedhof, Krypta, Spinnenhöhle, Spuksalon, Hexenküche und Jahrmarkt-Finale.
  Geister nähern sich dem Wagen, Skelette kommen aus Särgen und eine große Spinne lässt sich herunter.
- **Weißeritztalbahn bei Nacht:** Zusätzlich zur Tagfahrt mit Disco-Pokerwagen.

Alle Szenen lassen sich im freien Spiel und in Turnieren auswählen. Mit den drei Original-Introvideos liegt der Download bei rund 173 MB;
alle fünf Radiosender sind weiterhin in ihrer ursprünglichen Qualität enthalten.

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
- **Übers Internet:** Port 47123 (TCP) im Router auf den Host-PC weiterleiten und die öffentliche
  IPv4-Adresse weitergeben – oder ein gemeinsames VPN (z. B. Radmin VPN) nutzen – oder den
  eigenständigen Server auf einem VPS laufen lassen: `LeKekServer.exe --port 47123`.

## Mitwirkende

Geräusche von Chips, Karten und Dampfzug: ZapSplat – https://www.zapsplat.com
Radiomusik: AudioHero (https://www.audiohero.com) über ZapSplat – https://www.zapsplat.com
Sender Kekwelle und Nachtschicht: Foureye, Kulluh, Dark Harmonics, Pioxonaq und ZapSplat – https://www.zapsplat.com
(Geräusche und Musik sind fest ins Spiel eingebaut und dürfen nicht herausgelöst oder einzeln weitergegeben werden.)
