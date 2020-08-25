// Emu (c) 2020 @dragonitespam
// See the Github wiki for documentation: https://github.com/DragoniteSpam/Emu/wiki
function EmuTab(_name) : EmuCore(0, 0, 0, 0) constructor {
    text = _name;
    
    alignment = fa_center;
    valignment = fa_middle;
    row = 0;
    index = 0;
    header_x = 0;
    header_y = 0;
    header_width = 0;
    header_height = 0;
	parent_group_id = 0;
	
    sprite_nineslice_back = spr_emu_nineslice_tab_back;
    sprite_nineslice_out = spr_emu_nineslice_tab_out;
	// TODO: This variable lacks a setter method:
    sprite_nineslice_out_active = spr_emu_nineslice_tab_out_active;
	
	ds_list_add(obj_emu_react.allTabs, self);
	
	// This method is accessible to outside classes.
	MouseIsHovering = function() {
		return getMouseHover(
			header_x,
			y + parent_group_id.rows * header_height - header_y,
			header_x + header_width,
			y + parent_group_id.rows * header_height - header_y + header_height,
		);
	}
    
    Render = function(base_x, base_y) {
        processAdvancement();
        
        var x1 = x + base_x;
        var y1 = y + base_y;
        var x2 = x1 + width;
        var y2 = y1 + height;
        
        #region header stuff
        var hx1 = header_x + base_x;
        var hy1 = header_y + base_y - root.rows * root.row_height;
        var hx2 = hx1 + header_width;
        var hy2 = hy1 + header_height;
        
        if (getMouseHover(x1, y1, x2, y2)) {
            ShowTooltip();
        }
        
        if (getMouseReleased(hx1, hy1, hx2, hy2)) {
            Activate();
            root.RequestActivateTab(self);
        }
        
		if (isActiveTab() || row < root.rows - 1) {
            var outlineSpr = sprite_nineslice_out_active;
        } else {
            var outlineSpr = sprite_nineslice_out;
        }
        
        var _color_back = getMouseHover(hx1, hy1, hx2, hy2) ? color_hover : (GetInteractive() ? color_back : EMU_COLOR_DISABLED);
        drawNineslice(sprite_nineslice_back, hx1, hy1, hx2, hy2, _color_back, 1, nineslice_mode, true);
        drawNineslice(outlineSpr, hx1, hy1, hx2, hy2, color_out, 1, nineslice_mode, false);
		
		scribble_set_box_align(alignment, valignment);
        scribble_set_wrap(header_width, header_height);
        scribble_draw(floor(mean(hx1, hx2)), floor(mean(hy1, hy2)), text);
        #endregion
        
        if (isActiveTab()) {
            renderContents(x1, y1);
        }
    }
    
    // This is NOT the same as isActiveElement() - this checks for the active
    // tab in the tab group, rather than the UI element which will respond to
    // keyboard input
    isActiveTab = function() {
        return (root.active_tab == self);
    }
    
    RequestActivate = function() {
        root.RequestActivateTab(self);
    }
    
    GetInteractive = function() {
        return enabled && interactive && root.isActiveDialog();
    }
}