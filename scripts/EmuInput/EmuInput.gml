function EmuInput(_x, _y, _w, _h, _text, _value, _help_text, _character_limit, _vx1, _vy1, _vx2, _vy2, _callback) : EmuCallback(_x, _y, _w, _h, _value, _callback) constructor {
    text = _text;
    help_text = _help_text;
    character_limit = clamp(_character_limit, 1, 1000);  // keyboard_string maxes out at 1024 characters but I like to cut it off before then to be safe
    value_x1 = _vx1;
    value_y1 = _vy1;
    value_x2 = _vx2;
    value_y2 = _vy2;
    
    override_escape = true;
    require_enter = false;
    multi_line = false;
    input_font = EMU_FONT_DEFAULT;
    
    surface = surface_create(value_x2 - value_x1, value_y2 - value_y1);
    
    SetValue = function(_value) {
        
    }
    
    Render = function(base_x, base_y) {
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
        
        var tx = GetTextX(x1);
        var ty = GetTextY(y1);
        
        var working_value = string(value);
        var sw = string_width(working_value);
        var sw_end = sw + 4;
        
        #region text label
        scribble_set_box_align(fa_left, fa_middle);
        scribble_draw(tx, ty, string(text));
        
        /*if (script_execute(validation, working_value, input)) {
            var c = color;
            if (real_value) {
                var n = script_execute(value_conversion, working_value);
                if (!is_clamped(n, value_lower, value_upper)) {
                    c = c_orange;
                }
            }
        } else {
            var c = c_red;
        }*/
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
        
        var display_text = working_value + (IsActiveElement() && (floor((current_time * 0.00125) % 2) == 0) ? "|" : "");
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
                draw_sprite(spr_emu_ring, 0, remaining_x, remaining_y);
                draw_primitive_begin_texture(pr_trianglefan, sprite_get_texture(spr_emu_ring, 0));
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
            draw_sprite(spr_emu_enter, 0, vx2 - sprite_get_width(spr_emu_enter) - 4, vy2 - sprite_get_height(spr_emu_enter) - 4);
        }

        if (GetInteractive()) {
            if (IsActiveElement()) {
                var v0 = value;
                value = string_copy(keyboard_string, 1, min(string_length(keyboard_string), character_limit));
                if (keyboard_check_pressed(vk_escape)) {
                    keyboard_clear(vk_escape);
                    value = "";
                    keyboard_string = "";
                }
                if (multi_line && !require_enter && keyboard_check_pressed(vk_enter)) {
                    value = value + "\n";
                    keyboard_string = keyboard_string + "\n";
                }
        
                value = value;
        
                if (true /* script_execute(validation, value, input) */) {
                    var execute_value_change = (!require_enter && v0 != value) || (require_enter && Controller.press_enter);
                    if (execute_value_change) {
                        /*if (real_value) {
                            var n = script_execute(value_conversion, value);
                            execute_value_change = execute_value_change && is_clamped(n, value_lower, value_upper);
                        }
                        if (execute_value_change) {
                            emphasis = (validation == validate_string_internal_name && internal_name_get(value));
                            callback();
                        }*/
                    }
                }
            }
            // activation
            if (GetMouseHover(vx1, vy1, vx2, vy2)) {
                if (GetMouseReleased(vx1, vy1, vx2, vy2)) {
                    keyboard_string = value;
                    Activate();
                }
                SetTooltip();
            }
        }

        surface_reset_target();
        #endregion

        draw_surface(surface, vx1, vy1)
        draw_rectangle_colour(vx1, vy1, vx2, vy2, c_black, c_black, c_black, c_black, true);
    }
    
    Destroy = function() {
        DestroyContent();
        if (surface_exists(surface)) surface_free(surface);
    }
}