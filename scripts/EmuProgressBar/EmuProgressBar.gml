// Emu (c) 2020 @dragonitespam
// See the Github wiki for documentation: https://github.com/DragoniteSpam/Documentation/wiki/Emu
function EmuProgressBar(x, y, w, h, thickness, value_min, value_max, draggable, value, callback) : EmuCallback(x, y, w, h, value, callback) constructor {
    self.thickness = thickness;
    self.value_min = min(value_min, value_max);
    self.value_max = max(value_min, value_max);
    self.draggable = draggable;
    
    self.color_bar = function() { return EMU_COLOR_PROGRESS_BAR };
    self.color_back = function() { return EMU_COLOR_BACK };
    
    self.sprite_bar = spr_emu_progress;
    self.sprite_knob = spr_emu_knob;
    self.knob_scale = 2;
    
    self._integers_only = false;
    self._currently_dragging = false;
    
    SetIntegersOnly = function(integers) {
        _integers_only = integers;
        return self;
    }
    
    DrawProgress = function(index, x1, y1, x2, y2, f, c, alpha) {
        draw_sprite_stretched_ext(sprite_bar, index, x1, y1, max((x2 - x1) * f, 0), y2 - y1, c, alpha);
    }
    
    Render = function(base_x, base_y) {
        processAdvancement();
        
        var x1 = x + base_x;
        var y1 = y + base_y;
        var x2 = x1 + width;
        var y2 = y1 + height;
        
        var bx1 = x1 + offset;
        var by1 = floor(mean(y1, y2) - thickness / 2);
        var bx2 = x2 - offset;
        var by2 = floor(mean(y1, y2) + thickness / 2);
        
        var knob_color = EMU_COLOR_BACK;
        
        if (getMouseHover(x1, y1, x2, y2)) {
            ShowTooltip();
            knob_color = EMU_COLOR_HOVER;
        }
        
        if (draggable) {
            if (getMousePressed(x1, y1, x2, y2)) {
                Activate();
                _currently_dragging = true;
            }
            
            if (_currently_dragging) {
                if (getMouseHold(0, 0, window_get_width(), window_get_height())) {
                    knob_color = EMU_COLOR_SELECTED;
                    value = clamp((device_mouse_x_to_gui(0) - bx1) / (bx2 - bx1) * (value_max - value_min) + value_min, value_min, value_max);
                    if (_integers_only) {
                        value = round(value);
                    }
                    callback();
                } else {
                    _currently_dragging = false;
                }
            }
        }
        
        var f = clamp((value - value_min) / (value_max - value_min), 0, 1);
        
        DrawProgress(2, bx1, by1, bx2, by2, 1, self.color_back(), 1);
        DrawProgress(0, bx1, by1, bx2, by2, f, self.color_bar(), 1);
        DrawProgress(1, bx1, by1, bx2, by2, 1, self.color(), 1);
        
        if (draggable) {
            var w = bx2 - bx1;
            var h = by2 - by1;
            var fw = max(w * f, 0);
            var scale = knob_scale * thickness / sprite_get_height(sprite_knob);
            draw_sprite_ext(sprite_knob, 2, bx1 + fw, floor(mean(y1, y2)), scale, scale, 0, knob_color, 1);
            draw_sprite_ext(sprite_knob, 1, bx1 + fw, floor(mean(y1, y2)), scale, scale, 0, self.color(), 1);
            draw_sprite_ext(sprite_knob, 0, bx1 + fw, floor(mean(y1, y2)), scale, scale, 0, self.color(), 1);
        }
    }
}