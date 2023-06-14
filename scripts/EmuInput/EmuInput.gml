// Emu (c) 2020 @dragonitespam
// See the Github wiki for documentation: https://github.com/DragoniteSpam/Documentation/wiki/Emu

// feather use syntax-errors
function EmuInput(x, y, width, height, text, value, help_text, character_limit, input, callback) : EmuCallback(x, y, width, height, text, value, callback) constructor {
    enum E_InputTypes { STRING, INT, REAL, HEX, LETTERSDIGITS, LETTERSDIGITSANDUNDERSCORES };
    
    self.help_text = help_text;
    self.character_limit = clamp(character_limit, 1, 1000);  // keyboard_string maxes out at 1024 characters but I like to cut it off before then to be safe
    
    self.color_text = function() { return EMU_COLOR_TEXT; };
    self.color_help_text = function() { return EMU_COLOR_HELP_TEXT; };
    self.color_warn = function() { return EMU_COLOR_INPUT_WARN; };
    self.color_reject = function() { return EMU_COLOR_INPUT_REJECT; };
    self.color_back = function() { return EMU_COLOR_BACK; };
    self.color_disabled = function() { return EMU_COLOR_DISABLED; };
    self.color_selected = function() { return EMU_COLOR_SELECTED; };
    self.input_font = EMU_FONT_DEFAULT;
    
    self.sprite_ring = EMU_SPRITE_RING;
    self.sprite_enter = EMU_SPRITE_SUBMIT;
    
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
    self.strict_input = false;
    
    self.surface = self.surfaceVerify(-1, self.box.x2 - self.box.x1, self.box.y2 - self.box.y1).surface;
    
    self.SetMultiLine = function(multi_line) {
        self.multi_line = multi_line;
        return self;
    };
    
    self.SetRequireConfirm = function(require) {
        self.require_enter = require;
        return self;
    };
    
    self.SetInputBoxPosition = function(vx1, vy1, vx2 = self.box.x2, vy2 = self.box.y2) {
        self.box.x1 = vx1;
        self.box.y1 = vy1;
        self.box.x2 = vx2;
        self.box.y2 = vy2;
        return self;
    };
    
    self.SetInputType = function(input_type) {
        self.value_type = input_type;
        return self;
    };
    
    self.SetValueType = function(type) {
        self._value_type = type;
        return self;
    };
    
    self.SetCharacterLimit = function(limit) {
        self.character_limit = limit;
        return self;
    };
    
    self.SetStrictInput = function(strict) {
        self.strict_input = strict;
        return self;
    };
    
    self.SetValue = function(value) {
        self.value = string(value);
        if (self.isActiveElement()) {
            keyboard_string = self.value;
        }
        return self;
    };
    
    self.SetRealNumberBounds = function(lower, upper) {
        self.value_lower = min(lower, upper);
        self.value_upper = max(lower, upper);
        return self;
    };
    
    self.SetValidateInput = function(f) {
        self.ValidateInput = method(self, f);
        return self;
    };
    
    self.Render = function(base_x, base_y, debug_render = false) {
        self.update_script();
        self.processAdvancement();
        
        var x1 = x + base_x;
        var y1 = y + base_y;
        var x2 = x1 + self.width;
        var y2 = y1 + self.height;
        var c = self.color_text();
        
        var vx1 = x1 + self.box.x1;
        var vy1 = y1 + self.box.y1;
        var vx2 = x1 + self.box.x2;
        var vy2 = y1 + self.box.y2;
        var ww = vx2 - vx1;
        var hh = vy2 - vy1;
        
        var tx = self.getTextX(x1);
        var ty = self.getTextY(y1);
        
        var working_value = string(self.value);
        
        #region work out the input color
        scribble(string(self.text))
            .wrap(self.width, self.height)
            .align(fa_left, fa_middle)
            .draw(tx, ty);
        
        if (self.ValidateInput(working_value)) {
            var cast = self.CastInput(working_value);
            if (is_real(cast) && clamp(cast, self.value_lower, self.value_upper) != cast) {
                c = self.color_warn();
            }
        } else {
            c = self.color_reject();
        }
        #endregion
        
        var spacing = 12;
        var vtx = vx1 + 12;
        var vty = floor(mean(vy1, vy2));
        
        #region input drawing
        self.surface = self.surfaceVerify(self.surface, ww, hh).surface;

        surface_set_target(self.surface);
        surface_set_target(self.surface);
        draw_clear(self.GetInteractive() ? self.color_back() : self.color_disabled());
        surface_reset_target();
        
        var display_text = working_value + (self.isActiveElement() && (floor((current_time * 0.0025) % 2) == 0) ? "|" : "");
        
        if (self.multi_line) {
            // i guess you could draw this in a single-line box too, but it would be pretty cramped
            #region the "how many characters remaining" counter
            var remaining = self.character_limit - string_length(working_value);
            var f = string_length(working_value) / self.character_limit;
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
                draw_sprite(self.sprite_ring, 0, remaining_x, remaining_y);
                draw_primitive_begin_texture(pr_trianglefan, sprite_get_texture(self.sprite_ring, 0));
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
            draw_set_font(self.input_font);
            var sh = string_height_ext(display_text, -1, vx2 - vx1 - (vtx - vx1) * 2);
            vty = vy1 + self.offset;
            draw_text_ext_colour(spacing, min(vty - vy1, hh - spacing - sh), display_text, -1, vx2 - vx1 - (vtx - vx1) * 2, c, c, c, c, 1);
        } else {
            draw_set_halign(fa_left);
            draw_set_valign(fa_middle);
            draw_set_font(self.input_font);
            var sw = string_width(working_value);
            draw_text_colour(min(spacing, ww - self.offset - sw), vty - vy1, display_text, c, c, c, c, 1);
        }
        
        if (string_length(self.value) == 0) {
            draw_text_colour(spacing, vty - vy1, string(self.help_text), self.color_help_text(), self.color_help_text(), self.color_help_text(), self.color_help_text(), 1);
        }

        if (self.require_enter) {
            draw_sprite(self.sprite_enter, 0, vx2 - vx1 - sprite_get_width(self.sprite_enter) - 4, vty - vy1);
        }
        #endregion
        
        #region interaction
        if (self.GetInteractive()) {
            if (self.isActiveElement()) {
                var v0 = working_value;
                working_value = keyboard_string;
                
                if (string_length(working_value) > self.character_limit) {
                	working_value = string_copy(working_value, 1, self.character_limit);
                	keyboard_string = working_value;
                }
                
				// press escape to clear input
				if (keyboard_check_pressed(vk_escape)) {
                    keyboard_clear(vk_escape);
                    working_value = "";
                    keyboard_string = "";
                }
				
				// add newline on pressing enter, if allowed
                if (self.multi_line && !self.require_enter && keyboard_check_pressed(vk_enter)) {
                    working_value += "\n";
                    keyboard_string += "\n";
                }
				
                if (self.ValidateInput(working_value)) {
                    self.value = working_value;
                    var execute_value_change = (!self.require_enter && v0 != working_value) || (self.require_enter && keyboard_check_pressed(vk_enter));
                    if (execute_value_change) {
                        var cast_value = self.CastInput(working_value);
                        if (is_real(cast_value)) {
                            execute_value_change &= (clamp(cast_value, self.value_lower, self.value_upper) == cast_value);
                        }
						
                        if (execute_value_change) {
                            self.callback();
                        }
                    }
                } else if (working_value == "") {
                	self.value = working_value;
                } else {
                    // you can set input boxes to reject invalid inputs entirely
                    if (!self.strict_input) {
                        self.value = working_value;
                    }
                }
            }
            // activation
            if (self.getMouseHover(vx1, vy1, vx2, vy2)) {
                if (self.getMouseReleased(vx1, vy1, vx2, vy2)) {
                    keyboard_string = self.value;
                    self.Activate();
                }
                self.ShowTooltip();
            }
        }
        
        surface_reset_target();
        #endregion
        
        draw_surface(self.surface, vx1, vy1)
        draw_rectangle_colour(vx1, vy1, vx2, vy2, self.color(), self.color(), self.color(), self.color(), true);
        
        if (debug_render) self.renderDebugBounds(x1, y1, x2, y2);
    };
    
    self.Activate = function() {
    	keyboard_string = self.value;
        _emu_active_element(self);
        return self;
    }
    
    self.ValidateInput = function(text) {
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
                return true;
        	case E_InputTypes.REAL:
	            try {
	                real(text);
	            } catch (e) {
	                return false;
	            }
                return true;
            case E_InputTypes.HEX:
	            try {
	                emu_hex(text);
	            } catch (e) {
	                return false;
	            }
                return true;
            case E_InputTypes.LETTERSDIGITS:
	            return string_lettersdigits(text) == text;
            case E_InputTypes.LETTERSDIGITSANDUNDERSCORES:
	            return string_length(string_lettersdigits(text)) + string_count("_", text) == string_length(text);
        }
        return true;
    };
    
    self.CastInput = function(text) {
        switch (self.value_type) {
            case E_InputTypes.STRING: return text;
            case E_InputTypes.LETTERSDIGITS: return text;
            case E_InputTypes.LETTERSDIGITSANDUNDERSCORES: return text;
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
        result = int64(ptr(str));
    } catch (e) {
        throw new EmuException("Bad input for emu_hex()", "Could not parse " + string(str) + " as a hex value");
    }
    
    return result;
}