function EmuCheckbox(_x, _y, _w, _h, _text, _value, _callback) : EmuCallback(_x, _y, _w, _h, _value, _callback) constructor {
    text = _text;
    
    box_size = 20;
    sprite_check = spr_emu_checkbox;
    
    Render = function(base_x, base_y) {
        var x1 = x + base_x;
        var y1 = y + base_y;
        var x2 = x1 + width;
        var y2 = y1 + height;
        
        if (GetInteractive()) {
            if (GetMouseHover(x1, y1, x2, y2)) {
                SetTooltip();
            }
            if (GetMouseReleased(x1, y1, x2, y2)) {
                value = !value;
                callback();
            }
        }
        
        var bx = x1 + offset + box_size / 2;
        var by = mean(y1, y2);
        var bx1 = bx - box_size / 2;
        var by1 = by - box_size / 2;
        var bx2 = bx + box_size / 2;
        var by2 = by + box_size / 2;
        var back_color = GetMouseHover(x1, y1, x2, y2) ? EMU_COLOR_HOVER : (GetInteractive() ? EMU_COLOR_BACK : EMU_COLOR_DISABLED);
        DrawNineslice(1, bx1, by1, bx2, by2, back_color, 1);
        draw_sprite(sprite_check, value, bx, by);
        DrawNineslice(0, bx1, by1, bx2, by2, color, 1);
        
        scribble_set_box_align(alignment, valignment);
        scribble_draw(x1 + box_size + offset * 2, floor(mean(y1, y2)), text);
    }
}