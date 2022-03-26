// Emu (c) 2020 @dragonitespam
// See the Github wiki for documentation: https://github.com/DragoniteSpam/Documentation/wiki/Emu
function EmuCheckbox(x, y, w, h, text, value, callback) : EmuCallback(x, y, w, h, text, value, callback) constructor {
    /// @ignore
    self.box_size = 20;
    /// @ignore
    self.sprite_check = spr_emu_checkbox;
    /// @ignore
    self.sprite_check_border = spr_emu_checkbox_border;
    
    /// @ignore
    self.color_active = function() { return EMU_COLOR_RADIO_ACTIVE; };
    /// @ignore
    self.color_hover = function() { return EMU_COLOR_HOVER; };
    /// @ignore
    self.color_disabled = function() { return EMU_COLOR_DISABLED; };
    /// @ignore
    self.color_back = function() { return EMU_COLOR_BACK; };
    
    #region mutators
    static SetBoxSize = function(size) {
        self.box_size = size;
        return self;
    };
    
    static SetSpriteCheck = function(sprite) {
        self.box_size = sprite;
        return self;
    };
    
    static SetSpriteBorder = function(sprite) {
        self.box_size = sprite;
        return self;
    };
    
    static SetColorActive = function(color_function) {
        self.color_active = method(self, color_function);
        return self;
    };
    
    static SetColorHover = function(color_function) {
        self.color_hover = method(self, color_function);
        return self;
    };
    
    static SetColorDisabled = function(color_function) {
        self.color_disabled = method(self, color_function);
        return self;
    };
    
    static SetColorBack = function(color_function) {
        self.color_back = method(self, color_function);
        return self;
    };
    #endregion
    
    #region other methods
    static Render = function(x, y) {
        self.gc.Clean();
        self.update_script();
        self.processAdvancement();
        
        var x1 = self.x + x;
        var y1 = self.y + y;
        var x2 = x1 + self.width;
        var y2 = y1 + self.height;
        
        if (self.getMouseHover(x1, y1, x2, y2)) {
            self.ShowTooltip();
        }
        
        if (self.getMouseReleased(x1, y1, x2, y2)) {
            self.Activate();
            self.value = !self.value;
            self.callback();
        }
        
        var bx = x1 + self.offset + self.box_size / 2;
        var by = mean(y1, y2);
        var bx1 = bx - self.box_size / 2;
        var by1 = by - self.box_size / 2;
        var bx2 = bx + self.box_size / 2;
        var by2 = by + self.box_size / 2;
        var back_color = self.getMouseHover(x1, y1, x2, y2) ? self.color_hover() : (self.GetInteractive() ? self.color_back() : self.color_disabled());
        draw_sprite_ext(self.sprite_check_border, 1, bx, by, 1, 1, 0, back_color, 1);
        draw_sprite_ext(self.sprite_check, self.value, bx, by, 1, 1, 0, self.color_active(), 1);
        draw_sprite_ext(self.sprite_check_border, 0, bx, by, 1, 1, 0, self.color(), 1);
        
        scribble(self.text)
            .wrap(self.width, self.height)
            .align(self.align.h, self.align.v)
            .draw(x1 + self.box_size + self.offset * 2, floor(mean(y1, y2)));
    };
    #endregion
}