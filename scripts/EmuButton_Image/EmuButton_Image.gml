function EmuButtonImage(_x, _y, _w, _h, _sprite, _index, _blend, _alpha, _scale_to_fit, _callback) : EmuCallback(_x, _y, _w, _h, 0, _callback) constructor {
    sprite = _sprite;
    index = _index;
    blend = _blend;
    alpha = _alpha;
    scale = _scale_to_fit;
    
    surface = noone;
    
    Render = function(base_x, base_y) {
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
        var exists = sprite_exists(sprite);
        var sprite_image = exists ? sprite : spr_emu_not_found;
        var sprite_frame = exists ? index : 0;
        var sprite_color = exists ? blend : c_white;
        var sprite_alpha = exists ? alpha : 1;
        var xscale = (exists && scale) ? min(width / sprite_get_width(sprite_image), 1) : 1;
        var yscale = (exists && scale) ? min(height / sprite_get_height(sprite_image), 1) : 1;
        DrawNineslice(1, 0, 0, width, height, EMU_COLOR_BACK, 1);
        draw_sprite_ext(sprite_image, index, width / 2, height / 2, xscale, yscale, 0, sprite_color, sprite_alpha);
        surface_reset_target();
        #endregion
        
        if (GetMouseHover(x1, y1, x2, y2)) {
            ShowTooltip();
        }
        
        if (GetMouseReleased(x1, y1, x2, y2)) {
            callback();
        }
        
        var back_color = GetMouseHover(x1, y1, x2, y2) ? EMU_COLOR_HOVER : (GetInteractive() ? EMU_COLOR_BACK : EMU_COLOR_DISABLED);
        draw_surface_ext(surface, x1, y1, 1, 1, 0, back_color, 1);
        DrawNineslice(0, x1, y1, x2, y2, color, 1);
    }
    
    Destroy = function() {
        if (surface_exists(surface)) surface_free(surface);
        DestroyContent();
    }
}