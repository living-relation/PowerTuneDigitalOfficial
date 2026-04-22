//Creates instances of RoundGauge, usable at runtime
var component;
var gauge;

// Column order for the round-gauge CSV / JSON schema (zero-indexed from col 1):
//   cols 1-66  : original fields ending with setpeakneedlevisible
//   col  67    : setgaugeStyleIndex  (added by gauge-style preset feature)
//   col  68    : setneedleStyleSource (added by SVG needle style feature)
// Older files that omit col 67 and/or 68 safely get undefined, which the
// property defaults handle (gaugeStyleIndex→0 Classic; needleStyleSource→"" canvas).
function createRoundGauge(setWidth,setX,setY,setmainvaluename,setmaxvalue,setminvalue,setwarnvaluehigh,setwarnvaluelow,setstartangle,setendangle,setredareastart,setdivider,settickmarksteps,setminortickmarksteps,setsetlabelsteps,setdecimalpoints,setneedleinset,setsetlabelinset,setsetminortickmarkinset,setsetmajortickmarkinset,setminortickmarkheight,setminortickmarkwidth,settickmarkheight,settickmarkwidth,settrailhighboarder,settrailmidboarder,settraillowboarder,settrailbottomboarder,setlabelfontsize,setneedleTipWidth,setneedleLength,setneedleBaseWidth,setredareainset,setredareawidth,setneedlecolor,setneedlecolor2,setbackroundcolor,setwarningcolor,setminortickmarkcoloractive,setminortickmarkcolorinactive,setmajortickmarkcoloractive,setmajortickmarkcolorinactive,setlabelcoloractive,setlabelcolorinactive,setouterneedlecolortrailsave,setmiddleneedlecortrailsave,setlowerneedlecolortrailsave,setinnerneedlecolortrailsave,setneedlevisible,setringvisible,setneedlecentervisisble,setlabelfont,setdesctextx,setdesctexty,setdesctextfontsize,setdesctextfontbold,setdesctextfonttype,setdesctextdisplaytext,setdesctextdisplaytextcolor,setpeakneedlecolor,setpeakneedlecolor2,setpeakneedlelenght,setpeakneedlebasewidth,setpeakneedletipwidth,setpeakneedleoffset,setpeakneedlevisible,setgaugeStyleIndex,setneedleStyleSource) {
    component = Qt.createComponent("RoundGauge.qml");
    if (component.status === Component.Ready){
        //console.log("round gauge ready");
        finishCreation(setWidth,setX,setY,setmainvaluename,setmaxvalue,setminvalue,setwarnvaluehigh,setwarnvaluelow,setstartangle,setendangle,setredareastart,setdivider,settickmarksteps,setminortickmarksteps,setsetlabelsteps,setdecimalpoints,setneedleinset,setsetlabelinset,setsetminortickmarkinset,setsetmajortickmarkinset,setminortickmarkheight,setminortickmarkwidth,settickmarkheight,settickmarkwidth,settrailhighboarder,settrailmidboarder,settraillowboarder,settrailbottomboarder,setlabelfontsize,setneedleTipWidth,setneedleLength,setneedleBaseWidth,setredareainset,setredareawidth,setneedlecolor,setneedlecolor2,setbackroundcolor,setwarningcolor,setminortickmarkcoloractive,setminortickmarkcolorinactive,setmajortickmarkcoloractive,setmajortickmarkcolorinactive,setlabelcoloractive,setlabelcolorinactive,setouterneedlecolortrailsave,setmiddleneedlecortrailsave,setlowerneedlecolortrailsave,setinnerneedlecolortrailsave,setneedlevisible,setringvisible,setneedlecentervisisble,setlabelfont,setdesctextx,setdesctexty,setdesctextfontsize,setdesctextfontbold,setdesctextfonttype,setdesctextdisplaytext,setdesctextdisplaytextcolor,setpeakneedlecolor,setpeakneedlecolor2,setpeakneedlelenght,setpeakneedlebasewidth,setpeakneedletipwidth,setpeakneedleoffset,setpeakneedlevisible,setgaugeStyleIndex,setneedleStyleSource);
    }
    else {
        function onStatusChanged() {
            if (component.status === Component.Ready) {
                component.statusChanged.disconnect(onStatusChanged);
                finishCreation.apply(null, capturedArgs);
            }
        }
        component.statusChanged.connect(onStatusChanged);
    }
}

function finishCreation(setWidth,setX,setY,setmainvaluename,setmaxvalue,setminvalue,setwarnvaluehigh,setwarnvaluelow,setstartangle,setendangle,setredareastart,setdivider,settickmarksteps,setminortickmarksteps,setsetlabelsteps,setdecimalpoints,setneedleinset,setsetlabelinset,setsetminortickmarkinset,setsetmajortickmarkinset,setminortickmarkheight,setminortickmarkwidth,settickmarkheight,settickmarkwidth,settrailhighboarder,settrailmidboarder,settraillowboarder,settrailbottomboarder,setlabelfontsize,setneedleTipWidth,setneedleLength,setneedleBaseWidth,setredareainset,setredareawidth,setneedlecolor,setneedlecolor2,setbackroundcolor,setwarningcolor,setminortickmarkcoloractive,setminortickmarkcolorinactive,setmajortickmarkcoloractive,setmajortickmarkcolorinactive,setlabelcoloractive,setlabelcolorinactive,setouterneedlecolortrailsave,setmiddleneedlecortrailsave,setlowerneedlecolortrailsave,setinnerneedlecolortrailsave,setneedlevisible,setringvisible,setneedlecentervisisble,setlabelfont,setdesctextx,setdesctexty,setdesctextfontsize,setdesctextfontbold,setdesctextfonttype,setdesctextdisplaytext,setdesctextdisplaytextcolor,setpeakneedlecolor,setpeakneedlecolor2,setpeakneedlelenght,setpeakneedlebasewidth,setpeakneedletipwidth,setpeakneedleoffset,setpeakneedlevisible,setgaugeStyleIndex,setneedleStyleSource) {
    if (component.status === Component.Ready) {
        gauge = component.createObject(userDash, {
                                           "width": setWidth,
                                           "height": setWidth,
                                           "x": setX,
                                           "y": setY,

                                           //main

                                           "mainvaluename":setmainvaluename,
                                           "maxvalue":setmaxvalue,
                                           "minvalue":setminvalue,
                                           "warnvaluehigh":setwarnvaluehigh,
                                           "warnvaluelow":setwarnvaluelow,
                                           "startangle":setstartangle,
                                           "endangle":setendangle,
                                           "redareastart":setredareastart,
                                           "divider":setdivider,

                                           //Steps
                                           "tickmarksteps":settickmarksteps,
                                           "minortickmarksteps":setminortickmarksteps,
                                           "setlabelsteps":setsetlabelsteps,
                                           "decimalpoints":setdecimalpoints,

                                           //Insets
                                           "needleinset":setneedleinset,
                                           "setlabelinset":setsetlabelinset,
                                           "setminortickmarkinset":setsetminortickmarkinset,
                                           "setmajortickmarkinset":setsetmajortickmarkinset,

                                           //Sizing
                                           "minortickmarkheight":setminortickmarkheight,
                                           "minortickmarkwidth":setminortickmarkwidth,
                                           "tickmarkheight":settickmarkheight,
                                           "tickmarkwidth":settickmarkwidth,
                                           "trailhighboarder":settrailhighboarder,
                                           "trailmidboarder":settrailmidboarder,
                                           "traillowboarder":settraillowboarder,

                                           "trailbottomboarder" : settrailbottomboarder,
                                           "labelfontsize":setlabelfontsize,
                                           "needleTipWidth":setneedleTipWidth,
                                           "needleLength":setneedleLength,
                                           "needleBaseWidth":setneedleBaseWidth,
                                           "redareainset":setredareainset,
                                           "redareawidth":setredareawidth,

                                           // Colors
                                           "needlecolor":setneedlecolor,
                                           "needlecolor2":setneedlecolor2,
                                           "backroundcolor":setbackroundcolor,
                                           "warningcolor":setwarningcolor,
                                           "minortickmarkcoloractive":setminortickmarkcoloractive,
                                           "minortickmarkcolorinactive":setminortickmarkcolorinactive,
                                           "majortickmarkcoloractive":setmajortickmarkcoloractive,
                                           "majortickmarkcolorinactive":setmajortickmarkcolorinactive,
                                           "labelcoloractive":setlabelcoloractive,
                                           "labelcolorinactive":setlabelcolorinactive,
                                           "outerneedlecolortrail":setouterneedlecolortrailsave,
                                           "middleneedlecortrail":setmiddleneedlecortrailsave,
                                           "lowerneedlecolortrail":setlowerneedlecolortrailsave,
                                           "innerneedlecolortrail":setinnerneedlecolortrailsave,
                                           "outerneedlecolortrailsave":setouterneedlecolortrailsave,
                                           "middleneedlecortrailsave":setmiddleneedlecortrailsave,
                                           "lowerneedlecolortrailsave":setlowerneedlecolortrailsave,
                                           "innerneedlecolortrailsave":setinnerneedlecolortrailsave,

                                           //Booleans

                                           "needlevisible":setneedlevisible,
                                           "ringvisible":setringvisible,
                                           "needlecentervisisble":setneedlecentervisisble,

                                           //Extra

                                           "labelfont" : setlabelfont,
                                           "desctextx" : setdesctextx,
                                           "desctexty" : setdesctexty,
                                           "desctextfontsize" : setdesctextfontsize,
                                           "desctextfontbold" : setdesctextfontbold,
                                           "desctextfonttype" : setdesctextfonttype,
                                           "desctextdisplaytext" : setdesctextdisplaytext,
                                           "desctextdisplaytextcolor" : setdesctextdisplaytextcolor,

                                           // col 67: visual gauge style preset (int, default 0 = Classic)
                                           "gaugeStyleIndex" : (function(v){ var n = parseInt(v, 10); return isNaN(n) ? 0 : n; })(setgaugeStyleIndex),

                                           // col 68: SVG needle style source path ("" = default canvas needle)
                                           "needleStyleSource" : (setneedleStyleSource !== undefined && typeof setneedleStyleSource === "string" && !(/^\d+$/.test(setneedleStyleSource)) ? setneedleStyleSource : "")
                                           /* Provision to implement a peak needle at a later stage
                                           "peakneedlecolor" : setpeakneedlecolor,
                                           "peakneedlecolor2" : setpeakneedlecolor2,
                                           "peakneedlelenght" : setpeakneedlelenght,
                                           "peakneedlebasewidth" : setpeakneedlebasewidth,
                                           "peakneedletipwidth" : setpeakneedletipwidth,
                                           "peakneedleoffset" : setpeakneedleoffset,
                                           "peakneedlevisible" : setpeakneedlevisible
                                           */
                                       });

        if (gauge === null) {
            // Error Handling
            console.log("Error creating object");
        }
    } else if (component.status === Component.Error) {
        // Error Handling
        console.log("Error loading component:", component.errorString());
    }
}

//  Stuff
/*
/////////////////////////////////////////////////////////////////////////////////////////////
setWidth,
setWidth,
setX,
setY,
setmainvaluename,
setmaxvalue,
setminvalue,
setwarnvaluehigh,
setwarnvaluelow,
setstartangle,
setendangle,
setredareastart,
setdivider,
settickmarksteps,
setminortickmarksteps,
setsetlabelsteps,
setdecimalpoints,
setneedleinset,
setsetlabelinset,
setsetminortickmarkinset,
setsetmajortickmarkinset,
setminortickmarkheight,
setminortickmarkwidth,
settickmarkheight,
settickmarkwidth,
settrailhighboarder,
settrailmidboarder,
settraillowboarder,
setlabelfontsize,
setneedleTipWidth,
setneedleLength,
setneedleBaseWidth,
setredareainset,
setredareawidth,
settickmarkcolor,
setneedlecolor,
setneedlecolor2,
setbackroundcolor,
setwarningcolor,
setminortickmarkcoloractive,
setminortickmarkcolorinactive,
setmajortickmarkcoloractive,
setmajortickmarkcolorinactive,
setlabelcoloractive,
setlabelcolorinactive,
setouterneedlecolortrailsave,
setmiddleneedlecortrailsave,
setlowerneedlecolortrailsave,
setinnerneedlecolortrailsave,
setneedlevisible,
setringvisible,
*/
