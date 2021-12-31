// Emu (c) 2020 @dragonitespam
// See the Github wiki for documentation: https://github.com/DragoniteSpam/Documentation/wiki/Emu
function EmuList(x, y, w, h, text, element_height, content_slots, callback) : EmuCallback(x, y, w, h, 0, callback) constructor {
    enum E_ListEntryTypes { STRINGS, STRUCTS, SCRIPTS };
    self.text = text;
    self.element_height = element_height;
    self.slots = content_slots;
    
    self.color_back = function() { return EMU_COLOR_BACK };
    self.color_hover = function() { return EMU_COLOR_HOVER };
    self.color_disabled = function() { return EMU_COLOR_DISABLED };
    self.color_selected = function() { return EMU_COLOR_SELECTED };
    
    self.auto_multi_select = false;
    self.allow_multi_select = false;
    self.allow_deselect = true;
    self.select_toggle = false;
    self.entries_are = E_ListEntryTypes.STRINGS;
    self.numbered = false;
    self.text_vacant = "(empty list)";
    
    self.sprite_help = spr_emu_help;
    self.sprite_arrows = spr_emu_scroll_arrow;
    
    self._index = 0;
    self._index_last = -1;
    self._click_x = -1;
    self._click_y = -1;
    self._own_entries = true;
    
    self._selected_entries = { };
    self._surface = -1;
    self._entries = [];
	self._dragging = false;
    
    static SetList = function(array) {
        _entries = array;
        _own_entries = false;
        ClearSelection();
        return self;
    }
    
    static SetEntryTypes = function(_type) {
        entries_are = _type;
        return self;
    }
    
    static SetMultiSelect = function(_multi_select, _auto, _toggle) {
        allow_multi_select = _multi_select;
        auto_multi_select = _auto;
        select_toggle = _toggle;
        return self;
    }
    
    static SetVacantText = function(_text) {
        text_vacant = _text;
        return self;
    }
    
    static AddEntries = function(elements) {
        if (!_own_entries) {
            throw new EmuException("Trying to add to a list owned by someone else", "Please do not add to a list using an external list for its _entries.");
        }
        
        if (!is_array(elements)) elements = [elements];
        for (var i = 0; i < array_length(elements); i++) {
            array_push(_entries, elements[i]);
        }
        return self;
    }
    
    static Clear = function() {
        if (_own_entries) {
            _entries = [];
        } else {
            throw new EmuException("Trying to clear a list owned by someone else", "Please do not clear a list using an external list for its _entries.");
        }
        return self;
    }
    
    static GetHeight = function() {
        return height + element_height * slots;
    }
    
    static GetSelected = function(list_index) {
        return variable_struct_exists(_selected_entries, string(list_index));
    }
    
    static getListColors = function(list_index) {
        return EMU_COLOR_LIST_TEXT;
    }
    
    static GetSelection = function() {
        if (variable_struct_names_count(_selected_entries) == 0) return -1;
        return _selected_entries[$ "first"];
    }
    
    static ClearSelection = function() {
        _selected_entries = { };
        callback();
        return self;
    }
    
    static Select = function(_list_index, _set_index) {
        if (_set_index == undefined) _set_index = false;
        if (!variable_struct_exists(_selected_entries, "first")) _selected_entries[$ "first"] = _list_index;
        _selected_entries[$ "last"] = _list_index;
        _selected_entries[$ string(_list_index)] = true;
        if (_set_index && clamp(_list_index, _index, _index + slots - 1) != _list_index) {
            _index = max(0, min(_list_index, array_length(_entries) - slots));
        }
        callback();
        return self;
    }
    
    static Deselect = function(_list_index) {
        variable_struct_remove(_selected_entries, _list_index);
        callback();
        return self;
    }
    
    static Render = function(base_x, base_y) {
        self.gc.Clean();
        processAdvancement();
        
        var col_main = self.color();
        var col_back = self.color_back();
        var col_hover = self.color_hover();
        var col_disabled = self.color_disabled();
        var col_selected = self.color_selected();
        
        var x1 = x + base_x;
        var y1 = y + base_y;
        var x2 = x1 + width;
        var y2 = y1 + height;
        var y3 = y2 + slots * height;
        var ww = x2 - x1;
        var hh = y3 - y2;
        var tx = getTextX(x1);
        var ty = getTextY(y1);
        
        #region list header
        if (string_length(tooltip) > 0) {
            var spr_xoffset = sprite_get_xoffset(sprite_help);
            var spr_yoffset = sprite_get_yoffset(sprite_help);
            var spr_width = sprite_get_width(sprite_help);
            var spr_height = sprite_get_height(sprite_help);
            var txoffset = spr_width;
            
            if (getMouseHover(tx - spr_xoffset, ty - spr_yoffset, tx - spr_xoffset + spr_width, ty - spr_yoffset + spr_height)) {
                draw_sprite_ext(sprite_help, 2, tx, ty, 1, 1, 0, col_hover, 1);
                ShowTooltip();
            } else {
                draw_sprite_ext(sprite_help, 2, tx, ty, 1, 1, 0, col_back, 1);
            }
            draw_sprite_ext(sprite_help, 1, tx, ty, 1, 1, 0, col_main, 1);
            draw_sprite_ext(sprite_help, 0, tx, ty, 1, 1, 0, col_main, 1);
        } else {
            var txoffset = 0;
        }
        
        scribble(self.text)
            .wrap(self.width, self.height)
            .align(fa_left, fa_center)
            .draw(tx + txoffset, ty);
        #endregion
        
        #region list drawing
        self._surface = self.surfaceVerify(self._surface, ww, hh).surface;
        
        surface_set_target(_surface);
        draw_clear_alpha(GetInteractive() ? col_back : col_disabled, 1);
        
        var n = array_length(_entries);
        _index = clamp(n - slots, 0, _index);
        
        if (n == 0) {
            draw_sprite_stretched_ext(sprite_nineslice, 1, 0, 0, x2 - x1, element_height, col_disabled, 1);
            ty = mean(y2, y2 + height);
            
            scribble(self.text_vacant)
                .wrap(self.width, self.height)
                .align(fa_left, fa_center)
                .draw(tx - x1, ty - y2);
        } else {
            for (var i = 0; i < min(n, slots); i++) {
                var current_index = i + _index;
                var ya = y2 + height * i;
                var yb = ya + height;
                var tya = mean(ya, yb);
                
                if (GetInteractive()) {
                    if (GetSelected(current_index)) {
                        draw_rectangle_colour(0, ya - y2, x2 - x1, yb - y2, col_selected, col_selected, col_selected, col_selected, false);
                    }
                }
                
                var c = getListColors(current_index);
                var index_text = numbered ? (string(current_index) + ". ") : "";
                
                switch (entries_are) {
                    case E_ListEntryTypes.STRINGS: index_text += string(_entries[current_index]); break;
                    case E_ListEntryTypes.STRUCTS: index_text += _entries[current_index].name; break;
                    case E_ListEntryTypes.SCRIPTS: index_text = index_text + string(_entries[current_index](current_index)); break;
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
        
        draw_surface(_surface, x1, y2);
        
        #region interaction
        var offset = (n > slots) ? 16 : 0;
        var lx1 = x1;
        var ly1 = y2;
        var lx2 = x2 - offset;
        var ly2 = y3;
        
        var move_direction = 0;
        
        if (getMouseHover(lx1, ly1, lx2, ly2)) {
            var mn = min(((mouse_y - ly1) div height) + _index, n - 1);
            if (getMouseMiddleReleased(lx1, ly1, lx2, ly2)) {
                callback_middle(mn);
            } else if (getMouseDouble(lx1, ly1, lx2, ly2)) {
                callback_double(mn);
            } else if (getMousePressed(lx1, ly1, lx2, ly2)) {
                Activate();
                // deselect the list if that's what yo uwould expect to happen
                if (!auto_multi_select) {
                    if ((!keyboard_check(vk_control) && !keyboard_check(vk_shift) && !select_toggle) || !allow_multi_select) {
                        ClearSelection();
                    }
                }
                // toggle selection over a range
                if (allow_multi_select && keyboard_check(vk_shift)) {
                    if (last_index > -1) {
                        var d = sign(mn - last_index);
                        for (var i = last_index; i != (mn + d); i = i + d) {
                            if (!GetSelected(i)) {
                                Select(i);
                            } else if (select_toggle && allow_deselect) {
                                Deselect(i);
                            }
                        }
                    }
                // toggle single selections
                } else {
                    if (!GetSelected(mn)) {
                        Select(mn);
                    } else if (select_toggle && allow_deselect) {
                        Deselect(mn);
                    }
                }
                last_index = mn;
            } else if (getMouseRightReleased(lx1, ly1, lx2, ly2)) {
                Activate();
                if (allow_deselect) {
                    ClearSelection();
                }
            }
            
            if (mouse_wheel_up()) {
                move_direction = -1;
            } else if (mouse_wheel_down()) {
                move_direction = 1;
            }
            
            if (allow_multi_select) {
                if (keyboard_check(vk_control) && keyboard_check_pressed(ord("A"))) {
                    Activate();
                    for (var i = 0; i < n; i++) {
                        if (!GetSelected(i)) {
                            Select(i);
                        } else if (select_toggle) {
                            Deselect(i);
                        }
                    }
                }
            }
        }
        #endregion
        
        #region slider
        if (n > slots) {
            var sw = 16;
            var noutofrange = n - slots; // at minimum, one
            // the minimum slider height will never be below 20, but it'll scale up for longer lists;
            // otherwise it's simply proportional to the fraction of the _entries that are visible in the list
            var shalf = max(20 + 20 * log10(slots), (y3 - y2 - sw * 2) * slots / n) / 2;
            var smin = y2 + sw + shalf;
            var smax = y3 - sw - shalf;
            var srange = smax - smin;
            var sy = smin + srange * _index / noutofrange;
            var active = GetInteractive();
            draw_rectangle_colour(x2 - sw, y2, x2, y3, col_back, col_back, col_back, col_back, false);
            draw_line_colour(x2 - sw, y2 + sw, x2, y2 + sw, col_main, col_main);
            draw_line_colour(x2 - sw, y3 - sw, x2, y3 - sw, col_main, col_main);
            draw_rectangle_colour(x2 - sw, y2, x2, y3, col_main, col_main, col_main, col_main, true);
            
            var sby1 = sy - shalf;
            var sby2 = sy + shalf;
            if (active) {
                // Hover over the scroll bar: draw the hover col_main
                if (getMouseHover(x2 - sw, sby1, x2, sby2) || _dragging) {
                    draw_rectangle_colour(x2 - sw + 1, sby1 + 1, x2 - 1, sby2 - 1, col_hover, col_hover, col_hover, col_hover, false);
                    // Click: begin _dragging the scroll bar
                    if (getMousePressed(x2 - sw, sby1, x2, sby2) && !_dragging) {
                        Activate();
						_dragging = true;
                        _click_x = mouse_x;
                        _click_y = mouse_y;
                    }
                }
                // Hold while _dragging: update the list position
                if (getMouseHold(0, 0, window_get_width(), window_get_height()) && _click_y > -1) {
                    _index = floor(noutofrange * clamp(mouse_y - smin, 0, srange) / srange);
                }
                // Release: stop _dragging
                if (getMouseReleased(0, 0, window_get_width(), window_get_height())) {
					_dragging = false;
                    _click_x = -1;
                    _click_y = -1;
                }
            }
            
            draw_rectangle_colour(x2 - sw, sby1, x2, sby2, col_main, col_main, col_main, col_main, true);
            draw_line_colour(x2 - sw * 4 / 5, sy - 4, x2 - sw / 5, sy - 4, col_main, col_main);
            draw_line_colour(x2 - sw * 4 / 5, sy, x2 - sw / 5, sy, col_main, col_main);
            draw_line_colour(x2 - sw * 4 / 5, sy + 4, x2 - sw / 5, sy + 4, col_main, col_main);
            
            if (active) {
                var inbounds_top = getMouseHover(x2 - sw, y2, x2, y2 + sw);
                var inbounds_bottom = getMouseHover(x2 - sw, y3 - sw, x2, y3);
                // Top button
                if (inbounds_top) {
                    draw_rectangle_colour(x2 - sw + 1, y2 + 1, x2 - 1, y2 + sw - 1, col_hover, col_hover, col_hover, col_hover, false);
                    if (getMousePressed(x2 - sw, y2, x2, y2 + sw)) {
                        Activate();
                        move_direction = -1;
                    } else if (getMouseHold(x2 - sw, y2, x2, y2 + sw)) {
                        if (getMouseHoldDuration(x2 - sw, y2, x2, y2 + sw) > EMU_TIME_HOLD_THRESHOLD) {
                            move_direction = -1;
                        }
                    }
                // Bottom button
                } else if (inbounds_bottom) {
                    draw_rectangle_colour(x2 - sw + 1, y3 - sw + 1, x2 - 1, y3 - 1, col_hover, col_hover, col_hover, col_hover, false);
                    // On click, scroll once
                    if (getMousePressed(x2 - sw, y3 - sw, x2, y3)) {
                        Activate();
                        move_direction = 1;
                    // On hold, scroll after an amount of time
                    } else if (getMouseHold(x2 - sw, y3 - sw, x2, y3)) {
                        if (getMouseHoldDuration(x2 - sw, y3 - sw, x2, y3) > EMU_TIME_HOLD_THRESHOLD) {
                            move_direction = 1;
                        }
                    }
                }
            }
            
            draw_sprite_ext(sprite_arrows, 0, x2 - sw, y2, 1, 1, 0, col_main, 1);
            draw_sprite_ext(sprite_arrows, 1, x2 - sw, y3 - sw, 1, 1, 0, col_main, 1);
            
            _index = clamp(_index + move_direction, 0, max(0, n - slots));
        }
        #endregion
    }
}