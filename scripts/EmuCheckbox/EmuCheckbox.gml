// Emu (c) 2020 @dragonitespam
// See the Github wiki for documentation: https://github.com/DragoniteSpam/Emu/wiki
function EmuCheckbox(x, y, w, h, text, value, callback) : EmuCallback(x, y, w, h, value, callback) constructor {
    self.text = text;
    
    self.box_size = 20;
    self.sprite_check = spr_emu_checkbox;
    self.color_active = EMU_COLOR_RADIO_ACTIVE;
    self.color_hover = EMU_COLOR_HOVER
    self.color_disabled = EMU_COLOR_DISABLED;
    self.color_back = EMU_COLOR_BACK;
    
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
            value = !value;
            callback();
        }
        
        var bx = x1 + offset + box_size / 2;
        var by = mean(y1, y2);
        var bx1 = bx - box_size / 2;
        var by1 = by - box_size / 2;
        var bx2 = bx + box_size / 2;
        var by2 = by + box_size / 2;
        var back_color = getMouseHover(x1, y1, x2, y2) ? color_hover : (GetInteractive() ? color_back : color_disabled);
        drawNineslice(1, bx1, by1, bx2, by2, back_color, 1);
        draw_sprite_ext(sprite_check, value, bx, by, 1, 1, 0, color_active, 1);
        drawNineslice(0, bx1, by1, bx2, by2, color, 1);
        
        scribble_set_box_align(alignment, valignment);
        scribble_set_wrap(width, height);
        scribble_draw(x1 + box_size + offset * 2, floor(mean(y1, y2)), text);
    }
}