// Emu (c) 2020 @dragonitespam
// See the Github wiki for documentation: https://github.com/DragoniteSpam/Documentation/wiki/Emu

function EmuDialog(w, h, title, callback = function() { EmuOverlay.Pop(); }) : EmuCallback(0, 0, w, h, title, 0, callback) constructor {
    static drawn_dialog_shade_time = -1;
    
    _emu_active_element(undefined);
    
    var size = array_length(EmuOverlay.contents);
    self.x = 64 * (size + 1);
    self.y = 64 * (size + 1);
    
    /// @ignore
    self.active_shade = EMU_DIALOG_SHADE_ALPHA;
    /// @ignore
    self.close_button = true;
    
    /// @ignore
    self.changed = false;
    /// @ignore
    self.sprite_close = spr_emu_close;
    /// @ignore
    self.color_header = function() { return EMU_COLOR_WINDOWSKIN; };
    /// @ignore
    self.color_back = function() { return EMU_COLOR_BACK; };
    
    /// @ignore
    self.header_height = 32;
    /// @ignore
    self.click_x = -1;
    /// @ignore
    self.click_y = -1;
    /// @ignore
    self.disposed = false;
    
    EmuOverlay.AddContent(self);
    
    #region mutators
    static SetCloseButton = function(show) {
        self.close_button = show;
        return self;
    };
    
    static SetSpriteClose = function(sprite) {
        self.sprite_close = sprite;
        return self;
    };
    
    static SetActiveShade = function(shade) {
        self.active_shade = shade;
        return self;
    };
    
    static SetTitle = function(text) {
        self.text = text;
        return self;
    };
    #endregion
    
    #region accessors
    static GetHeight = function() {
        return self.height + self.header_height;
    };
    #endregion
    
    #region public methods
    static Close = function() {
        // this needs to be done after the entire dialog box is finished rendering
        self.disposed = true;
    };
    
    static Render = function() {
        self.gc.Clean();
        self.update_script();
        
        var x1 = x;
        var y1 = y;
        var x2 = x1 + self.width;
        var y2 = y1 + self.GetHeight();
        
        var cbx1 = x2 - sprite_get_width(self.sprite_close);
        var cbx2 = x2;
        var cby1 = y1;
        var cby2 = y1 + sprite_get_height(self.sprite_close);
        var cbi = 2;  // 0 is is available, 1 is hovering, 2 is unavailable
        
        var active = self.isActiveDialog();
        var kill = false;
        
        if (active) {
            cbi = 0;
            if (self.getMouseHover(x1, y1, x2, y1 + self.header_height)) {
                if (self.close_button && self.getMouseHover(cbx1, cby1, cbx2, cby2)) {
                    cbi = 1;
                    if (self.getMouseReleased(cbx1, cby1, cbx2, cby2)) {
                        kill = true;
                        _emu_active_element(undefined);
                    }
                } else {
                    if (self.getMousePressed(x1, y1, x2, y1 + self.header_height)) {
                        self.click_x = device_mouse_x_to_gui(0);
                        self.click_y = device_mouse_y_to_gui(0);
                    }
                    if (self.getMouseReleased(x1, y1, x2, y1 + self.header_height)) {
                        self.click_x = -1;
                        self.click_y = -1;
                    }
                }
            }
            
            if (self.getMouseHold(0, 0, window_get_width(), window_get_height()) && self.click_x > -1) {
                self.x += (device_mouse_x_to_gui(0) - self.click_x);
                self.y += (device_mouse_y_to_gui(0) - self.click_y);
                self.click_x = device_mouse_x_to_gui(0);
                self.click_y = device_mouse_y_to_gui(0);
            }
        }
        
        // re-set these in case you dragged the window around
        var x1 = x;
        var y1 = y;
        var x2 = x1 + self.width;
        var y2 = y1 + self.GetHeight();
        
        var tx = x1 + self.offset;
        var ty = floor(mean(y1, y1 + self.header_height));
        
        var cbx1 = x2 - sprite_get_width(self.sprite_close);
        var cbx2 = x2;
        var cby1 = y1;
        var cby2 = y1 + sprite_get_height(self.sprite_close);
        
        // tint the screen behind the active dialog (but only once per frame)
        if (active && (self.drawn_dialog_shade_time != current_time)) {
            draw_set_alpha(self.active_shade);
            draw_rectangle_colour(0, 0, window_get_width(), window_get_height(), EMU_DIALOG_SHADE_COLOR, EMU_DIALOG_SHADE_COLOR, EMU_DIALOG_SHADE_COLOR, EMU_DIALOG_SHADE_COLOR, false);
            draw_set_alpha(1);
            self.drawn_dialog_shade_time = current_time;
        }
        
        draw_sprite_stretched_ext(self.sprite_nineslice, 1, x1, y1, x2 - x1, y2 - y1, self.color_back(), 1);
        draw_sprite_stretched_ext(self.sprite_nineslice, 0, x1, y1, x2 - x1, y2 - y1, self.color(), 1);
        var ch = merge_colour(self.color_header(), EMU_DIALOG_SHADE_COLOR, active ? 0 : 0.5);
        draw_sprite_stretched_ext(self.sprite_nineslice, 1, x1, y1, x2 - x1, self.header_height, ch, 1);
        draw_sprite_stretched_ext(self.sprite_nineslice, 0, x1, y1, x2 - x1, self.header_height, self.color(), 1);
        
        scribble(self.text)
            .wrap(self.width, self.header_height)
            .align(fa_left, fa_middle)
            .draw(tx, ty);
        
        if (self.close_button) {
            draw_sprite(self.sprite_close, cbi, cbx1, cby1);
        }
        
        self.renderContents(x1, y1 + self.header_height);
        
        kill |= (active && self.close_button && keyboard_check_released(vk_escape) && !(EmuActiveElement && EmuActiveElement.override_escape)) || self.disposed;
        
        if (kill) {
            self.callback();
        }
    };
    #endregion
    
    #region private methods
    // Override this function for dialogs
    static isActiveDialog = function() {
        return (EmuOverlay.contents[array_length(EmuOverlay.contents) - 1] == self);
    };
    #endregion
}

function emu_dialog_close_auto() {
    self.root.Close();
}