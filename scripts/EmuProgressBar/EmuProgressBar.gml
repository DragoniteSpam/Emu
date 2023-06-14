// Emu (c) 2020 @dragonitespam
// See the Github wiki for documentation: https://github.com/DragoniteSpam/Documentation/wiki/Emu

// feather use syntax-errors
function EmuProgressBar(x, y, width, height, thickness, value_min, value_max, draggable, value, callback) : EmuCallback(x, y, width, height, "progress bar", value, callback) constructor {
    /// @region
    self.thickness = thickness;
    /// @region
    self.value_min = min(value_min, value_max);
    /// @region
    self.value_max = max(value_min, value_max);
    /// @region
    self.draggable = draggable;
    
    self.color_bar = function() { return EMU_COLOR_PROGRESS_BAR; };
    /// @region
    self.color_back = function() { return EMU_COLOR_BACK; };
    
    /// @region
    self.sprite_bar = EMU_SPRITE_PROGRESS;
    /// @region
    self.sprite_knob = EMU_SPRITE_DRAG_KNOB;
    /// @region
    self.knob_scale = 2;
    
    /// @region
    self.integers_only = false;
    /// @region
    self.dragging = false;
    
    #region mutators
    self.SetThickness = function(thickness) {
        self.thickness = thickness;
        return self;
    };
    
    self.SetValueRange = function(value_min, value_max) {
        self.value_min = value_min;
        self.value_max = value_max;
        return self;
    };
    
    self.SetDraggable = function(draggable) {
        self.draggable = draggable;
        return self;
    };
    
    self.SetSpriteBar = function(sprite) {
        self.sprite_bar = sprite;
        return self;
    };
    
    self.SetSpriteKnob = function(sprite) {
        self.sprite_knob = sprite;
        return self;
    };
    
    self.SetColorBar = function(color_function) {
        self.color_bar = method(self, color_function);
        return self;
    };
    
    self.SetColorBack = function(color_function) {
        self.color_back = method(self, color_function);
        return self;
    };
    
    self.SetKnobScale = function(scale) {
        self.knob_scale = scale;
        return self;
    };
    
    self.SetIntegersOnly = function(integers) {
        self.integers_only = integers;
        return self;
    };
    #endregion
    
    #region other methods
    self.DrawProgress = function(index, x1, y1, x2, y2, f, c, alpha) {
        draw_sprite_stretched_ext(self.sprite_bar, index, x1, y1, max((x2 - x1) * f, 0), y2 - y1, c, alpha);
    };
    
    self.Render = function(x, y, debug_render = false) {
        self.update_script();
        self.processAdvancement();
        
        var x1 = self.x + x;
        var y1 = self.y + y;
        var x2 = x1 + self.width;
        var y2 = y1 + self.height;
        
        var bx1 = x1 + self.offset;
        var by1 = floor(mean(y1, y2) - self.thickness / 2);
        var bx2 = x2 - self.offset;
        var by2 = floor(mean(y1, y2) + self.thickness / 2);
        
        var knob_color = EMU_COLOR_BACK;
        
        if (self.getMouseHover(x1, y1, x2, y2)) {
            self.ShowTooltip();
            knob_color = EMU_COLOR_HOVER;
        }
        
        if (self.draggable) {
            if (self.getMousePressed(x1, y1, x2, y2)) {
                self.Activate();
                self.dragging = true;
            }
            
            if (self.dragging) {
                if (self.getMouseHold(0, 0, window_get_width(), window_get_height())) {
                    knob_color = EMU_COLOR_SELECTED;
                    /// @todo this will need to be redone when the system has the interactivity/rendering separated
                    self.value = clamp(((device_mouse_x_to_gui(0) - view_get_xport(view_current)) - bx1) / (bx2 - bx1) * (self.value_max - self.value_min) + self.value_min, self.value_min, self.value_max);
                    if (self.integers_only) {
                        self.value = round(self.value);
                    }
                    self.callback();
                } else {
                    self.dragging = false;
                }
            }
        }
        
        var f = clamp((self.value - self.value_min) / (self.value_max - self.value_min), 0, 1);
        
        self.DrawProgress(2, bx1, by1, bx2, by2, 1, self.color_back(), 1);
        self.DrawProgress(0, bx1, by1, bx2, by2, f, self.color_bar(), 1);
        self.DrawProgress(1, bx1, by1, bx2, by2, 1, self.color(), 1);
        
        if (self.draggable) {
            var w = bx2 - bx1;
            var h = by2 - by1;
            var fw = max(w * f, 0);
            var scale = self.knob_scale * self.thickness / sprite_get_height(self.sprite_knob);
            draw_sprite_ext(self.sprite_knob, 2, bx1 + fw, floor(mean(y1, y2)), scale, scale, 0, knob_color, 1);
            draw_sprite_ext(self.sprite_knob, 1, bx1 + fw, floor(mean(y1, y2)), scale, scale, 0, self.color(), 1);
            draw_sprite_ext(self.sprite_knob, 0, bx1 + fw, floor(mean(y1, y2)), scale, scale, 0, self.color(), 1);
        }
        
        if (debug_render) self.renderDebugBounds(x1, y1, x2, y2);
    };
    #endregion
}