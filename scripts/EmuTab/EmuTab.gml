// Emu (c) 2020 @dragonitespam
// See the Github wiki for documentation: https://github.com/DragoniteSpam/Documentation/wiki/Emu
function EmuTab(name) : EmuCore(0, 0, 0, 0) constructor {
    self.text = name;
    
    self.alignment = fa_center;
    self.valignment = fa_middle;
    self.sprite_nineslice = spr_emu_nineslice_tab;
    
    self.color_hover = function() { return EMU_COLOR_HOVER };
    self.color_back = function() { return EMU_COLOR_BACK };
    self.color_disabled = function() { return EMU_COLOR_DISABLED };
    
    self._row = 0;
    self._index = 0;
    self._header_x = 0;
    self._header_y = 0;
    self._header_width = 0;
    self._header_height = 0;
    
    self._override_root_check = true;
    
    Render = function(base_x, base_y) {
        processAdvancement();
        
        var x1 = x + base_x;
        var y1 = y + base_y;
        var x2 = x1 + width;
        var y2 = y1 + height;
        
        #region header stuff
        var hx1 = _header_x + base_x;
        var hy1 = _header_y + base_y - root._rows * root._row_height;
        var hx2 = hx1 + _header_width;
        var hy2 = hy1 + _header_height;
        
        if (getMouseHover(x1, y1, x2, y2)) {
            ShowTooltip();
        }
        
        if (getMouseReleased(hx1, hy1, hx2, hy2)) {
            Activate();
            root.RequestActivateTab(self);
        }
        
        if (isActiveTab() || root._active_tab && (root._active_tab._row != _row)) {
            var index = 0;
        } else {
            var index = 2;
        }
        
        var back_color = getMouseHover(hx1, hy1, hx2, hy2) ? self.color_hover() : (GetInteractive() ? self.color_back() : self.color_disabled());
        draw_sprite_stretched_ext(sprite_nineslice, 1, hx1, hy1, hx2 - hx1, hy2 - hy1, back_color, 1);
        draw_sprite_stretched_ext(sprite_nineslice, index, hx1, hy1, hx2 - hx1, hy2 - hy1, self.color(), 1);
        scribble_set_box_align(alignment, valignment);
        scribble_set_wrap(_header_width, _header_height);
        scribble_draw(floor(mean(hx1, hx2)), floor(mean(hy1, hy2)), text);
        #endregion
        
        if (isActiveTab()) {
            renderContents(x1, y1);
        }
    }
    
    // This is NOT the same as isActiveElement() - this checks for the active
    // tab in the tab group, rather than the UI element which will respond to
    // keyboard input
    isActiveTab = function() {
        return (root._active_tab == self);
    }
    
    RequestActivate = function() {
        root.RequestActivateTab(self);
        return self;
    }
    
    GetInteractive = function() {
        return enabled && interactive && root.isActiveDialog();
    }
}