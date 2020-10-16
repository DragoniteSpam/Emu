// Emu (c) 2020 @dragonitespam
// See the Github wiki for documentation: https://github.com/DragoniteSpam/Emu/wiki
function EmuBitfield(x, y, w, h, value, callback) : EmuCallback(x, y, w, h, value, callback) constructor {
    enum E_BitfieldOrientations { HORIZONTAL, VERTICAL };
    
    self._fixed_spacing = -1;
    self._orientation = E_BitfieldOrientations.HORIZONTAL;
    
    SetOrientation = function(orientation) {
        _orientation = orientation;
        ArrangeElements();
    }
    
    SetFixedSpacing = function(spacing) {
        _fixed_spacing = spacing;
        ArrangeElements();
    }
    
    SetAutoSpacing = function() {
        _fixed_spacing = -1;
        ArrangeElements();
    }
    
    AddOptions = function(elements) {
        if (!is_array(elements)) {
            elements = [elements];
        }
        
        for (var i = 0; i < array_length(elements); i++) {
            if (!is_struct(elements[i])) {
                elements[i] = new EmuBitfieldOption(string(elements[i]), 1 << (ds_list_size(_contents) + i),
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
        if (_orientation == E_BitfieldOrientations.HORIZONTAL) {
            for (var i = 0; i < ds_list_size(_contents); i++) {
                var option = _contents[| i];
                option.width = (_fixed_spacing == -1) ? floor(width / ds_list_size(_contents)) : _fixed_spacing;
                option.height = height;
                option.x = option.width * i;
                option.y = 0;
            }
        } else {
            for (var i = 0; i < ds_list_size(_contents); i++) {
                var option = _contents[| i];
                option.width = width;
                option.height = (_fixed_spacing == -1) ? floor(height / ds_list_size(_contents)) : _fixed_spacing;
                option.x = 0;
                option.y = option.height * i;
            }
        }
    }
    
    GetHeight = function() {
        var first = _contents[| 0];
        var last = _contents[| ds_list_size(_contents) - 1];
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

function EmuBitfieldOption(text, value, callback, eval) : EmuCallback(0, 0, 0, 0, value, callback) constructor {
    SetEval = function(eval) {
        evaluate = method(self, eval);
    }
    
    self.text = text;
    SetEval(eval);
    
    self.color_hover = EMU_COLOR_HOVER;
    self.color_disabled = EMU_COLOR_DISABLED;
    self.color_active = EMU_COLOR_SELECTED;
    self.color_inactive = EMU_COLOR_BACK;
    
    Render = function(base_x, base_y) {
        var x1 = x + base_x;
        var y1 = y + base_y;
        var x2 = x1 + width;
        var y2 = y1 + height;
        
        var back_color = evaluate() ? color_active : color_inactive;
        
        if (root.GetInteractive()) {
            back_color = merge_colour(back_color, getMouseHover(x1, y1, x2, y2) ? color_hover : back_color, 0.5);
        } else {
            back_color = merge_colour(back_color, color_disabled, 0.5);
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