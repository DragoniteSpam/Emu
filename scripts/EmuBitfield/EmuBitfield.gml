// Emu (c) 2020 @dragonitespam
// See the Github wiki for documentation: https://github.com/DragoniteSpam/Documentation/wiki/Emu

// feather use syntax-errors
function EmuBitfield(x, y, width, height, value, callback) : EmuCallback(x, y, width, height, "bitfield", value, callback) constructor {
    enum E_BitfieldOrientations { HORIZONTAL, VERTICAL };
    
    /// @ignore
    self.fixed_spacing = -1;
    /// @ignore
    self.orientation = E_BitfieldOrientations.HORIZONTAL;
    
    #region mutators
    self.SetFixedSpacing = function(spacing) {
        self.fixed_spacing = spacing;
        self.ArrangeElements();
        return self;
    };
    
    self.SetAutoSpacing = function() {
        self.fixed_spacing = -1;
        self.ArrangeElements();
        return self;
    };
    
    self.SetOrientation = function(orientation) {
        self.orientation = orientation;
        self.ArrangeElements();
        return self;
    };
    #endregion
    
    #region accessors
    self.GetHeight = function() {
        var first = self.contents[0];
        var last = self.contents[array_length(self.contents) - 1];
        return (first == undefined) ? self.height : (last.y + last.height - first.y);
    };
    #endregion
    
    #region other methods
    self.AddOptions = function(elements) {
        if (!is_array(elements)) {
            elements = [elements];
        }
        
        for (var i = 0; i < array_length(elements); i++) {
            if (!is_struct(elements[i])) {
                elements[i] = new EmuBitfieldOption(string(elements[i]), 1 << (array_length(self.contents) + i),
                    function() {
                        self.root.value ^= self.value;
                        self.root.callback();
                    },
                    function() {
                        return (self.root.value & self.value) == self.value;
                    }
                );
            }
        }
        
        self.AddContent(elements);
        self.ArrangeElements();
        return self;
    };
    
    self.ArrangeElements = function() {
        if (self.orientation == E_BitfieldOrientations.HORIZONTAL) {
            for (var i = 0, n = array_length(self.contents); i < n; i++) {
                var option = self.contents[i];
                option.width = (self.fixed_spacing == -1) ? floor(self.width / n) : self.fixed_spacing;
                option.height = self.height;
                option.x = option.width * i;
                option.y = 0;
            }
        } else {
            for (var i = 0, n = array_length(self.contents); i < n; i++) {
                var option = self.contents[i];
                option.width = self.width;
                option.height = (self.fixed_spacing == -1) ? floor(self.height / n) : self.fixed_spacing;
                option.x = 0;
                option.y = option.height * i;
            }
        }
        return self;
    };
    
    self.Render = function(x, y, debug_render = false) {
        self.update_script();
        self.processAdvancement();
        
        var x1 = self.x + x;
        var y1 = self.y + y;
        var x2 = x1 + self.width;
        var y2 = y1 + self.height;
        
        if (debug_render) self.renderDebugBounds(x1, y1, x2, y2);
        
        self.renderContents(x1, y1);
    };
    #endregion
}

function EmuBitfieldOption(text, value, callback, eval) : EmuCallback(0, 0, 0, 0, text, value, callback) constructor {
    /// @ignore
    self.eval = method(self, eval);
    
    /// @ignore
    self.color_hover = function() { return EMU_COLOR_HOVER; };
    /// @ignore
    self.color_disabled = function() { return EMU_COLOR_DISABLED; };
    /// @ignore
    self.color_active = function() { return EMU_COLOR_SELECTED; };
    /// @ignore
    self.color_inactive = function() { return EMU_COLOR_BACK; };
    
    #region mutators
    self.SetEval = function(eval) {
        self.evaluate = method(self, eval);
    };
    #endregion
    
    #region accessors
    self.GetInteractive = function() {
        return self.enabled && self.interactive && self.root.interactive && self.root.isActiveDialog();
    };
    #endregion
    
    #region other methods
    self.Render = function(x, y, debug_render = false) {
        var x1 = self.x + x;
        var y1 = self.y + y;
        var x2 = x1 + self.width;
        var y2 = y1 + self.height;
        
        var back_color = self.evaluate() ? self.color_active() : self.color_inactive();
        
        if (self.root.GetInteractive()) {
            back_color = merge_colour(back_color, self.getMouseHover(x1, y1, x2, y2) ? self.color_hover() : back_color, 0.5);
        } else {
            back_color = merge_colour(back_color, self.color_disabled(), 0.5);
        }
        
        draw_sprite_stretched_ext(self.sprite_nineslice, 1, x1, y1, x2 - x1, y2 - y1, back_color, 1);
        draw_sprite_stretched_ext(self.sprite_nineslice, 0, x1, y1, x2 - x1, y2 - y1, self.color(), 1);
        
        scribble(self.text)
            .align(fa_center, fa_middle)
            .draw(floor(mean(x1, x2)), floor(mean(y1, y2)));
        
        if (self.getMouseHover(x1, y1, x2, y2)) {
            self.ShowTooltip();
        }
        
        if (self.getMousePressed(x1, y1, x2, y2)) {
            self.callback();
            self.root.callback();
        }
        
        if (debug_render) self.renderDebugBounds(x1, y1, x2, y2);
    };
    #endregion
}

// You may find yourself using these particularly often
function emu_bitfield_option_callback_toggle() {
    self.root.value ^= self.value;
}

function emu_bitfield_option_callback_exact() {
    self.root.value = self.value;
}

function emu_bitfield_option_eval_includes() {
    return (self.root.value & self.value) > 0;
}

function emu_bitfield_option_eval_exact() {
    return self.root.value == self.value;
}
