// Emu (c) 2020 @dragonitespam
// See the Github wiki for documentation: https://github.com/DragoniteSpam/Emu/wiki
scribble_init("emu", "fnt_emu_default", true);

#region some macros which you may want to set
#macro EMU_COLOR_BACK 0xffffff
#macro EMU_COLOR_DEFAULT 0x000000
#macro EMU_COLOR_DISABLED 0xe0e0e0
#macro EMU_COLOR_HELP_TEXT 0x404040
#macro EMU_COLOR_HOVER 0xffe5ce
#macro EMU_COLOR_INPUT_REJECT 0x0000ff
#macro EMU_COLOR_INPUT_WARN 0x3399ff
#macro EMU_COLOR_LIST_TEXT 0x000000
#macro EMU_COLOR_PROGRESS_BAR 0xff9900
#macro EMU_COLOR_RADIO_ACTIVE 0x009900
#macro EMU_COLOR_SELECTED 0xffb8ac
#macro EMU_COLOR_WINDOWSKIN 0x339900

#macro EMU_DIALOG_SHADE_ALPHA 0.5
#macro EMU_DIALOG_SHADE_COLOR 0x000000

#macro EMU_FONT_DEFAULT fnt_emu_default

#macro EMU_TIME_DOUBLE_CLICK_THRESHOLD 250
#macro EMU_TIME_HOLD_THRESHOLD 500

#macro EMU_INPUT_BLINKING_SPEED 800
#macro EMU_KEY_REPEAT_DELAY 60
#macro EMU_KEY_REPEAT_RATE 2
#endregion

#region macros which it is not very useful to touch
#macro EMU_AUTO undefined
#macro EmuOverlay (_emu_get_overlay())

function _emu_get_overlay() {
    static _overlay = noone;
    if (!_overlay) _overlay = new EmuCore(0, 0, window_get_width(), window_get_height());
    return _overlay;
}
#macro EmuActiveElement (_emu_active_element())

function _emu_active_element() { 
    static _active = undefined;
    if (argument_count > 0) {
        _active = argument[0];
    }
    return _active;
}
#endregion

/*
//For a dark mode, you may wish to use colors similar to this:
#macro EMU_COLOR_BACK 0x1f1f1f
#macro EMU_COLOR_DEFAULT 0xffffff
#macro EMU_COLOR_DISABLED 0x4f4f4f
#macro EMU_COLOR_HELP_TEXT 0x606060
#macro EMU_COLOR_HOVER 0x4f4f4f
#macro EMU_COLOR_INPUT_REJECT 0x2f2fff
#macro EMU_COLOR_INPUT_WARN 0x3399ff
#macro EMU_COLOR_LIST_TEXT 0xffffff
#macro EMU_COLOR_PROGRESS_BAR 0xff9900
#macro EMU_COLOR_RADIO_ACTIVE 0x009900
#macro EMU_COLOR_SELECTED 0x4f4f4f
#macro EMU_COLOR_WINDOWSKIN 0x339900
*/