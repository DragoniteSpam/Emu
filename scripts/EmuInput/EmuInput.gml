function EmuInput(_x, _y, _w, _h, _text, _value, _help_text, _limit, _callback, _vx1, _vy1, _vx2, _vy2) : EmuCallback(_x, _y, _w, _h, _value, _callback) constructor {
    text = _text;
    help_text = _help_text;
    limit = _limit;
    value_x1 = _vx1;
    value_y1 = _vy1;
    value_x2 = _vx2;
    value_y2 = _vy2;
    
    override_escape = true;
    require_enter = false;
    
    surface = surface_create(value_vx2 - value_vx1, value_vy2 - value_vy1);
    
    SetValue = function(_value) {
        
    }
    
    IsActive = function() {
        return false;
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
        
        var value = string(value);
        var sw = string_width(value);
        var sw_end = sw + 4;
        
        #region text label
        scribble_set_box_align(fa_left, fa_middle);
        draw_text_colour(tx, ty, string(text), c, c, c, c, 1);
        
        /*if (script_execute(validation, value, input)) {
            var c = color;
            if (real_value) {
                var n = script_execute(value_conversion, value);
                if (!is_clamped(n, value_lower, value_upper)) {
                    c = c_orange;
                }
            }
        } else {
            var c = c_red;
        }*/
        #endregion

        var vtx = vx1 + 12;
        var vty = mean(vy1, vy2);
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
        
        var display_text = value + (GetInteractive() && (floor((current_time * 0.00125) % 2) == 0) ? "|" : "");
        if (multi_line) {
            // i guess you could draw this in a single-line box too, but it would be pretty cramped
            #region the "how many characters remaining" counter
            if (value_limit > 0) {
                var remaining = value_limit - string_length(value);
                var f = string_length(value) / value_limit;
                // hard limit on 99 for characters remaining
                if (f > 0.9 && remaining < 100) {
                    var remaining_w = string_width(string(remaining));
                    var remaining_h = string_height(string(remaining));
                    var remaining_x = ww - 4 - remaining_w;
                    var remaining_y = hh - remaining_h;
                    draw_text(remaining_x, remaining_y, string(remaining));
                } else {
                    var remaining_x = ww - 16;
                    var remaining_y = hh - 16;
                    var r = 12;
                    var steps = 32;
                    draw_sprite(spr_emu_ring, 0, remaining_x, remaining_y);
                    draw_primitive_begin_texture(pr_trianglefan, sprite_get_texture(spr_ring, 0));
                    draw_vertex_texture_colour(remaining_x, remaining_y, 0.5, 0.5, c_ui_select, 1);
                    for (var i = 0; i <= steps * f; i++) {
                        var angle = 360 / steps * i - 90;
                        draw_vertex_texture_colour(
                            clamp(remaining_x + r * dcos(angle), remaining_x - r, remaining_x + r),
                            clamp(remaining_y + r * dsin(angle), remaining_y - r, remaining_y + r),
                            clamp(0.5 + 0.5 * dcos(angle), 0, 1),
                            clamp(0.5 + 0.5 * dsin(angle), 0, 1),
                        c_ui_select, 1);
                    }
                    draw_primitive_end();
                }
            }
            #endregion
            
            var valign = draw_get_valign();
            draw_set_valign(fa_top);
            var sh = string_height_ext(display_text, -1, vx2 - vx1 - (vtx - vx1) * 2);
            var vty = vy1 + offset;
            draw_text_ext_colour(vtx - vx1, min(vty - vy1, hh - spacing - sh), display_text, -1, vx2 - vx1 - (vtx - vx1) * 2, c, c, c, c, 1);
            draw_set_valign(valign);
        } else {
            var sw_begin = min(vtx - vx1, ww - offset - sw);
            draw_text_colour(sw_begin, vty - vy1, display_text, c, c, c, c, 1);
            sw_end = sw_begin + sw + 4;
        }
        
        if (string_length(value) == 0) {
            draw_text_colour(vtx - vx1, vty - vy1, string(value_default), c_dkgray, c_dkgray, c_dkgray, c_dkgray, 1);
        }

        if (require_enter) {
            draw_sprite(spr_emu_enter, 0, vx2 - sprite_get_width(spr_enter) - 4, vy2 - sprite_get_height(spr_enter) - 4);
        }

        if (GetInteractive()) {
            if (false && IsActive()) {
                var v0 = value;
                value = string_copy(keyboard_string, 1, min(string_length(keyboard_string), value_limit));
                if (Controller.press_escape) {
                    Controller.press_escape = false;
                    value = "";
                    keyboard_string = "";
                }
                if (multi_line && !require_enter && Controller.press_enter) {
                    value = value + "\n";
                    keyboard_string = keyboard_string + "\n";
                }
        
                value = value;
        
                if (script_execute(validation, value, input)) {
                    var execute_value_change = (!require_enter && v0 != value) || (require_enter && Controller.press_enter);
                    if (execute_value_change) {
                        if (real_value) {
                            var n = script_execute(value_conversion, value);
                            execute_value_change = execute_value_change && is_clamped(n, value_lower, value_upper);
                        }
                        if (execute_value_change) {
                            emphasis = (validation == validate_string_internal_name && internal_name_get(value));
                            script_execute(onvaluechange, input);
                        }
                    }
                }
            }
            // activation
            if (GetHover(vx1, vy1, vx2, vy2)) {
                if (GetMouseReleased(vx1, vy1, vx2, vy2)) {
                    keyboard_string = value;
                    //ui_activate(input);
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