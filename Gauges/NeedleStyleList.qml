import QtQuick 2.8

// Root Item so a Loader can host this and expose the model to parents.
Item {
    id: root
    property alias needleModel: needleStyleModel
    width: 0
    height: 0
    visible: false

    ListModel {
        id: needleStyleModel
    ListElement {
        name: "Default (Canvas)"
        source: ""
        isCanvas: true
    }
    ListElement {
        name: "Classic Knife"
        source: "qrc:/graphics/Needles/needle_classic-knife.svg"
        isCanvas: false
    }
    ListElement {
        name: "Carbon Fighter"
        source: "qrc:/graphics/Needles/needle_carbon-fighter.svg"
        isCanvas: false
    }
    ListElement {
        name: "Hellfire"
        source: "qrc:/graphics/Needles/needle_hellfire.svg"
        isCanvas: false
    }
    ListElement {
        name: "Motorsport Paddle"
        source: "qrc:/graphics/Needles/needle_motorsport-paddle.svg"
        isCanvas: false
    }
    ListElement {
        name: "Neon Cyber"
        source: "qrc:/graphics/Needles/needle_neon-cyber.svg"
        isCanvas: false
    }
    ListElement {
        name: "OEM Red"
        source: "qrc:/graphics/Needles/needle_oem-red.svg"
        isCanvas: false
    }
    ListElement {
        name: "Plasma"
        source: "qrc:/graphics/Needles/needle_plasma.svg"
        isCanvas: false
    }
    ListElement {
        name: "Rally Stripe"
        source: "qrc:/graphics/Needles/needle_rallystripe.svg"
        isCanvas: false
    }
    ListElement {
        name: "Spear"
        source: "qrc:/graphics/Needles/needle_spear.svg"
        isCanvas: false
    }
    ListElement {
        name: "Titanium Spike"
        source: "qrc:/graphics/Needles/needle_titanium-spike.svg"
        isCanvas: false
    }
    ListElement {
        name: "Turbo Blade"
        source: "qrc:/graphics/Needles/needle_turbo-blade.svg"
        isCanvas: false
    }
    ListElement {
        name: "Aurora Edge"
        source: "qrc:/graphics/Needles/needle_aurora-edge.svg"
        isCanvas: false
    }
    ListElement {
        name: "Stealth Mono"
        source: "qrc:/graphics/Needles/needle_stealth-mono.svg"
        isCanvas: false
    }
    ListElement {
        name: "Pro Carbon"
        source: "qrc:/graphics/Needles/needle_pro-carbon.svg"
        isCanvas: false
    }
    }
}
