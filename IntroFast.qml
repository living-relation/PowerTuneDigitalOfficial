import QtQuick 2.8

// Lightweight first-screen splash: no /home/pi/Logo file I/O — faster first paint
// when the full Intro.qml would wait on a missing or slow file:// image.
Rectangle {
    id: introFast
    anchors.fill: parent
    color: "black"

    readonly property string accent: "#7eb8f7"

    Text {
        id: title
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -24
        text: "PowerTune"
        color: parent.accent
        font.pixelSize: Math.min(parent.width, parent.height) * 0.055
        font.bold: true
        font.family: "Eurostile"
    }
    Text {
        anchors.top: title.bottom
        anchors.topMargin: 12
        anchors.horizontalCenter: parent.horizontalCenter
        text: qsTr("Light splash — swipe for gauges, open settings from last page")
        color: Qt.rgba(0.75, 0.78, 0.85, 0.85)
        font.pixelSize: Math.min(parent.width, parent.height) * 0.018
        horizontalAlignment: Text.AlignHCenter
        width: parent.width * 0.9
        wrapMode: Text.WordWrap
    }
}
