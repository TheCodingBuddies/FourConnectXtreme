# Common Lisp (SBCL) Four Connect Xtreme Client

Das ist eine Common Lisp Implementierung für das Four Connect Xtreme Turnier.

Die eigene Logik kann einfach in der main.lisp Datei in der `get-move` Funktion implementiert werden. Alle notwendigen Informationen sind dort bereits vorhanden. Diese Funktion muss nur den Index der Spalte zurückgeben in die der Bot die Scheibe einführen soll.

## Implementierung
Um den Bot zu implementieren muss SBCL (zumindest mit keiner anderen Common Lisp Implementierung getestet) installiert sein. Dann kann der Bot in der REPL via `start-client <PORT> <NAME>` gestartet werden. Beispielsweise `(start-client 5051 "BesterBotYuhu")`.

## Deployment
Es muss das build.sh Skript ausgeführt werden, dadurch wird eine Executable des Bots generiert. Ich habe allerdings keine Ahung ob der selbe Command der in der .sh Datei ausgeführt wird auch unter Windows funktionieren würde. In der Theorie sollte das kein Problem sein da SBCL cross-platform ist und ich keine UNIX spezifischen Befehle verwendet habe.

Der Command zum Builden des Bots ist der Folgende, falls man das Skript nicht ausführen kann/möchte:

`sbcl --load "common_lisp_sbcl.asd" --eval "(ql:quickload :c4x-bot)" --eval "(c4x-bot::create-executable \"<NAME_DES_BOTS>\")"`

## Ausführen der Executable
Die Executable kann einfach in einem Terminal ausgeführt werden. Der Nutzer wird dann gepromptet einen Botnamen einzugeben und im Anschluss den Port des Servers. Danach sollte alles von alleine klappen. Der Bot kann derzeit leider nur mit Ctrl+C geschlossen werden. 
