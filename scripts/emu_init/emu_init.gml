scribble_init("emu_fonts", "fnt_emu_default", true);

global.__emu_dialogs = ds_list_create();
global.__emu_active_element = noone;

#region some macros which you may want to set
#macro EMU_FONT_DEFAULT fnt_emu_default

#macro EMU_COLOR_BACK 0xffffff
#macro EMU_COLOR_DEFAULT 0x000000
#macro EMU_COLOR_DISABLED c_ltgray
#macro EMU_COLOR_HOVER 0xffe5ce
#macro EMU_COLOR_PROGRESS_BAR 0xff9900
#macro EMU_COLOR_RADIO_ACTIVE 0x009900
#macro EMU_COLOR_SELECTED 0xffb8ac
#endregion