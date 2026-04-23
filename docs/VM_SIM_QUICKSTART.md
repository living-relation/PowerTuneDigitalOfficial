# PowerTune VM Sim Quickstart

Use this from `/workspace` in the VM.

## One-time dependency install (Ubuntu/Debian)

```bash
sudo apt-get update
sudo apt-get install -y \
  qtbase5-dev qtdeclarative5-dev qtquickcontrols2-5-dev \
  qtmultimedia5-dev libqt5serialport5-dev libqt5serialbus5-dev \
  libqt5charts5-dev qtlocation5-dev qtpositioning5-dev \
  libqt5positioning5 libqt5sensors5-dev qtchooser \
  qml-module-qtquick-controls qml-module-qtquick-controls2 \
  qml-module-qtquick-dialogs qml-module-qtquick-window2 \
  qml-module-qtquick-layouts qml-module-qtquick-extras \
  qml-module-qtgraphicaleffects qml-module-qt-labs-settings \
  qml-module-qtpositioning qml-module-qtlocation \
  qml-module-qtmultimedia qml-module-qtsensors \
  qtvirtualkeyboard-plugin xvfb xdotool ffmpeg
```

## Build + run commands

```bash
cd /workspace
bash scripts/powertune_vm_sim.sh build
bash scripts/powertune_vm_sim.sh run
```

## Headless simulation run

```bash
cd /workspace
bash scripts/powertune_vm_sim.sh headless
```

## Record a short demo video

```bash
cd /workspace
bash scripts/powertune_vm_sim.sh record 20 artifacts/powertune-demo.mp4
```

## Useful extras

```bash
# verify setup/build sanity (non-fatal if qmake missing)
bash scripts/verify_build.sh

# stop any running sim processes
pkill -f PowertuneQMLGui || true
```
