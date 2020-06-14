// Emu (c) 2020 @dragonitespam
// See the Github wiki for documentation: https://github.com/DragoniteSpam/Emu/wiki
function EmuCore(_x, _y, _w, _h) constructor {
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
    color = EMU_COLOR_DEFAULT;
    
    active_element = noone;
    
    text = "core";
    offset = 12;
    
    alignment = fa_left;
    valignment = fa_middle;
    
    override_escape = false;
    override_tab = false;
    
    next = noone;
    previous = noone;
    sprite_nineslice = spr_emu_nineslice;
    element_spacing_y = 16;
    sprite_checkers = spr_emu_checker;
    
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
    
    getTextX = function(_x) {
        switch (alignment) {
            case fa_left: return _x + offset;
            case fa_center: return _x + width / 2;
            case fa_right: return _x + width - offset;
        }
    }
    
    getTextY = function(_y) {
        switch (valignment) {
            case fa_top: return _y + offset;
            case fa_middle: return _y + height / 2;
            case fa_bottom: return _y + height - offset;
        }
    }
    
    SetInteractive = function(_interactive) {
        interactive = _interactive;
    }
    
    SetNext = function(_element) {
        next = _element;
        if (next) next.previous = self;
    }
    
    SetPrevious = function(_element) {
        previous = _element;
        if (previous) previous.next = self;
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
        if (base_x == undefined) base_x = 0;
        if (base_y == undefined) base_y = 0;
        processAdvancement();
        renderContents(x + base_x, y + base_y);
    }
    
    renderContents = function(at_x, at_y) {
        for (var i = 0; i < ds_list_size(contents); i++) {
            if (contents[| i]) contents[| i].Render(at_x, at_y);
        }
    }
    
    processAdvancement = function() {
        if (!isActiveElement()) return false;
        if (!override_tab && keyboard_check_pressed(vk_tab)) {
            if (keyboard_check(vk_shift) && previous) {
                previous.Activate();
                keyboard_clear(vk_tab);
                return true;
            }
            if (next) {
                next.Activate();
                keyboard_clear(vk_tab);
                return true;
            }
        }
    }
    
    Destroy = function() {
        destroyContent();
    }
    
    destroyContent = function() {
        if (isActiveElement()) _emu_active_element(undefined);
        for (var i = 0; i < ds_list_size(contents); i++) {
            contents[| i].Destroy();
        }
    }
    
    ShowTooltip = function() {
        // The implementation of this is up to you - but you probably want to
        // assign the element's "tooltip" text to be drawn on the UI somewhere
    }
    
    drawNineslice = function(index, x1, y1, x2, y2, color, alpha) {
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
    
    drawCheckerbox = function(_x, _y, _w, _h, _xscale, _yscale, _color, _alpha) {
        if (_xscale == undefined) _xscale = 1;
        if (_yscale == undefined) _yscale = 1;
        if (_color == undefined) _color = c_white;
        if (_alpha == undefined) _alpha = 1;
        
        var old_repeat = gpu_get_texrepeat();
        gpu_set_texrepeat(true);
        var _s = sprite_get_width(sprite_checkers);
        var _xcount = _w / _s / _xscale;
        var _ycount = _h / _s / _yscale;
        
        draw_primitive_begin_texture(pr_trianglelist, sprite_get_texture(sprite_checkers, 0));
        draw_vertex_texture_colour(_x, _y, 0, 0, _color, _alpha);
        draw_vertex_texture_colour(_x + _w, _y, _xcount, 0, _color, _alpha);
        draw_vertex_texture_colour(_x + _w, _y + _h, _xcount, _ycount, _color, _alpha);
        draw_vertex_texture_colour(_x + _w, _y + _h, _xcount, _ycount, _color, _alpha);
        draw_vertex_texture_colour(_x, _y + _h, 0, _ycount, _color, _alpha);
        draw_vertex_texture_colour(_x, _y, 0, 0, _color, _alpha);
        draw_primitive_end();
        
        gpu_set_texrepeat(old_repeat);
    }
    
    isActiveDialog = function() {
        var top = EmuOverlay.contents[| ds_list_size(EmuOverlay.contents) - 1];
        return !top || (top == root);
    }
    
    isActiveElement = function() {
        return EmuActiveElement == self;
    }
    
    Activate = function() {
        _emu_active_element(self);
    }
    
    time_click_left = -1;
    time_click_left_last = -10000;
    
    GetInteractive = function() {
        return enabled && interactive && isActiveDialog();
    }
    
    getMouseHover = function(x1, y1, x2, y2) {
        return GetInteractive() && point_in_rectangle(window_mouse_get_x(), window_mouse_get_y(), x1, y1, x2 - 1, y2 - 1);
    }
    
    getMousePressed = function(x1, y1, x2, y2) {
        var click = (getMouseHover(x1, y1, x2, y2) && mouse_check_button_pressed(mb_left)) || (isActiveElement() && keyboard_check_pressed(vk_space));
        // In the event that clicking is polled more than once per frame, don't
        // register two clicks per frame
        if (click && time_click_left != current_time) {
            time_click_left_last = time_click_left;
            time_click_left = current_time;
        }
        return click;
    }
    
    getMouseDouble = function(x1, y1, x2, y2) {
        return getMousePressed(x1, y1, x2, y2) && (current_time - time_click_left_last < EMU_TIME_DOUBLE_CLICK_THRESHOLD);
    }
    
    getMouseHold = function(x1, y1, x2, y2) {
        return (getMouseHover(x1, y1, x2, y2) && mouse_check_button(mb_left)) || (isActiveElement() && keyboard_check(vk_space));
    }
    
    getMouseHoldDuration = function(x1, y1, x2, y2) {
        return getMouseHold(x1, y1, x2, y2) ? (current_time - time_click_left) : 0;
    }
    
    getMouseReleased = function(x1, y1, x2, y2) {
        return (getMouseHover(x1, y1, x2, y2) && mouse_check_button_released(mb_left)) || (isActiveElement() && keyboard_check_released(vk_space));
    }
    
    getMouseMiddlePressed = function(x1, y1, x2, y2) {
        return getMouseHover(x1, y1, x2, y2) && mouse_check_button_pressed(mb_middle);
    }
    
    getMouseMiddleReleased = function(x1, y1, x2, y2) {
        return getMouseHover(x1, y1, x2, y2) && mouse_check_button_released(mb_middle);
    }
    
    GetMouseRightPressed = function(x1, y1, x2, y2) {
        return getMouseHover(x1, y1, x2, y2) && mouse_check_button_pressed(mb_right);
    }
    
    getMouseRightReleased = function(x1, y1, x2, y2) {
        return getMouseHover(x1, y1, x2, y2) && mouse_check_button_released(mb_right);
    }
}

function EmuCallback(_x, _y, _w, _h, _value, _callback) : EmuCore(_x, _y, _w, _h) constructor {
    SetCallback = function(_callback) {
        callback = method(self, _callback);
    }
    
    setCallbackMiddle = function(_callback) {
        callback_middle = method(self, _callback);
    }
    
    setCallbackRight = function(_callback) {
        callback_right = method(self, _callback);
    }
    
    setCallbackDouble = function(_callback) {
        callback_double = method(self, _callback);
    }
    
    SetValue = function(_value) {
        value = _value;
    }
    
    SetCallback(_callback);
    SetValue(_value);
    
    setCallbackMiddle(emu_null);
    setCallbackRight(emu_null);
    setCallbackDouble(emu_null);
}

function emu_null() {
    
}