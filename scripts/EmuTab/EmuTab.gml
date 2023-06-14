// Emu (c) 2020 @dragonitespam
// See the Github wiki for documentation: https://github.com/DragoniteSpam/Documentation/wiki/Emu

// feather use syntax-errors
function EmuTab(name) : EmuCore(0, 0, 0, 0, name) constructor {
    self.align.h = fa_center;
    self.align.v = fa_middle;
    
    self.sprite_nineslice = spr_emu_nineslice_tab;
    
    self.color_hover = function() { return EMU_COLOR_HOVER; };
    self.color_back = function() { return EMU_COLOR_BACK; };
    self.color_disabled = function() { return EMU_COLOR_DISABLED; };
    
    self.row = 0;
    self.index = 0;
    self.header_x = 0;
    self.header_y = 0;
    self.header_width = 0;
    self.header_height = 0;
    
    self.override_root_check = true;
    
    self.Render = function(base_x, base_y, debug_render = false) {
        self.update_script();
        self.processAdvancement();
        
        var x1 = x + base_x;
        var y1 = y + base_y;
        var x2 = x1 + self.width;
        var y2 = y1 + self.height;
        
        #region header stuff
        var hx1 = self.header_x + base_x;
        var hy1 = self.header_y + base_y - self.root.rows * self.root.row_height;
        var hx2 = hx1 + self.header_width;
        var hy2 = hy1 + self.header_height;
        
        if (self.getMouseHover(x1, y1, x2, y2)) {
            self.ShowTooltip();
        }
        
        if (self.getMouseReleased(hx1, hy1, hx2, hy2)) {
            self.Activate();
            self.root.RequestActivateTab(self);
        }
        
        var index = (self.isActiveTab() || self.root.active_tab && (self.root.active_tab.row != self.row)) ? 0 : 2;
        var back_color = self.getMouseHover(hx1, hy1, hx2, hy2) ? self.color_hover() : (self.GetInteractive() ? self.color_back() : self.color_disabled());
        draw_sprite_stretched_ext(self.sprite_nineslice, 1, hx1, hy1, hx2 - hx1, hy2 - hy1, back_color, 1);
        draw_sprite_stretched_ext(self.sprite_nineslice, index, hx1, hy1, hx2 - hx1, hy2 - hy1, self.color(), 1);
        
        scribble(self.text)
            .wrap(self.header_width, self.header_height)
            .align(self.align.h, self.align.v)
            .draw(floor(mean(hx1, hx2)), floor(mean(hy1, hy2)));
        #endregion
        
        if (debug_render) self.renderDebugBounds(hx1, hy1, hx2, hy2);
        
        if (self.isActiveTab()) {
            self.renderContents(x1, y1, debug_render);
        }
    };
    
    // This is NOT the same as isActiveElement() - this checks for the active
    // tab in the tab group, rather than the UI element which will respond to
    // keyboard input
    self.isActiveTab = function() {
        return (self.root.active_tab == self);
    };
    
    self.RequestActivate = function() {
        self.root.RequestActivateTab(self);
        return self;
    };
    
    self.GetInteractive = function() {
        return self.enabled && self.interactive && self.root.isActiveDialog();
    };
}