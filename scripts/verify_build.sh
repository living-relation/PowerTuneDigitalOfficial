#!/usr/bin/env bash
# Simulated / local build verification for PowerTune QML GUI.
# Run from repo root: bash scripts/verify_build.sh
set -eu
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "== PowerTune verify_build =="
echo "ROOT=$ROOT"

FAIL=0

if command -v qmake >/dev/null 2>&1; then
  QMAKE=qmake
elif command -v qmake6 >/dev/null 2>&1; then
  QMAKE=qmake6
else
  echo "NOTE: qmake not found — skipping compile (install Qt dev tools to run a real build)."
  QMAKE=""
fi

if [ -n "${QMAKE}" ]; then
  BUILD_DIR="${ROOT}/build-verify-$$"
  mkdir -p "$BUILD_DIR"
  echo "Running: $QMAKE PowertuneQMLGui.pro && make -j4"
  ( cd "$BUILD_DIR" && "$QMAKE" "$ROOT/PowertuneQMLGui.pro" && make -j4 )
  echo "OK: Build dir $BUILD_DIR/ (see Makefile for target name)"
  echo "Tip: To run the demo path, set working directory and use the platform plugin for your host."
fi

echo ""
echo "== QML resource sanity (new UI files) =="
for f in IntroFast.qml Gauges/RoundGauge.qml Gauges/NeedleStyleList.qml; do
  if [ -f "$ROOT/$f" ]; then echo "  OK $f"; else echo "  MISSING $f"; FAIL=1; fi
done

if grep -q 'IntroFast.qml' "$ROOT/qml.qrc"; then
  echo "  OK IntroFast.qml registered in qml.qrc"
else
  echo "  FAIL IntroFast.qml not in qml.qrc"
  FAIL=1
fi

echo ""
echo "== CSV field count check (legacy 68 vs new 70 for round gauge) =="
if [ -f "$ROOT/exampleDash/UserDashboards/BlueDash.txt" ]; then
  head -1 "$ROOT/exampleDash/UserDashboards/BlueDash.txt" | awk -F',' '{print "  First row fields:", NF}'
fi

exit "$FAIL"
