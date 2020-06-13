container = new EmuCore(32, 32, 640, 640);

var group = new EmuTabGroup(0, EMU_AUTO, 640, 640, 2, 32);
var tab_1 = new EmuTab("Tab1");
var tab_2 = new EmuTab("Tab2");
var tab_3 = new EmuTab("Tab3");
var tab_4 = new EmuTab("Multi-line");
var tab_5 = new EmuTab("Render Surface");
group.AddTabs(0, [tab_1, tab_2, tab_3]);
group.AddTabs(1, [tab_4, tab_5]);

container.AddContent(group);

var bar_int = new EmuProgressBar(32, EMU_AUTO, 256, 32, 12, 0, 10, true, 7, emu_null);

bar_int.SetIntegersOnly(true);

tab_1.AddContent([
    new EmuText(32, EMU_AUTO, 256, 32, "Text label"),
    new EmuText(32, EMU_AUTO, 256, 32, "[rainbow][wave](scribble enabled!)[]"),
    new EmuProgressBar(32, EMU_AUTO, 256, 32, 12, 0, 100, true, 1, emu_null),
    new EmuProgressBar(32, EMU_AUTO, 256, 32, 12, 0, 100, false, 35, emu_null),
    new EmuProgressBar(32, EMU_AUTO, 256, 32, 12, 0, 5, false, 2, emu_null),
    bar_int,
    new EmuButton(32, EMU_AUTO, 256, 32, "make popup dialog", function() {
        var group = new EmuTabGroup(32, EMU_AUTO, 576, 320, 2, 32);
        var tab_1 = new EmuTab("Tab1");
        var tab_2 = new EmuTab("Tab2");
        var tab_3 = new EmuTab("Tab3");
        var tab_4 = new EmuTab("Multi-line");
        var tab_5 = new EmuTab("Render Surface");
        group.AddTabs(0, [tab_1, tab_2, tab_3]);
        group.AddTabs(1, [tab_4, tab_5]);
        
        var dialog = new EmuDialog(640, 416, "Hey, listen!");
        dialog.AddContent([
            group,
            new EmuButton(dialog.width / 2 - 128 / 2, dialog.height - 32 - 32 / 2, 128, 32, "Close", emu_dialog_close_auto),
        ]);
        
        tab_5.AddContent(new EmuRenderSurface(32, EMU_AUTO, 240, 180,
            function(mx, my) { data.Render(); },
            function(mx, my) { data.Control(); },
            function() { data = new EmuDemoMeshScene(); },
            function() { data.Destroy(); }
        ));
    }),
    new EmuInput(32, EMU_AUTO, 256, 32, "Hex:", "FF", "a hex value", 4, E_InputTypes.HEX, emu_null),
]);

var bitfield_3_1 = new EmuBitfield(32, EMU_AUTO, 256, 32, 15, emu_null);
var bitfield_3_2 = new EmuBitfield(352, 16, 256, 256, 41, emu_null);
bitfield_3_1.AddOptions([
    "0", "1", "2", "4"
]);
bitfield_3_1.SetInteractive(false);

bitfield_3_2.SetFixedSpacing(32);
bitfield_3_2.AddOptions([
    "my", "very", "earnest", "mother", "just", "served", "us", "nine", "pickles",
    new EmuBitfieldOption("all", 0x1ff, emu_bitfield_option_exact_callback, emu_bitfield_option_exact_eval),
    new EmuBitfieldOption("none", 0, emu_bitfield_option_exact_callback, emu_bitfield_option_exact_eval),
]);
bitfield_3_2.SetOrientation(E_BitfieldOrientations.VERTICAL);

var picker_1 = new EmuColorPicker(320, EMU_AUTO, 256, 32, "Color:", 0xff000000 | c_maroon, function() {
    
});
picker_1.allow_alpha = true;
tab_1.AddContent([
    bitfield_3_1,
    bitfield_3_2,
    picker_1,
]);

var list_2 = new EmuList(320, 32, 256, 32, "List of things", "no things", 24, 6, emu_null);
list_2.SetMultiSelect(true, true, true);
list_2.AddEntries(["Mercury", "Venus", "Earth", "Mars", "Jupiter", "Saturn", "Uranus", "Neptune"]);
list_2.setCallbackDouble(function(index) {
    show_debug_message("Double-click on element: " + string(index));
});
list_2.setCallbackMiddle(function(index) {
    show_debug_message("Middle-click on element: " + string(index));
});

tab_2.AddContent([
    new EmuText(32, EMU_AUTO, 256, 32, "Text label"),
    new EmuButton(32, EMU_AUTO, 256, 32, "Button", function() {
        show_message("clicked the that does absolutely nothing");
    }),
    new EmuCheckbox(32, EMU_AUTO, 256, 32, "Toggle", false, function() {
    
    }),
    new EmuButtonImage(32, EMU_AUTO, 128, 128, spr_emu_birb, 0, c_white, 1, false, function() {
        var dialog = new EmuDialog(320, 240, "Hey, listen!");
        dialog.AddContent(new EmuText(32, 32, 256, 64, "You clicked on the birb!"));
    }),
    list_2,
]);

var radio_4 = new EmuRadioArray(32, EMU_AUTO, 256, 32, "Select your favorite planet:", 0, function() {
    show_message("You have chosen planet #" + string(value) + ".");
});
radio_4.AddOptions(["Mercury", "Venus", "Earth", "Mars", "Jupiter", "Saturn", "Uranus", "Neptune"]);
radio_4.SetColumns(3, 160);
tab_4.AddContent(radio_4);

var input_4 = new EmuInput(32, EMU_AUTO, 560, 128, "Summary 1:", "You can enter some longer text here, if you want", "start typing", 600, E_InputTypes.STRING, function() { show_debug_message(value); });
input_4.multi_line = true;
tab_4.AddContent(input_4);
var input_5 = new EmuInput(32, EMU_AUTO, 560, 128, "Summary 2:", "You can enter some longer text here, if you want", "start typing", 600, E_InputTypes.STRING, function() { show_debug_message(value); });
input_5.multi_line = true;
tab_4.AddContent(input_5);
input_4.SetNext(input_5);
input_5.SetNext(input_4);

var group_inner = new EmuTabGroup(32, 32, 640 - 64, 640 - 128, 3, 32)
tab_3.AddContent(group_inner);
var tab_11 = new EmuTab("Tab 11");
var tab_12 = new EmuTab("Tab 12");
var tab_13 = new EmuTab("Tab 13");
var tab_14 = new EmuTab("Tab 14");
var tab_15 = new EmuTab("Tab 15");
var tab_16 = new EmuTab("Tab 16");
var tab_17 = new EmuTab("Tab 17");
var tab_18 = new EmuTab("Tab 18");
var tab_19 = new EmuTab("Tab 19");
group_inner.AddTabs(0, [tab_11, tab_12]);
group_inner.AddTabs(1, [tab_13, tab_14, tab_15]);
group_inner.AddTabs(2, [tab_16, tab_17, tab_18, tab_19]);

tab_15.AddContent([
    new EmuButton(32, EMU_AUTO, 320, 32, "another button ", function() { show_message("clicked the bottom button"); }),
]);

var picker_5 = new EmuColorPicker(320, 32, 256, 32, "Color:", c_black, emu_null);
picker_5.allow_alpha = true;
tab_5.AddContent([
    new EmuInput(32, 32, 256, 32, "Enter int:", "15", "start typing", 6, E_InputTypes.INT, emu_null),
    picker_5,
    new EmuRenderSurface(32, EMU_AUTO, 576, 432,
        function(mx, my) { data.Render(); },
        function(mx, my) { data.Control(); },
        function() { data = new EmuDemoMeshScene(); },
        function() { data.Destroy(); }
    ),
]);

var render_surface = new EmuRenderSurface(32, 32, 256, 256,
    function(mx, my) {
        if (mouse_check_button(mb_left)) {
            draw_circle_colour(mx, my, 2, c_black, c_black, false);
            draw_line_width_colour(mx_previous, my_previous, mx, my, 4, c_black, c_black);
        }
        mx_previous = mx;
        my_previous = my;
    },
    function(mx, my) {
        buffer_seek(surface_buffer, buffer_seek_start, 0);
        buffer_get_surface(surface_buffer, GetSurface(), buffer_surface_copy, 0, 0);
    },
    function() {
        draw_clear(c_yellow);
        mx_previous = 0;
        my_previous = 0;
        surface_buffer = buffer_create(width * height * 4, buffer_fixed, 1);
    },
    function() {
        buffer_delete(surface_buffer);
    }
);

render_surface.SetRecreate(function() {
    buffer_set_surface(surface_buffer, GetSurface(), buffer_surface_copy, 0, 0);
});
tab_11.AddContent(render_surface);