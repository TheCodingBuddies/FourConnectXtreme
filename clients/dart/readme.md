# Dart Bot Installieren
- Dart nach beliebiger Methode installieren: https://dart.dev/get-dart
- Dependencies installieren
```bash
cd dart                                    # In den Dart Client Ordner wechseln
"C:\tools\dart-sdk\bin\dart.exe" pub get   # Abhängigkeiten via Dart installieren
```
# Dart Bot starten
```bash
cd dart                                      # In den Dart Client Ordner wechseln
"C:\tools\dart-sdk\bin\dart.exe" main.dart   # Bot mit Standardparameter starten
```

Um einen anderen Port oder eine andere KI zu verwenden:

```bash
"C:\tools\dart-sdk\bin\dart.exe" main.dart <BotName> <Port>
``` 

| Parameter | Beschreibung                                           |
|-----------|--------------------------------------------------------|
| BotName   | Name der KI, die gestartet werden soll (default: MyAI) |
| Port      | Port des Servers (default: 5051)                       |