// Emu (c) 2020 @dragonitespam
// See the Github wiki for documentation: https://github.com/DragoniteSpam/Documentation/wiki/Emu

// feather use syntax-errors
function EmuText(x, y, width, height, text) : EmuCore(x, y, width, height, text) constructor {
    /// @ignore
    self.update_text = undefined;
    
    #region mutators
    self.SetTextUpdate = function(f) {
        if (f) {
            self.update_text = method(self, f);
        } else {
            self.update_text = undefined;
        }
        return self;
    };
    #endregion
    
    #region other methods
    self.Render = function(x, y, debug_render = false) {
        self.update_script();
        self.processAdvancement();
        
        if (self.update_text) self.text = self.update_text();
        
        var x1 = self.x + x;
        var y1 = self.y + y;
        var x2 = x1 + self.width;
        var y2 = y1 + self.height;
        
        var tx = self.getTextX(x1);
        var ty = self.getTextY(y1);
        
        if (self.getMouseHover(x1, y1, x2, y2)) {
            self.ShowTooltip();
            if (self.getMouseReleased(x1, y1, x2, y2)) {
                self.Activate();
            }
        }
        
        scribble(self.text)
            .wrap(self.width, self.height)
            .align(self.align.h, self.align.v)
            .draw(tx, ty);
        
        if (debug_render) self.renderDebugBounds(x1, y1, x2, y2);
    };
    #endregion
}