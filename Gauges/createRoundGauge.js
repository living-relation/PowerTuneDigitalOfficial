//Creates instances of RoundGauge, usable at runtime
var component;
var gauge;

// The trailing `setgaugeStyleIndex` argument was added after the original 67
// arguments. Older callers that don't pass it get `undefined`, which the
// QML property (int with default 0) safely coerces to Classic.
function createRoundGauge(setWidth,setX,setY,setmainvaluename,setmaxvalue,setminvalue,setwarnvaluehigh,setwarnvaluelow,setstartangle,setendangle,setredareastart,setdivider,settickmarksteps,setminortickmarksteps,setsetlabelsteps,setdecimalpoints,setneedleinset,setsetlabelinset,setsetminortickmarkinset,setsetmajortickmarkinset,setminortickmarkheight,setminortickmarkwidth,settickmarkheight,settickmarkwidth,settrailhighboarder,settrailmidboarder,settraillowboarder,settrailbottomboarder,setlabelfontsize,setneedleTipWidth,setneedleLength,setneedleBaseWidth,setredareainset,setredareawidth,setneedlecolor,setneedlecolor2,setbackroundcolor,setwarningcolor,setminortickmarkcoloractive,setminortickmarkcolorinactive,setmajortickmarkcoloractive,setmajortickmarkcolorinactive,setlabelcoloractive,setlabelcolorinactive,setouterneedlecolortrailsave,setmiddleneedlecortrailsave,setlowerneedlecolortrailsave,setinnerneedlecolortrailsave,setneedlevisible,setringvisible,setneedlecentervisisble,setlabelfont,setdesctextx,setdesctexty,setdesctextfontsize,setdesctextfontbold,setdesctextfonttype,setdesctextdisplaytext,setdesctextdisplaytextcolor,setpeakneedlecolor,setpeakneedlecolor2,setpeakneedlelenght,setpeakneedlebasewidth,setpeakneedletipwidth,setpeakneedleoffset,setpeakneedlevisible,setgaugeStyleIndex) {
    component = Qt.createComponent("RoundGauge.qml");
    if (component.status === Component.Ready){
        //console.log("round gauge ready");
        finishCreation(setWidth,setX,setY,setmainvaluename,setmaxvalue,setminvalue,setwarnvaluehigh,setwarnvaluelow,setstartangle,setendangle,setredareastart,setdivider,settickmarksteps,setminortickmarksteps,setsetlabelsteps,setdecimalpoints,setneedleinset,setsetlabelinset,setsetminortickmarkinset,setsetmajortickmarkinset,setminortickmarkheight,setminortickmarkwidth,settickmarkheight,settickmarkwidth,settrailhighboarder,settrailmidboarder,settraillowboarder,settrailbottomboarder,setlabelfontsize,setneedleTipWidth,setneedleLength,setneedleBaseWidth,setredareainset,setredareawidth,setneedlecolor,setneedlecolor2,setbackroundcolor,setwarningcolor,setminortickmarkcoloractive,setminortickmarkcolorinactive,setmajortickmarkcoloractive,setmajortickmarkcolorinactive,setlabelcoloractive,setlabelcolorinactive,setouterneedlecolortrailsave,setmiddleneedlecortrailsave,setlowerneedlecolortrailsave,setinnerneedlecolortrailsave,setneedlevisible,setringvisible,setneedlecentervisisble,setlabelfont,setdesctextx,setdesctexty,setdesctextfontsize,setdesctextfontbold,setdesctextfonttype,setdesctextdisplaytext,setdesctextdisplaytextcolor,setpeakneedlecolor,setpeakneedlecolor2,setpeakneedlelenght,setpeakneedlebasewidth,setpeakneedletipwidth,setpeakneedleoffset,setpeakneedlevisible,setgaugeStyleIndex);
    }
     else
        component.statusChanged.connect(finishCreation);
}

function finishCreation(setWidth,setX,setY,setmainvaluename,setmaxvalue,setminvalue,setwarnvaluehigh,setwarnvaluelow,setstartangle,setendangle,setredareastart,setdivider,settickmarksteps,setminortickmarksteps,setsetlabelsteps,setdecimalpoints,setneedleinset,setsetlabelinset,setsetminortickmarkinset,setsetmajortickmarkinset,setminortickmarkheight,setminortickmarkwidth,settickmarkheight,settickmarkwidth,settrailhighboarder,settrailmidboarder,settraillowboarder,settrailbottomboarder,setlabelfontsize,setneedleTipWidth,setneedleLength,setneedleBaseWidth,setredareainset,setredareawidth,setneedlecolor,setneedlecolor2,setbackroundcolor,setwarningcolor,setminortickmarkcoloractive,setminortickmarkcolorinactive,setmajortickmarkcoloractive,setmajortickmarkcolorinactive,setlabelcoloractive,setlabelcolorinactive,setouterneedlecolortrailsave,setmiddleneedlecortrailsave,setlowerneedlecolortrailsave,setinnerneedlecolortrailsave,setneedlevisible,setringvisible,setneedlecentervisisble,setlabelfont,setdesctextx,setdesctexty,setdesctextfontsize,setdesctextfontbold,setdesctextfonttype,setdesctextdisplaytext,setdesctextdisplaytextcolor,setpeakneedlecolor,setpeakneedlecolor2,setpeakneedlelenght,setpeakneedlebasewidth,setpeakneedletipwidth,setpeakneedleoffset,setpeakneedlevisible,setgaugeStyleIndex) {
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

                                           // Visual style preset. Coerce through parseInt so CSV strings,
                                           // JSON numbers, and missing values all map cleanly to an int;
                                           // anything that doesn't parse falls back to 0 (Classic).
                                           "gaugeStyleIndex" : (function(v){
                                               var n = parseInt(v, 10);
                                               return isNaN(n) ? 0 : n;
                                           })(setgaugeStyleIndex)
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
