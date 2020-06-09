function VButton(_x, _y, _w, _h, _text, _callback, _root) : VCore(_x, _y, _w, _h, _root) constructor {
    SetCallback = function(_callback) {
        callback = method(self, _callback);
    }
    
    text = _text;
    SetCallback(_callback);
    alignment = fa_center;
    valignment = fa_middle;
    
    Render = function(base_x, base_y) {
        var x1 = x + base_x;
        var y1 = y + base_y;
        var x2 = x1 + width;
        var y2 = y1 + height;
        
        if (GetMouseReleased(x1, y1, x2, y2)) {
            callback();
        }
        
        DrawNineslice(spr_vanadium_nineslice, 1, x1, y1, x2, y2, interactive ? VANADIUM_COLOR_BACK : VANADIUM_COLOR_DISABLED, 1);
        DrawNineslice(spr_vanadium_nineslice, 0, x1, y1, x2, y2, color, 1);
        
        scribble_set_box_align(alignment, valignment);
        scribble_draw(floor(mean(x1, x2)), floor(mean(y1, y2)), text);
    }
}