function VCore(_x, _y, _w, _h, _root) constructor {
    x = _x;
    y = _y;
    width = _w;
    height = _h;
    root = _root;
    
    contents = ds_list_create();
    enabled = true;
    interactive = true;
    outline = true;             // not used in all element types
    tooltip = "";               // not used by all element types
    
    active_element = noone;
    
    text = "core";
    offset = 12;
    
    color = VANADIUM_DEFAULT_COLOR;
    alignment = fa_left;
    valignment = fa_middle;
    
    // if you have a list of ui things in a list, and want to iterate over the
    // list, but want to ignore this one
    is_aux = false;
    
    // if this is set to true the mouse click check will use mouse_within_rectangle_adjusted
    // instead of mouse_within_rectangle_view
    adjust_view = false;
    
    override_escape = false;
    
    next = noone;
    previous = noone;
    
    Render = function(base_x, base_y) {
        for (var i = 0; i < ds_list_size(contents); i++) {
            var what = contents[| i];
            if (what.enabled) {
                what.Render(x + base_x, y + base_y);
            }
        }
    }
    
    Destroy = function() {
        for (var i = 0; i < ds_list_size(contents); i++) {
            contents[| i].Destroy();
        }
    }
    
    SetTooltip = function() {
        // The implementation of this is up to you - but you probably want to
        // assign the element's "tooltip" text to be drawn on the UI somewhere
    }
    
    static DrawNineslice = function(sprite, index, x1, y1, x2, y2, color, alpha) {
        color = (color != undefined) ? color : c_white;
        alpha = (alpha != undefined) ? alpha : 1;
        var w = x2 - x1;
        var h = y2 - y1;
        var sw = sprite_get_width(sprite) / 3;
        var sh = sprite_get_height(sprite) / 3;
        
        draw_sprite_general(sprite, index, 0, 0, sw, sh, x1, y1, 1, 1, 0, color, color, color, color, alpha);
        draw_sprite_general(sprite, index, 2 * sw, 0, sw, sh, x1 + w - sw, y1, 1, 1, 0, color, color, color, color, alpha);
        draw_sprite_general(sprite, index, 2 * sw, 2 * sh, sw, sh, x1 + w - sw, y1 + h - sh, 1, 1, 0, color, color, color, color, alpha);
        draw_sprite_general(sprite, index, 0, 2 * sh, sw, sh, x1, y1 + h - sh, 1, 1, 0, color, color, color, color, alpha);
        
        var hxscale = (w - 2 * sw) / sw;
        var vyscale = (h - 2 * sh) / sh;
        
        draw_sprite_general(sprite, index, sw, 0, sw, sh, x1 + sw, y1, hxscale, 1, 0, color, color, color, color, alpha);
        draw_sprite_general(sprite, index, sw, sh * 2, sw, sh, x1 + sw, y1 + h - sh, hxscale, 1, 0, color, color, color, color, alpha);
        draw_sprite_general(sprite, index, 0, sh, sw, sh, x1, y1 + sh, 1, vyscale, 0, color, color, color, color, alpha);
        draw_sprite_general(sprite, index, 2 * sw, sh, sw, sh, x1 + w - sw, y1 + sh, 1, vyscale, 0, color, color, color, color, alpha);
        draw_sprite_general(sprite, index, sw, sh, sw, sh, x1 + sw, y1 + sh, hxscale, vyscale, 0, color, color, color, color, alpha);
    }
}