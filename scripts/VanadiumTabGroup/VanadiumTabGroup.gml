function VTabGroup(_x, _y, _w, _h, _rows, _row_height) : VCore(_x, _y, _w, _h) constructor {
    rows = _rows;
    row_height = _row_height;
    
    // Initialize the tab rows - which are just empty VCores
    repeat (rows) {
        ds_list_add(contents, new VCore(0, 0, 0, 0));
    }
    
    active_tab = noone;
    active_tab_request = noone;
    
    AddTab = function(tab, row) {
        if (row > rows) {
            throw new VException("Tab row out of bounds", "Trying to add to tab row " + string(row) + ", but only up to " + string(rows) + " are available");
        }
        tab.root = self;
        tab.row = row;
        tab.index = ds_list_size(contents[| row].contents);
        ds_list_add(contents[| row].contents, tab);
        ArrangeRow(row);
        return tab;
    }
    
    ArrangeRow = function(row) {
        if (row > rows) {
            throw new VException("Tab row out of bounds", "Trying to arrange tab row " + string(row) + ", but only up to " + string(rows) + " are available");
        }
        
        var tab_row = contents[| row];
        for (var i = 0; i < ds_list_size(tab_row.contents); i++) {
            var tab = tab_row.contents[| i];
            tab.row = row;
            tab.header_width = floor(width / ds_list_size(tab_row.contents));
            tab.header_height = row_height;
            tab.header_x = tab.header_width * i;
            tab.header_y = tab.header_height * row;
        }
    }
    
    ActivateTab = function(tab) {
        if (tab.root != self) {
            throw new VException("Tab is not included in group", "You are trying to activate a tab in a group that it does not belong to. Please only activate tabs that are members of a group.");
        }
        
        active_tab = tab;
        var contents_clone = ds_list_create();
        ds_list_copy(contents_clone, contents);
        var index = 0;
        for (var i = 0; i < ds_list_size(contents_clone); i++) {
            if (i == tab.row) continue;
            contents[| index] = contents_clone[| i];
            ArrangeRow(index++);
        }
        contents[| rows - 1] = contents_clone[| tab.row];
        ArrangeRow(rows - 1);
    }
    
    RequestActivateTab = function(tab) {
        active_tab_request = tab;
    }
    
    Render = function(base_x, base_y) {
        var x1 = x + base_x;
        var y1 = y + base_y;
        var x2 = x1 + width;
        var y2 = y1 + height;
        
        for (var i = 0; i < ds_list_size(contents); i++) {
            contents[| i].Render(x1, y1 + rows * row_height);
        }
        
        // no sense making a tab group non-interactive
        DrawNineslice(sprite_nineslice, 2, x1, y1 + rows * row_height, x2, y2, VANADIUM_COLOR_BACK, 1);
        DrawNineslice(sprite_nineslice, 2, x1, y1 + rows * row_height, x2, y2, color, 1);
        
        // Save this for after everything has been drawn, because if you do it
        // in the middle you'll find the tabs become misaligned for one frame
        if (active_tab_request) {
            ActivateTab(active_tab_request);
            active_tab_request = noone;
        }
    }
}