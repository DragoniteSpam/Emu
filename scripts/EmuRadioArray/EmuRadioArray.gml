// Emu (c) 2020 @dragonitespam
// See the Github wiki for documentation: https://github.com/DragoniteSpam/Documentation/wiki/Emu
function EmuRadioArray(x, y, w, h, text, value, callback) : EmuCallback(x, y, w, h, value, callback) constructor {
    self.text = text;
    
    static AddOptions = function(elements) {
        if (!is_array(elements)) {
            elements = [elements];
        }
        
        for (var i = 0; i < array_length(elements); i++) {
            elements[i] = new emu_radio_array_option(0, height * (1 + i), width, height, elements[i], i);
        }
        
        AddContent(elements);
        return self;
    }
    
    static SetColumns = function(_column_capacity, _column_width) {
        if (_column_capacity <= 0) _column_capacity = 10000;
        for (var i = 0; i < ds_list_size(self._contents); i++) {
            var option = self._contents[| i];
            option.x = (i div _column_capacity) * _column_width;
            option.y = self.height * (1 + (i % _column_capacity));
            option.width = _column_width;
        }
        self.width = (ds_list_size(self._contents) div _column_capacity) * _column_width;
        return self;
    }
    
    static GetHeight = function() {
        var maximum_height = self.height;
        for (var i = 0; i < ds_list_size(self._contents); i++) {
            maximum_height = max(self._contents[| i].y + self.height, maximum_height);
        }
        return maximum_height;
    }
    
    static Render = function(base_x, base_y) {
        self.processAdvancement();
        
        var x1 = x + base_x;
        var y1 = y + base_y;
        var x2 = x1 + self.width;
        var y2 = y1 + self.height;
        
        var tx = self.getTextX(x1);
        var ty = self.getTextY(y1);
        
        if (self.getMouseHover(x1, y1, x2, y2)) {
            self.ShowTooltip();
        }
        
        scribble_set_wrap(self.width, self.height);
        scribble_set_box_align(fa_left, fa_middle);
        scribble_draw(tx, ty, self.text);
        
        self.renderContents(x1, y1);
    }
    
    static emu_radio_array_option = function(x, y, w, h, text, value) : EmuCore(x, y, w, h) constructor {
        self.text = text;
        self.value = value;
        
        self.color_active = function() { return EMU_COLOR_RADIO_ACTIVE };
        self.color_back_disabled = function() { return EMU_COLOR_DISABLED };
        self.color_back = function() { return EMU_COLOR_BACK };
        
        self.sprite_radio = spr_emu_radio;
        
        static Render = function(base_x, base_y) {
            var x1 = x + base_x;
            var y1 = y + base_y;
            var x2 = x1 + self.width;
            var y2 = y1 + self.height;
            
            var tx = self.getTextX(x1);
            var ty = self.getTextY(y1);
            
            if (self.getMouseHover(x1, y1, x2, y2)) {
                self.ShowTooltip();
            }
            
            if (self.getMouseReleased(x1, y1, x2, y2)) {
                self.root.Activate();
                // radio array options don't get individual callbacks
                self.root.value = value;
                self.root.callback();
            }
            
            draw_sprite_ext(self.sprite_radio, 2, tx + self.offset, ty, 1, 1, 0, self.root.GetInteractive() ? self.color_back() : self.color_back_disabled(), 1);
            draw_sprite_ext(self.sprite_radio, 1, tx + self.offset, ty, 1, 1, 0, self.color(), 1);
            draw_sprite_ext(self.sprite_radio, 0, tx + self.offset, ty, 1, 1, 0, self.color(), 1);
            if (self.value == self.root.value) {
                draw_sprite_ext(self.sprite_radio, 3, tx + self.offset, ty, 1, 1, 0, self.color_active(), self.GetInteractive());
            }
            
            scribble_set_box_align(fa_left, fa_center);
            scribble_set_wrap(self.width, self.height);
            scribble_draw(tx + self.offset + sprite_get_width(self.sprite_radio), ty, self.text);
        }
        
        static GetInteractive = function() {
            return self.enabled && self.interactive && self.root.interactive && self.root.isActiveDialog();
        }
    }
}