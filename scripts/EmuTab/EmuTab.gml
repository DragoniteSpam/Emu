// Emu (c) 2020 @dragonitespam
// See the Github wiki for documentation: https://github.com/DragoniteSpam/Documentation/wiki/Emu
function EmuTab(name) : EmuCore(0, 0, 0, 0, name) constructor {
    self.align.h = fa_center;
    self.align.v = fa_middle;
    
    self.sprite_nineslice = spr_emu_nineslice_tab;
    
    self.color_hover = function() { return EMU_COLOR_HOVER };
    self.color_back = function() { return EMU_COLOR_BACK };
    self.color_disabled = function() { return EMU_COLOR_DISABLED };
    
    self.row = 0;
    self.index = 0;
    self.header_x = 0;
    self.header_y = 0;
    self.header_width = 0;
    self.header_height = 0;
    
    self.override_root_check = true;
    
    static Render = function(base_x, base_y) {
        self.gc.Clean();
        processAdvancement();
        
        var x1 = x + base_x;
        var y1 = y + base_y;
        var x2 = x1 + width;
        var y2 = y1 + height;
        
        #region header stuff
        var hx1 = header_x + base_x;
        var hy1 = header_y + base_y - root.rows * root.row_height;
        var hx2 = hx1 + header_width;
        var hy2 = hy1 + header_height;
        
        if (getMouseHover(x1, y1, x2, y2)) {
            ShowTooltip();
        }
        
        if (getMouseReleased(hx1, hy1, hx2, hy2)) {
            Activate();
            root.RequestActivateTab(self);
        }
        
        if (isActiveTab() || root.active_tab && (root.active_tab.row != row)) {
            var index = 0;
        } else {
            var index = 2;
        }
        
        var back_color = getMouseHover(hx1, hy1, hx2, hy2) ? self.color_hover() : (GetInteractive() ? self.color_back() : self.color_disabled());
        draw_sprite_stretched_ext(sprite_nineslice, 1, hx1, hy1, hx2 - hx1, hy2 - hy1, back_color, 1);
        draw_sprite_stretched_ext(sprite_nineslice, index, hx1, hy1, hx2 - hx1, hy2 - hy1, self.color(), 1);
        
        scribble(self.text)
            .wrap(self.header_width, self.header_height)
            .align(self.align.h, self.align.v)
            .draw(floor(mean(hx1, hx2)), floor(mean(hy1, hy2)));
        #endregion
        
        if (isActiveTab()) {
            renderContents(x1, y1);
        }
    };
    
    // This is NOT the same as isActiveElement() - this checks for the active
    // tab in the tab group, rather than the UI element which will respond to
    // keyboard input
    static isActiveTab = function() {
        return (root.active_tab == self);
    };
    
    static RequestActivate = function() {
        root.RequestActivateTab(self);
        return self;
    };
    
    static GetInteractive = function() {
        return enabled && interactive && root.isActiveDialog();
    };
}