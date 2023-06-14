// Emu (c) 2020 @dragonitespam
// See the Github wiki for documentation: https://github.com/DragoniteSpam/Documentation/wiki/Emu

// feather use syntax-errors
function EmuCore(x, y, width, height, text = "") constructor {
    /// @ignore
    self.x = x;
    /// @ignore
    self.y = y;
    /// @ignore
    self.width = width;
    /// @ignore
    self.height = height;
    /// @ignore
    self.root = undefined;
    /// @ignore
    self.identifier = "";
    /// @ignore
    self.child_ids = { };
    /// @ignore
    self.use_surface_depth = false;
    
    /// @ignore
    self.enabled = true;
    /// @ignore
    self.interactive = true;
    /// @ignore
    self.outline = true;             // not used in all element types
    /// @ignore
    self.tooltip = "";               // not used by all element types
    /// @ignore
    self.color = function() { return EMU_COLOR_DEFAULT; };
    
    /// @ignore
    self.active_element = noone;
    
    /// @ignore
    self.text = text;
    /// @ignore
    self.offset = 12;
    
    /// @ignore
    self.align = {
        h: fa_left,
        v: fa_middle,
    };
    
    /// @ignore
    self.sprite_nineslice = spr_emu_nineslice;
    /// @ignore
    self.sprite_checkers = EMU_SPRITE_CHECKERS;
    
    /// @ignore
    self.contents = [];
    
    /// @ignore
    self.override_escape = false;
    /// @ignore
    self.override_tab = false;
    /// @ignore
    self.override_root_check = false;
    
    /// @ignore
    self.next = noone;
    /// @ignore
    self.previous = noone;
    /// @ignore
    self.element_spacing_x = 32;
    /// @ignore
    self.element_spacing_y = 16;
    
    /// @ignore
    self.time_click_left = -1;
    /// @ignore
    self.time_click_left_last = -10000;
    
    self.update_script = function() { };
    
    self.refresh_script = function(data) { };
    
    #region mutators
    self.SetUpdate = function(f) {
        self.update_script = method(self, f);
        return self;
    };
    
    self.SetRefresh = function(f) {
        self.refresh_script = method(self, f);
        return self;
    };
    
    self.SetText = function(text) {
        self.text = text;
        return self;
    };
    
    self.SetAlign = function(h, v) {
        self.align.h = h;
        self.align.v = v;
        return self;
    };
    
    self.SetInteractive = function(interactive) {
        self.interactive = interactive;
        return self;
    };
    
    self.SetEnabled = function(enabled) {
        self.enabled = enabled;
        return self;
    };
    
    self.SetTooltip = function(text) {
        self.tooltip = text;
        return self;
    };
    
    self.SetSpriteNineslice = function(sprite) {
        self.sprite_nineslice = sprite;
        return self;
    };
    
    self.SetSpriteCheckers = function(sprite) {
        self.sprite_checkers = sprite;
        return self;
    };
    
    self.SetNext = function(element) {
        self.next = element;
        if (is_struct(self.next)) self.next.previous = self;
        return self;
    };
    
    self.SetPrevious = function(element) {
        self.previous = element;
        if (is_struct(self.previous)) self.previous.next = self;
        return self;
    };
    
    self.SetID = function(identifier) {
        identifier = string(identifier);
        if (self.root) {
            if (self.root.child_ids[$ self.identifier] == self) {
                variable_struct_remove(self.root.child_ids, self.identifier);
            }
            if (identifier != "") {
                self.root.child_ids[$ identifier] = self;
            }
        }
        self.identifier = identifier;
        return self;
    };
    #endregion
    
    #region accessors
    self.GetHeight = function() {
        return self.height;
    };
    
    self.GetInteractive = function() {
        return self.enabled && self.interactive && self.isActiveDialog();
    };
    
    self.GetTop = function() {
        if (array_length(self.contents) == 0) return undefined;
        return self.contents[array_length(self.contents) - 1];
    };
    
    self.GetMouseOver = function() {
        return point_in_rectangle(self.getMousePositionX(), self.getMousePositionY(), self.x, self.y, self.x + self.width, self.y + self.height);
    };
    
    self.GetChild = function(identifier) {
        identifier = string(identifier);
        return self.child_ids[$ identifier];
    };
    
    self.GetSibling = function(identifier) {
        if (!self.root) return undefined;
        return self.root.GetChild(identifier);
    };
    #endregion
    
    #region other public methods
    self.AddContent = function(elements) {
        if (!is_array(elements)) {
            elements = [elements];
        }
        for (var i = 0; i < array_length(elements); i++) {
            var thing = elements[i];
            thing.root = self;
            
            if (is_ptr(thing.y) && thing.y == EMU_AUTO) {
                var top = self.GetTop();
                if (top) {
                    thing.y = top.y + top.GetHeight() + thing.element_spacing_y;
                } else {
                    thing.y = thing.element_spacing_y;
                }
            } else if (is_ptr(thing.y) && thing.y == EMU_AUTO_NO_SPACING) {
                var top = self.GetTop();
                if (top) {
                    thing.y = top.y + top.GetHeight();
                } else {
                    thing.y = thing.element_spacing_y;
                }
            } else if (is_ptr(thing.y) && thing.y == EMU_INLINE) {
                var top = self.GetTop();
                if (top) {
                    thing.y = top.y;
                } else {
                    thing.y = thing.element_spacing_y;
                }
            } else if (is_ptr(thing.y) && thing.y == EMU_BASE) {
                thing.y = thing.element_spacing_y;
            }
            
            if (thing.identifier != "") {
                self.child_ids[$ thing.identifier] = thing;
            }
            
            array_push(self.contents, thing);
            
        }
        return self;
    };
    
    self.RemoveContent = function(elements) {
        if (!is_array(elements)) {
            elements = [elements];
        }
        for (var i = array_length(elements) - 1; i >= 0; i--) {
            var thing = elements[i];
            array_delete(self.contents, array_get_index(self.contents, thing), 1);
            if (self.child_ids[$ thing.identifier] == thing) {
                variable_struct_remove(self.child_ids, thing.identifier);
            }
        }
        _emu_active_element(pointer_null);
        return self;
    };
    
    static ClearContent = function() {
        if (self.isActiveElement()) _emu_active_element(undefined);
        for (var i = 0, n = array_length(self.contents); i < n; i++) {
            self.contents[i].Destroy();
        }
        self.contents = [];
    };
    
    self.Render = function(base_x = 0, base_y = 0, debug_render = false) {
        self.update_script();
        self.processAdvancement();
        self.renderContents(self.x + base_x, self.y + base_y, debug_render);
        return self;
    };
    
    self.ShowTooltip = function() {
        // The implementation of this is up to you - but you probably want to
        // assign the element's "tooltip" text to be drawn on the UI somewhere
        return self;
    };
    
    self.Activate = function() {
        _emu_active_element(self);
        return self;
    };
    
    self.Refresh = function(data) {
        self.refresh_script(data);
        for (var i = 0, n = array_length(self.contents); i < n; i++) {
            self.contents[i].Refresh(data);
        }
        return self;
    };
    
    self.GetBaseElement = function() {
        var element = self;
        while (true) {
            if (!element.root) return element;
            element = element.root;
        }
        // this will never happen
        return undefined;
    };
    #endregion
    
    #region private methods
    /// @ignore
    self.getTextX = function(x) {
        switch (self.align.h) {
            case fa_left: return x + self.offset;
            case fa_center: return x + self.width / 2;
            case fa_right: return x + self.width - self.offset;
        }
    };
    
    /// @ignore
    self.getTextY = function(y) {
        switch (self.align.v) {
            case fa_top: return y + self.offset;
            case fa_middle: return y + self.height / 2;
            case fa_bottom: return y + self.height - self.offset;
        }
    };
    
    /// @ignore
    self.renderContents = function(at_x, at_y, debug_render = false) {
        for (var i = 0, n = array_length(self.contents); i < n; i++) {
            if (self.contents[i] && self.contents[i].enabled) self.contents[i].Render(at_x, at_y, debug_render);
        }
    };
    
    /// @ignore
    self.renderDebugBounds = function(x1, y1, x2, y2) {
        // gamemaker
        x2--;
        y2--;
        draw_rectangle_colour(x1, y1, x2, y2, c_red, c_red, c_red, c_red, true);
        draw_set_alpha(0.25);
        draw_line_colour(x1, y1, x2, y2, c_red, c_red);
        draw_line_colour(x2, y1, x1, y2, c_red, c_red);
        draw_set_alpha(1); 
    };
    
    /// @ignore
    self.processAdvancement = function() {
        if (!self.isActiveElement()) return false;
        if (!self.override_tab && keyboard_check_pressed(vk_tab)) {
            if (keyboard_check(vk_shift) && self.previous != undefined) {
                if (is_struct(self.previous))
                    self.previous.Activate();
                else if (self.GetSibling(self.previous))
                    self.GetSibling(self.previous).Activate();
                keyboard_clear(vk_tab);
                return true;
            }
            if (self.next != undefined) {
                if (is_struct(self.next))
                    self.next.Activate();
                else if (self.GetSibling(self.next))
                    self.GetSibling(self.next).Activate();
                keyboard_clear(vk_tab);
                return true;
            }
        }
    }
    
    /// @ignore
    self.drawCheckerbox = function(x = 0, y = 0, w = self.width - 1, h = self.height - 1, xscale = 1, yscale = 1, color = c_white, alpha = 1) {
        var old_repeat = gpu_get_texrepeat();
        gpu_set_texrepeat(true);
        var s = sprite_get_width(self.sprite_checkers);
        var xcount = w / s / xscale;
        var ycount = h / s / yscale;
        
        draw_primitive_begin_texture(pr_trianglelist, sprite_get_texture(self.sprite_checkers, 0));
        draw_vertex_texture_colour(x, y, 0, 0, color, alpha);
        draw_vertex_texture_colour(x + w, y, xcount, 0, color, alpha);
        draw_vertex_texture_colour(x + w, y + h, xcount, ycount, color, alpha);
        draw_vertex_texture_colour(x + w, y + h, xcount, ycount, color, alpha);
        draw_vertex_texture_colour(x, y + h, 0, ycount, color, alpha);
        draw_vertex_texture_colour(x, y, 0, 0, color, alpha);
        draw_primitive_end();
        
        gpu_set_texrepeat(old_repeat);
    };
    
    /// @ignore
    self.isActiveDialog = function() {
        var top = EmuOverlay.GetTop();
        if (!top) return true;
        
        var root = self.root;
        
        while (root && root.override_root_check) {
            root = root.root;
        }
        
        return (top == root);
    };
    
    /// @ignore
    self.isActiveElement = function() {
        return (EmuActiveElement == self) && (self.isActiveDialog());
    };
    #endregion
    
    #region cursor detection methods
    self.getMousePositionX = function() {
        return device_mouse_x_to_gui(0);
    };
    
    self.getMousePositionY = function() {
        return device_mouse_y_to_gui(0);
    };
    
    self.getMouseHover = function(x1, y1, x2, y2) {
        return self.GetInteractive() && point_in_rectangle(self.getMousePositionX(), self.getMousePositionY(), x1, y1, x2 - 1, y2 - 1);
    };
    
    self.getMousePressed = function(x1, y1, x2, y2) {
        var click = (self.getMouseHover(x1, y1, x2, y2) && device_mouse_check_button_pressed(0, mb_left)) || (self.isActiveElement() && keyboard_check_pressed(vk_space));
        // In the event that clicking is polled more than once per frame, don't
        // register two clicks per frame
        if (click && self.time_click_left != current_time) {
            self.time_click_left_last = self.time_click_left;
            self.time_click_left = current_time;
        }
        return click;
    };
    
    self.getMouseDouble = function(x1, y1, x2, y2) {
        return self.getMousePressed(x1, y1, x2, y2) && (current_time - self.time_click_left_last < EMU_TIME_DOUBLE_CLICK_THRESHOLD);
    };
    
    self.getMouseHold = function(x1, y1, x2, y2) {
        return (self.getMouseHover(x1, y1, x2, y2) && device_mouse_check_button(0, mb_left)) || (self.isActiveElement() && keyboard_check(vk_space));
    };
    
    self.getMouseHoldDuration = function(x1, y1, x2, y2) {
        return self.getMouseHold(x1, y1, x2, y2) ? (current_time - self.time_click_left) : 0;
    };
    
    self.getMouseReleased = function(x1, y1, x2, y2) {
        return (self.getMouseHover(x1, y1, x2, y2) && device_mouse_check_button_released(0, mb_left)) || (self.isActiveElement() && keyboard_check_released(vk_space));
    };
    
    self.getMouseMiddlePressed = function(x1, y1, x2, y2) {
        return self.getMouseHover(x1, y1, x2, y2) && device_mouse_check_button_pressed(0, mb_middle);
    };
    
    self.getMouseMiddleReleased = function(x1, y1, x2, y2) {
        return self.getMouseHover(x1, y1, x2, y2) && device_mouse_check_button_released(0, mb_middle);
    };
    
    self.GetMouseRightPressed = function(x1, y1, x2, y2) {
        return self.getMouseHover(x1, y1, x2, y2) && device_mouse_check_button_pressed(0, mb_right);
    };
    
    self.getMouseRightReleased = function(x1, y1, x2, y2) {
        return self.getMouseHover(x1, y1, x2, y2) && device_mouse_check_button_released(0, mb_right);
    };
    #endregion
    
    #region garbage collector stuff
    /// @ignore
    self.surfaceVerify = function(surface, width, height) {
        width = floor(width);
        height = floor(height);
        
        static gc_ref = function(ref, surface) constructor {
            self.ref = ref;
            self.surface = surface;
            
            static Clean = function() {
                if (surface_exists(self.surface)) surface_free(self.surface);
            };
        };
        var depth_state = surface_get_depth_disable();
        if (!surface_exists(surface)) {
            surface_depth_disable(!self.use_surface_depth);
            var ref = new gc_ref(weak_ref_create(self), surface_create(width, height));
            surface_depth_disable(depth_state);
            gc[$ string(ptr(ref))] = ref;
            return { surface: ref.surface, changed: true };
        }
        if (surface_get_width(surface) != width || surface_get_height(surface) != height) {
            surface_free(surface);
            surface_depth_disable(!self.use_surface_depth);
            var ref = new gc_ref(weak_ref_create(self), surface_create(width, height));
            surface_depth_disable(depth_state);
            gc[$ string(ptr(ref))] = ref;
            return { surface: ref.surface, changed: true };
        }
        return { surface: surface, changed: false };
    };
    
    /// @ignore
    static gc = new (function() constructor {
        self.frequency = 5;                 // seconds between cleanings
        self.batch_size = 10;               // items per cleanings
        
        self.refs = { };
        
        self.timer = call_later(self.frequency, time_source_units_seconds, function() {
            var cleaned = 0;
            var keys = variable_struct_get_names(self.refs);
            for (var i = 0, n = array_length(keys); i < n; i++) {
                var ref = self.refs[$ keys[i]];
                if (!weak_ref_alive(ref.ref)) {
                    ref.Clean();
                    variable_struct_remove(self.refs, keys[i]);
                    if (++cleaned >= self.batch_size) break;
                }
            }
        }, true);
    })();
    #endregion
    
    self.DroppedFileHandler = function(files) {
    };
    
    self.SetDroppedFileHandler = function(f) {
        self.DroppedFileHandler = method(self, f);
        return self;
    };
}

function EmuCallback(x, y, width, height, text, value, callback) : EmuCore(x, y, width, height, text) constructor {
    #region mutators
    self.SetCallback = function(callback) {
        self.callback = method(self, callback);
        return self;
    };
    
    self.SetCallbackMiddle = function(callback) {
        self.callback_middle = method(self, callback);
        return self;
    };
    
    self.SetCallbackRight = function(callback) {
        self.callback_right = method(self, callback);
        return self;
    };
    
    self.SetCallbackDouble = function(callback) {
        self.callback_double = method(self, callback);
        return self;
    };
    
    self.SetValue = function(value) {
        self.value = value;
        return self;
    };
    #endregion
    
    /// @ignore
    self.callback = undefined;
    /// @ignore
    self.callback_middle = undefined;
    /// @ignore
    self.callback_right = undefined;
    /// @ignore
    self.callback_double = undefined;
    
    self.SetCallback(callback);
    self.SetValue(value);
    
    self.SetCallbackMiddle(emu_null);
    self.SetCallbackRight(emu_null);
    self.SetCallbackDouble(emu_null);
}

function emu_null() { }