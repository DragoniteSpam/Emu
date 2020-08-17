// Emu (c) 2020 @dragonitespam
// See the Github wiki for documentation: https://github.com/DragoniteSpam/Emu/wiki
function EmuInput(_x, _y, _w, _h, _text, _value, _help_text, _character_limit, _input_type, _callback) : EmuCallback(_x, _y, _w, _h, _value, _callback) constructor {
    enum E_InputTypes { STRING, INT, REAL, HEX };
    
    text = _text;
    help_text = _help_text;
    character_limit = clamp(_character_limit, 1, 1000);  // keyboard_string maxes out at 1024 characters but I like to cut it off before then to be safe
    value_x1 = width / 2;
    value_y1 = 0;
    value_x2 = width;
    value_y2 = height;
    
    override_escape = true;
    require_enter = false;
    multi_line = false;
    input_font = EMU_FONT_DEFAULT;
    value_type = _input_type;
    value_lower = 0;
    value_upper = 100;
    
    sprite_ring = spr_emu_ring
    sprite_enter = spr_emu_enter;
    
    SetMultiLine = function(_multi_line) {
        multi_line = _multi_line;
    }
    
    SetRequireConfirm = function(_require) {
        require_enter = _require;
    }
    
    surface = surface_create(value_x2 - value_x1, value_y2 - value_y1);
    
    SetInputBoxPosition = function(_vx1, _vy1, _vx2, _vy2) {
        value_x1 = _vx1;
        value_y1 = _vy1;
        value_x2 = _vx2;
        value_y2 = _vy2;
    }
    
    SetValue = function(_value) {
        value = string(_value);
        value = _value;
        if (isActiveElement()) {
            keyboard_string = value;
        }
    }
    
    SetRealNumberBounds = function(_lower, _upper) {
        value_lower = min(_lower, _upper);
        value_upper = max(_lower, _upper);
    }
    
    Render = function(base_x, base_y) {
        processAdvancement();
        
        var x1 = x + base_x;
        var y1 = y + base_y;
        var x2 = x1 + width;
        var y2 = y1 + height;
        var c = color;

        var vx1 = x1 + value_x1;
        var vy1 = y1 + value_y1;
        var vx2 = x1 + value_x2;
        var vy2 = y1 + value_y2;
        var ww = vx2 - vx1;
        var hh = vy2 - vy1;
        
        var tx = getTextX(x1);
        var ty = getTextY(y1);
        
        var working_value = string(value);
        var sw = string_width(working_value);
        var sw_end = sw + 4;
        
        #region work out the input color
        scribble_set_box_align(fa_left, fa_middle);
        scribble_set_wrap(width, height);
        scribble_draw(tx, ty, string(text));
        
        if (ValidateInput(working_value)) {
            var cast = CastInput(working_value);
            if (is_real(cast) && clamp(cast, value_lower, value_upper) != cast) {
                c = EMU_COLOR_INPUT_WARN;
            }
        } else {
            var c = EMU_COLOR_INPUT_REJECT;
        }
        #endregion
        
        var vtx = vx1 + 12;
        var vty = floor(mean(vy1, vy2));
        var spacing = 12;
        
        #region input drawing
        if (surface_exists(surface) && (surface_get_width(surface) != ww || surface_get_height(surface) != hh)) {
            surface_free(surface);
        }

        if (!surface_exists(surface)) {
            surface = surface_create(ww, hh);
        }

        surface_set_target(surface);
        surface_set_target(surface);
        draw_clear(GetInteractive() ? EMU_COLOR_BACK : EMU_COLOR_DISABLED);
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
                scribble_draw(remaining_x, remaining_y, string(remaining));
            } else {
                var remaining_x = ww - 16;
                var remaining_y = hh - 16;
                var r = 12;
                var steps = 32;
                draw_sprite(sprite_ring, 0, remaining_x, remaining_y);
                draw_primitive_begin_texture(pr_trianglefan, sprite_get_texture(sprite_ring, 0));
                draw_vertex_texture_colour(remaining_x, remaining_y, 0.5, 0.5, EMU_COLOR_SELECTED, 1);
                for (var i = 0; i <= steps * f; i++) {
                    var angle = 360 / steps * i - 90;
                    draw_vertex_texture_colour(
                        clamp(remaining_x + r * dcos(angle), remaining_x - r, remaining_x + r),
                        clamp(remaining_y + r * dsin(angle), remaining_y - r, remaining_y + r),
                        clamp(0.5 + 0.5 * dcos(angle), 0, 1),
                        clamp(0.5 + 0.5 * dsin(angle), 0, 1),
                    EMU_COLOR_SELECTED, 1);
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
            draw_text_colour(vtx - vx1, vty - vy1, string(help_text), c_dkgray, c_dkgray, c_dkgray, c_dkgray, 1);
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
							// only change actual value when it's allowed
			                value = working_value;
                            callback();
                        }
                    }
					// reset the keyboard string if value change didn't occur
					// this is to fix the bug that occured before, where you could essentially 'type past'
					// the contents of the textbox. the value didn't change but you had to backspace more than once 
					// to remove the last character of the textbox.
					if (!execute_value_change) {
						keyboard_string = working_value;
					}
                }
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
        draw_rectangle_colour(vx1, vy1, vx2, vy2, color, color, color, color, true);
    }
    
    Destroy = function() {
        destroyContent();
        if (surface_exists(surface)) surface_free(surface);
    }
    
    ValidateInput = function(_text) {
        // this used to be a switch tree, but 23.1.1.159 has issues with
        // try-catch in switch trees; if that issue has been fixed, feel
        // free to change it back if you think those look nicer
        var success = true;
        if (value_type == E_InputTypes.STRING) {
            return true;
        }
        if (value_type == E_InputTypes.INT) {
            try {
                var cast = real(_text);
                if (floor(cast) != cast) success = false;
            } catch (e) {
                success = false;
            }
            return success;
        }
        if (value_type == E_InputTypes.REAL) {
            try {
                var cast = real(_text);
            } catch (e) {
                success = false;
            }
            return success;
        }
        if (value_type == E_InputTypes.HEX) {
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
        switch (value_type) {
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