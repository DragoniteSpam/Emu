function VTab(_name) : VCore(0, 0, 0, 0, noone) constructor {
    text = _name;
    
    alignment = fa_center;
    valignment = fa_middle;
    row = 0;
    index = 0;
    
    Render = function(base_x, base_y) {
        var x1 = x + base_x;
        var y1 = y + base_y;
        var x2 = x1 + width;
        var y2 = y1 + height;
        
        if (!interactive) {
            var index = 1;
        } else if (root.active_tab == self || row < root.rows - 1) {
            var index = 0;
        } else {
            var index = 2;
        }
        
        DrawNineslice(spr_vanadium_nineslice_tab, index, x1, y1, x2, y2, color);
        scribble_set_box_align(alignment, valignment);
        scribble_draw(floor(mean(x1, x2)), floor(mean(y1, y2)), text);
        
        if (point_in_rectangle(mouse_x, mouse_y, x1, y1, x2, y2) && mouse_check_button_pressed(mb_left)) {
            root.ActivateTab(self);
        }
    }
    
    IsActive = function() {
        return (root.active_tab == self);
    }
    
    // Inherited:
    // SetTooltip()
    // Destroy()
}