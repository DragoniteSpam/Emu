// Emu (c) 2020 @dragonitespam
// See the Github wiki for documentation: https://github.com/DragoniteSpam/Documentation/wiki/Emu

// feather use syntax-errors
function EmuButton(x, y, width, height, text, callback) : EmuCallback(x, y, width, height, text, 0, callback) constructor {
    self.align.h = fa_center;
    self.align.v = fa_middle;
    
    /// @ignore
    self.color_hover = function() { return EMU_COLOR_HOVER; };
    /// @ignore
    self.color_back = function() { return EMU_COLOR_BACK; };
    /// @ignore
    self.color_disabled = function() { return EMU_COLOR_DISABLED; };
    
    #region mutators
    self.SetColorHover = function(color_function) {
        self.color_hover = method(self, color_function);
        return self;
    };
    
    self.SetColorDisabled = function(color_function) {
        self.color_disabled = method(self, color_function);
        return self;
    };
    
    self.SetColorBack = function(color_function) {
        self.color_back = method(self, color_function);
        return self;
    };
    #endregion
    
    #region other methods
    self.Render = function(x, y, debug_render) {
        self.update_script();
        self.processAdvancement();
        
        var x1 = self.x + x;
        var y1 = self.y + y;
        var x2 = x1 + self.width;
        var y2 = y1 + self.height;
        
        if (self.getMouseHover(x1, y1, x2, y2)) {
            self.ShowTooltip();
        }
        
        if (self.getMouseReleased(x1, y1, x2, y2)) {
            self.Activate();
            self.callback();
        }
        
        var back_color = self.getMouseHover(x1, y1, x2, y2) ? self.color_hover() : (self.GetInteractive() ? self.color_back() : self.color_disabled());
        draw_sprite_stretched_ext(self.sprite_nineslice, 1, x1, y1, x2 - x1, y2 - y1, back_color, 1);
        draw_sprite_stretched_ext(self.sprite_nineslice, 0, x1, y1, x2 - x1, y2 - y1, self.color(), 1);
        
        scribble(self.text)
            .wrap(self.width, self.height)
            .align(self.align.h, self.align.v)
            .draw(floor(mean(x1, x2)), floor(mean(y1, y2)));
        
        if (debug_render) self.renderDebugBounds(x1, y1, x2, y2);
    };
    #endregion
}