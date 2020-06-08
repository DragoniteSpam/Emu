function VText(_x, _y, _w, _h, _text, _root) : VCore(_x, _y, _w, _h, _root) constructor {
    text = _text;
    
    wrap_height = -1;
    use_scribble = false;
    
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
        var x1 = text.x + base_x;
        var y1 = text.y + base_y;
        var x2 = x1 + text.width;
        var y2 = y1 + text.height;
        
        var tx = GetTextX(x1);
        var ty = GetTextY(y1);
        
        if (use_scribble) {
            scribble_draw_set_wrap(wrap_height, wrap_width, -1);
            scribble_draw(tx, ty, string(text));
        } else {
            draw_set_halign(alignment);
            draw_set_valign(valignment);
            draw_set_color(color);
            draw_text_ext(tx, ty, string(text), wrap_height, wrap_width);
        }
    }
    
    // Inherited:
    // SetTooltip()
    // Destroy()
}