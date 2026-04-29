---
name: powertune-cloud-agent-starter
description: Run, build, and smoke-test the PowerTune Qt/QML codebase on Linux agents (qmake, CI parity, QML lint, headless run, settings and optional build flags).
---

# PowerTune — Cloud agent runbook

Minimal instructions for **building and validating** this repository in agent or CI-like Linux environments. There is **no web login** or SaaS feature-flag system; persistence is **local `QSettings`**, and “flags” in QML are **dashboard sensor properties**, not remote toggles.

## Prerequisites (all areas)

Install a **Qt 5** desktop SDK with at least:

- **Modules:** `qtcharts`, `qtvirtualkeyboard` (matches `.github/workflows/build.yml`).
- **Components used by `PowertuneQMLGui.pro`:** `qml`, `quick`, `serialport`, `serialbus`, `network`, `charts`, `location`, `positioning`, `sensors`, `multimedia`, `widgets`.

On Debian/Ubuntu-style images, package names are often along the lines of `qtbase5-dev`, `qtdeclarative5-dev`, `qtmultimedia5-dev`, `libqt5charts5-dev`, `libqt5virtualkeyboard5-dev`, `libqt5serialport5-dev`, `libqt5serialbus5-dev`, `libqt5location5-plugins`, etc. Adjust for your distro’s Qt 5 packaging.

**Optional:** `libddcutil` development library — if present at link time, `HAVE_DDCUTIL` is defined and brightness/DDC paths are compiled in (`PowertuneQMLGui.pro`). Not required for a default desktop build.

**Tools for verification:** `qmake`, `make`, `qmllint` (optional but recommended for QML edits).

---

## Area: Core app (C++ / Qt)

**Layout:** `*.cpp`, `*.h`, `main.cpp`, `PowertuneQMLGui.pro`, `deployment.pri`.

### Build

```bash
cd /path/to/PowerTune
mkdir -p build && cd build
qmake ..
make -j"$(nproc)"
```

**Expected artifact:** `build/PowertuneQMLGui` (same name CI checks in `.github/workflows/build.yml`).

### Run (desktop)

```bash
cd build
./PowertuneQMLGui
```

### Run (headless / no display)

Use the Qt offscreen platform plugin (useful in agents without X11/Wayland):

```bash
cd build
QT_QPA_PLATFORM=offscreen ./PowertuneQMLGui
```

If plugins are not found, set `QT_PLUGIN_PATH` to your Qt plugins directory (distro-specific).

### Testing workflow (C++)

1. Clean or incremental build: `make clean` (optional) then `make -j"$(nproc)"`.
2. Fix compile errors; watch for missing Qt or system dev packages.
3. Optional: **cpplint** on touched C/C++ headers/sources (see CI area below).

---

## Area: QML / JavaScript UI

**Layout:** `*.qml`, `qml.qrc`, `Gauges/`, `Settings/`, `exampleDash/`, embedded assets under `graphics/`, `Sounds/`, etc.

### Lint (matches automation intent)

CI uses a **GitHub Action** for QML/JS validation (`.github/workflows/qmllint.yml`). Locally, run `qmllint` on files you change, for example:

```bash
cd /path/to/PowerTune
qmllint main.qml
# add paths for any new or edited QML/JS files
```

### Testing workflow (QML)

1. After edits, run `qmllint` on modified files.
2. Full build (`qmake && make`) — QML is bundled via `qml.qrc`, so syntax issues may still surface at **runtime** if not caught by lint.
3. Smoke-run the binary (with `QT_QPA_PLATFORM=offscreen` if there is no display) and watch stderr for QML errors.

---

## Area: CI / GitHub Actions (parity checks)

**Layout:** `.github/workflows/`.

| Workflow | What it does |
|----------|----------------|
| `build.yml` | Installs Qt **5.15.2** (charts + virtualkeyboard), `qmake ..`, `make`, checks `build/PowertuneQMLGui` exists. |
| `qmllint.yml` | QML/JS lint on pushes/PRs to `develop` (and PR events). |
| `cpplint_modified_files.yml` | On PRs, cpplint only on C++ files changed vs `origin/main` (see `.github/workflows/lint.py`). |

### Testing workflow (match CI locally)

```bash
mkdir -p build && cd build && qmake .. && make
test -f PowertuneQMLGui
```

For PRs that touch C++, mirror CI:

```bash
python3 -m pip install --user cpplint
# Compare against main as in CI; then:
cpplint --linelength=120 --filter=-legal/copyright,-whitespace/braces path/to/your.cpp ...
```

---

## Area: Assets and bundled content

**Layout:** `Gauges/`, `graphics/`, `fonts/`, `Sounds/`, `KTracks/`, `CAN_Configs/`, `exampleDash/`, `Logo/`, `Documents/`, `Settings/`.

These are mostly **data and QML** shipped through `qml.qrc`. There is no separate asset pipeline in-repo.

### Testing workflow

1. If you add or rename files, update **`qml.qrc`** (and any QML `import` paths) so the build still packages them.
2. Rebuild; missing resources usually fail at **runtime** (image/sound not found) — grep QML for the old path.

---

## Area: Hardware / platform scripts (not unit tests)

**Layout:** `Scripts/`, `test.sh` (Raspberry Pi SD/CAN checks — **not** the app test suite).

Treat `test.sh` as a **device runbook** (uses `dd`, `vcgencmd`, `can0`). Do not assume it is safe or meaningful on a generic cloud VM.

---

## Configuration, “flags”, and mocking

### Application identity (`QSettings`)

`AppSettings` uses:

```text
QSettings("PowerTuneQML", "PowerTuneDash", ...)
```

So on Linux, settings typically live under **`~/.config/PowerTuneQML/PowerTuneDash.conf`** (Qt native format). Back up or delete this file to reset UI/serial preferences between runs.

There are **no environment-variable feature flags** documented in-tree for behavior toggles.

### Compile-time option

- **`HAVE_DDCUTIL`**: auto-defined in `PowertuneQMLGui.pro` when `libddcutil` is present. Exposed to QML as context property `HAVE_DDCUTIL` (`main.cpp`).

### Dashboard “Flag1…FlagN” / “FlagString…”

In `dashboard.h`, “Flag*” names are **Q_PROPERTY** fields for gauge/dashboard data, **not** feature flags. To “mock” values for UI work, set them through the existing QML/C++ data path or the ECU/simulation layer you are testing — there is no central feature-flag service.

### Serial / CAN / GPS

Real hardware is optional for **build** verification. Runtime features need devices or protocol stubs appropriate to your task; see `README.md` for supported ECUs and historical platform notes.

---

## Updating this skill

When you discover a new reproducible step (package name, env var, headless quirk, CI drift, qmllint invocation, path to settings file on a new OS, etc.):

1. **Confirm** it against `PowertuneQMLGui.pro`, `main.cpp`, or `.github/workflows/*.yml`.
2. **Edit** `skills/powertune-cloud-agent-starter/SKILL.md` in the matching **Area** section (or add a short subsection).
3. Keep entries **action-oriented** (exact commands, file paths, expected artifacts).
4. If CI changes, update the **CI parity** table so agents do not follow stale commands.

---

## Quick reference

| Goal | Command / location |
|------|---------------------|
| Configure + compile | `mkdir build && cd build && qmake .. && make` |
| Binary | `build/PowertuneQMLGui` |
| Headless smoke | `QT_QPA_PLATFORM=offscreen ./PowertuneQMLGui` |
| QML lint | `qmllint <files.qml>` |
| User settings | `~/.config/PowerTuneQML/PowerTuneDash.conf` (typical on Linux) |
