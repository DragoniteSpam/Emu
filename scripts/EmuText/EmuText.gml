// Emu (c) 2020 @dragonitespam
// See the Github wiki for documentation: https://github.com/DragoniteSpam/Documentation/wiki/Emu
function EmuText(x, y, w, h, text) : EmuCore(x, y, w, h) constructor {
    self.text = text;
    
    self.update_text = undefined;
    
    static SetTextUpdate = function(f) {
        if (f) {
            self.update_text = method(self, f);
        } else {
            self.update_text = undefined;
        }
        return self;
    };
    
    Render = function(base_x, base_y) {
        processAdvancement();
        
        if (self.update_text) self.text = self.update_text();
        
        var x1 = x + base_x;
        var y1 = y + base_y;
        var x2 = x1 + width;
        var y2 = y1 + height;
        
        var tx = getTextX(x1);
        var ty = getTextY(y1);
        
        if (getMouseHover(x1, y1, x2, y2)) {
            ShowTooltip();
            if (getMouseReleased(x1, y1, x2, y2)) {
                Activate();
            }
        }
        
        scribble_set_wrap(width, height);
        scribble_set_box_align(alignment, valignment);
        scribble_draw(tx, ty, text);
    }
}