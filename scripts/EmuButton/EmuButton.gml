// Emu (c) 2020 @dragonitespam
// See the Github wiki for documentation: https://github.com/DragoniteSpam/Emu/wiki
function EmuButton(_x, _y, _w, _h, _text, _callback) : EmuCallback(_x, _y, _w, _h, 0, _callback) constructor {
    text = _text;
    alignment = fa_center;
    valignment = fa_middle;
    
    Render = function(base_x, base_y) {
        processAdvancement();
        
        var x1 = x + base_x;
        var y1 = y + base_y;
        var x2 = x1 + width;
        var y2 = y1 + height;
        
        if (getMouseHover(x1, y1, x2, y2)) {
            ShowTooltip();
        }
        
        if (getMouseReleased(x1, y1, x2, y2)) {
            Activate();
            callback();
        }
        
        var _color_back = getMouseHover(x1, y1, x2, y2) ? EMU_COLOR_HOVER : (GetInteractive() ? EMU_COLOR_BACK : EMU_COLOR_DISABLED);
        drawNineslice(sprite_nineslice_back, x1, y1, x2, y2, _color_back, 1, nineslice_mode, true);
        drawNineslice(sprite_nineslice_out, x1, y1, x2, y2, color_out, 1, nineslice_mode, false);
		
        scribble_set_box_align(alignment, valignment);
        scribble_set_wrap(width, height);
        scribble_draw(floor(mean(x1, x2)), floor(mean(y1, y2)), text);
    }
}