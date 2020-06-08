function VText(_x, _y, _w, _h, _text, _root) : VCore(_x, _y, _w, _h, _root) constructor {
    text = _text;
    
    use_scribble = false;
    font = VANADIUM_DEFAULT_FONT;
    
    GetTextX = function(_x) {
        switch (alignment) {
            case fa_left: return _x + offset;
            case fa_center: return _x + width / 2;
            case fa_right: return _x + width - offset;
        }
    }
    
    GetTextY = function(_y) {
        switch (valignment) {
            case fa_left: return _y + offset;
            case fa_center: return _y + height / 2;
            case fa_right: return _y + height - offset;
        }
    }
    
    Render = function(base_x, base_y) {
        var x1 = x + base_x;
        var y1 = y + base_y;
        var x2 = x1 + width;
        var y2 = y1 + height;
        
        var tx = GetTextX(x1);
        var ty = GetTextY(y1);
        
        if (use_scribble) {
            scribble_set_wrap(width, height);
            scribble_draw(tx, ty, string(text));
        } else {
            draw_set_halign(alignment);
            draw_set_valign(valignment);
            draw_set_color(color);
            draw_set_font(font);
            draw_text_ext(tx, ty, string(text), height, width);
        }
    }
    
    // Inherited:
    // SetTooltip()
    // Destroy()
}