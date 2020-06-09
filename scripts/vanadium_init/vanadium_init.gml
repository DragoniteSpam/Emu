scribble_init("vanadium_fonts", "fnt_vanadium_default", true);

global.__vanadium_dialogs = ds_list_create();
global.__vanadium_active_element = noone;

#region some macros which you may want to set
#macro VANADIUM_FONT_DEFAULT fnt_vanadium_default

#macro VANADIUM_COLOR_DEFAULT 0x000000
#macro VANADIUM_COLOR_BACK 0xffffff
#macro VANADIUM_COLOR_HOVER 0xffe5ce
#macro VANADIUM_COLOR_SELECTED 0xffb8ac
#macro VANADIUM_COLOR_DISABLED c_ltgray
#endregion