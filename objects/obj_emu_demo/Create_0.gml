group = new EmuTabGroup(32, 32, 640, 640, 2, 32);
var tab_1 = group.AddTab(new EmuTab("Tab1"), 0);
var tab_2 = group.AddTab(new EmuTab("Tab2"), 0);
var tab_3 = group.AddTab(new EmuTab("Tab3"), 0);
var tab_4 = group.AddTab(new EmuTab("Multi-line"), 1);
var tab_5 = group.AddTab(new EmuTab("Render Surface"), 1);

var u = undefined;

var bar_int = new EmuProgressBar(32, u, 256, 32, 12, 0, 10, true, 7, function() { });
bar_int.integers_only = true;
tab_1.AddContent([
    new EmuText(32, u, 256, 32, "Text label"),
    new EmuText(32, u, 256, 32, "[rainbow][wave](scribble enabled!)[]"),
    new EmuProgressBar(32, u, 256, 32, 12, 0, 100, true, 1, function() { }),
    new EmuProgressBar(32, u, 256, 32, 12, 0, 100, false, 35, function() { }),
    new EmuProgressBar(32, u, 256, 32, 12, 0, 5, false, 2, function() { }),
    bar_int,
    new EmuButton(32, u, 256, 32, "make popup dialog", function() {
        var u = undefined;
        var dialog = new EmuDialog(320, 240, "Hey, listen!", function() { });
        dialog.AddContent([
            new EmuText(32, u, 256, 64, "These are words that you can read and stuff"),
            new EmuButton(dialog.width / 2 - 128 / 2, dialog.height - 32 - 32 / 2, 128, 32, "Close", function() {
                root.Close();
            }),
        ]);
    }),
]);

var bitfield_3_1 = new EmuBitfield(32, u, 256, 32, 15, function() { });
var bitfield_3_2 = new EmuBitfield(352, 16, 256, 256, 41, function() { });
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
bitfield_3_2.SetOrientation(EmuBitfieldOrientations.VERTICAL);

tab_1.AddContent([
    bitfield_3_1,
    bitfield_3_2,
    new EmuColorPicker(320, u, 256, 32, "Color:", c_red, 128, 0, 256, 32, function() { }),
]);

var list_2 = new EmuList(320, 32, 256, 32, "List of things", "no things", 24, 6, function() { });
list_2.tooltip = "This list has a tooltip";
list_2.AddContent(["Alice", "Bob", "Charlie", "And", "Your", "Little", "Dog", "Too"]);
list_2.SetCallbackDouble(function() {
    show_message("double click");
});
list_2.SetCallbackMiddle(function() {
    show_message("middle click");
});

tab_2.AddContent([
    new EmuText(32, u, 256, 32, "Text label"),
    new EmuButton(32, u, 256, 32, "Button", function() {
        show_message("clicked the that does absolutely nothing");
    }),
    new EmuCheckbox(32, u, 256, 32, "Toggle", false, function() {
    
    }),
    new EmuButtonImage(32, u, 256, 256, spr_emu_birb, 0, c_white, 1, false, function() { }),
    list_2,
]);

group.ActivateTab(tab_1);

var radio_4 = new EmuRadioArray(32, u, 256, 32, "Pick one", 0, function() {
    show_message("Option set to " + string(value));
});
radio_4.AddOptions(["Sausage", "Pepperoni", "Cheese", "Olives", "Tomatoes", "Garlic"]);
radio_4.SetColumns(4, 160);
tab_4.AddContent(radio_4);

var input_4 = new EmuInput(32, u, 560, 128, "Summary:", "You can enter some longer text here, if you want", "start typing", 600, EmuInputTypes.STRING, 128, 0, 560, 128, function() { show_debug_message(value); });
input_4.multi_line = true;
tab_4.AddContent(input_4);

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
    new EmuButton(32, u, 320, 32, "another button ", function() { show_message("clicked the bottom button"); }),
]);

tab_5.AddContent([
    new EmuInput(32, 32, 256, 32, "Enter int:", "15", "start typing", 6, EmuInputTypes.INT, 128, 0, 256, 32, function() { }),
    new EmuColorPicker(320, 32, 256, 32, "Color:", c_black, 128, 0, 256, 32, function() { }),
    new EmuRenderSurface(32, u, 576, 432,
        function(x1, y1, x2, y2) { data.Render(); },
        function(x1, y1, x2, y2) { data.Control(); },
        function() { data = new EmuDemoMeshScene(); },
        function() { data.Destroy(); }
    ),
]);