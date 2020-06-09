function VBitfield(_x, _y, _w, _h, _orientation, _value, _callback) : VCallback(_x, _y, _w, _h, _value, _callback) constructor {
    enum EVBitfieldOrientations { HORIZONTAL, VERTICAL };
    
    orientation = _orientation;
    
    AddOptions = function(elements) {
        if (!is_array(elements)) {
            elements = [elements];
        }
        for (var i = 0; i < array_length(elements); i++) {
            if (!is_struct(elements[i])) {
                elements[i] = new VBitfieldOption(string(elements[i]), 1 << (ds_list_size(contents) + i),
                function() {
                    root.callback();
                },
                function() {
                    return !!(root.value & value);
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
                option.width = floor(width / ds_list_size(contents));
                option.height = height;
                option.x = option.width * i;
                option.y = 0;
            }
        } else {
            for (var i = 0; i < ds_list_size(contents); i++) {
                var option = contents[| i];
                option.width = width;
                option.height = floor(height / ds_list_size(contents));
                option.x = 0;
                option.y = option.height * i;
            }
        }
    }
    
    GetHeight = function() {
        return ds_list_empty(contents) ? height : contents[| ds_list_size(contents) - 1].y + contents[| ds_list_size(contents) - 1].height;
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
        /*
        if (interactive && dialog_is_active(bitfield.root.root)) {
            var inbounds = mouse_within_rectangle_determine(x1, y1, x2, y2, bitfield.adjust_view);
            if (inbounds) {
                if (Controller.release_left) {
                    ui_activate(bitfield);
                    script_execute(bitfield.onvaluechange, bitfield);
                }
                Stuff.element_tooltip = bitfield.root;
            }
        }*/
    }
}