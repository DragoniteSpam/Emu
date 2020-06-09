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
    
    AddContent = function(elements) {
        if (!is_array(elements)) {
            elements = [elements];
        }
        for (var i = 0; i < array_length(elements); i++) {
            var thing = elements[i];
            if (thing.y == undefined) {
                var top = contents[| ds_list_size(contents) - 1];
                if (top) {
                    thing.y = top.y + top.GetHeight() + element_spacing_y;
                } else {
                    thing.y = element_spacing_y;
                }
            }
            ds_list_add(contents, thing);
            thing.root = self;
        }
    }
    
    RemoveContent = function(elements) {
        if (!is_array(elements)) {
            elements = [elements];
        }
        for (var i = 0; i < array_length(elements); i++) {
            var thing = elements[i];
            ds_list_delete(contents, ds_list_find_index(contents, thing));
        }
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
    
    DrawNineslice = function(index, x1, y1, x2, y2, color, alpha) {
        color = (color != undefined) ? color : c_white;
        alpha = (alpha != undefined) ? alpha : 1;
        var w = x2 - x1;
        var h = y2 - y1;
        var sw = sprite_get_width(sprite_nineslice) / 3;
        var sh = sprite_get_height(sprite_nineslice) / 3;
        
        draw_sprite_general(sprite_nineslice, index, 0, 0, sw, sh, x1, y1, 1, 1, 0, color, color, color, color, alpha);
        draw_sprite_general(sprite_nineslice, index, 2 * sw, 0, sw, sh, x1 + w - sw, y1, 1, 1, 0, color, color, color, color, alpha);
        draw_sprite_general(sprite_nineslice, index, 2 * sw, 2 * sh, sw, sh, x1 + w - sw, y1 + h - sh, 1, 1, 0, color, color, color, color, alpha);
        draw_sprite_general(sprite_nineslice, index, 0, 2 * sh, sw, sh, x1, y1 + h - sh, 1, 1, 0, color, color, color, color, alpha);
        
        var hxscale = (w - 2 * sw) / sw;
        var vyscale = (h - 2 * sh) / sh;
        
        draw_sprite_general(sprite_nineslice, index, sw, 0, sw, sh, x1 + sw, y1, hxscale, 1, 0, color, color, color, color, alpha);
        draw_sprite_general(sprite_nineslice, index, sw, sh * 2, sw, sh, x1 + sw, y1 + h - sh, hxscale, 1, 0, color, color, color, color, alpha);
        draw_sprite_general(sprite_nineslice, index, 0, sh, sw, sh, x1, y1 + sh, 1, vyscale, 0, color, color, color, color, alpha);
        draw_sprite_general(sprite_nineslice, index, 2 * sw, sh, sw, sh, x1 + w - sw, y1 + sh, 1, vyscale, 0, color, color, color, color, alpha);
        draw_sprite_general(sprite_nineslice, index, sw, sh, sw, sh, x1 + sw, y1 + sh, hxscale, vyscale, 0, color, color, color, color, alpha);
    }
    
    IsActiveDialog = function() {
        var top = global.__vanadium_dialogs[| ds_list_size(global.__vanadium_dialogs) - 1];
        return !top || (top == root);
    }
    
    IsActiveElement = function() {
        return global.__vanadium_active_element == self;
    }
    
    GetInteractive = function() {
        return interactive && IsActiveDialog();
    }
    
    GetMousePressed = function(x1, y1, x2, y2) {
        return GetInteractive() && point_in_rectangle(window_mouse_get_x(), window_mouse_get_y(), x1, y1, x2, y2) && mouse_check_button_pressed(mb_left);
    }
    
    GetMouseReleased = function(x1, y1, x2, y2) {
        return GetInteractive() && point_in_rectangle(window_mouse_get_x(), window_mouse_get_y(), x1, y1, x2, y2) && mouse_check_button_released(mb_left);
    }
    
    GetMouseHold = function(x1, y1, x2, y2) {
        return GetInteractive() && point_in_rectangle(window_mouse_get_x(), window_mouse_get_y(), x1, y1, x2, y2) && mouse_check_button(mb_left);
    }
    
    GetMouseHover = function(x1, y1, x2, y2) {
        return GetInteractive() && point_in_rectangle(window_mouse_get_x(), window_mouse_get_y(), x1, y1, x2, y2);
    }
}

function VCallback(_x, _y, _w, _h, _value, _callback) : VCore(_x, _y, _w, _h) constructor {
    SetCallback = function(_callback) {
        callback = method(self, _callback);
    }
    
    SetCallback(_callback);
    value = _value;
}