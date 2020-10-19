// Emu (c) 2020 @dragonitespam
// See the Github wiki for documentation: https://github.com/DragoniteSpam/Emu/wiki
function EmuInput(x, y, w, h, text, value, help_text, character_limit, input, callback) : EmuCallback(x, y, w, h, value, callback) constructor {
    enum E_InputTypes { STRING, INT, REAL, HEX };
    
    self.text = text;
    self.help_text = help_text;
    self.character_limit = clamp(character_limit, 1, 1000);  // keyboard_string maxes out at 1024 characters but I like to cut it off before then to be safe
    
    self.color_help_text = EMU_COLOR_HELP_TEXT;
    self.color_warn = EMU_COLOR_INPUT_WARN;
    self.color_reject = EMU_COLOR_INPUT_REJECT;
    self.color_back = EMU_COLOR_BACK;
    self.color_disabled = EMU_COLOR_DISABLED;
    self.color_selected = EMU_COLOR_SELECTED;
    self.input_font = EMU_FONT_DEFAULT;
    
    self.sprite_ring = spr_emu_ring;
    self.sprite_enter = spr_emu_enter;
    
    self._value_x1 = self.width / 2;
    self._value_y1 = 0;
    self._value_x2 = self.width;
    self._value_y2 = self.height;
    
    self._override_escape = true;
    self._require_enter = false;
    self._multi_line = false;
    self._value_type = input;
    self._value_lower = 0;
    self._value_upper = 100;
    
    self._surface = surface_create(self._value_x2 - self._value_x1, self._value_y2 - self._value_y1);
    
    SetMultiLine = function(_multi_line) {
        _multi_line = _multi_line;
    }
    
    SetRequireConfirm = function(_require) {
        _require_enter = _require;
    }
    
    SetInputBoxPosition = function(_vx1, _vy1, _vx2, _vy2) {
        _value_x1 = _vx1;
        _value_y1 = _vy1;
        _value_x2 = _vx2;
        _value_y2 = _vy2;
    }
    
    SetValue = function(_value) {
        value = string(_value);
        if (isActiveElement()) {
            keyboard_string = value;
        }
    }
    
    SetRealNumberBounds = function(_lower, _upper) {
        _value_lower = min(_lower, _upper);
        _value_upper = max(_lower, _upper);
    }
    
    Render = function(base_x, base_y) {
        processAdvancement();
        
        var x1 = x + base_x;
        var y1 = y + base_y;
        var x2 = x1 + width;
        var y2 = y1 + height;
        var c = color;

        var vx1 = x1 + _value_x1;
        var vy1 = y1 + _value_y1;
        var vx2 = x1 + _value_x2;
        var vy2 = y1 + _value_y2;
        var ww = vx2 - vx1;
        var hh = vy2 - vy1;
        
        var tx = getTextX(x1);
        var ty = getTextY(y1);
        
        var _working_value = string(value);
        var sw = string_width(_working_value);
        var sw_end = sw + 4;
        
        #region work out the input color
        scribble_set_box_align(fa_left, fa_middle);
        scribble_set_wrap(width, height);
        scribble_draw(tx, ty, string(text));
        
        if (ValidateInput(_working_value)) {
            var cast = CastInput(_working_value);
            if (is_real(cast) && clamp(cast, _value_lower, _value_upper) != cast) {
                c = color_warn;
            }
        } else {
            var c = color_reject;
        }
        #endregion
        
        var vtx = vx1 + 12;
        var vty = floor(mean(vy1, vy2));
        var spacing = 12;
        
        #region input drawing
        if (surface_exists(_surface) && (surface_get_width(_surface) != ww || surface_get_height(_surface) != hh)) {
            surface_free(_surface);
        }

        if (!surface_exists(_surface)) {
            _surface = surface_create(ww, hh);
        }

        surface_set_target(_surface);
        surface_set_target(_surface);
        draw_clear(GetInteractive() ? color_back : color_disabled);
        surface_reset_target();
        
        var display_text = _working_value + (isActiveElement() && (floor((current_time * 0.00125) % 2) == 0) ? "|" : "");
        
        if (_multi_line) {
            // i guess you could draw this in a single-line box too, but it would be pretty cramped
            #region the "how many characters remaining" counter
            var remaining = character_limit - string_length(_working_value);
            var f = string_length(_working_value) / character_limit;
            // hard limit on 99 for characters remaining
            if (f > 0.9 && remaining < 100) {
                var remaining_w = string_width(string(remaining));
                var remaining_h = string_height(string(remaining));
                var remaining_x = ww - 4 - remaining_w;
                var remaining_y = hh - remaining_h;
                scribble_draw(remaining_x, remaining_y, string(remaining));
            } else {
                var remaining_x = ww - 16;
                var remaining_y = hh - 16;
                var r = 12;
                var steps = 32;
                draw_sprite(sprite_ring, 0, remaining_x, remaining_y);
                draw_primitive_begin_texture(pr_trianglefan, sprite_get_texture(sprite_ring, 0));
                draw_vertex_texture_colour(remaining_x, remaining_y, 0.5, 0.5, color_selected, 1);
                for (var i = 0; i <= steps * f; i++) {
                    var angle = 360 / steps * i - 90;
                    draw_vertex_texture_colour(
                        clamp(remaining_x + r * dcos(angle), remaining_x - r, remaining_x + r),
                        clamp(remaining_y + r * dsin(angle), remaining_y - r, remaining_y + r),
                        clamp(0.5 + 0.5 * dcos(angle), 0, 1),
                        clamp(0.5 + 0.5 * dsin(angle), 0, 1),
                    color_selected, 1);
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
            draw_text_colour(vtx - vx1, vty - vy1, string(help_text), color_help_text, color_help_text, color_help_text, color_help_text, 1);
        }

        if (_require_enter) {
            draw_sprite(sprite_enter, 0, vx2 - vx1 - sprite_get_width(sprite_enter) - 4, vty - vy1);
        }
        #endregion
        
        #region interaction
        if (GetInteractive()) {
            if (isActiveElement()) {
                var v0 = _working_value;
                _working_value = string_copy(keyboard_string, 1, min(string_length(keyboard_string), character_limit));
                
				// press escape to clear input
				if (keyboard_check_pressed(vk_escape)) {
                    keyboard_clear(vk_escape);
                    _working_value = "";
                    keyboard_string = "";
                }
				
				// add newline on pressing enter, if allowed
                if (_multi_line && !_require_enter && keyboard_check_pressed(vk_enter)) {
                    _working_value += "\n";
                    keyboard_string = keyboard_string + "\n";
                }
				
                if (ValidateInput(_working_value)) {
                    var execute_value_change = (!_require_enter && v0 != _working_value) || (_require_enter && keyboard_check_pressed(vk_enter));
                    if (execute_value_change) {
                        var cast = CastInput(_working_value);
                        if (is_real(cast)) {
                            execute_value_change = execute_value_change && (clamp(cast, _value_lower, _value_upper) == cast);
                        }
						
                        if (execute_value_change) {
                            value = _working_value;
                            callback();
                        }
                    }
                }
                
				keyboard_string = string_copy(_working_value, 1, min(string_length(_working_value), character_limit));
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
        
        draw_surface(_surface, vx1, vy1)
        draw_rectangle_colour(vx1, vy1, vx2, vy2, color, color, color, color, true);
    }
    
    Destroy = function() {
        destroyContent();
        if (surface_exists(_surface)) surface_free(_surface);
    }
    
    ValidateInput = function(_text) {
        // this used to be a switch tree, but 23.1.1.159 has issues with
        // try-catch in switch trees; if that issue has been fixed, feel
        // free to change it back if you think those look nicer
        var success = true;
        if (_value_type == E_InputTypes.STRING) {
            return true;
        }
        if (_value_type == E_InputTypes.INT) {
            try {
                var cast = real(_text);
                if (floor(cast) != cast) success = false;
            } catch (e) {
                success = false;
            }
            return success;
        }
        if (_value_type == E_InputTypes.REAL) {
            try {
                var cast = real(_text);
            } catch (e) {
                success = false;
            }
            return success;
        }
        if (_value_type == E_InputTypes.HEX) {
            var success = true;
            try {
                var cast = emu_hex(_text);
            } catch (e) {
                success = false;
            }
            return success;
        }
        return success;
    }
    
    CastInput = function(_text) {
        switch (_value_type) {
            case E_InputTypes.STRING: return _text;
            case E_InputTypes.INT: return real(_text);
            case E_InputTypes.REAL: return real(_text);
            case E_InputTypes.HEX: return emu_hex(_text);
        }
    }
}

/// @param _value
/// @param _padding
function emu_string_hex() {
    var _value = argument[0];
    var _padding = (argument_count > 1) ? argument[1] : 0;
    
    var s = sign(_value);
    var v = abs(_value);
    var output = "";
    
    while (v > 0)  {
        var c  = v & 0xf;
        // magic, do not touch
        output = chr(c + ((c < 10) ? 48 : 55)) + output;
        v = v >> 4;
    }
    
    if (string_length(output) == 0) {
        output = "0";
    }
    
    while (string_length(output) < _padding) {
        output = "0" + output;
    }

    return ((s < 0) ? "-" : "") + output;
}

function emu_hex(_string) {
    var result = 0;
    var ZERO = ord("0");
    var NINE = ord("9");
    var A = ord("A");
    var F = ord("F");
    
    for (var i = 1; i <= string_length(_string); i++) {
        var c = ord(string_char_at(string_upper(_string), i));
        // you could also multiply by 16 but you get more nerd points for bitshifts
        result = result << 4;
        if (c >= ZERO && c <= NINE) {
            result = result + (c - ZERO);
        } else if (c >= A && c <= F) {
            result = result + (c - A + 10);
        } else {
            throw new EmuException("Bad input for emu_hex()", "Could not parse " + string(_string) + " as a hex value");
        }
    }
    
    return result;
}