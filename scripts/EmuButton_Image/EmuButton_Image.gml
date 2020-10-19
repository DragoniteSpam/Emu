// Emu (c) 2020 @dragonitespam
// See the Github wiki for documentation: https://github.com/DragoniteSpam/Emu/wiki
function EmuButtonImage(x, y, w, h, sprite, index, blend, alpha, scale_to_fit, callback) : EmuCallback(x, y, w, h, 0, callback) constructor {
    self.sprite = sprite;
    self.blend = blend;
    self.alpha = alpha;
    self.fill = scale_to_fit;
    self.allow_shrink = true;
    
    self.alignment = fa_center;
    self.valignment = fa_middle;
    self.text = "";
    
    self.color_hover = EMU_COLOR_HOVER;
    self.color_back = EMU_COLOR_BACK;
    self.color_disabled = EMU_COLOR_DISABLED;
    
    self.checker_background = false;
    
    self._surface = noone;
    self._index = index;
    
    Render = function(base_x, base_y) {
        processAdvancement();
        
        var x1 = x + base_x;
        var y1 = y + base_y;
        var x2 = x1 + width;
        var y2 = y1 + height;
        
        #region draw the image to the _surface
        if (surface_exists(_surface) && (surface_get_width(_surface) != width || surface_get_height(_surface) != height)) {
            surface_free(_surface);
        }
        
        if (!surface_exists(_surface)) {
            _surface = surface_create(width, height);
        }
        
        surface_set_target(_surface);
        draw_clear_alpha(c_black, 0);
        drawNineslice(1, 0, 0, width, height, color_back, 1);
        if (sprite_exists(sprite)) {
            if (checker_background) drawCheckerbox(0, 0, width - 1, height - 1);
            if (allow_shrink) {
                var scale = fill ? min(width / sprite_get_width(sprite), height / sprite_get_height(sprite)) : 1;
            } else {
                var scale = fill ? min(max(width / sprite_get_width(sprite), 1), max(height / sprite_get_height(sprite), 1)) : 1;
            }
            draw_sprite_ext(sprite, _index, width / 2, height / 2, scale, scale, 0, blend, alpha);
        }
        
        scribble_set_box_align(alignment, valignment);
        scribble_set_wrap(width, height);
        scribble_draw(width div 2, height div 2, text);
        surface_reset_target();
        #endregion
        
        if (getMouseHover(x1, y1, x2, y2)) {
            ShowTooltip();
        }
        
        if (getMouseReleased(x1, y1, x2, y2)) {
            Activate();
            callback();
        }
        
        var back_color = getMouseHover(x1, y1, x2, y2) ? color_hover : (GetInteractive() ? color_back : color_disabled);
        draw_surface_ext(_surface, x1, y1, 1, 1, 0, back_color, 1);
        drawNineslice(0, x1, y1, x2, y2, color, 1);
    }
    
    Destroy = function() {
        if (surface_exists(_surface)) surface_free(_surface);
        destroyContent();
    }
}