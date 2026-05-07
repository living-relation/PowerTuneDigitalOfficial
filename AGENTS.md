# AGENTS.md

## Cursor Cloud specific instructions

### Product overview

PowerTune is a C++/Qt5/QML automotive gauge dashboard application. It is a single monolithic desktop binary — no web servers, databases, Docker, or microservices. See `README.md` for full ECU and vehicle support details.

### Build and run

Standard commands are documented in `README.md` and `docs/VM_SIM_QUICKSTART.md`. Quick reference:

| Goal | Command |
|------|---------|
| Build | `cd /workspace && qmake PowertuneQMLGui.pro && make -j$(nproc)` |
| Run (display) | `DISPLAY=:1 ./PowertuneQMLGui` |
| Run (headless) | `xvfb-run -a ./PowertuneQMLGui` |
| Run (offscreen) | `QT_QPA_PLATFORM=offscreen ./PowertuneQMLGui` |
| QML lint | `qmllint <files.qml>` |
| Verify build | `bash scripts/verify_build.sh` |
| Full sim script | `bash scripts/powertune_vm_sim.sh <deps\|build\|run\|headless\|demo>` |

### Gotchas

- The build produces `PowertuneQMLGui` in the workspace root (not a `build/` subdirectory) when `qmake` is run from `/workspace`. The `verify_build.sh` script builds in a temp `build-verify-*` directory — clean those up after use.
- Expected runtime warnings (not errors): missing `/sys/class/backlight/rpi_backlight/brightness`, missing `/home/pi/Logo/Logo.png`, deprecated `Connections` syntax, `Translator.js` TypeError for undefined locale, `QQuickAnchorLine` assignment warnings. These are all benign in the VM.
- The app defaults to showing 1 dashboard page (`Dashboard.Visibledashes = 1`). Additional pages and the Settings tab require configuring more visible dashboards through the Dash Selector.
- There are no automated unit tests in this repository. Verification is done via build checks (`verify_build.sh`), `qmllint`, and manual UI testing.
- Hardware-dependent features (CAN bus, serial ECU, GPS, GoPro, Pi backlight, audio) require real hardware or protocol stubs and are not testable in the VM.
- CI uses Qt 5.15.2 via `jurplel/install-qt-action@v3`; the VM uses Ubuntu 24.04 distro Qt5 packages, which are 5.15.13. Both are compatible.
