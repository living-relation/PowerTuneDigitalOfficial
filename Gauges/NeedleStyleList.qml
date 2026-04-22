import QtQuick 2.8

ListModel {
    id: needleStyleModel
    ListElement {
        name: "Default (Canvas)"
        source: ""
        isCanvas: true
    }
    ListElement {
        name: "Classic Knife"
        source: "qrc:/graphics/Needles/needle_classic-knife.png"
        isCanvas: false
    }
    ListElement {
        name: "Carbon Fighter"
        source: "qrc:/graphics/Needles/needle_carbon-fighter.png"
        isCanvas: false
    }
    ListElement {
        name: "Hellfire"
        source: "qrc:/graphics/Needles/needle_hellfire.png"
        isCanvas: false
    }
    ListElement {
        name: "Motorsport Paddle"
        source: "qrc:/graphics/Needles/needle_motorsport-paddle.png"
        isCanvas: false
    }
    ListElement {
        name: "Neon Cyber"
        source: "qrc:/graphics/Needles/needle_neon-cyber.png"
        isCanvas: false
    }
    ListElement {
        name: "OEM Red"
        source: "qrc:/graphics/Needles/needle_oem-red.png"
        isCanvas: false
    }
    ListElement {
        name: "Plasma"
        source: "qrc:/graphics/Needles/needle_plasma.png"
        isCanvas: false
    }
    ListElement {
        name: "Rally Stripe"
        source: "qrc:/graphics/Needles/needle_rallystripe.png"
        isCanvas: false
    }
    ListElement {
        name: "Spear"
        source: "qrc:/graphics/Needles/needle_spear.png"
        isCanvas: false
    }
    ListElement {
        name: "Titanium Spike"
        source: "qrc:/graphics/Needles/needle_titanium-spike.png"
        isCanvas: false
    }
    ListElement {
        name: "Turbo Blade"
        source: "qrc:/graphics/Needles/needle_turbo-blade.png"
        isCanvas: false
    }
}