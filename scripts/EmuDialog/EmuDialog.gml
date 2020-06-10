function EmuDialog(_w, _h, _title, _callback) : EmuCallback(0, 0, _w, _h, 0, _callback) constructor {
    static drawn_dialog_shade_time = -1;
    
    var size = ds_list_size(global.__emu_dialogs);
    x = 64 * (size + 1);
    y = 64 * (size + 1);
    
    text = _title;
    
    enum EmuDialogFlags {
        IS_QUIT                 = 0x0001,
        IS_EXCEPTION            = 0x0002,
        CLOSE_BUTTON            = 0x0004,
        IS_DUPLICATE_WARNING    = 0x0008,
        ACTIVE_SHADE            = 0x0010,
        
        DEFAULT_FLAGS           = EmuDialogFlags.CLOSE_BUTTON | EmuDialogFlags.ACTIVE_SHADE,
    }
    
    flags = EmuDialogFlags.DEFAULT_FLAGS;
    
    header_height = 32;
    changed = false;
    sprite_close = spr_emu_close;
    color_header = EMU_COLOR_WINDOWSKIN;
    
    click_x = -1;
    click_y = -1;
    
    ds_list_add(global.__emu_dialogs, self);
    
    Close = function() {
        do {
            var top = global.__emu_dialogs[| ds_list_size(global.__emu_dialogs) - 1];
            top.Destroy();
            ds_list_delete(global.__emu_dialogs, ds_list_size(global.__emu_dialogs) - 1);
        } until (top == self);
    }
    
    GetHeight = function() {
        return height + header_height;
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
        
        var active = IsActiveDialog();
        var kill = false;
        
        if (active) {
            cbi = 0;
            if (GetMouseHover(x1, y1, x2, y1 + header_height)) {
                if ((flags & EmuDialogFlags.CLOSE_BUTTON) && GetMouseHover(cbx1, cby1, cbx2, cby2)) {
                    cbi = 1;
                    if (GetMouseReleased(cbx1, cby1, cbx2, cby2)) {
                        kill = true;
                        global.__emu_active_element = noone;
                    }
                } else {
                    if (GetMousePressed(x1, y1, x2, y1 + header_height)) {
                        click_x = window_mouse_get_x();
                        click_y = window_mouse_get_y();
                    }
                    if (GetMouseReleased(x1, y1, x2, y1 + header_height)) {
                        click_x = -1;
                        click_y = -1;
                    }
                }
            }
            
            if (GetMouseHold(0, 0, window_get_width(), window_get_height()) && click_x > -1) {
                x += (window_mouse_get_x() - click_x);
                y += (window_mouse_get_y() - click_y);
                click_x = window_mouse_get_x();
                click_y = window_mouse_get_y();
            }
        }
        
        // re-set these in case you dragged the window around
        var x1 = x;
        var y1 = y;
        var x2 = x1 + width;
        var y2 = y1 + GetHeight();
        
        var tx = x1 + offset;
        var ty = floor(mean(y1, y1 + header_height));
        
        var cbx1 = x2 - sprite_get_width(sprite_close);
        var cbx2 = x2;
        var cby1 = y1;
        var cby2 = y1 + sprite_get_height(sprite_close);
        
        // tint the screen behind the active dialog (but only once per frame)
        if (active && !!(flags & EmuDialogFlags.ACTIVE_SHADE) && (drawn_dialog_shade_time != current_time)) {
            draw_set_alpha(EMU_DIALOG_SHADE_ALPHA);
            draw_rectangle_colour(0, 0, window_get_width(), window_get_height(), EMU_DIALOG_SHADE_COLOR, EMU_DIALOG_SHADE_COLOR, EMU_DIALOG_SHADE_COLOR, EMU_DIALOG_SHADE_COLOR, false);
            draw_set_alpha(1);
            drawn_dialog_shade_time = current_time;
        }
        
        DrawNineslice(1, x1, y1, x2, y2, EMU_COLOR_BACK, 1);
        DrawNineslice(0, x1, y1, x2, y2, color, 1);
        var ch = merge_colour(color_header, EMU_DIALOG_SHADE_COLOR, active ? 0 : 0.5);
        DrawNineslice(1, x1, y1, x2, y1 + header_height, ch, 1);
        DrawNineslice(0, x1, y1, x2, y1 + header_height, color, 1);
        
        scribble_set_box_align(fa_left, fa_middle);
        scribble_draw(tx, ty, string(text), c_black, c_black, c_black, c_black, 1);
        
        if (flags & EmuDialogFlags.CLOSE_BUTTON) {
            draw_sprite(sprite_close, cbi, cbx1, cby1);
        }
        
        RenderContents(x1, y1 + header_height);
        
        kill |= (active && (flags & EmuDialogFlags.CLOSE_BUTTON) && keyboard_check_released(vk_escape) && !(global.__emu_active_element && global.__emu_active_element.override_escape));
        
        if (kill) {
            Close();
        }
    }
    
    // Override this function for dialogs
    IsActiveDialog = function() {
        return (global.__emu_dialogs[| ds_list_size(global.__emu_dialogs) - 1] == self);
    }
}