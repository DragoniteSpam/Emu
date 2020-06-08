function VTab(_name) : VCore(0, 0, 0, 0, noone) constructor {
    text = _name;
    
    Render = function(base_x, base_y) {
        var x1 = x + base_x;
        var y1 = y + base_y;
        var x2 = x1 + width;
        var y2 = y1 + height;
        
        DrawNineslice(spr_vanadium_nineslice, 0, x1, y1, x2, y2, color);
    }
    
    // Inherited:
    // SetTooltip()
    // Destroy()
}