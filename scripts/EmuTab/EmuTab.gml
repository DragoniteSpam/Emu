// Emu (c) 2020 @dragonitespam
// See the Github wiki for documentation: https://github.com/DragoniteSpam/Emu/wiki
function EmuTab(_name) : EmuCore(0, 0, 0, 0) constructor {
    text = _name;
    
    alignment = fa_center;
    valignment = fa_middle;
    row = 0;
    index = 0;
    header_x = 0;
    header_y = 0;
    header_width = 0;
    header_height = 0;
    
    color_hover = EMU_COLOR_HOVER;
    color_back = EMU_COLOR_BACK;
    color_disabled = EMU_COLOR_DISABLED;
    
    Render = function(base_x, base_y) {
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
        
        if (isActiveTab() || row < root.rows - 1) {
            var index = 3;
        } else {
            var index = 5;
        }
        
        var back_color = getMouseHover(hx1, hy1, hx2, hy2) ? color_hover : (GetInteractive() ? color_back : color_disabled);
        drawNineslice(4, hx1, hy1, hx2, hy2, back_color, 1);
        drawNineslice(index, hx1, hy1, hx2, hy2, color, 1);
        scribble_set_box_align(alignment, valignment);
        scribble_set_wrap(header_width, header_height);
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
        return (root.active_tab == self);
    }
    
    RequestActivate = function() {
        root.RequestActivateTab(self);
    }
    
    GetInteractive = function() {
        return enabled && interactive && root.isActiveDialog();
    }
}