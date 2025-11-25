# Common Lisp (SBCL) Four Connect Xtreme Client

Das ist eine Client Implementierung in Common Lisp für das Four Connect Xtreme Turnier.

## Entwicklung
Um einen Bot für das Turnier zu entwickeln muss einfach in der bots.lisp Datei die Funktion `defbot` mit einem Namen und einer Funktion aufgerufen werden. Die Funktion bekommt als einzigen Parameter den aktuellen State übergeben. Es finden sich Beispiele wie "Dumpling" und "FirstIsKey" in der `bots.lisp` Datei.

## Deployment
Um den Bot zu starten kann das beigelegte Dockerfile verwendet werden. Dazu müssen die folgenden Commands ausgeführt werden:

1. `docker build -t c4xbot .` - Dieses Command baut den Container zusammen und lädt alle Dependencies herunter.
2. `docker run --add-host host.docker.internal:host-gateway c4xbot <name des bots> <websocket>` - Der `--add-host host.docker.internal:host-gateway` Parameter wird scheinbar nur unter Linux gebraucht, unter Windows und MacOS kann das weggelassen werden. Also beispielsweise: `docker run --add-host host.docker.internal:host-gateway c4xbot DUMPLING host.docker.internal:5051`.
3. Der Bot sollte sich verbinden und die Spiele spielen.
4. Da der Bot derzeit den Main-Thread ausschließlich zum sleepen verwendet kann der Dockerprozess nur mit Ctrl-C Ctrl-C Ctrl-C abgebrochen werden. Das liegt daran dass ich keine Möglichkeit gefunden habe zu prüfen ob noch eine Verbindung existiert oder ob wir schon disconnected sind.
