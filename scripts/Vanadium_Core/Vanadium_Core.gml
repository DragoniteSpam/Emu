function VCore(_x, _y, _w, _h) constructor {
    x = _x;
    y = _y;
    width = _w;
    height = _h;
    root = noone;
    
    contents = ds_list_create();
    enabled = true;
    interactive = true;
    outline = true;             // not used in all element types
    tooltip = "";               // not used by all element types
    color = VANADIUM_COLOR_DEFAULT;
    
    active_element = noone;
    
    text = "core";
    offset = 12;
    
    alignment = fa_left;
    valignment = fa_middle;
    
    override_escape = false;
    
    next = noone;
    previous = noone;
    sprite_nineslice = spr_vanadium_nineslice;
    element_spacing_y = 16;
    
    AddContent = function(addition) {
        if (addition.y == undefined) {
            var top = contents[| ds_list_size(contents) - 1];
            if (top) {
                addition.y = top.y + top.GetHeight() + element_spacing_y;
            } else {
                addition.y = element_spacing_y;
            }
        }
        ds_list_add(contents, addition);
        addition.root = self;
        return addition;
    }
    
    RemoveContent = function(addition) {
        ds_list_delete(contents, ds_list_find_index(contents, addition));
        return addition;
    }
    
    GetHeight = function() {
        return height;
    }
    
    Render = function(base_x, base_y) {
        RenderContents(x + base_x, y + base_y);
    }
    
    RenderContents = function(at_x, at_y) {
        for (var i = 0; i < ds_list_size(contents); i++) {
            var what = contents[| i];
            if (what.enabled) {
                what.Render(at_x, at_y);
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
    
    static GetMousePressed = function(x1, y1, x2, y2) {
        return interactive && point_in_rectangle(window_mouse_get_x(), window_mouse_get_y(), x1, y1, x2, y2) && mouse_check_button_pressed(mb_left);
    }
    
    static GetMouseReleased = function(x1, y1, x2, y2) {
        return interactive && point_in_rectangle(window_mouse_get_x(), window_mouse_get_y(), x1, y1, x2, y2) && mouse_check_button_released(mb_left);
    }
    
    static GetMouseHold = function(x1, y1, x2, y2) {
        return interactive && point_in_rectangle(window_mouse_get_x(), window_mouse_get_y(), x1, y1, x2, y2) && mouse_check_button(mb_left);
    }
    
    static GetMouseHover = function(x1, y1, x2, y2) {
        return interactive && point_in_rectangle(window_mouse_get_x(), window_mouse_get_y(), x1, y1, x2, y2);
    }
}