function EmuProgressBar(_x, _y, _w, _h, _thickness, _value, _callback) : EmuCallback(_x, _y, _w, _h, _value, _callback) constructor {
    thickness = _thickness;
    
    color_bar = EMU_COLOR_PROGRESS_BAR;
    sprite_bar = spr_emu_progress;
    
    DrawProgress = function(index, x1, y1, x2, y2, c, alpha) {
        color = (color != undefined) ? color : c_white;
        alpha = (alpha != undefined) ? alpha : 1;
        var w = x2 - x1;
        var h = y2 - y1;
        var sw = sprite_get_width(sprite_bar) / 3;
        var sh = sprite_get_height(sprite_bar);
        var vyscale = h / sh;
        var hxscale = (w - sw * vyscale * 2) / sw;
        draw_sprite_general(sprite_bar, index, sw * 0, 0, sw, sh, x1, y1, vyscale, vyscale, 0, c, c, c, c, alpha);
        draw_sprite_general(sprite_bar, index, sw * 1, 0, sw, sh, x1 + sw * vyscale, y1, hxscale, vyscale, 0, c, c, c, c, alpha);
        draw_sprite_general(sprite_bar, index, sw * 2, 0, sw, sh, x2 - sw * vyscale, y1, vyscale, vyscale, 0, c, c, c, c, alpha);
    }
    
    Render = function(base_x, base_y) {
        var x1 = x + base_x;
        var y1 = y + base_y;
        var x2 = x1 + width;
        var y2 = y1 + height;
        
        DrawProgress(2, x1, y1, x2, y2, EMU_COLOR_BACK, 1);
        DrawProgress(0, x1, y1, x2, y2, color_bar, 1);
        DrawProgress(1, x1, y1, x2, y2, color, 1);
    }
}