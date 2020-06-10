// I wanted to make this inherit from EmuInput but that made GameMaker cranky
// for some reason
function EmuColorPicker(_x, _y, _w, _h, _text, _value, _vx1, _vy1, _vx2, _vy2, _callback) : EmuCallback(_x, _y, _w, _h, _value, _callback) constructor {
    text = _text;
    value_x1 = _vx1;
    value_y1 = _vy1;
    value_x2 = _vx2;
    value_y2 = _vy2;
    
    alpha = 1;
    allow_alpha = false;
    active_shade = true;
    
    Render = function(base_x, base_y) {
        var x1 = x + base_x;
        var y1 = y + base_y;
        var x2 = x1 + width;
        var y2 = y1 + height;
        var c = color;
        
        var vx1 = x1 + value_x1;
        var vy1 = y1 + value_y1;
        var vx2 = x1 + value_x2;
        var vy2 = y1 + value_y2;
        var ww = vx2 - vx1;
        var hh = vy2 - vy1;
        var a = allow_alpha ? ((value >> 24) & 0xff) / 0xff : 1;
        
        var tx = GetTextX(x1);
        var ty = GetTextY(y1);
        
        scribble_set_box_align(fa_left, fa_middle);
        scribble_draw(tx, ty, text);
        
        DrawNineslice(1, vx1 + 1, vy1 + 1, vx2 - 1, vy2 - 1, EMU_COLOR_BACK, 1);
        //draw_checkerbox(vx1, vy1, (vx2 - vx1), (vy2 - vy1));
        DrawNineslice(1, vx1 + 2, vy1 + 2, vx2 - 2, vy2 - 2, value, value, value, value, a);
        if (!GetInteractive()) {
            DrawNineslice(1, vx1 + 2, vy1 + 2, vx2 - 2, vy2 - 2, EMU_COLOR_DISABLED, EMU_COLOR_DISABLED, EMU_COLOR_DISABLED, EMU_COLOR_DISABLED, 1);
            DrawNineslice(1, vx1 + 3, vy1 + 3, vx2 - 3, vy2 - 3, EMU_COLOR_DISABLED, EMU_COLOR_DISABLED, EMU_COLOR_DISABLED, EMU_COLOR_DISABLED, 1);
        }
        DrawNineslice(0, vx1 + 1, vy1 + 1, vx2 - 1, vy2 - 1, color, 1);
        
        if (GetInteractive()) {
            if (GetMouseHover(vx1, vy1, vx2, vy2)) {
                if (GetMouseReleased(vx1, vy1, vx2, vy2)) {
                    Activate();
                    var dialog = new EmuDialog(480, 400, "Pick a color", emu_dialog_close_auto);
                    dialog.el_alpha = alpha;
                    dialog.el_allow_alpha = allow_alpha;
                    dialog.flags = (dialog.flags ^ EmuDialogFlags.ACTIVE_SHADE) | (allow_alpha * EmuDialogFlags.ACTIVE_SHADE);
                }
                SetTooltip();
            }
        }
    }
    
    Destroy = function() {
        DestroyContent();
        if (surface_exists(surface)) surface_free(surface);
    }
    
    ValidateInput = function(_text) {
        switch (value_type) {
            case EmuInputTypes.STRING:
                return true;
            case EmuInputTypes.INT:
                var success = true;
                try {
                    var cast = real(_text);
                    if (floor(cast) != cast) success = false;
                } catch (e) {
                    success = false;
                }
                return success;
            case EmuInputTypes.REAL:
                var success = true;
                try {
                    var cast = real(_text);
                } catch (e) {
                    success = false;
                }
                return success;
        }
    }
    
    CastInput = function(_text) {
        switch (value_type) {
            case EmuInputTypes.STRING: return _text;
            case EmuInputTypes.INT: return real(_text);
            case EmuInputTypes.REAL: return real(_text);
        }
    }
}