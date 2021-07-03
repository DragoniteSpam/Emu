// Emu (c) 2020 @dragonitespam
// See the Github wiki for documentation: https://github.com/DragoniteSpam/Documentation/wiki/Emu
function EmuButton(x, y, w, h, text, callback) : EmuCallback(x, y, w, h, 0, callback) constructor {
    self.text = text;
    self.alignment = fa_center;
    self.valignment = fa_middle;
    
    self.color_hover = function() { return EMU_COLOR_HOVER };
    self.color_back = function() { return EMU_COLOR_BACK };
    self.color_disabled = function() { return EMU_COLOR_DISABLED };
    
    Render = function(base_x, base_y) {
        processAdvancement();
        
        var x1 = x + base_x;
        var y1 = y + base_y;
        var x2 = x1 + width;
        var y2 = y1 + height;
        
        if (getMouseHover(x1, y1, x2, y2)) {
            ShowTooltip();
        }
        
        if (getMouseReleased(x1, y1, x2, y2)) {
            Activate();
            callback();
        }
        
        var back_color = getMouseHover(x1, y1, x2, y2) ? self.color_hover() : (GetInteractive() ? self.color_back() : self.color_disabled());
        draw_sprite_stretched_ext(sprite_nineslice, 1, x1, y1, x2 - x1, y2 - y1, back_color, 1);
        draw_sprite_stretched_ext(sprite_nineslice, 0, x1, y1, x2 - x1, y2 - y1, self.color(), 1);
        
        scribble_set_box_align(alignment, valignment);
        scribble_set_wrap(width, height);
        scribble_draw(floor(mean(x1, x2)), floor(mean(y1, y2)), text);
    }
}