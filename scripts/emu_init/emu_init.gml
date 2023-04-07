// Emu (c) 2020 @dragonitespam
// See the Github wiki for documentation: https://github.com/DragoniteSpam/Documentation/wiki/Emu

#region some macros which you may want to set
#macro EMU_COLOR_BACK                   #1f1f1f
#macro EMU_COLOR_DEFAULT                #5f5f5f
#macro EMU_COLOR_TEXT                   #ffffff
#macro EMU_COLOR_DISABLED               #4f4f4f
#macro EMU_COLOR_HELP_TEXT              #606060
#macro EMU_COLOR_HOVER                  #4f4f4f
#macro EMU_COLOR_INPUT_REJECT           #ff2f2f
#macro EMU_COLOR_INPUT_WARN             #ff9933
#macro EMU_COLOR_LIST_TEXT              #ffffff
#macro EMU_COLOR_PROGRESS_BAR           #0099ff
#macro EMU_COLOR_RADIO_ACTIVE           #009900
#macro EMU_COLOR_SELECTED               #4f4f4f
#macro EMU_COLOR_WINDOWSKIN             #009933

#macro EMU_DIALOG_SHADE_ALPHA           0.5
#macro EMU_DIALOG_SHADE_COLOR           #000000

#macro EMU_FONT_DEFAULT                 fnt_emu_default

#macro EMU_SPRITE_CHECKERS              spr_emu_checker
#macro EMU_SPRITE_CHECKBOX              spr_emu_checkbox
#macro EMU_SPRITE_CHECKBOX_BORDER       spr_emu_checkbox_border
#macro EMU_SPRITE_CLOSE_BUTTON          spr_emu_close
#macro EMU_SPRITE_HELP                  spr_emu_help
#macro EMU_SPRITE_DRAG_KNOB             spr_emu_knob
#macro EMU_SPRITE_MENU_BAR_H            spr_emu_mask_bar_h
#macro EMU_SPRITE_MENU_BAR_V            spr_emu_mask_bar_v
#macro EMU_SPRITE_CROSSHAIR             spr_emu_mask_crosshair
#macro EMU_SPRITE_NOT_FOUND             spr_emu_not_found
#macro EMU_SPRITE_PROGRESS              spr_emu_progress
#macro EMU_SPRITE_RADIO                 spr_emu_radio
#macro EMU_SPRITE_RING                  spr_emu_ring
#macro EMU_SPRITE_SCROLL_ARROW          spr_emu_scroll_arrow
#macro EMU_SPRITE_SUBMIT                spr_emu_enter

#macro EMU_TIME_DOUBLE_CLICK_THRESHOLD  250
#macro EMU_TIME_HOLD_THRESHOLD          500

#macro EMU_INPUT_BLINKING_SPEED         800
#macro EMU_KEY_REPEAT_DELAY             60
#macro EMU_KEY_REPEAT_RATE              2

#macro EMU_DEFAULT_FONT                 "fnt_emu_default"

#macro EMU_DEFAULT_CLOSE_BUTTON_WIDTH   160
#macro EMU_DEFAULT_CLOSE_BUTTON_HEIGHT  32
#endregion

scribble_font_set_default(EMU_DEFAULT_FONT);

#region macros which it is not very useful to touch
#macro EMU_AUTO                         ptr(0)
#macro EMU_INLINE                       ptr(1)
#macro EMU_BASE                         ptr(2)
#macro EMU_AUTO_NO_SPACING              ptr(3)
#macro EmuOverlay                       _emu_get_overlay()
#macro EmuActiveElement                 _emu_active_element()

function _emu_get_overlay() {
    static EmuCoreOverlay = function() : EmuCore(0, 0, 1, 1, "overlay") constructor {
        self.baseRender = self.Render;
        
        self.Render = function(debug_render = false) {
            self.width = window_get_width();
            self.height = window_get_height();
            self.baseRender(0, 0, debug_render);
        };
        
        self.Pop = function() {
            array_delete(self.contents, array_length(self.contents) - 1, 1);
            _emu_active_element(pointer_null);
        };
    };
    
    static inst = new EmuCoreOverlay();
    return inst;
}

function _emu_active_element(element = undefined) {
    static inst = undefined;
    if (element == pointer_null) inst = undefined;
    else if (element) inst = element;
    return inst;
}
#endregion

/*
//For a light mode, although i dont know if you really want to use that:
#macro EMU_COLOR_BACK                   0xffffff
#macro EMU_COLOR_DEFAULT                0x000000
#macro EMU_COLOR_DISABLED               0xe0e0e0
#macro EMU_COLOR_HELP_TEXT              0x404040
#macro EMU_COLOR_HOVER                  0xffe5ce
#macro EMU_COLOR_INPUT_REJECT           0x0000ff
#macro EMU_COLOR_INPUT_WARN             0x3399ff
#macro EMU_COLOR_LIST_TEXT              0x000000
#macro EMU_COLOR_PROGRESS_BAR           0xff9900
#macro EMU_COLOR_RADIO_ACTIVE           0x009900
#macro EMU_COLOR_SELECTED               0xffb8ac
#macro EMU_COLOR_WINDOWSKIN             0x339900
*/