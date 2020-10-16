// Emu (c) 2020 @dragonitespam
// See the Github wiki for documentation: https://github.com/DragoniteSpam/Emu/wiki
function EmuTabGroup(x, y, w, h, rows, row_height) : EmuCore(x, y, w, h) constructor {
    self._rows = rows;
    self._row_height = row_height;
    
    // Initialize the tab _rows - which are just empty EmuCores
    repeat (self._rows) {
        ds_list_add(self._contents, new EmuCore(0, 0, 0, 0));
    }
    
    self.color_back = EMU_COLOR_BACK;
    
    self._active_tab = noone;
    self._active_tab_request = noone;
    
    AddTabs = function(row, tabs) {
        processAdvancement();
        
        if (row > _rows) {
            throw new EmuException("Tab row out of bounds", "Trying to add to tab row " + string(row) + ", but only up to " + string(_rows) + " are available");
        }
        if (!is_array(tabs)) {
            tabs = [tabs];
        }
        
        var _tab_row = _contents[| row];
        for (var i = 0; i < array_length(tabs); i++) {
            var _tab = tabs[i];
            _tab.root = self;
            _tab.row = row;
            _tab._index = ds_list_size(_contents[| row]._contents);
            ds_list_add(_tab_row._contents, _tab);
            if (!_active_tab && !_active_tab_request) {
                RequestActivateTab(_tab);
            }
        }
        arrangeRow(row);
    }
    
    arrangeRow = function(row) {
        if (row > _rows) {
            throw new EmuException("Tab row out of bounds", "Trying to arrange tab row " + string(row) + ", but only up to " + string(_rows) + " are available");
        }
        
        var tab_row = _contents[| row];
        for (var i = 0; i < ds_list_size(tab_row._contents); i++) {
            var tab = tab_row._contents[| i];
            tab.row = row;
            tab._header_width = floor(width / ds_list_size(tab_row._contents));
            tab._header_height = _row_height;
            tab._header_x = tab._header_width * i;
            tab._header_y = tab._header_height * row;
        }
    }
    
    activateTab = function(tab) {
        if (tab.root != self) {
            throw new EmuException("Tab is not included in group", "You are trying to activate a tab in a group that it does not belong to. Please only activate tabs that are members of a group.");
        }
        
        _active_tab = tab;
        var contents_clone = ds_list_create();
        ds_list_copy(contents_clone, _contents);
        var _index = 0;
        for (var i = 0; i < ds_list_size(contents_clone); i++) {
            if (i == tab.row) continue;
            _contents[| _index] = contents_clone[| i];
            arrangeRow(_index++);
        }
        _contents[| _rows - 1] = contents_clone[| tab.row];
        arrangeRow(_rows - 1);
    }
    
    RequestActivateTab = function(tab) {
        _active_tab_request = tab;
    }
    
    Render = function(base_x, base_y) {
        var x1 = x + base_x;
        var y1 = y + base_y;
        var x2 = x1 + width;
        var y2 = y1 + height;
        
        drawNineslice(1, x1, y1 + _rows * _row_height, x2, y2, color_back, 1);
        
        // Save this for the beginning of the _next frame, because if you do it
        // in the middle you'll find the tabs become misaligned for one frame
        if (_active_tab_request) {
            activateTab(_active_tab_request);
            _active_tab_request = noone;
        }
        
        for (var i = 0; i < ds_list_size(_contents); i++) {
            _contents[| i].Render(x1, y1 + _rows * _row_height);
        }
        
        // no sense making a tab group non-interactive
        drawNineslice(2, x1, y1 + _rows * _row_height, x2, y2, color, 1);
    }
}