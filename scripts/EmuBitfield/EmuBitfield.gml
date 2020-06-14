// Emu (c) 2020 @dragonitespam
// See the Github wiki for documentation: https://github.com/DragoniteSpam/Emu/wiki
function EmuBitfield(_x, _y, _w, _h, _value, _callback) : EmuCallback(_x, _y, _w, _h, _value, _callback) constructor {
    enum E_BitfieldOrientations { HORIZONTAL, VERTICAL };
    
    fixed_spacing = -1;
    orientation = E_BitfieldOrientations.HORIZONTAL;
    
    SetOrientation = function(_orientation) {
        orientation = _orientation;
        ArrangeElements();
    }
    
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
                elements[i] = new EmuBitfieldOption(string(elements[i]), 1 << (ds_list_size(contents) + i),
                function() {
                    root.value ^= value;
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
    
    ArrangeElements = function() {
        if (orientation == E_BitfieldOrientations.HORIZONTAL) {
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
    
    GetHeight = function() {
        var first = contents[| 0];
        var last = contents[| ds_list_size(contents) - 1];
        return (first == undefined) ? height : (last.y + last.height - first.y);
    }
    
    Render = function(base_x, base_y) {
        processAdvancement();
        
        var x1 = x + base_x;
        var y1 = y + base_y;
        var x2 = x1 + width;
        var y2 = y1 + height;
        
        renderContents(x1, y1);
    }
}

function EmuBitfieldOption(_text, _value, _callback, _eval) : EmuCallback(0, 0, 0, 0, _value, _callback) constructor {
    SetEval = function(_eval) {
        evaluate = method(self, _eval);
    }
    
    text = _text;
    SetEval(_eval);
    
    color_active = EMU_COLOR_SELECTED;
    color_inactive = EMU_COLOR_BACK;
    
    Render = function(base_x, base_y) {
        var x1 = x + base_x;
        var y1 = y + base_y;
        var x2 = x1 + width;
        var y2 = y1 + height;
        
        var back_color = evaluate() ? color_active : color_inactive;
        
        if (root.GetInteractive()) {
            back_color = merge_colour(back_color, getMouseHover(x1, y1, x2, y2) ? EMU_COLOR_HOVER : back_color, 0.5);
        } else {
            back_color = merge_colour(back_color, EMU_COLOR_DISABLED, 0.5);
        }
        
        drawNineslice(1, x1, y1, x2, y2, back_color, 1);
        drawNineslice(0, x1, y1, x2, y2, color, 1);
        scribble_set_box_align(fa_center, fa_middle);
        scribble_draw(floor(mean(x1, x2)), floor(mean(y1, y2)), text);
        
        if (getMouseHover(x1, y1, x2, y2)) {
            ShowTooltip();
        }
        
        if (getMousePressed(x1, y1, x2, y2)) {
            callback();
        }
    }
    
    GetInteractive = function() {
        return enabled && interactive && root.interactive && root.isActiveDialog();
    }
}

// You may find yourself using these particularly often
function emu_bitfield_option_exact_callback() {
    root.value = value;
    root.callback();
}

function emu_bitfield_option_exact_eval() {
    return root.value == value;
};