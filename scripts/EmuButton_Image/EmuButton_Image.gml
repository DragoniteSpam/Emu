// Emu (c) 2020 @dragonitespam
// See the Github wiki for documentation: https://github.com/DragoniteSpam/Emu/wiki
function EmuButtonImage(_x, _y, _w, _h, _sprite, _index, _blend, _alpha, _scale_to_fit, _callback) : EmuCallback(_x, _y, _w, _h, 0, _callback) constructor {
    sprite = _sprite;
    index = _index;
    blend = _blend;
    alpha = _alpha;
    fill = _scale_to_fit;
    
    alignment = fa_center;
    valignment = fa_middle;
    text = "";
    
    color_hover = EMU_COLOR_HOVER;
    color_back = EMU_COLOR_BACK;
    color_disabled = EMU_COLOR_DISABLED;
    
    surface = noone;
    
    Render = function(base_x, base_y) {
        processAdvancement();
        
        var x1 = x + base_x;
        var y1 = y + base_y;
        var x2 = x1 + width;
        var y2 = y1 + height;
        
        #region draw the image to the surface
        if (surface_exists(surface) && (surface_get_width(surface) != width || surface_get_height(surface) != height)) {
            surface_free(surface);
        }
        
        if (!surface_exists(surface)) {
            surface = surface_create(width, height);
        }
        
        surface_set_target(surface);
        draw_clear_alpha(c_black, 0);
        drawNineslice(1, 0, 0, width, height, color_back, 1);
        if (sprite_exists(sprite)) {
            var scale = fill ? min(max(width / sprite_get_width(sprite), 1), max(height / sprite_get_height(sprite), 1)) : 1;
            draw_sprite_ext(sprite, index, width / 2, height / 2, scale, scale, 0, blend, alpha);
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
        draw_surface_ext(surface, x1, y1, 1, 1, 0, back_color, 1);
        drawNineslice(0, x1, y1, x2, y2, color, 1);
    }
    
    Destroy = function() {
        if (surface_exists(surface)) surface_free(surface);
        destroyContent();
    }
}