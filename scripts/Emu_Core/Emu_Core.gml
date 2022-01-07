// Emu (c) 2020 @dragonitespam
// See the Github wiki for documentation: https://github.com/DragoniteSpam/Documentation/wiki/Emu
function EmuCore(x, y, w, h, text = "") constructor {
    /// @ignore
    self.x = x;
    /// @ignore
    self.y = y;
    /// @ignore
    self.width = w;
    /// @ignore
    self.height = h;
    /// @ignore
    self.root = undefined;
    /// @ignore
    self.identifier = "";
    /// @ignore
    self.child_ids = { };
    
    /// @ignore
    self.enabled = true;
    /// @ignore
    self.interactive = true;
    /// @ignore
    self.outline = true;             // not used in all element types
    /// @ignore
    self.tooltip = "";               // not used by all element types
    /// @ignore
    self.color = function() { return EMU_COLOR_DEFAULT };
    
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
    self.sprite_checkers = spr_emu_checker;
    
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
    
    #region mutators
    static SetText = function(text) {
        self.text = text;
        return self;
    };
    
    static SetAlign = function(h, v) {
        self.align.h = h;
        self.align.v = v;
        return self;
    };
    
    static SetInteractive = function(interactive) {
        self.interactive = interactive;
        return self;
    };
    
    static SetEnabled = function(enabled) {
        self.enabled = enabled;
        return self;
    };
    
    static SetTooltip = function(text) {
        self.tooltip = text;
        return self;
    };
    
    static SetSpriteNineslice = function(sprite) {
        self.sprite_nineslice = sprite;
        return self;
    };
    
    static SetSpriteCheckers = function(sprite) {
        self.sprite_checkers = sprite;
        return self;
    };
    
    static SetNext = function(element) {
        self.next = element;
        if (self.next) self.next.previous = self;
        return self;
    };
    
    static SetPrevious = function(element) {
        self.previous = element;
        if (self.previous) self.previous.next = self;
        return self;
    };
    
    static SetID = function(identifier) {
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
    static GetHeight = function() {
        return self.height;
    };
    
    static GetInteractive = function() {
        return self.enabled && self.interactive && self.isActiveDialog();
    };
    
    static GetTop = function() {
        if (array_length(self.contents) == 0) return undefined;
        return self.contents[array_length(self.contents) - 1];
    };
    
    static GetMouseOver = function() {
        return point_in_rectangle(device_mouse_x_to_gui(0), device_mouse_y_to_gui(0), self.x, self.y, self.x + self.width, self.y + self.height);
    };
    
    static GetChild = function(identifier) {
        identifier = string(identifier);
        return self.child_ids[$ identifier];
    };
    
    static GetSibling = function(identifier) {
        if (!self.root) return undefined;
        return self.root.GetChild(identifier);
    };
    #endregion
    
    #region other public methods
    static AddContent = function(elements) {
        if (!is_array(elements)) {
            elements = [elements];
        }
        for (var i = 0; i < array_length(elements); i++) {
            var thing = elements[i];
            thing.root = self;
            
            if (thing.y == EMU_AUTO) {
                var top = self.GetTop();
                if (top) {
                    thing.y = top.y + top.GetHeight() + self.element_spacing_y;
                } else {
                    thing.y = self.element_spacing_y;
                }
            } else if (thing.y == EMU_INLINE) {
                var top = self.GetTop();
                if (top) {
                    thing.y = top.y;
                } else {
                    thing.y = self.element_spacing_y;
                }
            } else if (thing.y == EMU_BASE) {
                thing.y = self.element_spacing_y;
            }
            
            if (thing.identifier != "") {
                self.child_ids[$ thing.identifier] = thing;
            }
            
            array_push(self.contents, thing);
            
        }
        return self;
    };
    
    static RemoveContent = function(elements) {
        if (!is_array(elements)) {
            elements = [elements];
        }
        for (var i = 0; i < array_length(elements); i++) {
            var thing = elements[i];
            array_delete(self.contents, emu_array_search(self.contents, thing), 1);
            if (self.child_ids[$ thing.identifier] == thing) {
                variable_struct_remove(self.child_ids, thing.identifier);
            }
        }
        _emu_active_element(pointer_null);
        return self;
    };
    
    static Render = function(base_x = 0, base_y = 0) {
        self.gc.Clean();
        self.processAdvancement();
        self.renderContents(self.x + base_x, self.y + base_y);
        return self;
    };
    
    static ShowTooltip = function() {
        // The implementation of this is up to you - but you probably want to
        // assign the element's "tooltip" text to be drawn on the UI somewhere
        return self;
    };
    
    static Activate = function() {
        _emu_active_element(self);
        return self;
    };
    #endregion
    
    #region private methods
    /// @ignore
    static getTextX = function(x) {
        switch (self.align.h) {
            case fa_left: return x + self.offset;
            case fa_center: return x + self.width / 2;
            case fa_right: return x + self.width - self.offset;
        }
    };
    
    /// @ignore
    static getTextY = function(y) {
        switch (self.align.v) {
            case fa_top: return y + self.offset;
            case fa_middle: return y + self.height / 2;
            case fa_bottom: return y + self.height - self.offset;
        }
    };
    
    /// @ignore
    static renderContents = function(at_x, at_y) {
        for (var i = 0, n = array_length(self.contents); i < n; i++) {
            if (self.contents[i]) self.contents[i].Render(at_x, at_y);
        }
    };
    
    /// @ignore
    static processAdvancement = function() {
        if (!self.isActiveElement()) return false;
        if (!self.override_tab && keyboard_check_pressed(vk_tab)) {
            if (keyboard_check(vk_shift) && self.previous) {
                self.previous.Activate();
                keyboard_clear(vk_tab);
                return true;
            }
            if (self.next) {
                self.next.Activate();
                keyboard_clear(vk_tab);
                return true;
            }
        }
    };
    
    /// @ignore
    static drawCheckerbox = function(x, y, w, h, xscale = 1, yscale = 1, color = c_white, alpha = 1) {
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
    static isActiveDialog = function() {
        var top = EmuOverlay.GetTop();
        if (!top) return true;
        
        var root = self.root;
        
        while (root && root.override_root_check) {
            root = root.root;
        }
        
        return (top == root);
    };
    
    /// @ignore
    static isActiveElement = function() {
        return EmuActiveElement == self;
    };
    #endregion
    
    #region cursor detection methods
    static getMouseHover = function(x1, y1, x2, y2) {
        return self.GetInteractive() && point_in_rectangle(device_mouse_x_to_gui(0), device_mouse_y_to_gui(0), x1, y1, x2 - 1, y2 - 1);
    };
    
    static getMousePressed = function(x1, y1, x2, y2) {
        var click = (self.getMouseHover(x1, y1, x2, y2) && device_mouse_check_button_pressed(0, mb_left)) || (self.isActiveElement() && keyboard_check_pressed(vk_space));
        // In the event that clicking is polled more than once per frame, don't
        // register two clicks per frame
        if (click && self.time_click_left != current_time) {
            self.time_click_left_last = self.time_click_left;
            self.time_click_left = current_time;
        }
        return click;
    };
    
    static getMouseDouble = function(x1, y1, x2, y2) {
        return self.getMousePressed(x1, y1, x2, y2) && (current_time - self.time_click_left_last < EMU_TIME_DOUBLE_CLICK_THRESHOLD);
    };
    
    static getMouseHold = function(x1, y1, x2, y2) {
        return (self.getMouseHover(x1, y1, x2, y2) && device_mouse_check_button(0, mb_left)) || (self.isActiveElement() && keyboard_check(vk_space));
    };
    
    static getMouseHoldDuration = function(x1, y1, x2, y2) {
        return self.getMouseHold(x1, y1, x2, y2) ? (current_time - self.time_click_left) : 0;
    };
    
    static getMouseReleased = function(x1, y1, x2, y2) {
        return (self.getMouseHover(x1, y1, x2, y2) && device_mouse_check_button_released(0, mb_left)) || (self.isActiveElement() && keyboard_check_released(vk_space));
    };
    
    static getMouseMiddlePressed = function(x1, y1, x2, y2) {
        return self.getMouseHover(x1, y1, x2, y2) && device_mouse_check_button_pressed(0, mb_middle);
    };
    
    static getMouseMiddleReleased = function(x1, y1, x2, y2) {
        return self.getMouseHover(x1, y1, x2, y2) && device_mouse_check_button_released(0, mb_middle);
    };
    
    static GetMouseRightPressed = function(x1, y1, x2, y2) {
        return self.getMouseHover(x1, y1, x2, y2) && device_mouse_check_button_pressed(0, mb_right);
    };
    
    static getMouseRightReleased = function(x1, y1, x2, y2) {
        return self.getMouseHover(x1, y1, x2, y2) && device_mouse_check_button_released(0, mb_right);
    };
    #endregion
    
    #region garbage collector stuff
    /// @ignore
    static surfaceVerify = function(surface, width, height) {
        static gc_ref = function(ref, surface) constructor {
            self.ref = ref;
            self.surface = surface;
            
            static Clean = function() {
                if (surface_exists(self.surface)) surface_free(self.surface);
            };
        };
        if (!surface_exists(surface)) {
            var ref = new gc_ref(weak_ref_create(self), surface_create(width, height));
            gc[$ string(ptr(ref))] = ref;
            return { surface: ref.surface, changed: true };
        }
        if (surface_get_width(surface) != width || surface_get_height(surface) != height) {
            surface_free(surface);
            var ref = new gc_ref(weak_ref_create(self), surface_create(width, height));
            gc[$ string(ptr(ref))] = ref;
            return { surface: ref.surface, changed: true };
        }
        return { surface: surface, changed: false };
    };
    
    /// @ignore
    static gc = new (function() constructor {
        self.frequency = 500;               // ms between cleanings
        self.batch_size = 10;               // items per cleanings
        
        self.refs = { };
        
        self.last_clean_time = current_time;
        static Clean = function() {
            if (current_time < self.last_clean_time + self.frequency) return;
            self.last_clean_time = current_time;
            
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
        };
    })();
    #endregion
}

function EmuCallback(x, y, w, h, text, value, callback) : EmuCore(x, y, w, h, text) constructor {
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
    
    #region mutators
    static SetCallback = function(callback) {
        self.callback = method(self, callback);
        return self;
    };
    
    static SetCallbackMiddle = function(callback) {
        self.callback_middle = method(self, callback);
        return self;
    };
    
    static SetCallbackRight = function(callback) {
        self.callback_right = method(self, callback);
        return self;
    };
    
    static SetCallbackDouble = function(callback) {
        self.callback_double = method(self, callback);
        return self;
    };
    
    static SetValue = function(value) {
        self.value = value;
        return self;
    };
    #endregion
}

function emu_null() { }