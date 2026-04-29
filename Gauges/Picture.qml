import QtQuick 2.5
import QtQuick.Controls 2.1
import "qrc:/Translator.js" as Translator

Item {
    id: picture
    height: pictureheight
    width : pictureheight
    property string information: "gauge image"
    property string picturesource
    property int pictureheight
    //property int picturewidth
    property string increasedecreaseident
    Drag.active: true
    // Raise this gauge above its siblings while its edit menu is open so the
    // menu is never hidden behind a later-added gauge on the same dashboard.
    z: changesize.visible ? 999 : 0
    Component.onCompleted: togglemousearea();

    Connections{
        target: Dashboard
        onDraggableChanged: togglemousearea();
    }

    Image {
        anchors.fill: parent
        id: mypicture
        fillMode: Image.PreserveAspectFit
        source:  picturesource
    }
    // MouseArea {
    //     id: touchArea
    //     anchors.fill: parent
    //     drag.target: parent
    //     enabled: false
    //     onDoubleClicked: {
    //         changesize.visible = true;
    //         Connect.readavailablebackrounds();
    //     }
    // }

    MouseArea {
        id: touchArea
        anchors.fill: parent
        drag.target: parent
        enabled: false
        onPressed:
        {
            touchCounter++;
            if (touchCounter == 1) {
                lastTouchTime = Date.now();
                timerDoubleClick.restart();
            } else if (touchCounter == 2) {
                var currentTime = Date.now();
                if (currentTime - lastTouchTime <= 500) { // Double-tap detected within 500 ms
                    console.log("Double-tap detected at", mouse.x, mouse.y);
                }
                touchCounter = 0;
                timerDoubleClick.stop();
                changesize.visible = true;
                Connect.readavailablebackrounds();
            }
        }
        }
    }
    Timer {
        id: timerDoubleClick
        interval: 500
        running: false
        repeat: false
        onTriggered: {
            touchCounter = 0; // Reset counter if time interval exceeds 500 ms
        }
    }

    Rectangle{
        id : changesize
        color: "darkgrey"
        radius: 6
        border.color: Qt.rgba(1, 1, 1, 0.25)
        border.width: 1
        visible: false
        width : 200
        height : 180
        x: 0
        y: 0
        z: 1000        //ensure the Menu is always in the foreground
        Drag.active: true
        onVisibleChanged: {
            changesize.x= -picture.x;
            changesize.y= -picture.y;
        }
        MouseArea {
            anchors.fill: parent
            drag.target: parent
            enabled: true
        }
        // Dedicated drag grip so the menu stays easy to grab on touch even
        // when most of the body is covered by interactive controls.
        Rectangle {
            id: changesizeDragHandle
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 22
            radius: 4
            color: Qt.rgba(0.2, 0.2, 0.3, 0.85)
            z: 2
            Rectangle {
                anchors.centerIn: parent
                width: 40
                height: 4
                radius: 2
                color: Qt.rgba(1, 1, 1, 0.6)
            }
            MouseArea {
                anchors.fill: parent
                drag.target: changesize
            }
        }

        Grid { width: parent.width
            anchors.top: changesizeDragHandle.bottom
            anchors.bottom: parent.bottom
            rows: 4
            columns: 1
            rowSpacing :5
            Grid {
                rows: 1
                columns: 3
                rowSpacing :5
                RoundButton{text: "-"
                    width: changesize.width /3.2
                    onPressAndHold: {timer.running = true;
                        increasedecreaseident = "decreasePicture"}
                    onReleased: {timer.running = false;}
                    onClicked: {pictureheight--}
                }
                Text{id: sizeTxt
                    text: pictureheight
                    font.pixelSize: 15
                    width: changesize.width /3.2
                    horizontalAlignment: Text.AlignHCenter
                    onTextChanged: pictureheight = sizeTxt.text
                }
                RoundButton{ text: "+"
                    width: changesize.width /3.2
                    onPressAndHold: {timer.running = true;
                        increasedecreaseident = "increasePicture"}
                    onReleased: {timer.running = false;}
                    onClicked: {pictureheight++}
                }
            }
            ComboBox {
                id: pictureSelector
                width: 200
                height: 40
                font.pixelSize: 15
                model: Dashboard.backroundpictures
                currentIndex: 0
                onCurrentIndexChanged: {
                    picturesource = "file:///home/pi/Logo/" + pictureSelector.textAt(pictureSelector.currentIndex);
                    //picturesource = "file:" + pictureSelector.textAt(pictureSelector.currentIndex); // windows
                    mypicture.source = picturesource;
                                       }
                delegate: ItemDelegate {
                    width: pictureSelector.width
                    text: pictureSelector.textRole ? (Array.isArray(pictureSelector.model) ? modelData[pictureSelector.textRole] : model[pictureSelector.textRole]) : modelData
                    font.weight: pictureSelector.currentIndex === index ? Font.DemiBold : Font.Normal
                    font.family: pictureSelector.font.family
                    font.pixelSize: pictureSelector.font.pixelSize
                    highlighted: pictureSelector.highlightedIndex === index
                    hoverEnabled: pictureSelector.hoverEnabled
                }
            }
            RoundButton{
                width: parent.width
                text: Translator.translate("Delete image", Dashboard.language)
                font.pixelSize: 15
                onClicked: picture.destroy();
            }
            RoundButton{
                width: parent.width
                text: Translator.translate("Close", Dashboard.language)
                onClicked: changesize.visible = false;
            }
        }
    }

    Item {
        Timer {
            id: timer
            interval: 50; running: false; repeat: true
            onTriggered: {increaseDecrease()}
        }

        Text { id: time }
    }
    function togglemousearea()
    {
    //    console.log("toggle" + Dashboard.draggable);
        if (Dashboard.draggable === 1)
        {
            touchArea.enabled = true;
        }
        else
            touchArea.enabled = false;
    }
    function increaseDecrease()
    {
        //console.log("ident "+ increasedecreaseident);
        switch(increasedecreaseident)
        {

        case "increasePicture": {
            pictureheight++;
            //picturewidth++;
            break;
        }
        case "decreasePicture": {
            pictureheight--;
            //picturewidth--;
            break;
        }
        }
    }
}
