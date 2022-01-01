// Emu (c) 2020 @dragonitespam
// See the Github wiki for documentation: https://github.com/DragoniteSpam/Documentation/wiki/Emu
function EmuTabGroup(x, y, w, h, rows, row_height) : EmuCore(x, y, w, h, "tab group") constructor {
    self.rows = rows;
    self.row_height = row_height;
    
    // Initialize the tab rows - which are just empty EmuCores
    repeat (self.rows) {
        array_push(self.contents, new EmuCore(0, 0, 0, 0, ""));
    }
    
    self.color_back = function() { return EMU_COLOR_BACK };
    
    self.active_tab = undefined;
    self.active_tab_request = undefined;
    self.override_root_check = true;
    
    static AddTabs = function(row, tabs) {
        processAdvancement();
        
        if (row > rows) {
            throw new EmuException("Tab row out of bounds", "Trying to add to tab row " + string(row) + ", but only up to " + string(rows) + " are available");
        }
        if (!is_array(tabs)) {
            tabs = [tabs];
        }
        
        for (var i = 0; i < array_length(tabs); i++) {
            var tab = tabs[i];
            tab.root = self;
            tab.row = row;
            tab.index = array_length(contents[row].contents);
            array_push(self.contents[row].contents, tab);
            if (!active_tab && !active_tab_request) {
                RequestActivateTab(tab);
            }
        }
        arrangeRow(row);
        return self;
    };
    
    static arrangeRow = function(row) {
        if (row > rows) {
            throw new EmuException("Tab row out of bounds", "Trying to arrange tab row " + string(row) + ", but only up to " + string(rows) + " are available");
        }
        
        var tab_row = contents[row];
        for (var i = 0, n = array_length(tab_row.contents); i < n; i++) {
            var tab = tab_row.contents[i];
            tab.row = row;
            tab.header_width = floor(width / n);
            tab.header_height = row_height;
            tab.header_x = tab.header_width * i;
            tab.header_y = tab.header_height * row;
        }
    };
    
    static activateTab = function(tab) {
        if (tab.root != self) {
            throw new EmuException("Tab is not included in group", "You are trying to activate a tab in a group that it does not belong to. Please only activate tabs that are members of a group.");
        }
        
        active_tab = tab;
        var contents_clone = [];
        array_copy(contents_clone, 0, self.contents, 0, array_length(self.contents));
        var index = 0;
        for (var i = 0, n = array_length(contents_clone); i < n; i++) {
            if (i == tab.row) continue;
            contents[index] = contents_clone[i];
            arrangeRow(index++);
        }
        contents[rows - 1] = contents_clone[tab.row];
        arrangeRow(rows - 1);
    };
    
    static RequestActivateTab = function(tab) {
        active_tab_request = tab;
        return self;
    };
    
    static Render = function(base_x, base_y) {
        self.gc.Clean();
        var x1 = x + base_x;
        var y1 = y + base_y;
        var x2 = x1 + width;
        var y2 = y1 + height;
        
        draw_sprite_stretched_ext(sprite_nineslice, 1, x1, y1 + rows * row_height, x2 - x1, y2 - y1 - rows * row_height, self.color_back(), 1);
        
        // Save this for the beginning of the next frame, because if you do it
        // in the middle you'll find the tabs become misaligned for one frame
        if (active_tab_request) {
            activateTab(active_tab_request);
            active_tab_request = undefined;
        }
        
        for (var i = 0, n = array_length(contents); i < n; i++) {
            contents[i].Render(x1, y1 + rows * row_height);
        }
        
        // no sense making a tab group non-interactive
        draw_sprite_stretched_ext(sprite_nineslice, 2, x1, y1 + rows * row_height, x2 - x1, y2 - y1 - rows * row_height, self.color(), 1);
    };
}