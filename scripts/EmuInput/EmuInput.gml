// Emu (c) 2020 @dragonitespam
// See the Github wiki for documentation: https://github.com/DragoniteSpam/Documentation/wiki/Emu
function EmuInput(x, y, w, h, text, value, help_text, character_limit, input, callback) : EmuCallback(x, y, w, h, text, value, callback) constructor {
    enum E_InputTypes { STRING, INT, REAL, HEX };
    
    self.help_text = help_text;
    self.character_limit = clamp(character_limit, 1, 1000);  // keyboard_string maxes out at 1024 characters but I like to cut it off before then to be safe
    
    self.color_help_text = function() { return EMU_COLOR_HELP_TEXT };
    self.color_warn = function() { return EMU_COLOR_INPUT_WARN };
    self.color_reject = function() { return EMU_COLOR_INPUT_REJECT };
    self.color_back = function() { return EMU_COLOR_BACK };
    self.color_disabled = function() { return EMU_COLOR_DISABLED };
    self.color_selected = function() { return EMU_COLOR_SELECTED };
    self.input_font = EMU_FONT_DEFAULT;
    
    self.sprite_ring = spr_emu_ring;
    self.sprite_enter = spr_emu_enter;
    
    self.box = {
        x1: self.width / 2,
        y1: 0,
        x2: self.width,
        y2: self.height,
    };
    
    self.override_escape = true;
    self.require_enter = false;
    self.multi_line = false;
    self.value_type = input;
    self.value_lower = 0;
    self.value_upper = 100;
    
    self.surface = self.surfaceVerify(-1, self.box.x2 - self.box.x1, self.box.y2 - self.box.y1).surface;
    
    static SetMultiLine = function(multi_line) {
        self.multi_line = multi_line;
        return self;
    };
    
    static SetRequireConfirm = function(require) {
        self.require_enter = require;
        return self;
    };
    
    static SetInputBoxPosition = function(vx1, vy1, vx2, vy2) {
        self.box.x1 = vx1;
        self.box.y1 = vy1;
        self.box.x2 = vx2;
        self.box.y2 = vy2;
        return self;
    };
    
    static SetInputType = function(input_type) {
        self.value_type = input_type;
        return self;
    };
    
    static SetValue = function(value) {
        self.value = string(value);
        if (isActiveElement()) {
            keyboard_string = self.value;
        }
        return self;
    };
    
    static SetRealNumberBounds = function(lower, upper) {
        self.value_lower = min(lower, upper);
        self.value_upper = max(lower, upper);
        return self;
    };
    
    static Render = function(base_x, base_y) {
        self.gc.Clean();
        processAdvancement();
        
        var x1 = x + base_x;
        var y1 = y + base_y;
        var x2 = x1 + width;
        var y2 = y1 + height;
        var c = self.color();
        
        var vx1 = x1 + box.x1;
        var vy1 = y1 + box.y1;
        var vx2 = x1 + box.x2;
        var vy2 = y1 + box.y2;
        var ww = vx2 - vx1;
        var hh = vy2 - vy1;
        
        var tx = getTextX(x1);
        var ty = getTextY(y1);
        
        var working_value = string(self.value);
        var sw = string_width(working_value);
        var sw_end = sw + 4;
        
        #region work out the input color
        scribble(string(self.text))
            .wrap(self.width, self.height)
            .align(fa_left, fa_middle)
            .draw(tx, ty);
        
        if (ValidateInput(working_value)) {
            var cast = CastInput(working_value);
            if (is_real(cast) && clamp(cast, value_lower, value_upper) != cast) {
                c = self.color_warn();
            }
        } else {
            c = self.color_reject();
        }
        #endregion
        
        var vtx = vx1 + 12;
        var vty = floor(mean(vy1, vy2));
        var spacing = 12;
        
        #region input drawing
        self.surface = self.surfaceVerify(self.surface, ww, hh).surface;

        surface_set_target(surface);
        surface_set_target(surface);
        draw_clear(GetInteractive() ? self.color_back() : self.color_disabled());
        surface_reset_target();
        
        var display_text = working_value + (isActiveElement() && (floor((current_time * 0.00125) % 2) == 0) ? "|" : "");
        
        if (multi_line) {
            // i guess you could draw this in a single-line box too, but it would be pretty cramped
            #region the "how many characters remaining" counter
            var remaining = character_limit - string_length(working_value);
            var f = string_length(working_value) / character_limit;
            // hard limit on 99 for characters remaining
            if (f > 0.9 && remaining < 100) {
                var remaining_w = string_width(string(remaining));
                var remaining_h = string_height(string(remaining));
                var remaining_x = ww - 4 - remaining_w;
                var remaining_y = hh - remaining_h;
                scribble(string(remaining))
                    .draw(remaining_x, remaining_y);
            } else {
                var remaining_x = ww - 16;
                var remaining_y = hh - 16;
                var r = 12;
                var steps = 32;
                draw_sprite(sprite_ring, 0, remaining_x, remaining_y);
                draw_primitive_begin_texture(pr_trianglefan, sprite_get_texture(sprite_ring, 0));
                draw_vertex_texture_colour(remaining_x, remaining_y, 0.5, 0.5, self.color_selected(), 1);
                for (var i = 0; i <= steps * f; i++) {
                    var angle = 360 / steps * i - 90;
                    draw_vertex_texture_colour(
                        clamp(remaining_x + r * dcos(angle), remaining_x - r, remaining_x + r),
                        clamp(remaining_y + r * dsin(angle), remaining_y - r, remaining_y + r),
                        clamp(0.5 + 0.5 * dcos(angle), 0, 1),
                        clamp(0.5 + 0.5 * dsin(angle), 0, 1),
                    self.color_selected(), 1);
                }
                draw_primitive_end();
            }
            #endregion
            
            draw_set_halign(fa_left);
            draw_set_valign(fa_top);
            draw_set_font(input_font);
            var sh = string_height_ext(display_text, -1, vx2 - vx1 - (vtx - vx1) * 2);
            var vty = vy1 + offset;
            draw_text_ext_colour(vtx - vx1, min(vty - vy1, hh - spacing - sh), display_text, -1, vx2 - vx1 - (vtx - vx1) * 2, c, c, c, c, 1);
        } else {
            draw_set_halign(fa_left);
            draw_set_valign(fa_middle);
            draw_set_font(input_font);
            var sw_begin = min(vtx - vx1, ww - offset - sw);
            draw_text_colour(sw_begin, vty - vy1, display_text, c, c, c, c, 1);
            sw_end = sw_begin + sw + 4;
        }
        
        if (string_length(value) == 0) {
            draw_text_colour(vtx - vx1, vty - vy1, string(help_text), self.color_help_text(), self.color_help_text(), self.color_help_text(), self.color_help_text(), 1);
        }

        if (require_enter) {
            draw_sprite(sprite_enter, 0, vx2 - vx1 - sprite_get_width(sprite_enter) - 4, vty - vy1);
        }
        #endregion
        
        #region interaction
        if (GetInteractive()) {
            if (isActiveElement()) {
                var v0 = working_value;
                working_value = string_copy(keyboard_string, 1, min(string_length(keyboard_string), character_limit));
                
				// press escape to clear input
				if (keyboard_check_pressed(vk_escape)) {
                    keyboard_clear(vk_escape);
                    working_value = "";
                    keyboard_string = "";
                }
				
				// add newline on pressing enter, if allowed
                if (multi_line && !require_enter && keyboard_check_pressed(vk_enter)) {
                    working_value += "\n";
                    keyboard_string = keyboard_string + "\n";
                }
				
                if (ValidateInput(working_value)) {
                    var execute_value_change = (!require_enter && v0 != working_value) || (require_enter && keyboard_check_pressed(vk_enter));
                    if (execute_value_change) {
                        var cast = CastInput(working_value);
                        if (is_real(cast)) {
                            execute_value_change = execute_value_change && (clamp(cast, value_lower, value_upper) == cast);
                        }
						
                        if (execute_value_change) {
                            value = working_value;
                            callback();
                        }
                    }
                }
                
				keyboard_string = string_copy(working_value, 1, min(string_length(working_value), character_limit));
                value = keyboard_string;
            }
            // activation
            if (getMouseHover(vx1, vy1, vx2, vy2)) {
                if (getMouseReleased(vx1, vy1, vx2, vy2)) {
                    keyboard_string = value;
                    Activate();
                }
                ShowTooltip();
            }
        }
        
        surface_reset_target();
        #endregion
        
        draw_surface(surface, vx1, vy1)
        draw_rectangle_colour(vx1, vy1, vx2, vy2, self.color(), self.color(), self.color(), self.color(), true);
    };
    
    static ValidateInput = function(text) {
        switch (self.value_type) {
        	case E_InputTypes.STRING:
        		return true;
        	case E_InputTypes.INT:
	        	if (string_count(".", text) > 0) return false;
	        	if (string_count("e", text) > 0) return false;
	            try {
	                real(text);
	            } catch (e) {
	                return false;
	            }
        	case E_InputTypes.REAL:
	            try {
	                real(text);
	            } catch (e) {
	                return false;
	            }
            case E_InputTypes.HEX:
	            try {
	                emu_hex(text);
	            } catch (e) {
	                return false;
	            }
        }
        return true;
    };
    
    static CastInput = function(text) {
        switch (self.value_type) {
            case E_InputTypes.STRING: return text;
            case E_InputTypes.INT: return real(text);
            case E_InputTypes.REAL: return real(text);
            case E_InputTypes.HEX: return emu_hex(text);
        }
    };
}

function emu_string_hex(value, padding = 0) {
    var output = "";
    var s = sign(value);
    
    if (value != 0) {
        output = string(ptr(abs(value)));
    
        while (string_char_at(output, 1) == "0") {
            output = string_copy(output, 2, string_length(output) - 1);
        }
    }
    
    while (string_length(output) < padding) {
        output = "0" + output;
    }
    
    return ((s < 0) ? "-" : "") + output;
}

function emu_hex(str) {
    var result = 0;
    var ZERO = ord("0");
    var NINE = ord("9");
    var A = ord("A");
    var F = ord("F");
    
    try {
        result = real(ptr(str));
    } catch (e) {
        throw new EmuException("Bad input for emu_hex()", "Could not parse " + string(str) + " as a hex value");
    }
    
    return result;
}