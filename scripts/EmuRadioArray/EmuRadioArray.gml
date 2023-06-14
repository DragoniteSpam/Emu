// Emu (c) 2020 @dragonitespam
// See the Github wiki for documentation: https://github.com/DragoniteSpam/Documentation/wiki/Emu

// feather use syntax-errors
function EmuRadioArray(x, y, width, height, text, value, callback) : EmuCallback(x, y, width, height, text, value, callback) constructor {
    self.column_capacity = 10000;
    self.column_width = self.width;
    
    self.AddOptions = function(elements) {
        if (!is_array(elements)) {
            elements = [elements];
        }
        
        for (var i = 0; i < array_length(elements); i++) {
            elements[i] = new self.emu_radio_array_option(0, self.height * (1 + i), self.width, self.height, elements[i], i);
        }
        
        self.AddContent(elements);
        self.SetColumns(self.column_capacity, self.column_width);
        return self;
    };
    
    self.SetColumns = function(column_capacity, column_width = undefined) {
        if (column_width == undefined || column_capacity <= 0) {
            column_capacity = 10000;
            column_width = self.width;
        }
        self.column_capacity = column_capacity;
        self.column_width = column_width;
        
        for (var i = 0, n = array_length(self.contents); i < n; i++) {
            var option = self.contents[i];
            option.x = (i div column_capacity) * column_width;
            option.y = self.height * (1 + (i % column_capacity));
            option.width = column_width;
        }
        self.width = ceil(array_length(self.contents) / column_capacity) * column_width;
        return self;
    };
    
    self.GetHeight = function() {
        var maximum_height = self.height;
        for (var i = 0, n = array_length(self.contents); i < n; i++) {
            maximum_height = max(self.contents[i].y + self.height, maximum_height);
        }
        return maximum_height;
    };
    
    self.Render = function(base_x, base_y, debug_render = false) {
        self.update_script();
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
        
        scribble(self.text)
            .wrap(self.width, self.height)
            .align(fa_left, fa_middle)
            .draw(tx, ty);
        
        if (debug_render) self.renderDebugBounds(x1, y1, x2, y2);
        
        self.renderContents(x1, y1, debug_render);
    };
    
    self.emu_radio_array_option = function(x, y, width, height, text, value) : EmuCore(x, y, width, height, text) constructor {
        self.value = value;
        
        self.color_active = function() { return EMU_COLOR_RADIO_ACTIVE; };
        self.color_back_disabled = function() { return EMU_COLOR_DISABLED; };
        self.color_back = function() { return EMU_COLOR_BACK; };
        
        self.sprite_radio = EMU_SPRITE_RADIO;
        
        self.Render = function(base_x, base_y, debug_render = false) {
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
            
            scribble(self.text)
                .wrap(self.width, self.height)
                .align(fa_left, fa_center)
                .draw(tx + self.offset + sprite_get_width(self.sprite_radio), ty);
            
            if (debug_render) self.renderDebugBounds(x1, y1, x2, y2);
        }
        
        self.GetInteractive = function() {
            return self.enabled && self.interactive && self.root.interactive && self.root.isActiveDialog();
        }
    };
}