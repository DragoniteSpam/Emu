function EmuProgressBar(_x, _y, _w, _h, _thickness, _min, _max, _draggable, _value, _callback) : EmuCallback(_x, _y, _w, _h, _value, _callback) constructor {
    thickness = _thickness;
    value_min = min(_min, _max);
    value_max = max(_min, _max);
    draggable = _draggable;
    
    integers_only = false;
    
    color_bar = EMU_COLOR_PROGRESS_BAR;
    sprite_bar = spr_emu_progress;
    sprite_knob = spr_emu_knob;
    knob_scale = 1.5;
    
    currently_dragging = false;
    
    SetIntegersOnly = function(_integers) {
        integers_only = _integers;
    }
    
    DrawProgress = function(index, x1, y1, x2, y2, f, c, alpha) {
        c = (c != undefined) ? c : c_white;
        alpha = (alpha != undefined) ? alpha : 1;
        var w = x2 - x1;
        var h = y2 - y1;
        var fw = max(w * f, 0);
        var sw = sprite_get_width(sprite_bar) / 3;
        var sh = sprite_get_height(sprite_bar) / 3;
        var hxscale = (w - 2 * sw) / sw;
        var vyscale = (h - 2 * sh) / sh;
        
        var sw2 = min(sw, fw);
        draw_sprite_general(sprite_bar, index, 0, 0, sw2, sh, x1, y1, 1, 1, 0, c, c, c, c, alpha);
        draw_sprite_general(sprite_bar, index, 0, 2 * sh, sw2, sh, x1, y1 + h - sh, 1, 1, 0, c, c, c, c, alpha);
        draw_sprite_general(sprite_bar, index, 0, sh, sw2, sh, x1, y1 + sh, 1, vyscale, 0, c, c, c, c, alpha);
        
        if (fw > sw) {
            var sw2 = min(sw, sw * (fw - sw) / (w - sw * 2));
            draw_sprite_general(sprite_bar, index, sw, 0, sw2, sh, x1 + sw, y1, hxscale, 1, 0, c, c, c, c, alpha);
            draw_sprite_general(sprite_bar, index, sw, sh * 2, sw2, sh, x1 + sw, y1 + h - sh, hxscale, 1, 0, c, c, c, c, alpha);
            draw_sprite_general(sprite_bar, index, sw, sh, sw2, sh, x1 + sw, y1 + sh, hxscale, vyscale, 0, c, c, c, c, alpha);
        }
        if (fw > w - sw) {
            var sw2 = min(sw, fw - (w - sw));
            draw_sprite_general(sprite_bar, index, 2 * sw, 0, sw2, sh, x1 + w - sw, y1, 1, 1, 0, c, c, c, c, alpha);
            draw_sprite_general(sprite_bar, index, 2 * sw, 2 * sh, sw2, sh, x1 + w - sw, y1 + h - sh, 1, 1, 0, c, c, c, c, alpha);
            draw_sprite_general(sprite_bar, index, 2 * sw, sh, sw2, sh, x1 + w - sw, y1 + sh, 1, vyscale, 0, c, c, c, c, alpha);
        }
    }
    
    Render = function(base_x, base_y) {
        processAdvancement();
        
        var x1 = x + base_x;
        var y1 = y + base_y;
        var x2 = x1 + width;
        var y2 = y1 + height;
        
        var bx1 = x1 + offset;
        var by1 = floor(mean(y1, y2)) - thickness / 2;
        var bx2 = x2 - offset;
        var by2 = floor(mean(y1, y2)) + thickness / 2;
        
        var knob_color = EMU_COLOR_BACK;
        
        if (GetMouseHover(x1, y1, x2, y2)) {
            ShowTooltip();
            knob_color = EMU_COLOR_HOVER;
        }
        
        if (draggable) {
            if (GetMousePressed(x1, y1, x2, y2)) {
                currently_dragging = true;
            }
            
            if (currently_dragging) {
                if (GetMouseHold(0, 0, window_get_width(), window_get_height())) {
                    knob_color = EMU_COLOR_SELECTED;
                    value = clamp((window_mouse_get_x() - bx1) / (bx2 - bx1) * (value_max - value_min) + value_min, value_min, value_max);
                    if (integers_only) {
                        value = round(value);
                    }
                    callback();
                } else {
                    currently_dragging = false;
                }
            }
        }
        
        var f = clamp((value - value_min) / (value_max - value_min), 0, 1);
        
        DrawProgress(2, bx1, by1, bx2, by2, 1, EMU_COLOR_BACK, 1);
        DrawProgress(0, bx1, by1, bx2, by2, f, color_bar, 1);
        DrawProgress(1, bx1, by1, bx2, by2, 1, color, 1);
        
        if (draggable) {
            var w = bx2 - bx1;
            var h = by2 - by1;
            var fw = max(w * f, 0);
            var scale = knob_scale * thickness / sprite_get_height(sprite_knob);
            draw_sprite_ext(sprite_knob, 2, bx1 + fw, floor(mean(y1, y2)), scale, scale, 0, knob_color, 1);
            draw_sprite_ext(sprite_knob, 1, bx1 + fw, floor(mean(y1, y2)), scale, scale, 0, color, 1);
            draw_sprite_ext(sprite_knob, 0, bx1 + fw, floor(mean(y1, y2)), scale, scale, 0, color, 1);
        }
    }
}