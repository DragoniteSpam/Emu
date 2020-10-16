// Emu (c) 2020 @dragonitespam
// See the Github wiki for documentation: https://github.com/DragoniteSpam/Emu/wiki
function EmuDialog(w, h, title) : EmuCallback(0, 0, w, h, 0, 0) constructor {
    static drawn_dialog_shade_time = -1;
    
    _emu_active_element(undefined);
    
    SetCallback(function() { Close(); });
    
    var size = ds_list_size(EmuOverlay._contents);
    x = 64 * (size + 1);
    y = 64 * (size + 1);
    
    self.text = title;
    
    self.active_shade = true;
    self.close_button = true;
    
    self.changed = false;
    self.sprite_close = spr_emu_close;
    self.color_header = EMU_COLOR_WINDOWSKIN;
    self.color_back = EMU_COLOR_BACK;
    
    self._header_height = 32;
    self._click_x = -1;
    self._click_y = -1;
    self._dispose = false;
    
    EmuOverlay.AddContent(self);
    
    Dispose = function() {
        _dispose = true;
    }
    
    Close = function() {
        do {
            var top = EmuOverlay._contents[| ds_list_size(EmuOverlay._contents) - 1];
            top.Destroy();
            ds_list_delete(EmuOverlay._contents, ds_list_size(EmuOverlay._contents) - 1);
        } until (top == self);
    }
    
    GetHeight = function() {
        return height + _header_height;
    }
    
    Render = function() {
        var x1 = x;
        var y1 = y;
        var x2 = x1 + width;
        var y2 = y1 + GetHeight();
        
        var cbx1 = x2 - sprite_get_width(sprite_close);
        var cbx2 = x2;
        var cby1 = y1;
        var cby2 = y1 + sprite_get_height(sprite_close);
        var cbi = 2;  // 0 is is available, 1 is hovering, 2 is unavailable
        
        var active = isActiveDialog();
        var kill = false;
        
        if (active) {
            cbi = 0;
            if (getMouseHover(x1, y1, x2, y1 + _header_height)) {
                if (close_button && getMouseHover(cbx1, cby1, cbx2, cby2)) {
                    cbi = 1;
                    if (getMouseReleased(cbx1, cby1, cbx2, cby2)) {
                        kill = true;
                        _emu_active_element(undefined);
                    }
                } else {
                    if (getMousePressed(x1, y1, x2, y1 + _header_height)) {
                        _click_x = window_mouse_get_x();
                        _click_y = window_mouse_get_y();
                    }
                    if (getMouseReleased(x1, y1, x2, y1 + _header_height)) {
                        _click_x = -1;
                        _click_y = -1;
                    }
                }
            }
            
            if (getMouseHold(0, 0, window_get_width(), window_get_height()) && _click_x > -1) {
                x += (window_mouse_get_x() - _click_x);
                y += (window_mouse_get_y() - _click_y);
                _click_x = window_mouse_get_x();
                _click_y = window_mouse_get_y();
            }
        }
        
        // re-set these in case you dragged the window around
        var x1 = x;
        var y1 = y;
        var x2 = x1 + width;
        var y2 = y1 + GetHeight();
        
        var tx = x1 + offset;
        var ty = floor(mean(y1, y1 + _header_height));
        
        var cbx1 = x2 - sprite_get_width(sprite_close);
        var cbx2 = x2;
        var cby1 = y1;
        var cby2 = y1 + sprite_get_height(sprite_close);
        
        // tint the screen behind the active dialog (but only once per frame)
        if (active && !!active_shade && (drawn_dialog_shade_time != current_time)) {
            draw_set_alpha(EMU_DIALOG_SHADE_ALPHA);
            draw_rectangle_colour(0, 0, window_get_width(), window_get_height(), EMU_DIALOG_SHADE_COLOR, EMU_DIALOG_SHADE_COLOR, EMU_DIALOG_SHADE_COLOR, EMU_DIALOG_SHADE_COLOR, false);
            draw_set_alpha(1);
            drawn_dialog_shade_time = current_time;
        }
        
        drawNineslice(1, x1, y1, x2, y2, color_back, 1);
        drawNineslice(0, x1, y1, x2, y2, color, 1);
        var ch = merge_colour(color_header, EMU_DIALOG_SHADE_COLOR, active ? 0 : 0.5);
        drawNineslice(1, x1, y1, x2, y1 + _header_height, ch, 1);
        drawNineslice(0, x1, y1, x2, y1 + _header_height, color, 1);
        
        scribble_set_box_align(fa_left, fa_middle);
        scribble_set_wrap(width, _header_height);
        scribble_draw(tx, ty, text);
        
        if (close_button) {
            draw_sprite(sprite_close, cbi, cbx1, cby1);
        }
        
        renderContents(x1, y1 + _header_height);
        
        kill |= (active && close_button && keyboard_check_released(vk_escape) && !(EmuActiveElement && EmuActiveElement._override_escape)) || _dispose;
        
        if (kill) {
            callback();
        }
    }
    
    // Override this function for dialogs
    isActiveDialog = function() {
        return (EmuOverlay._contents[| ds_list_size(EmuOverlay._contents) - 1] == self);
    }
}

function emu_dialog_close_auto() {
    root.Dispose();
}