function EmuRadioArray(_x, _y, _w, _h, _text, _value, _callback) : EmuCallback(_x, _y, _w, _h, _value, _callback) constructor {
    text = _text;
    
    orientation = EmuBitfieldOrientations.VERTICAL;
    
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
        return height * (1 + ds_list_size(contents));
    }
    
    Render = function(base_x, base_y) {
        var x1 = x + base_x;
        var y1 = y + base_y;
        var x2 = x1 + width;
        var y2 = y1 + height;
        
        var tx = GetTextX(x1);
        var ty = GetTextY(y1);
        
        if (GetMouseHover(x1, y1, x2, y2)) {
            SetTooltip();
        }
        
        scribble_set_wrap(width, height);
        scribble_set_box_align(fa_left, fa_middle);
        scribble_draw(tx, ty, text);
        
        RenderContents(x1, y1);
    }
}

function EmuRadioArrayOption(_x, _y, _w, _h, _text, _value) : EmuCore(_x, _y, _w, _h) constructor {
    text = _text;
    value = _value;
    
    color_active = EMU_COLOR_RADIO_ACTIVE;
    
    Render = function(base_x, base_y) {
        var x1 = x + base_x;
        var y1 = y + base_y;
        var x2 = x1 + width;
        var y2 = y1 + height;
        
        var tx = GetTextX(x1);
        var ty = GetTextY(y1);
        
        if (GetMouseHover(x1, y1, x2, y2)) {
            SetTooltip();
        }
        
        if (GetMouseReleased(x1, y1, x2, y2)) {
            // radio array options don't get individual callbacks
            root.value = value;
            root.callback();
        }
        
        draw_sprite_ext(spr_emu_radio, 2, tx + offset, ty, 1, 1, 0, EMU_COLOR_BACK, 1);
        draw_sprite_ext(spr_emu_radio, 1, tx + offset, ty, 1, 1, 0, color, 1);
        draw_sprite_ext(spr_emu_radio, 0, tx + offset, ty, 1, 1, 0, color, 1);
        if (value == root.value) {
            draw_sprite_ext(spr_emu_radio, 3, tx + offset, ty, 1, 1, 0, color_active, GetInteractive());
        }
        
        scribble_set_box_align(fa_left, fa_center);
        scribble_set_wrap(width, height);
        scribble_draw(tx + offset + sprite_get_width(spr_emu_radio), ty, text);
    }
    
    GetInteractive = function() {
        return interactive && root.IsActiveDialog();
    }
}