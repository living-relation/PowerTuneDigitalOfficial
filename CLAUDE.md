# CLAUDE.md

Guidance for Claude Code (and other AI agents) working in this repository.

## Project overview

PowerTune is a **C++/Qt5/QML automotive gauge dashboard application** — a single
monolithic desktop binary, typically deployed to a Raspberry Pi as an in-car
display. It connects to aftermarket ECUs (Apexi PowerFC, Adaptronic, Haltech,
Microtech, Link G4, Nissan Consult, Holley EFI, OBD-II/ELM327, GT86/BRZ/FRS,
and others) via serial, CAN bus, or UDP-fed daemon processes, and renders
real-time engine/vehicle data (RPM, boost, AFR, temps, GPS, etc.) on
user-configurable gauge dashboards.

There are **no web servers, databases, Docker containers, or microservices**
in this project. See `README.md` for the full ECU/hardware compatibility
matrix and historical Raspberry Pi image-build instructions (those are
largely legacy — current CI targets a newer Qt than the old Buildroot/Debian
Stretch instructions in the README).

## Tech stack

- **Language:** C++11 for the app/business logic; **QML + JavaScript** for the UI.
- **Framework:** Qt 5 — CI installs **5.15.2**; local dev VMs commonly have distro
  Qt5 **5.15.13** (both are compatible). A separate workflow installs Qt 6
  purely to get a `qmllint` binary — the app itself is never built with Qt 6.
- **Build system:** qmake (`PowertuneQMLGui.pro`), not CMake. Qt modules used:
  `qml quick serialport serialbus network charts location positioning sensors
  multimedia widgets` (+ `svg` and the virtual-keyboard plugin under `static` config).
- **Optional native dependency:** `libddcutil` (DDC/CI monitor brightness
  control) — auto-detected at qmake time (`exists(/usr/lib/libddcutil.so.4)`
  in `PowertuneQMLGui.pro`), defines `HAVE_DDCUTIL`, exposed to QML as a
  context property in `main.cpp`. Not required for a normal desktop build.
- **Persistence:** `QSettings("PowerTuneQML", "PowerTuneDash", ...)` — on
  Linux this resolves to `~/.config/PowerTuneQML/PowerTuneDash.conf`. There is
  no database and **no environment-variable feature-flag system**; `Flag*`
  properties in `dashboard.h` are gauge/dashboard data fields, not feature toggles.

## Directory structure

```
*.cpp / *.h              Flat layout at repo root — all C++ source/headers live here (no src/).
                          Core files: main.cpp, dashboard.cpp/.h (the central data model),
                          connect.cpp/.h (ECU connection orchestration), appsettings.cpp/.h,
                          Extender.cpp/.h (SocketCAN), udpreceiver.cpp/.h (UDP CAN bridge),
                          Apexi.cpp/.h, AdaptronicSelect.cpp/.h (ECU protocol parsers),
                          gps.cpp/.h, gopro.cpp/.h, sensors.cpp/.h, datalogger.cpp/.h,
                          downloadmanager.cpp/.h, parsegithubdata.cpp/.h, iomapdata.cpp/.h,
                          calculations.cpp/.h, wifiscanner.cpp/.h, arduino.cpp/.h.
*.qml (root)              Top-level screens: main.qml, SerialSettings.qml, Intro.qml/IntroFast.qml,
                          ExBoardAnalog.qml, AnalogInputs.qml, ConsultRegs.qml, OBDPIDS.qml, etc.
Gauges/                   Gauge widgets/styles (RoundGauge.qml, BarGauge.qml, Dyno.qml, Charts.qml,
                          Cluster.qml, Userdash1/2/3.qml — the user-customizable dashboards).
Settings/                 In-app settings tabs (main.qml, DashSelector.qml, network.qml, rpm.qml, ...).
graphics/, fonts/, Sounds/, Logo/   Bundled UI assets, packaged via qml.qrc / graphics.qrc.
exampleDash/              Sample dashboards (exampleDash/UserDashboards/*.txt export format).
daemons/                  ~67 prebuilt per-ECU daemon binaries that feed UDP data to the app.
                          These are distributed binaries, not built from this source tree.
KTracks/, GPSTracks/, CAN_Configs/  GPS track data and CAN bus config reference data.
Documents/                Reference PDFs/spreadsheets for ECU protocols.
Scripts/  (capital S)     Raspberry Pi deployment: systemd units (PowerTune.service,
                          bootsplash.service), udev rules, start.sh. Device-image tooling, not dev tooling.
scripts/  (lowercase s)   Dev/CI tooling: verify_build.sh, powertune_vm_sim.sh,
                          branch_hygiene_audit.sh, branch_hygiene_cleanup.sh.
                          NOTE: Scripts/ and scripts/ are different directories — mind the case.
docs/                     BRANCH_GOVERNANCE.md, VM_SIM_QUICKSTART.md, DEMO_UI_WALKTHROUGH.md,
                          COLOR_PICKER_COLORS.md, conversation/session logs.
skills/powertune-cloud-agent-starter/SKILL.md   Detailed agent build/run/lint runbook (see below).
.cursor/rules/*.mdc       Subsystem-specific architecture notes for AI agents (see Architecture below).
.github/workflows/        CI: build.yml, qmllint.yml, cpplint_modified_files.yml (+ lint.py),
                          pr-target-policy.yml, feature-merge-command.yml, delete-merged-branches.yml.
```

## Build, run, lint, verify

```bash
# Build (matches AGENTS.md convention — builds in place at repo root)
qmake PowertuneQMLGui.pro && make -j"$(nproc)"

# Build (matches CI convention — builds in a build/ subdirectory)
mkdir -p build && cd build && qmake .. && make

# Run
DISPLAY=:1 ./PowertuneQMLGui            # visible display
xvfb-run -a ./PowertuneQMLGui           # headless via Xvfb
QT_QPA_PLATFORM=offscreen ./PowertuneQMLGui   # headless via Qt offscreen plugin

# Verify build sanity (builds in a temp build-verify-* dir; clean those up after)
bash scripts/verify_build.sh

# Full VM sim helper
bash scripts/powertune_vm_sim.sh {deps|build|run|headless|demo|all|help}

# QML/JS lint
qmllint main.qml
qmllint <files.qml>

# C++ lint (CI runs this only on files changed vs origin/main; config: CPPLINT.cfg)
python -m pip install cpplint
cpplint --linelength=120 --filter=-legal/copyright,-whitespace/braces <files...>
```

Dependency install (Ubuntu/Debian) — see `README.md` / `AGENTS.md` /
`docs/VM_SIM_QUICKSTART.md` for the full `apt-get install` package list
(Qt5 dev packages, QML modules, `xvfb`, `ffmpeg`, etc.).

## Testing conventions

**There is no automated unit test suite.** Verification for this project means:

1. A successful build (`qmake && make`, or `scripts/verify_build.sh`).
2. `qmllint` passing on changed `.qml`/`.js` files.
3. Manual UI walkthrough — see `docs/DEMO_UI_WALKTHROUGH.md` (swipe dashboards,
   open Settings/Dash Selector, add/edit gauges, save/export a dashboard `.txt`
   and re-import it to check backward compatibility).

`test.sh` at the repo root is **not** a test suite — it's a Raspberry Pi
hardware runbook (SD card speed test, `vcgencmd`, CAN interface up/down).
Don't run it expecting it to validate a code change, and don't treat it as
meaningful in a generic VM/agent environment.

Hardware-dependent features (CAN bus, serial ECU, GPS, GoPro, Pi backlight,
audio) require real hardware or protocol stubs and generally cannot be
exercised in a VM/container.

## Code style

- **C++:** `cpplint` is the only enforced linter. Config: `CPPLINT.cfg`
  (`filter=-build/include_subdir,-build/include_order`, because headers are
  flat at repo root rather than in subdirectories). CI (`cpplint_modified_files.yml`)
  only lints files that changed vs `origin/main` in a given PR, using
  `--linelength=120 --filter=-legal/copyright,-whitespace/braces`.
- **QML/JS:** `qmllint` is the only checker.
- There is **no clang-format, ESLint, or Prettier config** in this repo — don't
  invent or apply formatting rules that aren't actually enforced; match the
  surrounding code's existing style instead.

## Git workflow

- Canonical trunk is `main`. Default merge strategy is **rebase and merge**
  with a linear-history policy (no merge commits into trunk) — see
  `docs/BRANCH_GOVERNANCE.md`.
- CI (`pr-target-policy.yml`) enforces that PR base repo/branch must be
  `living-relation/PowerTuneDigitalOfficial` / `main`.
- Branch naming convention observed in history: `<tool>/<short-description>[-hash]`,
  e.g. `cursor/dev-env-setup-5ecd`, `claude/fix-branch-deletion-policy`,
  `copilot/update-cpplint-workflow-conditions`.
- Branch hygiene tooling: `bash scripts/branch_hygiene_audit.sh` and
  `TRUNK_BRANCH=main STALE_DAYS=90 DRY_RUN=true bash scripts/branch_hygiene_cleanup.sh`.
  Deleted branch tips are preserved as `archive/deleted-branches/<timestamp>/<branch>`
  tags before deletion — never delete `main`, `master`, `develop`, `release/*`,
  `support/*`, `hotfix/*`, `recovery/*`, or `archive/*`.
- Chat-ops PR commands exist (`feature-merge-command.yml`): `/merge-feature
  <source> into <target> delete <branch>` and `/feature-branches`, restricted
  to users with write/maintain/admin permission.

## Architecture notes

For subsystem-level detail, read the actual `.cursor/rules/*.mdc` files (they
are glob-scoped and actively maintained per subsystem) rather than relying on
a summary going stale here:

- `powertune-can-dataflow.mdc` — UDP (port 45454, `"id,value"` text format)
  and SocketCAN (`can0`, `QCanBusFrame`) ingestion paths into `DashBoard`.
- `powertune-hardware-can.mdc` / `powertune-pi-config-hardware.mdc` — Raspberry
  Pi `config.txt` device-tree overlays (MCP2515 CAN hat, SPI, GPIO 25 IRQ).
- `powertune-round-gauge-needles.mdc` — `RoundGauge.qml` Canvas-based needle
  rendering and the append-only `.txt` CSV schema for round gauges.
- `powertune-userdash-persistence.mdc` — `SwipeView`/`Loader` structure in
  `main.qml`, `Dashboard.Visibledashes`, `Qt.labs.settings`-based persistence,
  and the `.txt` dashboard import/export flow (note: `Cluster.qml` uses a
  different `MainDash.txt` load path than the numbered `UserdashN` dashboards).

## Deployment

Target deployment is a Raspberry Pi running the compiled binary as a
kiosk-style dashboard: `deployment.pri` installs to `/opt/PowerTune` on unix,
and `Scripts/` (capital S) holds the systemd units (`PowerTune.service`,
`bootsplash.service`) and udev rules used on-device. There is no
containerized or cloud deployment path for this app.

## CI

- `build.yml` — installs Qt 5.15.2, builds in `build/`, checks the
  `PowertuneQMLGui` binary exists. PR/build verification only, no deploy step.
- `qmllint.yml` — QML/JS lint on push to `main` and on PRs (installs Qt 6 just
  to get a `qmllint` binary).
- `cpplint_modified_files.yml` — cpplint on PR-modified C++ files, posts
  results as a PR comment.
- `pr-target-policy.yml` — enforces PR base repo/branch (see Git workflow above).

## Further reading

- `skills/powertune-cloud-agent-starter/SKILL.md` — a more detailed, actively
  maintained agent runbook per subsystem area (build/run/lint per component,
  configuration and "flags", mocking guidance). Keep it in sync if you
  discover new reproducible steps.
- `AGENTS.md` — short Cursor-Cloud-specific quick reference and gotchas list.
