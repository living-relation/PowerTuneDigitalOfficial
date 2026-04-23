import QtQuick 2.8
import QtGraphicalEffects 1.0
import QtQuick.Controls 2.1
import com.powertune 1.0

// Option-B RPM arc style: a pure-Canvas rectangular segmented sweep across
// the top of the screen. No PNG dependencies — resolution independent and
// themable through the properties below.
//
// Layout target: a flat horizontal bar of evenly spaced "cells" that light
// up left→right with RPM. Shift-light LEDs are drawn directly underneath
// via the existing ShiftLights.qml widget so this style visually carries
// the shift indicators inline with the sweep.
//
// Loaded by Userdash{1,2,3}.qml via rpmbarloader when rpmstyleselector
// currentIndex == 5 ("Style 5").

Item {
    id: rpmStyle5
    anchors.fill: parent

    // --- Tunables (kept as properties so they can be wired to a future
    //     "RPM arc style" customization submenu without refactoring). ---
    property int    segmentCount: 40                        // number of cells across the sweep
    property real   segmentGap: 3                           // px between cells
    property color  segmentOffColor: Qt.rgba(0.15, 0.15, 0.18, 1)
    property color  segmentLowColor: Qt.rgba(0.15, 0.85, 0.30, 1)   // green
    property color  segmentMidColor: Qt.rgba(0.95, 0.80, 0.15, 1)   // yellow
    property color  segmentHighColor: Qt.rgba(0.95, 0.20, 0.15, 1)  // red
    property real   lowBandEnd: 0.60                        // 0..1 fraction of RPM range (green)
    property real   midBandEnd: 0.85                        // 0..1 (yellow above low)
    property color  backgroundColor: Qt.rgba(0.07, 0.07, 0.08, 1)
    property color  frameColor: Qt.rgba(0.35, 0.35, 0.40, 1)
    property int    barHeight: Math.max(28, rpmStyle5.height * 0.11)
    property int    barTopPadding: 6

    // RPM progress 0..1 — bound so the Canvas repaints on every RPM tick.
    property real progress: Dashboard.maxRPM > 0
                            ? Math.max(0, Math.min(1, Dashboard.rpm / Dashboard.maxRPM))
                            : 0
    onProgressChanged: barCanvas.requestPaint()

    // The frame + cells live inside a dedicated banner so Shift Lights can
    // anchor beneath them without overlapping the gauges below.
    Rectangle {
        id: banner
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: barTopPadding + barHeight + 2
        color: "transparent"

        // The segmented sweep.
        Canvas {
            id: barCanvas
            anchors.top: parent.top
            anchors.topMargin: barTopPadding
            anchors.left: parent.left
            anchors.right: parent.right
            height: barHeight
            antialiasing: true

            Connections {
                target: rpmStyle5
                onSegmentCountChanged:   barCanvas.requestPaint()
                onSegmentOffColorChanged: barCanvas.requestPaint()
                onSegmentLowColorChanged: barCanvas.requestPaint()
                onSegmentMidColorChanged: barCanvas.requestPaint()
                onSegmentHighColorChanged: barCanvas.requestPaint()
                onLowBandEndChanged:     barCanvas.requestPaint()
                onMidBandEndChanged:     barCanvas.requestPaint()
                onBackgroundColorChanged: barCanvas.requestPaint()
                onFrameColorChanged:     barCanvas.requestPaint()
            }

            onPaint: {
                var ctx = getContext("2d");
                ctx.reset();

                // Outer frame + background.
                ctx.fillStyle = backgroundColor;
                ctx.fillRect(0, 0, width, height);
                ctx.strokeStyle = frameColor;
                ctx.lineWidth = 1;
                ctx.strokeRect(0.5, 0.5, width - 1, height - 1);

                // Segment geometry — account for gaps so the last cell lands flush.
                var innerPad = 3;
                var innerW = width - (innerPad * 2);
                var innerH = height - (innerPad * 2);
                var totalGap = segmentGap * (segmentCount - 1);
                var cellW = (innerW - totalGap) / segmentCount;

                // How many cells are "lit" at current progress. Use a soft
                // partial-fill on the leading cell so the sweep looks smooth
                // even at a low RPM.
                var litExact = progress * segmentCount;
                var litFull  = Math.floor(litExact);
                var litFrac  = litExact - litFull;

                for (var i = 0; i < segmentCount; ++i) {
                    var x = innerPad + i * (cellW + segmentGap);
                    var bandFraction = (i + 0.5) / segmentCount;
                    var litColor;
                    if (bandFraction <= lowBandEnd) {
                        litColor = segmentLowColor;
                    } else if (bandFraction <= midBandEnd) {
                        litColor = segmentMidColor;
                    } else {
                        litColor = segmentHighColor;
                    }

                    if (i < litFull) {
                        ctx.fillStyle = litColor;
                        ctx.fillRect(x, innerPad, cellW, innerH);
                    } else if (i === litFull && litFrac > 0) {
                        // Partial leading cell — draw the off-colour first then the lit
                        // portion on top so the cell never appears to shrink visually.
                        ctx.fillStyle = segmentOffColor;
                        ctx.fillRect(x, innerPad, cellW, innerH);
                        ctx.fillStyle = litColor;
                        ctx.fillRect(x, innerPad, cellW * litFrac, innerH);
                    } else {
                        ctx.fillStyle = segmentOffColor;
                        ctx.fillRect(x, innerPad, cellW, innerH);
                    }
                }
            }
        }
    }

    // Shift lights directly underneath the bar.
    Item {
        id: shiftWrap
        anchors.top: banner.bottom
        anchors.topMargin: 4
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        height: parent.width * 0.06
        ShiftLights {}
    }
}
