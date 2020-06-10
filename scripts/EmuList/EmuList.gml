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
    colorize = false;
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
        
        // Drawing to the surface instead of the screen directly - everything drawn needs
        // to be minus x1 and minus y1, because suddenly we're drawing at the origin again
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
                if (GetSelected(current_index)) {
                    var c = interactive ? c_ui_select : c_ltgray;
                    draw_rectangle_colour(0, ya - y2, x2 - x1, yb - y2, c, c, c, c, false);
                }
        
                var c = colorize ? script_execute(render_colors, list, current_index) : c_black;
                var index_text = numbered ? string(current_index) + ". " : "";
        
                switch (entries_are) {
                    case EmuListEntries.STRINGS: index_text += string(entries[| current_index]); break;
                    case EmuListEntries.INSTANCES: index_text += entries[| current_index].name; break;
                    case EmuListEntries.SCRIPT: index_text = index_text + string(entries[| current_index](list, current_index)); break;
                }
                scribble_draw(tx - x1, tya - y2, index_text);
            }
        }
        
        draw_rectangle_colour(1, 1, ww - 2, hh - 2, color, color, color, color, true);
        surface_reset_target();
        #endregion

        draw_surface(surface, x1, y2);
    }
    
    Destory = function() {
        DestroyContent();
        ds_map_destroy(selected_entries);
        if (own_entries) ds_list_destroy(entries);
        if (surface != -1) surface_free(surface);
    }
}