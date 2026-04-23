# PowerTune UI demo — menus, touch, new features, faster splash

This document is the **demo script** for what was added on branch `cursor/demo-build-verify-71bf`. It does not replace running the app on hardware; it lists **exact gestures and screens** so you can record a short video or step through QA.

## 1. Build / “simulate build” locally

From the repo root:

```bash
bash scripts/verify_build.sh
```

- If `qmake` is installed, the script runs `qmake` + `make` in a temp `build-verify-*` directory and checks that new QML files exist and `IntroFast.qml` is in `qml.qrc`.
- If `qmake` is missing, the script still runs the file checks and reports skip for compile.

## 2. Faster “bootup” (first screen)

**What changed:** `main.qml` can load **`IntroFast.qml`** instead of **`Intro.qml`** for the first `SwipeView` page when `useFastIntroSplash` is `true` (default) in `Qt.labs.settings`.

- **Classic:** `Intro.qml` loads `file:///home/pi/Logo/Logo.png` (I/O and decode on the logo file).
- **Fast:** `IntroFast.qml` is a **pure QML** dark splash with text — no external image path, so **first paint** is usually quicker on dev machines without `/home/pi/Logo/`.

**How to A/B in the app:** `useFastIntroSplash` is stored in **`Qt.labs.settings`** with `appSettings` in `main.qml` (default **true**). Set it to **false** for the classic logo intro, restart, and compare time to first visible frame. You can also flip the `firstPageLoader.source` binding temporarily while developing.

**What this is not:** It does not shorten C++ `main()`/ECU init — only the first QML page load path.

## 3. Navigation and menus (demo flow)

Assume **Settings (Serial)** is the **last** page in the `SwipeView` (swipe from intro toward the end).

1. **Swipe** from the intro left/right through dash slots (per **Dash Sel.** configuration).
2. **Top drawer** (from top edge): Trip reset, shutdown, brightness slider (when `Dashboard.screen` allows), etc. — **updated chrome** (darker surface, accent border).
3. **Settings tabs** (`SerialSettings.qml`): **Main**, **Dash Sel.**, **Sensehat**, **Warn / Gear**, **Speedtab**, **analog**, **RPM2**, **EX Board**, **Startup**, … — **darker frame + selected tab** styling.
4. **Dash Sel.** (`Settings/DashSelector.qml`): Choose **1–4** active dashes; assign **User dash 1/2/3** to slots.

## 4. User dashboard — touch and menus

On **User dash 1/2/3** (`Gauges/Userdash1.qml` etc.):

1. **Double-tap** the background (or use the documented double-tap region) to **show** edit chrome: import/export, color/source combos, **Save**.
2. Add a **round gauge** from the add flow, then **double-tap the gauge** to open its **context menu** (datasource, size/ring, start/stop, **Needle**).
3. **Needle** submenu: set colors/length; choose **Needle style** (canvas default vs **SVG** presets from `NeedleStyleList.qml`).
4. **Size and ring** submenu: set **Gauge style** to **Aurora / Stealth / Pro** (indices 5–7) in addition to the original five styles.

**Persistence:** **Save** stores JSON in `datastoreN`; **Export** writes `.txt` with two extra trailing fields for round gauges: `needleStyleIndex`, `needleImageSource` (old 68-field files still import).

## 5. Suggested “feature checklist” for a 2–3 minute video

| Shot | Action |
|------|--------|
| A | Cold start showing **IntroFast** vs **Intro** (optional A/B) |
| B | **Drawer** from top, trip/brightness, note new panel look |
| C | **Settings** last page → tab bar appearance |
| D | **Dash Sel.** set User dash, swipe to it |
| E | **Double-tap** user dash → import/save area |
| F | **Round gauge** → menu → **Gauge style** 5/6/7 |
| G | Same → **Needle** → **Needle style** (e.g. Aurora Edge SVG) |
| H | **Save** and **Export** dash; show `.txt` line with extra columns |

## 6. Branch and PR

- Work for this doc + scripts + `IntroFast` lives on **`cursor/demo-build-verify-71bf`**.
- **No PR** was created for this step per your request; push the branch and open a PR when ready.
