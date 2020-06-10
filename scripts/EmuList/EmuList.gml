function EmuList(_x, _y, _w, _h, _text, _text_vacant, _element_height, _content_slots, _callback, _list) : EmuCallback(_x, _y, _w, _h, 0, _callback) constructor {
    enum EmuListEntries { STRINGS, STRUCTS, SCRIPTS };
    text = _text;
    text_vacant = _text_vacant;
    element_height = _element_height;
    slots = _content_slots;
    
    index = 0;
    index_last = -1;
    click_x = -1;
    click_y = -1;
    
    auto_multi_select = false;
    allow_multi_select = false;
    allow_deselect = true;
    select_toggle = false;
    selected_entries = ds_map_create();
    entries_are = EmuListEntries.STRINGS;
    numbered = false;
    surface = -1;
    
    sprite_help = spr_emu_help;
    
    own_contents = (_list == undefined);
    if (own_contents) {
        entries = ds_list_create();
    } else {
        ds_list_destroy(contents);
        entries = _list;
    }
    
    AddContent = function(elements) {
        if (!is_array(elements)) elements = [elements];
        for (var i = 0; i < array_length(elements); i++) {
            ds_list_add(entries, elements[i]);
        }
    }
    
    Clear = function() {
        if (own_entries) {
            ds_list_clear(entries);
        } else {
            throw new EmuException("Trying to clear a list owned by someone else", "Please do not request to clear a list whose contents were passed in to the constructor.");
        }
    }
    
    GetHeight = function() {
        return height + element_height * slots;
    }
    
    GetSelected = function(list_index) {
        return ds_map_exists(selected_entries, list_index);
    }
    
    GetListColors = function(list_index) {
        return c_black;
    }
    
    GetSelection = function() {
        if (ds_map_empty(selected_entries)) return -1;
        return selected_entries[? "first"];
    }
    
    ClearSelection = function() {
        ds_map_clear(selected_entries);
    }
    
    Select = function(list_index, _set_index) {
        if (_set_index == undefined) _set_index = false;
        if (ds_map_empty(selected_entries)) return selected_entries[? "first"];
        selected_entries[? value] = true;
        if (clamp(list_index, index, index + slots - 1) != list_index) {
            index = max(0, min(list_index, ds_list_size(entries) - slots));
        }
    }
    
    Deselect = function(list_index) {
        ds_map_delete(selected_entries, list_index);
    }
    
    Render = function(base_x, base_y) {
        var x1 = x + base_x;
        var y1 = y + base_y;
        var x2 = x1 + width;
        var y2 = y1 + height;
        var y3 = y2 + slots * height;
        var ww = x2 - x1;
        var hh = y3 - y2;
        var tx = GetTextX(x1);
        var ty = GetTextY(y1);
        
        #region list header
        if (string_length(tooltip) > 0) {
            var spr_xoffset = sprite_get_xoffset(sprite_help);
            var spr_yoffset = sprite_get_yoffset(sprite_help);
            var spr_width = sprite_get_width(sprite_help);
            var spr_height = sprite_get_height(sprite_help);
            var txoffset = spr_width;
            
            if (GetMouseHover(tx - spr_xoffset, ty - spr_yoffset, tx - spr_xoffset + spr_width, ty - spr_yoffset + spr_height)) {
                draw_sprite_ext(sprite_help, 2, tx, ty, 1, 1, 0, EMU_COLOR_HOVER, 1);
                SetTooltip();
            } else {
                draw_sprite_ext(sprite_help, 2, tx, ty, 1, 1, 0, EMU_COLOR_BACK, 1);
            }
            draw_sprite_ext(sprite_help, 1, tx, ty, 1, 1, 0, color, 1);
            draw_sprite_ext(sprite_help, 0, tx, ty, 1, 1, 0, color, 1);
        } else {
            var txoffset = 0;
        }
        scribble_set_box_align(fa_left, fa_center);
        scribble_draw(tx + txoffset, ty, text);
        #endregion
        
        #region list drawing
        if (surface_exists(surface) && (surface_get_width(surface) != ww || surface_get_height(surface) != hh)) {
            surface_free(surface);
        }
        
        if (!surface_exists(surface)) {
            surface = surface_create(ww, hh);
        }
        
        surface_set_target(surface);
        draw_clear_alpha(GetInteractive() ? EMU_COLOR_BACK : EMU_COLOR_DISABLED, 1);
        
        var n = ds_exists(entries, ds_type_list) ? ds_list_size(entries) : 0;
        index = clamp(n - slots, 0, index);
        
        if (n == 0) {
            DrawNineslice(1, 0, 0, x2 - x1, element_height, EMU_COLOR_DISABLED, 1);
            ty = mean(y2, y2 + height);
            scribble_set_box_align(fa_left, fa_center);
            scribble_draw(tx - x1, ty - y2, text_vacant);
        } else {
            for (var i = 0; i < min(n, slots); i++) {
                var current_index = i + index;
                var ya = y2 + height * i;
                var yb = ya + height;
                var tya = mean(ya, yb);
                
                if (GetInteractive()) {
                    if (GetSelected(current_index)) {
                        draw_rectangle_colour(0, ya - y2, x2 - x1, yb - y2, EMU_COLOR_SELECTED, EMU_COLOR_SELECTED, EMU_COLOR_SELECTED, EMU_COLOR_SELECTED, false);
                    }
                }
                
                var c = GetListColors(current_index);
                var index_text = numbered ? (string(current_index) + ". ") : "";
        
                switch (entries_are) {
                    case EmuListEntries.STRINGS: index_text += string(entries[| current_index]); break;
                    case EmuListEntries.INSTANCES: index_text += entries[| current_index].name; break;
                    case EmuListEntries.SCRIPT: index_text = index_text + string(entries[| current_index](list, current_index)); break;
                }
                var base_color = global.scribble_state_starting_color;
                global.scribble_state_starting_color = c;
                scribble_draw(tx - x1, tya - y2, index_text);
                global.scribble_state_starting_color = base_color;
            }
        }
        
        draw_rectangle_colour(1, 1, ww - 2, hh - 2, color, color, color, color, true);
        surface_reset_target();
        #endregion
        
        draw_surface(surface, x1, y2);
        
        #region interaction
        var offset = (n > slots) ? 16 : 0;
        var lx1 = x1;
        var ly1 = y2;
        var lx2 = x2 - offset;
        var ly2 = y3;
        
        var move_direction = 0;
        
        if (GetMouseHover(lx1, ly1, lx2, ly2)) {
            if (GetMouseMiddleReleased(lx1, ly1, lx2, ly2)) {
                callback_middle();
            } else if (GetMouseDouble(lx1, ly1, lx2, ly2)) {
                callback_double();
            } else if (GetMousePressed(lx1, ly1, lx2, ly2)) {
                // if this ends up having a bounds problem it's probably because the list is empty and
                // it's trying to access n-1 from the next line
                var mn = min(((mouse_y - ly1) div height) + index, n - 1);
                // deselect the list if that's what yo uwould expect to happen
                if (!auto_multi_select) {
                    if ((!keyboard_check(vk_control) && !keyboard_check(vk_shift) && !select_toggle) || !allow_multi_select) {
                        ClearSelection();
                    }
                }
                // toggle selection over a range
                if (allow_multi_select && keyboard_check(vk_shift)) {
                    if (last_index > -1) {
                        var d = clamp(mn - last_index, -1, 1);
                        for (var i = last_index; i != mn; i = i + d) {
                            if (!GetSelected(i)) {
                                Select(i);
                            } else if (select_toggle && allow_deselect) {
                                Deselect(i);
                            }
                        }
                    }
                // toggle single selections
                } else {
                    if (!GetSelected(mn)) {
                        ds_map_add(selected_entries, mn, true);
                    } else if (select_toggle && allow_deselect) {
                        Deselect(mn);
                    }
                }
                
                last_index = mn;
                //ui_activate(list);
                callback();
            } else if (GetMouseRightReleased(lx1, ly1, lx2, ly2)) {
                if (allow_deselect) {
                    ClearSelection();
                    callback();
                }
            }
            
            if (mouse_wheel_up()) {
                move_direction = -1;
            } else if (mouse_wheel_down()) {
                move_direction = 1;
            }
            
            if (allow_multi_select) {
                if (keyboard_check(vk_control) && keyboard_check_pressed(ord("A"))) {
                    for (var i = 0; i < n; i++) {
                        if (!GetSelected(i)) {
                            Select(i);
                        } else if (select_toggle) {
                            Deselect(i);
                        }
                    }
                }
            }
        }
        #endregion
        
        #region slider
        if (n > slots) {
            var sw = 16;
            var noutofrange = n - slots; // at minimum, one
            // the minimum slider height will never be below 20, but it'll scale up for longer lists;
            // otherwise it's simply proportional to the fraction of the entries that are visible in the list
            var shalf = max(20 + 20 * log10(slots), (y3 - y2 - sw * 2) * slots / n) / 2;
            var smin = y2 + sw + shalf;
            var smax = y3 - sw - shalf;
            var srange = smax - smin;
            var sy = smin + srange * index / noutofrange;
            var active = GetInteractive();
            draw_rectangle_colour(x2 - sw, y2, x2, y3, EMU_COLOR_BACK, EMU_COLOR_BACK, EMU_COLOR_BACK, EMU_COLOR_BACK, false);
            draw_line_colour(x2 - sw, y2 + sw, x2, y2 + sw, color, color);
            draw_line_colour(x2 - sw, y3 - sw, x2, y3 - sw, color, color);
            draw_rectangle_colour(x2 - sw, y2, x2, y3, color, color, color, color, true);
            
            var sby1 = sy - shalf;
            var sby2 = sy + shalf;
            if (active) {
                if (GetMouseHover(x2 - sw, sby1, x2, sby2)) {
                    draw_rectangle_colour(x2 - sw + 1, sby1 + 1, x2 - 1, sby2 - 1, EMU_COLOR_HOVER, EMU_COLOR_HOVER, EMU_COLOR_HOVER, EMU_COLOR_HOVER, false);
                    if (GetMousePressed(x2 - sw, sby1, x2, sby2)) {
                        click_x = mouse_x;
                        click_y = mouse_y;
                    }
                }
                if (GetMousePressed(x2 - sw, sby1, x2, sby2)) {
                    if (click_y > -1) {
                        index = floor(noutofrange * clamp(mouse_y - smin, 0, srange) / srange);
                    }
                }
                if (GetMouseReleased(x2 - sw, sby1, x2, sby2)) {
                    click_x = -1;
                    click_y = -1;
                }
            }
            draw_rectangle_colour(x2 - sw, sby1, x2, sby2, color, color, color, color, true);
            draw_line_colour(x2 - sw * 4 / 5, sy - 4, x2 - sw / 5, sy - 4, color, color);
            draw_line_colour(x2 - sw * 4 / 5, sy, x2 - sw / 5, sy, color, color);
            draw_line_colour(x2 - sw * 4 / 5, sy + 4, x2 - sw / 5, sy + 4, color, color);
            
            if (active) {
                var inbounds_top = GetMouseHover(x2 - sw, y2, x2, y2 + sw);
                var inbounds_bottom = GetMouseHover(x2 - sw, y3 - sw, x2, y3);
                if (inbounds_top) {
                    draw_rectangle_colour(x2 - sw + 1, y2 + 1, x2 - 1, y2 + sw - 1, EMU_COLOR_HOVER, EMU_COLOR_HOVER, EMU_COLOR_HOVER, EMU_COLOR_HOVER, false);
                    if (GetMousePressed(x2 - sw, y3 - sw, x2, y3)) {
                        move_direction = -1;
                    } else if (GetMouseHold(x2 - sw, y3 - sw, x2, y3)) {
                        if (GetMouseHoldDuration(x2 - sw, y3 - sw, x2, y3) > 0.5) {
                            move_direction = -1;
                        }
                    }
                } else if (inbounds_bottom) {
                    draw_rectangle_colour(x2 - sw + 1, y3 - sw + 1, x2 - 1, y3 - 1, EMU_COLOR_HOVER, EMU_COLOR_HOVER, EMU_COLOR_HOVER, EMU_COLOR_HOVER, false);
                    if (GetMousePressed(x2 - sw, y3 - sw, x2, y3)) {
                        move_direction = 1;
                    } else if (GetMouseHold(x2 - sw, y3 - sw, x2, y3)) {
                        if (GetMouseHoldDuration(x2 - sw, y3 - sw, x2, y3) > 0.5) {
                            move_direction = 1;
                        }
                    }
                }
            }
            draw_sprite_ext(spr_emu_scroll_arrow, 0, x2 - sw, y2, 1, 1, 0, color, 1);
            draw_sprite_ext(spr_emu_scroll_arrow, 1, x2 - sw, y3 - sw, 1, 1, 0, color, 1);
        }
        #endregion

    }
    
    Destory = function() {
        DestroyContent();
        ds_map_destroy(selected_entries);
        if (own_entries) ds_list_destroy(entries);
        if (surface != -1) surface_free(surface);
    }
}