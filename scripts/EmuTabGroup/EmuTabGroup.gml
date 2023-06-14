// Emu (c) 2020 @dragonitespam
// See the Github wiki for documentation: https://github.com/DragoniteSpam/Documentation/wiki/Emu

// feather use syntax-errors
function EmuTabGroup(x, y, width, height, rows, row_height) : EmuCore(x, y, width, height, "tab group") constructor {
    self.rows = rows;
    self.row_height = row_height;
    
    // Initialize the tab rows - which are just empty EmuCores
    repeat (self.rows) {
        array_push(self.contents, new EmuCore(0, 0, 0, 0, ""));
    }
    
    self.color_back = function() { return EMU_COLOR_BACK; };
    
    self.active_tab = undefined;
    self.active_tab_request = undefined;
    self.override_root_check = true;
    
    self.AddTabs = function(row, tabs) {
        if (row > self.rows) {
            throw new EmuException("Tab row out of bounds", "Trying to add to tab row " + string(row) + ", but only up to " + string(self.rows) + " are available");
        }
        
        if (!is_array(tabs)) tabs = [tabs];
        
        for (var i = 0; i < array_length(tabs); i++) {
            var tab = tabs[i];
            tab.root = self;
            tab.row = row;
            tab.index = array_length(self.contents[row].contents);
            array_push(self.contents[row].contents, tab);
            if (!self.active_tab && !self.active_tab_request) {
                self.RequestActivateTab(tab);
            }
        }
        self.arrangeRow(row);
        return self;
    };
    
    self.GetActiveTab = function() {
        return self.active_tab;
    };
    
    self.arrangeRow = function(row) {
        if (row > rows) {
            throw new EmuException("Tab row out of bounds", "Trying to arrange tab row " + string(row) + ", but only up to " + string(self.rows) + " are available");
        }
        
        var tab_row = self.contents[row];
        for (var i = 0, n = array_length(tab_row.contents); i < n; i++) {
            var tab = tab_row.contents[i];
            tab.row = row;
            tab.header_width = floor(self.width / n);
            tab.header_height = self.row_height;
            tab.header_x = tab.header_width * i;
            tab.header_y = tab.header_height * row;
        }
    };
    
    self.activateTab = function(tab) {
        if (tab.root != self) {
            throw new EmuException("Tab is not included in group", "You are trying to activate a tab in a group that it does not belong to. Please only activate tabs that are members of a group.");
        }
        
        self.active_tab = tab;
        var contents_clone = [];
        array_copy(contents_clone, 0, self.contents, 0, array_length(self.contents));
        var index = 0;
        for (var i = 0, n = array_length(contents_clone); i < n; i++) {
            if (i == tab.row) continue;
            self.contents[index] = contents_clone[i];
            self.arrangeRow(index++);
        }
        self.contents[self.rows - 1] = contents_clone[tab.row];
        self.arrangeRow(self.rows - 1);
    };
    
    self.RequestActivateTab = function(tab) {
        self.active_tab_request = tab;
        return self;
    };
    
    self.Render = function(base_x, base_y, debug_render = false) {
        self.update_script();
        self.processAdvancement();
        
        var x1 = x + base_x;
        var y1 = y + base_y;
        var x2 = x1 + self.width;
        var y2 = y1 + self.height;
        
        draw_sprite_stretched_ext(self.sprite_nineslice, 1, x1, y1 + self.rows * self.row_height, x2 - x1, y2 - y1 - self.rows * self.row_height, self.color_back(), 1);
        
        // Save this for the beginning of the next frame, because if you do it
        // in the middle you'll find the tabs become misaligned for one frame
        if (self.active_tab_request) {
            self.activateTab(self.active_tab_request);
            self.active_tab_request = undefined;
        }
        
        if (debug_render) self.renderDebugBounds(x1, y1, x2, y2);
        
        for (var i = 0, n = array_length(self.contents); i < n; i++) {
            self.contents[i].Render(x1, y1 + self.rows * self.row_height, debug_render);
        }
        
        // no sense making a tab group non-interactive
        draw_sprite_stretched_ext(self.sprite_nineslice, 2, x1, y1 + self.rows * self.row_height, x2 - x1, y2 - y1 - self.rows * self.row_height, self.color(), 1);
    };
}