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
    
    GetTextX = function(_x) {
        switch (alignment) {
            case fa_left: return _x + offset;
            case fa_center: return _x + width / 2;
            case fa_right: return _x + width - offset;
        }
    }
    
    GetTextY = function(_y) {
        switch (valignment) {
            case fa_left: return _y + offset;
            case fa_center: return _y + height / 2;
            case fa_right: return _y + height - offset;
        }
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
        
        if (GetInteractive()) {
            if (GetMouseHover(x1, y1, x2, y2)) {
                SetTooltip();
            }
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
    color_back = EMU_COLOR_BACK;
    
    GetTextX = function(_x) {
        switch (alignment) {
            case fa_left: return _x + offset;
            case fa_center: return _x + width / 2;
            case fa_right: return _x + width - offset;
        }
    }
    
    GetTextY = function(_y) {
        switch (valignment) {
            case fa_left: return _y + offset;
            case fa_center: return _y + height / 2;
            case fa_right: return _y + height - offset;
        }
    }
    
    Render = function(base_x, base_y) {
        var x1 = x + base_x;
        var y1 = y + base_y;
        var x2 = x1 + width;
        var y2 = y1 + height;
        
        var tx = GetTextX(x1);
        var ty = GetTextY(y1);
        
        if (GetInteractive()) {
            if (GetMouseHover(x1, y1, x2, y2)) {
                SetTooltip();
            }
            if (GetMouseReleased(x1, y1, x2, y2)) {
                // radio array options don't get individual callbacks
                root.value = value;
                root.callback();
            }
        }
        
        draw_sprite_ext(spr_emu_radio, 2, tx + offset, ty, 1, 1, 0, color_back, 1);
        draw_sprite_ext(spr_emu_radio, 1, tx + offset, ty, 1, 1, 0, color, 1);
        draw_sprite_ext(spr_emu_radio, 0, tx + offset, ty, 1, 1, 0, color, 1);
        if (value == root.value) {
            draw_sprite_ext(spr_emu_radio, 3, tx + offset, ty, 1, 1, 0, color_active, GetInteractive());
        }
        
        scribble_set_box_align(fa_left, fa_center);
        scribble_set_wrap(width, height);
        scribble_draw(tx + offset + sprite_get_width(spr_emu_radio), ty, text);
    }
}