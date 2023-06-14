// Emu (c) 2020 @dragonitespam
// See the Github wiki for documentation: https://github.com/DragoniteSpam/Documentation/wiki/Emu

// feather use syntax-errors
function EmuList(x, y, width, header_height, text, element_height, content_slots, callback) : EmuCallback(x, y, width, header_height, text, 0, callback) constructor {
    enum E_ListEntryTypes { STRINGS, STRUCTS, SCRIPTS };
    
    self.element_height = element_height;
    self.slots = content_slots;
    
    self.color_back = function() { return EMU_COLOR_BACK; };
    self.color_hover = function() { return EMU_COLOR_HOVER; };
    self.color_disabled = function() { return EMU_COLOR_DISABLED; };
    self.color_selected = function() { return EMU_COLOR_SELECTED; };
    
    self.auto_multi_select = false;
    self.allow_multi_select = false;
    self.allow_deselect = true;
    self.select_toggle = false;
    self.entries_are = E_ListEntryTypes.STRINGS;
    self.numbered = false;
    self.text_vacant = "(empty list)";
    
    self.sprite_help = EMU_SPRITE_HELP;
    self.sprite_arrows = EMU_SPRITE_SCROLL_ARROW;
    
    self.index = 0;
    self.click_x = -1;
    self.click_y = -1;
    self.own_entries = true;
    
    self.selected_entries = { };
    self.surface = -1;
    self.entries = [];
	self.dragging = false;
    
    self.At = function(index) {
        return (index < 0 || index >= array_length(self.entries)) ? undefined : self.entries[index];
    };
    
    self.SetList = function(array) {
        self.entries = array;
        self.own_entries = false;
        self.ClearSelectionNoCallback();
        return self;
    };
    
    self.SetEntryTypes = function(type) {
        self.entries_are = type;
        return self;
    };
    
    self.SetMultiSelect = function(multi_select, auto, toggle) {
        self.allow_multi_select = multi_select;
        self.auto_multi_select = auto;
        self.select_toggle = toggle;
        return self;
    };
    
    self.SetVacantText = function(text) {
        self.text_vacant = text;
        return self;
    };
    
    self.SetNumbered = function(numbered) {
        self.numbered = numbered;
        return self;
    };
    
    self.AddEntries = function(elements) {
        if (!self.own_entries) {
            throw new EmuException("Trying to add to a list owned by someone else", "Please do not add to a list using an external list for its entries.");
        }
        
        if (!is_array(elements)) elements = [elements];
        for (var i = 0; i < array_length(elements); i++) {
            array_push(self.entries, elements[i]);
        }
        return self;
    };
    
    self.Clear = function() {
        if (self.own_entries) {
            self.entries = [];
        } else {
            throw new EmuException("Trying to clear a list owned by someone else", "Please do not clear a list using an external list for its entries.");
        }
        return self;
    };
    
    self.FitToBox = function(total_width = self.width, total_height = self.GetHeight(), header_height = self.height) {
        self.width = total_width;
        self.height = header_height;
        self.slots = (total_height - header_height) / self.element_height;
        return self;
    };
    
    self.GetHeight = function() {
        return self.height + self.element_height * self.slots;
    };
    
    self.GetSelected = function(list_index) {
        return variable_struct_exists(self.selected_entries, string(list_index));
    };
    
    self.getListColors = function(list_index) {
        return EMU_COLOR_LIST_TEXT;
    };
    
	self.ForEachSelection = function(f) {
		var names = variable_struct_get_names(self.selected_entries);
		for (var i = 0, n = array_length(names); i < n; i++) {
    		if (names[i] == "first") continue;
    		if (names[i] == "last") continue;
			f(real(names[i]));
		}
	};
	
    self.GetAllSelectedIndices = function() {
    	var names = variable_struct_get_names(self.selected_entries);
    	var n = array_length(names);
    	if (self.selected_entries[$ "first"] != undefined) n--;
    	if (self.selected_entries[$ "last"] != undefined) n--;
    	
    	var results = array_create(n);
    	var index = 0;
    	for (var i = array_length(names) - 1; i >= 0; i--) {
    		if (names[i] == "first") continue;
    		if (names[i] == "last") continue;
    		results[index++] = real(names[i]);
    	}
        
        array_sort(results, true);
    	
    	return results;
    };
    
    self.GetSelection = function() {
        if (variable_struct_names_count(self.selected_entries) == 0) return -1;
        return self.selected_entries[$ "first"];
    };
    
    self.GetSelectedItem = function() {
        var selection = self.GetSelection();
        if (selection < 0 || selection >= array_length(self.entries)) return undefined;
        return self.entries[selection];
    };
    
    self.GetAllSelectedItems = function() {
    	var names = variable_struct_get_names(self.selected_entries);
    	var n = array_length(names);
    	if (self.selected_entries[$ "first"] != undefined) n--;
    	if (self.selected_entries[$ "last"] != undefined) n--;
    	
    	var results = array_create(n);
    	var index = 0;
    	for (var i = array_length(names) - 1; i >= 0; i--) {
    		if (names[i] == "first") continue;
    		if (names[i] == "last") continue;
    		results[index++] = self.entries[real(names[i])];
    	}
    	
    	return results;
    };
    
    self.ClearSelection = function() {
        self.ClearSelectionNoCallback();
        self.callback();
        return self;
    };
    
    self.ClearSelectionNoCallback = function() {
        self.selected_entries = { };
        return self;
    };
    
    self.Select = function(list_index, set_index = false) {
        self.SelectNoCallback(list_index, set_index);
        self.callback();
        return self;
    };
    
    self.SelectNoCallback = function(list_index, set_index = false) {
        if (list_index < 0 || list_index >= array_length(self.entries)) return self;
        if (!variable_struct_exists(self.selected_entries, "first")) self.selected_entries[$ "first"] = list_index;
        self.selected_entries[$ "last"] = list_index;
        self.selected_entries[$ string(list_index)] = true;
        if (set_index && clamp(list_index, self.index, self.index + self.slots - 1) != list_index) {
            self.index = max(0, min(list_index, array_length(self.entries) - self.slots));
        }
        return self;
    };
    
    self.Deselect = function(list_index) {
        self.DeselectNoCallback();
        self.callback();
        return self;
    };
    
    self.DeselectNoCallback = function(list_index) {
        variable_struct_remove(self.selected_entries, list_index);
        return self;
    };
    
    self.Render = function(base_x, base_y, debug_render = false) {
        self.update_script();
        self.processAdvancement();
        
        var col_main = self.color();
        var col_back = self.color_back();
        var col_hover = self.color_hover();
        var col_disabled = self.color_disabled();
        var col_selected = self.color_selected();
        
        var x1 = x + base_x;
        var y1 = y + base_y;
        var x2 = x1 + self.width;
        var y2 = y1 + self.height;
        var y3 = y2 + self.slots * self.height;
        var ww = x2 - x1;
        var hh = y3 - y2;
        var tx = self.getTextX(x1);
        var ty = self.getTextY(y1);
        
        #region list header
        var txoffset = 0;
        if (string_length(self.tooltip) > 0) {
            var spr_xoffset = sprite_get_xoffset(self.sprite_help);
            var spr_yoffset = sprite_get_yoffset(self.sprite_help);
            var spr_width = sprite_get_width(self.sprite_help);
            var spr_height = sprite_get_height(self.sprite_help);
            txoffset = spr_width;
            
            if (self.getMouseHover(tx - spr_xoffset, ty - spr_yoffset, tx - spr_xoffset + spr_width, ty - spr_yoffset + spr_height)) {
                draw_sprite_ext(self.sprite_help, 2, tx, ty, 1, 1, 0, col_hover, 1);
                self.ShowTooltip();
            } else {
                draw_sprite_ext(self.sprite_help, 2, tx, ty, 1, 1, 0, col_back, 1);
            }
            draw_sprite_ext(self.sprite_help, 1, tx, ty, 1, 1, 0, col_main, 1);
            draw_sprite_ext(self.sprite_help, 0, tx, ty, 1, 1, 0, col_main, 1);
        }
        
        scribble(self.text)
            .wrap(self.width, self.height)
            .align(fa_left, fa_center)
            .draw(tx + txoffset, ty);
        #endregion
        
        #region list drawing
        self.surface = self.surfaceVerify(self.surface, ww, hh).surface;
        
        surface_set_target(self.surface);
        draw_clear_alpha(self.GetInteractive() ? col_back : col_disabled, 1);
        
        var n = array_length(self.entries);
        self.index = clamp(n - self.slots, 0, self.index);
        
        if (n == 0) {
            draw_sprite_stretched_ext(self.sprite_nineslice, 1, 0, 0, x2 - x1, self.element_height, col_disabled, 1);
            ty = mean(y2, y2 + self.height);
            
            scribble(self.text_vacant)
                .wrap(self.width, self.height)
                .align(fa_left, fa_center)
                .draw(tx - x1, ty - y2);
        } else {
            for (var i = 0; i < min(n, self.slots); i++) {
                var current_index = i + self.index;
                var ya = y2 + self.height * i;
                var yb = ya + self.height;
                var tya = mean(ya, yb);
                
                if (self.GetInteractive()) {
                    if (self.GetSelected(current_index)) {
                        draw_rectangle_colour(0, ya - y2, x2 - x1, yb - y2, col_selected, col_selected, col_selected, col_selected, false);
                    }
                }
                
                var c = self.getListColors(current_index);
                var index_text = self.numbered ? (string(current_index) + ". ") : "";
                
                switch (self.entries_are) {
                    case E_ListEntryTypes.STRINGS: index_text += string(self.entries[current_index]); break;
                    case E_ListEntryTypes.STRUCTS: index_text += self.entries[current_index].name; break;
                    case E_ListEntryTypes.SCRIPTS: index_text = index_text + string(self.entries[current_index](current_index)); break;
                }
                
                scribble(index_text)
                    .align(fa_left, fa_middle)
                    .starting_format(EMU_DEFAULT_FONT, c)
                    .wrap(self.width, self.height)
                    .draw(tx - x1, tya - y2);
            }
        }
        
        draw_rectangle_colour(1, 1, ww - 2, hh - 2, col_main, col_main, col_main, col_main, true);
        surface_reset_target();
        #endregion
        
        draw_surface(self.surface, x1, y2);
        
        #region interaction
        var offset = (n > self.slots) ? 16 : 0;
        var lx1 = x1;
        var ly1 = y2;
        var lx2 = x2 - offset;
        var ly2 = y3;
        
        var move_direction = 0;
        
        if (self.getMouseHover(lx1, ly1, lx2, ly2)) {
            var mn = min(((self.getMousePositionY() - ly1) div self.height) + self.index, n - 1);
            if (self.getMouseMiddleReleased(lx1, ly1, lx2, ly2)) {
                self.callback_middle(mn);
            } else if (self.getMouseDouble(lx1, ly1, lx2, ly2)) {
                self.callback_double(mn);
            } else if (self.getMousePressed(lx1, ly1, lx2, ly2)) {
                self.Activate();
                // deselect the list if that's what yo uwould expect to happen
                if (!self.auto_multi_select) {
                    if ((!keyboard_check(vk_control) && !keyboard_check(vk_shift) && !self.select_toggle) || !self.allow_multi_select) {
                        self.ClearSelection();
                    }
                }
                // toggle selection over a range
                if (self.allow_multi_select && keyboard_check(vk_shift)) {
                    if (self.last_index > -1) {
                        var d = sign(mn - self.last_index);
                        for (var i = self.last_index; i != (mn + d); i += d) {
                            if (!self.GetSelected(i)) {
                                self.Select(i);
                            } else if (self.select_toggle && self.allow_deselect) {
                                self.Deselect(i);
                            }
                        }
                    }
                // toggle single selections
                } else {
                    if (!self.GetSelected(mn)) {
                        self.Select(mn);
                    } else if (self.select_toggle && self.allow_deselect) {
                        self.Deselect(mn);
                    }
                }
                self.last_index = mn;
            } else if (self.getMouseRightReleased(lx1, ly1, lx2, ly2)) {
                self.Activate();
                if (self.allow_deselect) {
                    self.ClearSelection();
                }
            }
            
            if (mouse_wheel_up()) {
                move_direction = -1;
            } else if (mouse_wheel_down()) {
                move_direction = 1;
            }
            
            if (self.allow_multi_select) {
                if (keyboard_check(vk_control) && keyboard_check_pressed(ord("A"))) {
                    self.Activate();
                    for (var i = 0; i < n; i++) {
                        if (!self.GetSelected(i)) {
                            self.Select(i);
                        } else if (self.select_toggle) {
                            self.Deselect(i);
                        }
                    }
                }
            }
        }
        #endregion
        
        #region slider
        if (n > self.slots) {
            var sw = 16;
            var noutofrange = n - self.slots; // at minimum, one
            // the minimum slider height will never be below 20, but it'll scale up for longer lists;
            // otherwise it's simply proportional to the fraction of the entries that are visible in the list
            var shalf = max(20 + 20 * log10(self.slots), (y3 - y2 - sw * 2) * self.slots / n) / 2;
            var smin = y2 + sw + shalf;
            var smax = y3 - sw - shalf;
            var srange = smax - smin;
            var sy = smin + srange * self.index / noutofrange;
            var active = self.GetInteractive();
            draw_rectangle_colour(x2 - sw, y2, x2, y3, col_back, col_back, col_back, col_back, false);
            draw_line_colour(x2 - sw, y2 + sw, x2, y2 + sw, col_main, col_main);
            draw_line_colour(x2 - sw, y3 - sw, x2, y3 - sw, col_main, col_main);
            draw_rectangle_colour(x2 - sw, y2, x2, y3, col_main, col_main, col_main, col_main, true);
            
            var sby1 = sy - shalf;
            var sby2 = sy + shalf;
            if (active) {
                // Hover over the scroll bar: draw the hover col_main
                if (self.getMouseHover(x2 - sw, sby1, x2, sby2) || self.dragging) {
                    draw_rectangle_colour(x2 - sw + 1, sby1 + 1, x2 - 1, sby2 - 1, col_hover, col_hover, col_hover, col_hover, false);
                    // Click: begin dragging the scroll bar
                    if (self.getMousePressed(x2 - sw, sby1, x2, sby2) && !self.dragging) {
                        self.Activate();
						self.dragging = true;
                        self.click_x = self.getMousePositionX();
                        self.click_y = self.getMousePositionY();
                    }
                }
                // Hold while dragging: update the list position
                if (self.getMouseHold(0, 0, window_get_width(), window_get_height()) && self.click_y > -1) {
                    self.index = floor(noutofrange * clamp(self.getMousePositionY() - smin, 0, srange) / srange);
                }
                // Release: stop dragging
                if (self.getMouseReleased(0, 0, window_get_width(), window_get_height())) {
					self.dragging = false;
                    self.click_x = -1;
                    self.click_y = -1;
                }
            }
            
            draw_rectangle_colour(x2 - sw, sby1, x2, sby2, col_main, col_main, col_main, col_main, true);
            draw_line_colour(x2 - sw * 4 / 5, sy - 4, x2 - sw / 5, sy - 4, col_main, col_main);
            draw_line_colour(x2 - sw * 4 / 5, sy, x2 - sw / 5, sy, col_main, col_main);
            draw_line_colour(x2 - sw * 4 / 5, sy + 4, x2 - sw / 5, sy + 4, col_main, col_main);
            
            if (active) {
                var inbounds_top = self.getMouseHover(x2 - sw, y2, x2, y2 + sw);
                var inbounds_bottom = self.getMouseHover(x2 - sw, y3 - sw, x2, y3);
                // Top button
                if (inbounds_top) {
                    draw_rectangle_colour(x2 - sw + 1, y2 + 1, x2 - 1, y2 + sw - 1, col_hover, col_hover, col_hover, col_hover, false);
                    if (self.getMousePressed(x2 - sw, y2, x2, y2 + sw)) {
                        self.Activate();
                        move_direction = -1;
                    } else if (self.getMouseHold(x2 - sw, y2, x2, y2 + sw)) {
                        if (self.getMouseHoldDuration(x2 - sw, y2, x2, y2 + sw) > EMU_TIME_HOLD_THRESHOLD) {
                            move_direction = -1;
                        }
                    }
                // Bottom button
                } else if (inbounds_bottom) {
                    draw_rectangle_colour(x2 - sw + 1, y3 - sw + 1, x2 - 1, y3 - 1, col_hover, col_hover, col_hover, col_hover, false);
                    // On click, scroll once
                    if (self.getMousePressed(x2 - sw, y3 - sw, x2, y3)) {
                        self.Activate();
                        move_direction = 1;
                    // On hold, scroll after an amount of time
                    } else if (self.getMouseHold(x2 - sw, y3 - sw, x2, y3)) {
                        if (self.getMouseHoldDuration(x2 - sw, y3 - sw, x2, y3) > EMU_TIME_HOLD_THRESHOLD) {
                            move_direction = 1;
                        }
                    }
                }
            }
            
            draw_sprite_ext(self.sprite_arrows, 0, x2 - sw, y2, 1, 1, 0, col_main, 1);
            draw_sprite_ext(self.sprite_arrows, 1, x2 - sw, y3 - sw, 1, 1, 0, col_main, 1);
            
            self.index = clamp(self.index + move_direction, 0, max(0, n - self.slots));
        }
        #endregion
        
        if (debug_render) {
            self.renderDebugBounds(x1, y1, x2, y2);
            self.renderDebugBounds(x1, y2, x2, y3);
        }
    };
}