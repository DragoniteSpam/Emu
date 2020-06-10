function EmuList(_x, _y, _w, _h, _text, _vacant_text, _element_height, _content_slots, _callback, _list) : EmuCallback(_x, _y, _w, _h, 0, _callback) constructor {
    enum EmuListEntriesAre { STRINGS, STRUCTS, SCRIPTS };
    text = _text;
    vacant_text = _vacant_text;
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
    entries_are = EmuListEntriesAre.STRINGS;
    numbered = false;
    surface = -1;
    
    sprite_help = spr_emu_help;
    
    if (_list == undefined) {
        own_contents = false;
        ds_list_destroy(contents);
        entries = _list;
    } else {
        entries = ds_list_create();
    }
    
    AddOptions = function(elements) {
        if (!is_array(elements)) {
            elements = [elements];
        }
        
        for (var i = 0; i < array_length(elements); i++) {
            elements[i] = new EmuRadioArrayOption(0, height * (1 + i), width, height, elements[i], i);
        }
        
        AddContent(elements);
    }
    
    SetColumns = function(_column_capacity, _column_width) {
        for (var i = 0; i < ds_list_size(contents); i++) {
            var option = contents[| i];
            option.x = (i div _column_capacity) * _column_width;
            option.y = height * (1 + (i % _column_capacity));
            option.width = _column_width;
        }
        width = (ds_list_size(contents) div _column_capacity) * _column_width;
    }
    
    GetHeight = function() {
        return height + element_height * slots;
    }
    
    Render = function(base_x, base_y) {
        var x1 = x + base_x;
        var y1 = y + base_y;
        var x2 = x1 + width;
        var y2 = y1 + height;
        
        var tx = GetTextX(x1);
        var ty = GetTextY(y1);
        
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
    }
    
    Destory = function() {
        DestroyContent();
        ds_map_destroy(selected_entries);
        if (own_entries) ds_list_destroy(entries);
        if (surface != -1) surface_free(surface);
    }
}