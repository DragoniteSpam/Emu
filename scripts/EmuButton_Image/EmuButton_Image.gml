// Emu (c) 2020 @dragonitespam
// See the Github wiki for documentation: https://github.com/DragoniteSpam/Documentation/wiki/Emu
function EmuButtonImage(x, y, w, h, sprite, index, blend, alpha, scale_to_fit, callback) : EmuCallback(x, y, w, h, "", 0, callback) constructor {
    self.sprite = sprite;
    self.blend = blend;
    self.alpha = alpha;
    self.fill = scale_to_fit;
    self.allow_shrink = true;
    
    self.align.h = fa_center;
    self.align.v = fa_middle;
    
    self.color_hover = function() { return EMU_COLOR_HOVER };
    self.color_back = function() { return EMU_COLOR_BACK };
    self.color_disabled = function() { return EMU_COLOR_DISABLED };
    
    self.checker_background = false;
    
    self.surface = -1;
    self.index = index;
    
    static Render = function(base_x, base_y) {
        self.gc.Clean();
        processAdvancement();
        
        var x1 = x + base_x;
        var y1 = y + base_y;
        var x2 = x1 + width;
        var y2 = y1 + height;
        
        #region draw the image to the surface
        self.surface = self.surfaceVerify(self.surface, self.width, self.height).surface;
        
        surface_set_target(surface);
        draw_clear_alpha(c_black, 0);
        draw_sprite_stretched_ext(sprite_nineslice, 1, 0, 0, width, height, self.color_back(), 1);
        if (sprite_exists(sprite)) {
            if (checker_background) drawCheckerbox(0, 0, width - 1, height - 1);
            if (allow_shrink) {
                var scale = fill ? min(width / sprite_get_width(sprite), height / sprite_get_height(sprite)) : 1;
            } else {
                var scale = fill ? min(max(width / sprite_get_width(sprite), 1), max(height / sprite_get_height(sprite), 1)) : 1;
            }
            draw_sprite_ext(sprite, index, width / 2, height / 2, scale, scale, 0, blend, alpha);
        }
        
        scribble(self.text)
            .wrap(self.width, self.height)
            .align(self.align.h, self.align.v)
            .draw(self.width div 2, self.height div 2);
        surface_reset_target();
        #endregion
        
        if (getMouseHover(x1, y1, x2, y2)) {
            ShowTooltip();
        }
        
        if (getMouseReleased(x1, y1, x2, y2)) {
            Activate();
            callback();
        }
        
        var back_color = getMouseHover(x1, y1, x2, y2) ? self.color_hover() : (GetInteractive() ? self.color_back() : self.color_disabled());
        draw_surface_ext(surface, x1, y1, 1, 1, 0, back_color, 1);
        draw_sprite_stretched_ext(sprite_nineslice, 0, x1, y1, x2 - x1, y2 - y1, self.color(), 1);
    };
}