function VBitfield(_x, _y, _w, _h, _orientation, _value, _callback) : VCallback(_x, _y, _w, _h, _value, _callback) constructor {
    enum EVBitfieldOrientations { HORIZONTAL, VERTICAL };
    
    orientation = _orientation;
    fixed_spacing = -1;
    
    SetFixedSpacing = function(spacing) {
        fixed_spacing = spacing;
        ArrangeElements();
    }
    
    SetAutoSpacing = function() {
        fixed_spacing = -1;
        ArrangeElements();
    }
    
    AddOptions = function(elements) {
        if (!is_array(elements)) {
            elements = [elements];
        }
        
        for (var i = 0; i < array_length(elements); i++) {
            if (!is_struct(elements[i])) {
                elements[i] = new VBitfieldOption(string(elements[i]), 1 << (ds_list_size(contents) + i),
                function() {
                    state = !state;
                    root.Calculate();
                    root.callback();
                },
                function() {
                    return (root.value & value) == value;
                });
            }
        }
        
        AddContent(elements);
        ArrangeElements();
    }
    
    RemoveOptions = function(elements) {
        if (!is_array(elements)) {
            elements = [elements];
        }
        RemoveOptions(elements);
        ArrangeElements();
    }
    
    ArrangeElements = function() {
        if (orientation == EVBitfieldOrientations.HORIZONTAL) {
            for (var i = 0; i < ds_list_size(contents); i++) {
                var option = contents[| i];
                option.width = (fixed_spacing == -1) ? floor(width / ds_list_size(contents)) : fixed_spacing;
                option.height = height;
                option.x = option.width * i;
                option.y = 0;
            }
        } else {
            for (var i = 0; i < ds_list_size(contents); i++) {
                var option = contents[| i];
                option.width = width;
                option.height = (fixed_spacing == -1) ? floor(height / ds_list_size(contents)) : fixed_spacing;
                option.x = 0;
                option.y = option.height * i;
            }
        }
    }
    
    Calculate = function() {
        value = 0;
        for (var i = 0; i < ds_list_size(contents); i++) {
            value |= contents[| i].value * contents[| i].state;
        }
    }
    
    GetHeight = function() {
        var first = contents[| 0];
        var last = contents[| ds_list_size(contents) - 1];
        return (first == undefined) ? height : (last.y + last.height - first.y);
    }
    
    Render = function(base_x, base_y) {
        var x1 = x + base_x;
        var y1 = y + base_y;
        var x2 = x1 + width;
        var y2 = y1 + height;
        
        RenderContents(x1, y1);
    }
}

function VBitfieldOption(_text, _value, _callback, _eval) : VCallback(0, 0, 0, 0, _value, _callback) constructor {
    SetEval = function(_eval) {
        evaluate = method(self, _eval);
    }
    
    text = _text;
    SetEval(_eval);
    state = 0;
    
    color_active = VANADIUM_COLOR_SELECTED;
    color_inactive = VANADIUM_COLOR_BACK;
    
    Render = function(base_x, base_y) {
        var x1 = x + base_x;
        var y1 = y + base_y;
        var x2 = x1 + width;
        var y2 = y1 + height;
        
        state = evaluate();
        
        var back_color = state ? color_active : color_inactive;
        
        if (interactive && root.interactive) {
            back_color = merge_colour(back_color, GetMouseHover(x1, y1, x2, y2) ? VANADIUM_COLOR_HOVER : back_color, 0.5);
        } else {
            back_color = merge_colour(back_color, VANADIUM_COLOR_DISABLED, 0.5);
        }
        
        DrawNineslice(1, x1, y1, x2, y2, back_color, 1);
        DrawNineslice(0, x1, y1, x2, y2, color, 1);
        scribble_set_box_align(fa_center, fa_middle);
        scribble_draw(floor(mean(x1, x2)), floor(mean(y1, y2)), text);
        
        if (interactive) {
            if (GetMousePressed(x1, y1, x2, y2)) {
                callback();
            }
        }
    }
}

// You may find yourself using these particularly often
function v_bitfield_option_all_callback() {
    root.value = value;
    root.callback();
}

function v_bitfield_option_all_eval() {
    return root.value == value;
};

function v_bitfield_option_none_callback() {
    root.value = 0;
    root.callback();
}

function v_bitfield_option_none_eval() {
    return root.value == value;
};