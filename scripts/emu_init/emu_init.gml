scribble_init("emu", "fnt_emu_default", true);

global.__emu_dialogs = ds_list_create();
global.__emu_active_element = noone;

#region some macros which you may want to set
#macro EMU_COLOR_BACK 0xffffff
#macro EMU_COLOR_DEFAULT 0x000000
#macro EMU_COLOR_DISABLED 0xe0e0e0
#macro EMU_COLOR_HOVER 0xffe5ce
#macro EMU_COLOR_INPUT_REJECT 0x0000ff
#macro EMU_COLOR_INPUT_WARN 0x3399ff
#macro EMU_COLOR_PROGRESS_BAR 0xff9900
#macro EMU_COLOR_RADIO_ACTIVE 0x009900
#macro EMU_COLOR_SELECTED 0xffb8ac
#macro EMU_COLOR_WINDOWSKIN 0x339900

#macro EMU_DIALOG_SHADE_ALPHA 0.5
#macro EMU_DIALOG_SHADE_COLOR 0x000000

#macro EMU_FONT_DEFAULT fnt_emu_default

#macro EMU_TIME_DOUBLE_CLICK_THRESHOLD 250
#macro EMU_TIME_HOLD_THRESHOLD 500
#endregion

#region macros which it is not very useful to touch
#macro emu_auto undefined
#endregion