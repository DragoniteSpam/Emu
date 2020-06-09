function EmuButton(_x, _y, _w, _h, _text, _callback) : EmuCallback(_x, _y, _w, _h, 0, _callback) constructor {
    text = _text;
    alignment = fa_center;
    valignment = fa_middle;
    
    Render = function(base_x, base_y) {
        var x1 = x + base_x;
        var y1 = y + base_y;
        var x2 = x1 + width;
        var y2 = y1 + height;
        
        if (GetMouseHover(x1, y1, x2, y2)) {
            SetTooltip();
        }
        
        if (GetMouseReleased(x1, y1, x2, y2)) {
            callback();
        }
        
        var back_color = GetMouseHover(x1, y1, x2, y2) ? EMU_COLOR_HOVER : (GetInteractive() ? EMU_COLOR_BACK : EMU_COLOR_DISABLED);
        DrawNineslice(1, x1, y1, x2, y2, back_color, 1);
        DrawNineslice(0, x1, y1, x2, y2, color, 1);
        
        scribble_set_box_align(alignment, valignment);
        scribble_draw(floor(mean(x1, x2)), floor(mean(y1, y2)), text);
    }
}