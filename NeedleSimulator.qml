import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs 1.3

ApplicationWindow {
    id: root
    visible: true
    width: 1200
    height: 760
    title: "PowerTune Needle Simulator"
    color: "#1f1f1f"

    property real angleDeg: 0
    property int needleMode: 0 // 0=Canvas(default), 1=Image
    property color needleColorA: "#ff2d2d"
    property color needleColorB: "#8f0000"
    property real needleLengthPct: 86
    property real needleBasePct: 8
    property real needleTipPx: 6
    property real needleInsetPct: 6
    property real needleScaleX: 1.0
    property real needleScaleY: 1.0
    property string needleImageSource: ""

    function clamp(v, minV, maxV) {
        return Math.max(minV, Math.min(maxV, v));
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 14

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 8
            color: "#101010"
            border.width: 1
            border.color: "#333333"

            Item {
                id: gaugeArea
                anchors.fill: parent
                anchors.margins: 20

                Rectangle {
                    id: ring
                    anchors.centerIn: parent
                    width: Math.min(gaugeArea.width, gaugeArea.height) * 0.92
                    height: width
                    radius: width / 2
                    color: "#171717"
                    border.width: 3
                    border.color: "#4a4a4a"
                }

                Repeater {
                    model: 13
                    Rectangle {
                        width: 3
                        height: index % 3 === 0 ? 22 : 12
                        color: "#7a7a7a"
                        radius: 1
                        anchors.centerIn: ring
                        transform: [
                            Translate { y: -ring.width / 2 + 18 },
                            Rotation { angle: index * 25 - 150; origin.x: 1.5; origin.y: ring.width / 2 - 18 }
                        ]
                    }
                }

                Item {
                    id: needlePivot
                    width: ring.width
                    height: ring.height
                    anchors.centerIn: ring
                    rotation: root.angleDeg

                    Item {
                        id: needleRoot
                        width: ring.width
                        height: ring.height
                        // Do not use anchors.centerIn together with explicit y — anchors win and y is ignored.
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        // Inset offset after layout (same effect as a free y would have had without center anchor).
                        transform: Translate {
                            y: ring.width * (root.needleInsetPct * 0.01)
                        }

                        // Default PowerTune-like canvas needle
                        Canvas {
                            id: canvasNeedle
                            visible: root.needleMode === 0
                            anchors.centerIn: parent
                            width: ring.width * clamp(root.needleBasePct / 100.0, 0.01, 0.9)
                            height: ring.width * clamp(root.needleLengthPct / 100.0, 0.05, 1.2)
                            // Item.scale is uniform on both axes; use Scale transform so X/Y sliders match image needle.
                            transform: Scale {
                                origin.x: canvasNeedle.width / 2
                                origin.y: canvasNeedle.height
                                xScale: root.needleScaleX
                                yScale: root.needleScaleY
                            }
                            antialiasing: true

                            onPaint: {
                                var ctx = getContext("2d");
                                var xCenter = width / 2;
                                var yBottom = height;
                                var baseHalf = width / 2;
                                var tipHalf = root.needleTipPx / 2;

                                ctx.reset();
                                ctx.beginPath();
                                ctx.moveTo(xCenter, yBottom);
                                ctx.lineTo(xCenter - baseHalf, yBottom - baseHalf);
                                ctx.lineTo(xCenter - tipHalf, 0);
                                ctx.lineTo(xCenter, 0);
                                ctx.closePath();
                                ctx.fillStyle = root.needleColorB;
                                ctx.fill();

                                ctx.beginPath();
                                ctx.moveTo(xCenter, yBottom);
                                ctx.lineTo(xCenter + baseHalf, yBottom - baseHalf);
                                ctx.lineTo(xCenter + tipHalf, 0);
                                ctx.lineTo(xCenter, 0);
                                ctx.closePath();
                                ctx.fillStyle = root.needleColorA;
                                ctx.fill();
                            }

                            Connections {
                                target: root
                                function onNeedleColorAChanged() { canvasNeedle.requestPaint(); }
                                function onNeedleColorBChanged() { canvasNeedle.requestPaint(); }
                                function onNeedleTipPxChanged() { canvasNeedle.requestPaint(); }
                                function onNeedleBasePctChanged() { canvasNeedle.requestPaint(); }
                                function onNeedleLengthPctChanged() { canvasNeedle.requestPaint(); }
                                function onNeedleScaleXChanged() { canvasNeedle.requestPaint(); }
                                function onNeedleScaleYChanged() { canvasNeedle.requestPaint(); }
                            }
                        }

                        // Image-based needle mode for PNG/SVG
                        Image {
                            id: imageNeedle
                            visible: root.needleMode === 1
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottom: parent.verticalCenter
                            width: ring.width * clamp(root.needleBasePct / 100.0, 0.03, 0.9) * 3.0
                            height: ring.width * clamp(root.needleLengthPct / 100.0, 0.06, 1.3)
                            fillMode: Image.PreserveAspectFit
                            source: root.needleImageSource
                            smooth: true
                            antialiasing: true
                            // Do not combine Item.scale with Scale — scale is uniform and compounds with xScale on X.
                            transform: Scale {
                                origin.x: imageNeedle.width / 2
                                origin.y: imageNeedle.height
                                xScale: root.needleScaleX
                                yScale: root.needleScaleY
                            }
                        }
                    }

                    Rectangle {
                        width: ring.width * 0.08
                        height: width
                        radius: width / 2
                        anchors.centerIn: parent
                        color: "#202020"
                        border.width: 2
                        border.color: "#b3b3b3"
                    }
                }
            }
        }

        Rectangle {
            Layout.preferredWidth: 360
            Layout.fillHeight: true
            radius: 8
            color: "#121212"
            border.width: 1
            border.color: "#333333"

            ScrollView {
                anchors.fill: parent
                anchors.margins: 12
                clip: true

                ColumnLayout {
                    width: 320
                    spacing: 10

                    Label { text: "Needle Simulator"; color: "white"; font.pixelSize: 20; font.bold: true }
                    Label { text: "Use this to tune geometry and test PNG/SVG needles before wiring into RoundGauge."; wrapMode: Text.WordWrap; color: "#c8c8c8" }

                    ComboBox {
                        Layout.fillWidth: true
                        model: ["Canvas needle (default)", "Image needle (PNG/SVG)"]
                        currentIndex: root.needleMode
                        onCurrentIndexChanged: root.needleMode = currentIndex
                    }

                    Button {
                        Layout.fillWidth: true
                        text: "Choose image file..."
                        enabled: root.needleMode === 1
                        onClicked: fileDialog.open()
                    }

                    TextField {
                        Layout.fillWidth: true
                        enabled: root.needleMode === 1
                        placeholderText: "file:///path/to/needle.png or .svg"
                        text: root.needleImageSource
                        onEditingFinished: root.needleImageSource = text
                    }

                    Label { text: "Angle: " + Math.round(root.angleDeg) + " deg"; color: "#d8d8d8" }
                    Slider {
                        Layout.fillWidth: true
                        from: -180
                        to: 180
                        value: root.angleDeg
                        onMoved: root.angleDeg = value
                    }

                    Label { text: "Length (% of radius): " + Math.round(root.needleLengthPct); color: "#d8d8d8" }
                    Slider {
                        Layout.fillWidth: true
                        from: 20
                        to: 120
                        value: root.needleLengthPct
                        onMoved: root.needleLengthPct = value
                    }

                    Label { text: "Base width (% of radius): " + Math.round(root.needleBasePct); color: "#d8d8d8" }
                    Slider {
                        Layout.fillWidth: true
                        from: 2
                        to: 30
                        value: root.needleBasePct
                        onMoved: root.needleBasePct = value
                    }

                    Label { text: "Tip width (px): " + Math.round(root.needleTipPx); color: "#d8d8d8" }
                    Slider {
                        Layout.fillWidth: true
                        from: 1
                        to: 30
                        value: root.needleTipPx
                        onMoved: root.needleTipPx = value
                    }

                    Label { text: "Inset (% of radius): " + Math.round(root.needleInsetPct); color: "#d8d8d8" }
                    Slider {
                        Layout.fillWidth: true
                        from: -20
                        to: 20
                        value: root.needleInsetPct
                        onMoved: root.needleInsetPct = value
                    }

                    Label { text: "Scale X (maps to tip/base feel): " + root.needleScaleX.toFixed(2); color: "#d8d8d8" }
                    Slider {
                        Layout.fillWidth: true
                        from: 0.2
                        to: 2.0
                        value: root.needleScaleX
                        onMoved: root.needleScaleX = value
                    }

                    Label { text: "Scale Y (maps to length feel): " + root.needleScaleY.toFixed(2); color: "#d8d8d8" }
                    Slider {
                        Layout.fillWidth: true
                        from: 0.2
                        to: 2.0
                        value: root.needleScaleY
                        onMoved: root.needleScaleY = value
                    }

                    Label { text: "Canvas needle colors"; color: "#d8d8d8"; font.bold: true }
                    RowLayout {
                        Layout.fillWidth: true
                        Button { text: "Red"; onClicked: { root.needleColorA = "#ff2d2d"; root.needleColorB = "#8f0000"; } }
                        Button { text: "Blue"; onClicked: { root.needleColorA = "#52b6ff"; root.needleColorB = "#004b8f"; } }
                        Button { text: "White"; onClicked: { root.needleColorA = "#ffffff"; root.needleColorB = "#9a9a9a"; } }
                    }
                }
            }
        }
    }

    FileDialog {
        id: fileDialog
        title: "Select needle image"
        nameFilters: ["Images (*.png *.svg *.jpg *.jpeg *.webp)"]
        onAccepted: {
            root.needleImageSource = fileUrl;
        }
    }
}
