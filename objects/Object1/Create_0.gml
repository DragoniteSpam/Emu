group = new VTabGroup(32, 32, 640, 640, 2, 32);
var tab_1 = group.AddTab(new VTab("Tab1"), 0);
var tab_2 = group.AddTab(new VTab("Tab2"), 0);
var tab_3 = group.AddTab(new VTab("Tab3"), 0);
var tab_4 = group.AddTab(new VTab("Tab4"), 1);
var tab_5 = group.AddTab(new VTab("Tab5"), 1);

var u = undefined;
tab_1.AddContent([
    new VText(32, u, 256, 32, "Text label"),
    new VText(32, u, 256, 32, "[rainbow][wave](scribble enabled!)[]"),
]);
tab_2.AddContent([
    new VText(32, u, 256, 32, "Text label"),
    new VButton(32, u, 256, 32, "Button", function() {
        show_message("clicked the that does absolutely nothing");
    }),
    new VCheckbox(32, u, 256, 32, "Toggle", false, function() {
    
    })
]);

var bitfield_3_1 = new VBitfield(32, u, 256, 32, EVBitfieldOrientations.HORIZONTAL, 15, function() { });
var bitfield_3_2 = new VBitfield(352, 16, 256, 256, EVBitfieldOrientations.VERTICAL, 41, function() { });
bitfield_3_1.AddOptions([
    "0", "1", "2", "4"
]);
bitfield_3_1.interactive = false;

bitfield_3_2.SetFixedSpacing(32);
bitfield_3_2.AddOptions([
    "my", "very", "earnest", "mother", "just", "served", "us", "nine", "pickles",
    new VBitfieldOption("all", 0xffffffff, v_bitfield_option_all_callback, v_bitfield_option_all_eval),
    new VBitfieldOption("none", 0, v_bitfield_option_none_callback, v_bitfield_option_none_eval),
]);

tab_1.AddContent([
    bitfield_3_1,
    bitfield_3_2,
]);

group.ActivateTab(tab_1);

tab_4.interactive = false;

var group_inner = new VTabGroup(32, 32, 640 - 64, 640 - 128, 3, 32)
tab_3.AddContent(group_inner);
var tab_11 = group_inner.AddTab(new VTab("Tab 11"), 0);
var tab_12 = group_inner.AddTab(new VTab("Tab 12"), 0);
var tab_13 = group_inner.AddTab(new VTab("Tab 13"), 0);
var tab_14 = group_inner.AddTab(new VTab("Tab 14"), 1);
var tab_15 = group_inner.AddTab(new VTab("Tab 15"), 1);
var tab_16 = group_inner.AddTab(new VTab("Tab 16"), 2);
var tab_17 = group_inner.AddTab(new VTab("Tab 17"), 2);
var tab_18 = group_inner.AddTab(new VTab("Tab 18"), 2);
var tab_19 = group_inner.AddTab(new VTab("Tab 19"), 2);
group_inner.ActivateTab(tab_11);

tab_15.AddContent([
    new VButton(32, u, 320, 32, "i guess i should put something here", function() { show_message("clicked the top button"); }),
    new VButton(32, u, 320, 32, "just so that these aren't empty", function() { show_message("clicked the bottom button"); }),
]);