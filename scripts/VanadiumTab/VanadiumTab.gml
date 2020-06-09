function VTab(_name) : VCore(0, 0, 0, 0) constructor {
    text = _name;
    
    alignment = fa_center;
    valignment = fa_middle;
    row = 0;
    index = 0;
    header_x = 0;
    header_y = 0;
    header_width = 0;
    header_height = 0;
    
    Render = function(base_x, base_y) {
        var x1 = x + base_x;
        var y1 = y + base_y;
        var x2 = x1 + width;
        var y2 = y1 + height;
        
        #region header stuff
        var hx1 = header_x + base_x;
        var hy1 = header_y + base_y - root.rows * root.row_height;
        var hx2 = hx1 + header_width;
        var hy2 = hy1 + header_height;
        
        if (GetMouseReleased(hx1, hy1, hx2, hy2)) {
            root.RequestActivateTab(self);
        }
        
        if (IsActive() || row < root.rows - 1) {
            var index = 3;
        } else {
            var index = 5;
        }
        
        var back_color = GetMouseHover(hx1, hy1, hx2, hy2) ? VANADIUM_COLOR_HOVER : (interactive ? VANADIUM_COLOR_BACK : VANADIUM_COLOR_DISABLED);
        DrawNineslice(sprite_nineslice, 4, hx1, hy1, hx2, hy2, back_color, 1);
        DrawNineslice(sprite_nineslice, index, hx1, hy1, hx2, hy2, color, 1);
        scribble_set_box_align(alignment, valignment);
        scribble_draw(floor(mean(hx1, hx2)), floor(mean(hy1, hy2)), text);
        #endregion
        
        if (IsActive()) {
            RenderContents(x1, y1);
        }
    }
    
    IsActive = function() {
        return (root.active_tab == self);
    }
}