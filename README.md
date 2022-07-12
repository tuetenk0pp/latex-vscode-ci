# LaTeX VS Code CI

Ich habe mit LaTeX nun einige Dinge ausprobiert und bin immer wieder zu einer Wunschvorstellung zurückgekehrt.
Meine LaTex-Umgebung sollte geräteunabhängig sein, deshalb habe ich zunächst ein eigenes [Docker Image von Overleaf](https://github.com/Tuetenk0pp/sharelatex-full) kreiert.
So richtig warm geworden bin ich damit jedoch nicht, da die Community Edition von Overleaf Git nicht unterstützt.
Wieder auf der Suche bin ich ziemlich schnell bei Visual Studio Code und dem LaTeX Workshop gelandet.
Verfeinert mit Docker und GitHub Workflows, bzw. GitLab Pipelines entsteht eine sehr universelle und mächtige LaTeX Umgebung, die auf der meisten Hardware läuft.
Klingt unschlagbar?
Finde ich auch.
Deshalb legen wir gleich los.

## Funktionen

- Snippets und Rechtschreibung
- Versionsverwaltung mit Git
- Commit Informationen in das Dokument einfügen
- LaTeX Dokumente mit Docker lokal oder remote bauen
- Automatisches Hochladen an eine WebDav Adresse

## Schnellstart

1. Eigene Repository auf Basis der Vorlage erstellen ([klick](https://github.com/Tuetenk0pp/latex-vscode-ci/generate)).
2. Die erstellte Repository mit VS Code clonen.
3. Mit ``Strg+Umschalt+P`` die Befehlseingabe öffnen und ``Remote-Containers: Reopen in Container`` ausführen.
4. Die Tastenkombination ``Strg+Alt+B`` baut das Dokument.
5. Ein Commit (und Push im Anschluss) mit ``build-document`` irgendwo in der Commit Message löst die GitHub Workflow, bzw. die GitLab Pipeline aus.

## Voraussetzungen

Damit Dokumente Lokal gebaut werden können, wird Docker benötigt.
Wer seine Dokumente ausschließlich Remote bauen lassen will, kommt mit VS Code und einer Git Installation aus.
Der Einfachheit halber beschränkt sich dieser Teil auf Windows Systeme.
Anleitungen für andere Betriebssysteme finden sich hier:

- [Docker](https://docs.docker.com/get-docker/)
- [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
- [VS Code](https://code.visualstudio.com/docs/setup/setup-overview)

### Docker installieren

Damit Docker auf Windows läuft, muss zunächst das Windows Subsystem for Linux (WSL) installiert werden.
Das geht ganz einfach mit dem unten stehenden Befehl in Windows Powershell (Das Programm ist in Windows vorinstalliert).
Dafür muss die Powershell als Administrator ausgeführt werden.
Eine vollständige Anleitung zur Installation von WSL gibt es [hier](https://docs.microsoft.com/en-us/windows/wsl/install).

```
wsl --install
```

Um nun Docker Desktop zu installieren, können die Schritte in dieser [Anleitung](https://docs.docker.com/desktop/windows/install/#install-docker-desktop-on-windows) befolgt werden.
Auf der Seite befindet sich auch der Downloadlink für Docker Desktop.

Alternativ kann das Kommandozeilenprogramm [winget](https://docs.microsoft.com/de-de/windows/package-manager/winget/) für die Installation verwendet werden:

```
winget install -e --id Docker.DockerDesktop
```

### Git installieren

Das Versionsverwaltungsprogramm Git kann [hier](https://git-scm.com/download/win) herunter geladen werden. Nach Abschluss des Downloads das Programm installieren und den Anweisungen auf dem Bildschirm folgen.

Alternativ kann das Kommandozeilenprogramm [winget](https://docs.microsoft.com/de-de/windows/package-manager/winget/) für die Installation verwendet werden:

```
winget install -e --id Git.Git
```

### VS Code installieren und einrichten

Die Dokumentation für die Installation von VS Code befindet sich [hier](https://code.visualstudio.com/docs/setup/windows).
Nach der Installation müssen einige Erweiterungen installiert werden.

Alternativ kann das Kommandozeilenprogramm [winget](https://docs.microsoft.com/de-de/windows/package-manager/winget/) für die Installation verwendet werden:

```
winget install -e --id Microsoft.VisualStudioCode
```

Sobald VS Code fertig eingerichtet ist, wird noch die Erweiterung [Remote Development](vscode:extension/ms-vscode-remote.vscode-remote-extensionpack) benötigt.
Ein Klick auf den Link installiert das Paket.

## Eine Repository erstellen

Eine Repository kann von der [Vorlage auf GitHub](https://github.com/Tuetenk0pp/latex-vscode-ci/generate) erstellt werden.

## Dokumente Lokal bauen

In VS Code kann nun mit ``Strg+Umschalt+P`` die Befehlseingabe geöffnet werden und er Befehl

```
Git: Clone
```

ausgeführt werden.
Gegebenfalls will VS Code sich nun in den GitHub Account einloggen.
Sobald die Repository lokal verfügbar ist, wird wieder die Befehlseingabe geöffnet und der Befehl

```
Remote-Containers: Reopen in Container
```

ausgeführt.
VS Code ließt nun den Inhalt der ``.devcontainer.json`` Datei:

```json
// .devcontainer.json
{
    "name": "TexLive",
    "image": "texlive/texlive",
    "extensions": [
        "James-Yu.latex-workshop",
        "valentjn.vscode-ltex"
    ]
}
```
Bei der ersten Ausführung vergeht einige Zeit, da erst das [TeXlive](https://hub.docker.com/r/texlive/texlive) Docker Image geladen wird.
Zusätzlich installiert VS Code in dem Container nun die Erweiterungen [LaTeX Workshop](https://marketplace.visualstudio.com/items?itemName=James-Yu.latex-workshop) und [LTeX](https://marketplace.visualstudio.com/items?itemName=valentjn.vscode-ltex).
Sobald VS Code vollständig einsatzbereit ist, kann mit der Tastenkombination ``Strg+Alt+B`` das Dokument gebaut werden.
LaTeX Workshop kann umfangreich konfiguriert werden.
Die Einstellungen öffnen sich mit der Tastenkombination ``Strg+,`` und mit dem Filter ``@ext:james-yu.latex-workshop`` lassen sich die gewünschten Optionen leicht finden. Die Einstellungen für LTeX werden mit dem Filter ``@ext:valentjn.vscode-ltex`` angezeigt.

## Dokumente Remote bauen

Wenn an einem Dokument zusammen gearbeitet wird, kann es hilfreich sein, den build-Prozess zu vereinheitlichen.
Wenn viele unterschiedliche LaTeX Installationen und Paketversionen verwendet werden, kommt es vor, dass das fertige Dokument nicht reproduzierbar ist.
Deshalb bietet es sich an, Dokumente remote bauen zu lassen.

### GitHub

Sobald GitHub Änderungen an ``.tex`` Dateien bemerkt, wird ein Workflow ausgelöst und das Dokument gebaut.
Damit Revisionen des PDFs einem Commit zugeordnet werden können, wird die entsprechende Information in ``\date`` in der ``praeambel.tex`` eingefügt.
Die Magie steckt in der Datei ``.github/workflows/build-document.yml``:

```yml
name: Build Document

on:
  workflow_dispatch:
  push:
    paths:
      - '**.tex'

jobs:
  build-document:
    runs-on: ubuntu-latest
    container: texlive/texlive
    steps:
      - name: checkout
        uses: actions/checkout@v2
      - name: commit info
        run: |
          GITHUB_SHA_SHORT=$(git rev-parse --short $GITHUB_SHA)
          sed -i "/GIT COMMIT INFORMATIONEN/a , Commit \\\ttfamily\\\href{$GITHUB_SERVER_URL/$GITHUB_REPOSITORY/commit/$GITHUB_SHA}{$GITHUB_SHA_SHORT}" praeambel.tex
      - name: build
        run: latexmk
      - name: upload artifact
        uses: actions/upload-artifact@v3
        with:
          name: Dokument
          path: main.pdf
          retention-days: 5

```

Einige Minuten später ist das Dokument als Workflow Artefakt verfügbar.

### GitLab

Ganz ähnlich funktioniert der Spaß in GitLab.
Ein Workflow heißt hier Pipeline, sonst ändert sich nicht viel.

```yml
# .gitlab.ci.yml

build-document:
    image: texlive/texlive
    script:
        - 'echo commit info'
        - 'sed -i "/GIT COMMIT INFORMATIONEN/a , Commit \\\ttfamily\\\href{$CI_PROJECT_URL/-/commit/$CI_COMMIT_SHA}{$CI_COMMIT_SHORT_SHA}" praeambel.tex'
        - 'echo build'
        - 'latexmk -silent Main.tex'
    after_script:
        - 'cat main.log'
    artifacts:
        paths:
            - 'main.pdf'
        expire_in: 
    only:
        changes:
          - '**.tex'
```

## Dokumente in einen WebDav Ordner hochladen

Das Dokument kann natürlich von GitHub, bzw. GitLab automatisch in eine Cloud geladen werden.
Clouds wie Owncloud oder Nextcloud unterstützen WebDav.
Für andere Anbieter existieren Actions auf dem [GitHub Marketplace](https://github.com/marketplace?category=&query=&type=actions&verification=).

### GitHub

Um den Upload an eine WebDav Adresse zu aktivieren, muss bei den entsprechenden Zeilen im ``build-document.yml`` die vorangestellte ``#`` entfernt werden:

```yml
      - name: upload webdav
        run: curl -T main.pdf -u "$WEBDAV_USER:$WEBDAV_PASSWORD" "$WEBDAV_URL/main.pdf"
```

Die Variablen ``WEBDAV_USER``, ``WEBDAV_PASSWORD`` und ``WEBDAV_URL`` sollten als GitHub Secrets gesetzt werden, da es sich um Zugangsdaten handelt.
Auch der Pfad und der Dateiname kann weiter angepasst werden, zum Beispiel so:

```
"$WEBDAV_URL/ordner/unterordner/latex-doc.pdf"
```

Ist auch das erledigt, kann der Workflow manuell ausgelöst werden, um die Funktion zu testen.

### GitLab

Die nötigen Schritte können analog zu der Konfiguration in GitHub durchgeführt werden.

```yml
        - 'echo upload webdav'
        - 'curl -T main.pdf -u "$WEBDAV_USER:$WEBDAV_PASSWORD" "$WEBDAV_URL/main.pdf"'
```
