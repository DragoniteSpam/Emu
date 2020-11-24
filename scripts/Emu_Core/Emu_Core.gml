// Emu (c) 2020 @dragonitespam
// See the Github wiki for documentation: https://github.com/DragoniteSpam/Emu/wiki
function EmuCore(x, y, w, h) constructor {
    self.x = x;
    self.y = y;
    self.width = w;
    self.height = h;
    self.root = undefined;
    
    self.enabled = true;
    self.interactive = true;
    self.outline = true;             // not used in all element types
    self.tooltip = "";               // not used by all element types
    self.color = EMU_COLOR_DEFAULT;
    
    self.active_element = noone;
    
    self.text = "core";
    self.offset = 12;
    
    self.alignment = fa_left;
    self.valignment = fa_middle;
    self.sprite_nineslice = spr_emu_nineslice;
    self.sprite_checkers = spr_emu_checker;
    
    self._contents = ds_list_create();
    
    self._override_escape = false;
    self._override_tab = false;
    
    self._next = noone;
    self._previous = noone;
    self._element_spacing_y = 16;
    
    AddContent = function(elements) {
        if (!is_array(elements)) {
            elements = [elements];
        }
        for (var i = 0; i < array_length(elements); i++) {
            var thing = elements[i];
            if (thing.y == undefined) {
                var top = _contents[| ds_list_size(_contents) - 1];
                if (top) {
                    thing.y = top.y + top.GetHeight() + _element_spacing_y;
                } else {
                    thing.y = _element_spacing_y;
                }
            }
            ds_list_add(_contents, thing);
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
        _next = _element;
        if (_next) _next._previous = self;
    }
    
    SetPrevious = function(_element) {
        _previous = _element;
        if (_previous) _previous._next = self;
    }
    
    RemoveContent = function(elements) {
        if (!is_array(elements)) {
            elements = [elements];
        }
        for (var i = 0; i < array_length(elements); i++) {
            var thing = elements[i];
            ds_list_delete(_contents, ds_list_find_index(_contents, thing));
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
        for (var i = 0; i < ds_list_size(_contents); i++) {
            if (_contents[| i]) _contents[| i].Render(at_x, at_y);
        }
    }
    
    processAdvancement = function() {
        if (!isActiveElement()) return false;
        if (!_override_tab && keyboard_check_pressed(vk_tab)) {
            if (keyboard_check(vk_shift) && _previous) {
                _previous.Activate();
                keyboard_clear(vk_tab);
                return true;
            }
            if (_next) {
                _next.Activate();
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
        for (var i = 0; i < ds_list_size(_contents); i++) {
            _contents[| i].Destroy();
        }
        ds_list_destroy(_contents);
    }
    
    ShowTooltip = function() {
        // The implementation of this is up to you - but you probably want to
        // assign the element's "tooltip" text to be drawn on the UI somewhere
    }
    
    drawNineslice = function(_index, x1, y1, x2, y2, color, alpha) {
        color = (color != undefined) ? color : c_white;
        alpha = (alpha != undefined) ? alpha : 1;
        var w = x2 - x1;
        var h = y2 - y1;
        var sw = sprite_get_width(sprite_nineslice) / 3;
        var sh = sprite_get_height(sprite_nineslice) / 3;
        
        draw_sprite_general(sprite_nineslice, _index, 0, 0, sw, sh, x1, y1, 1, 1, 0, color, color, color, color, alpha);
        draw_sprite_general(sprite_nineslice, _index, 2 * sw, 0, sw, sh, x1 + w - sw, y1, 1, 1, 0, color, color, color, color, alpha);
        draw_sprite_general(sprite_nineslice, _index, 2 * sw, 2 * sh, sw, sh, x1 + w - sw, y1 + h - sh, 1, 1, 0, color, color, color, color, alpha);
        draw_sprite_general(sprite_nineslice, _index, 0, 2 * sh, sw, sh, x1, y1 + h - sh, 1, 1, 0, color, color, color, color, alpha);
        
        var hxscale = (w - 2 * sw) / sw;
        var vyscale = (h - 2 * sh) / sh;
        
        draw_sprite_general(sprite_nineslice, _index, sw, 0, sw, sh, x1 + sw, y1, hxscale, 1, 0, color, color, color, color, alpha);
        draw_sprite_general(sprite_nineslice, _index, sw, sh * 2, sw, sh, x1 + sw, y1 + h - sh, hxscale, 1, 0, color, color, color, color, alpha);
        draw_sprite_general(sprite_nineslice, _index, 0, sh, sw, sh, x1, y1 + sh, 1, vyscale, 0, color, color, color, color, alpha);
        draw_sprite_general(sprite_nineslice, _index, 2 * sw, sh, sw, sh, x1 + w - sw, y1 + sh, 1, vyscale, 0, color, color, color, color, alpha);
        draw_sprite_general(sprite_nineslice, _index, sw, sh, sw, sh, x1 + sw, y1 + sh, hxscale, vyscale, 0, color, color, color, color, alpha);
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
        var top = EmuOverlay._contents[| ds_list_size(EmuOverlay._contents) - 1];
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

function EmuCallback(x, y, w, h, value, callback) : EmuCore(x, y, w, h) constructor {
    SetCallback = function(callback) {
        self.callback = method(self, callback);
    }
    
    SetCallbackMiddle = function(callback) {
        self.callback_middle = method(self, callback);
    }
    
    SetCallbackRight = function(callback) {
        self.callback_right = method(self, callback);
    }
    
    SetCallbackDouble = function(callback) {
        self.callback_double = method(self, callback);
    }
    
    SetValue = function(value) {
        self.value = value;
    }
    
    SetCallback(callback);
    SetValue(value);
    
    SetCallbackMiddle(emu_null);
    SetCallbackRight(emu_null);
    SetCallbackDouble(emu_null);
}

function emu_null() { }