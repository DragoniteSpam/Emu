group = new EmuTabGroup(32, 32, 640, 640, 2, 32);
var tab_1 = group.AddTab(new EmuTab("Tab1"), 0);
var tab_2 = group.AddTab(new EmuTab("Tab2"), 0);
var tab_3 = group.AddTab(new EmuTab("Tab3"), 0);
var tab_4 = group.AddTab(new EmuTab("Tab4"), 1);
var tab_5 = group.AddTab(new EmuTab("Tab5"), 1);

var u = undefined;
tab_1.AddContent([
    new EmuText(32, u, 256, 32, "Text label"),
    new EmuText(32, u, 256, 32, "[rainbow][wave](scribble enabled!)[]"),
]);

var bitfield_3_1 = new EmuBitfield(32, u, 256, 32, EVBitfieldOrientations.HORIZONTAL, 15, function() { });
var bitfield_3_2 = new EmuBitfield(352, 16, 256, 256, EVBitfieldOrientations.VERTICAL, 41, function() { });
bitfield_3_1.AddOptions([
    "0", "1", "2", "4"
]);
bitfield_3_1.interactive = false;

bitfield_3_2.SetFixedSpacing(32);
bitfield_3_2.AddOptions([
    "my", "very", "earnest", "mother", "just", "served", "us", "nine", "pickles",
    new EmuBitfieldOption("all", 0xffffffff, v_bitfield_option_all_callback, v_bitfield_option_all_eval),
    new EmuBitfieldOption("none", 0, v_bitfield_option_none_callback, v_bitfield_option_none_eval),
]);

tab_1.AddContent([
    bitfield_3_1,
    bitfield_3_2,
]);

tab_2.AddContent([
    new EmuText(32, u, 256, 32, "Text label"),
    new EmuButton(32, u, 256, 32, "Button", function() {
        show_message("clicked the that does absolutely nothing");
    }),
    new EmuCheckbox(32, u, 256, 32, "Toggle", false, function() {
    
    }),
    new EmuButtonImage(32, u, 256, 256, spr_emu_birb, 0, c_white, 1, false, function() { })
]);

group.ActivateTab(tab_1);

tab_4.interactive = false;

var group_inner = new EmuTabGroup(32, 32, 640 - 64, 640 - 128, 3, 32)
tab_3.AddContent(group_inner);
var tab_11 = group_inner.AddTab(new EmuTab("Tab 11"), 0);
var tab_12 = group_inner.AddTab(new EmuTab("Tab 12"), 0);
var tab_13 = group_inner.AddTab(new EmuTab("Tab 13"), 0);
var tab_14 = group_inner.AddTab(new EmuTab("Tab 14"), 1);
var tab_15 = group_inner.AddTab(new EmuTab("Tab 15"), 1);
var tab_16 = group_inner.AddTab(new EmuTab("Tab 16"), 2);
var tab_17 = group_inner.AddTab(new EmuTab("Tab 17"), 2);
var tab_18 = group_inner.AddTab(new EmuTab("Tab 18"), 2);
var tab_19 = group_inner.AddTab(new EmuTab("Tab 19"), 2);
group_inner.ActivateTab(tab_11);

tab_15.AddContent([
    new EmuButton(32, u, 320, 32, "i guess i should put something here", function() { show_message("clicked the top button"); }),
    new EmuButton(32, u, 320, 32, "just so that these aren't empty", function() { show_message("clicked the bottom button"); }),
]);