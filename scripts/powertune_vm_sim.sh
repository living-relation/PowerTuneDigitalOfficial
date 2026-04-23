#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="${ROOT}"
APP_BIN="${ROOT}/PowertuneQMLGui"

print_help() {
  cat <<'EOF'
PowerTune VM simulation helper

Usage:
  bash scripts/powertune_vm_sim.sh <command>

Commands:
  deps      Install common Ubuntu/Debian build/runtime dependencies
  build     Build PowerTuneQMLGui in /workspace
  run       Run with visible desktop session (requires DISPLAY)
  headless  Run via xvfb-run (headless simulation)
  demo      Headless run + demo video capture to /workspace/artifacts
  all       deps + build + run
  help      Show this help
EOF
}

install_deps() {
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
}

build_app() {
  cd "${BUILD_DIR}"
  qmake PowertuneQMLGui.pro
  make -j"$(nproc)"
  if [[ ! -x "${APP_BIN}" ]]; then
    echo "Build completed but ${APP_BIN} is missing or not executable."
    exit 1
  fi
}

run_visible() {
  cd "${BUILD_DIR}"
  "${APP_BIN}"
}

run_headless() {
  cd "${BUILD_DIR}"
  xvfb-run -a "${APP_BIN}"
}

run_demo_capture() {
  cd "${BUILD_DIR}"
  mkdir -p "${ROOT}/artifacts"
  xvfb-run -a bash -lc '
    /workspace/PowertuneQMLGui > /workspace/artifacts/powertune-sim.log 2>&1 &
    APP_PID=$!
    sleep 2
    ffmpeg -y -video_size 1280x720 -framerate 20 -f x11grab -i "$DISPLAY" \
      -t 25 -pix_fmt yuv420p /workspace/artifacts/powertune-sim-demo.mp4 >/dev/null 2>&1
    kill $APP_PID || true
    wait $APP_PID 2>/dev/null || true
  '
  echo "Demo video: /workspace/artifacts/powertune-sim-demo.mp4"
}

cmd="${1:-help}"
case "${cmd}" in
  deps)
    install_deps
    ;;
  build)
    build_app
    ;;
  run)
    run_visible
    ;;
  headless)
    run_headless
    ;;
  demo)
    run_demo_capture
    ;;
  all)
    install_deps
    build_app
    run_visible
    ;;
  help|--help|-h)
    print_help
    ;;
  *)
    echo "Unknown command: ${cmd}"
    print_help
    exit 1
    ;;
esac
