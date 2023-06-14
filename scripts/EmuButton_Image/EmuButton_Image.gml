// Emu (c) 2020 @dragonitespam
// See the Github wiki for documentation: https://github.com/DragoniteSpam/Documentation/wiki/Emu

// feather use syntax-errors
function EmuButtonImage(x, y, width, height, sprite, index, blend, alpha, scale_to_fit, callback) : EmuCallback(x, y, width, height, "", 0, callback) constructor {
    self.sprite = sprite;
    self.blend = blend;
    self.alpha = alpha;
    self.fill = scale_to_fit;
    self.allow_shrink = true;
    
    self.align.h = fa_center;
    self.align.v = fa_middle;
    
    self.color_hover = function() { return EMU_COLOR_HOVER; };
    self.color_back = function() { return EMU_COLOR_BACK; };
    self.color_disabled = function() { return EMU_COLOR_DISABLED; };
    
    self.checker_background = false;
    
    self.surface = -1;
    self.index = index;
    
    self.Render = function(base_x, base_y, debug_render = false) {
        self.update_script();
        self.processAdvancement();
        
        var x1 = x + base_x;
        var y1 = y + base_y;
        var x2 = x1 + self.width;
        var y2 = y1 + self.height;
        
        #region draw the image to the surface
        self.surface = self.surfaceVerify(self.surface, self.width, self.height).surface;
        
        var back_color = self.getMouseHover(x1, y1, x2, y2) ? self.color_hover() : (self.GetInteractive() ? self.color_back() : self.color_disabled());
        
        surface_set_target(self.surface);
        draw_clear_alpha(c_black, 0);
        draw_sprite_stretched_ext(self.sprite_nineslice, 1, 0, 0, self.width, self.height, back_color, 1);
        if (sprite_exists(self.sprite)) {
            if (self.checker_background) self.drawCheckerbox();
            var scale = self.allow_shrink ?
                (self.fill ? min(self.width / sprite_get_width(self.sprite), self.height / sprite_get_height(self.sprite)) : 1) :
                (self.fill ? min(max(self.width / sprite_get_width(self.sprite), 1), max(self.height / sprite_get_height(self.sprite), 1)) : 1);
            draw_sprite_ext(self.sprite, self.index, self.width / 2, self.height / 2, scale, scale, 0, self.blend, self.alpha);
        }
        
        scribble(self.text)
            .wrap(self.width, self.height)
            .align(self.align.h, self.align.v)
            .draw(self.width div 2, self.height div 2);
        surface_reset_target();
        #endregion
        
        if (self.getMouseHover(x1, y1, x2, y2)) {
            self.ShowTooltip();
        }
        
        if (self.getMouseReleased(x1, y1, x2, y2)) {
            self.Activate();
            self.callback();
        }
        
        draw_surface_ext(self.surface, x1, y1, 1, 1, 0, c_white, 1);
        draw_sprite_stretched_ext(self.sprite_nineslice, 0, x1, y1, x2 - x1, y2 - y1, self.color(), 1);
        
        if (debug_render) self.renderDebugBounds(x1, y1, x2, y2);
    };
}