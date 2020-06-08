function VTabGroup(_x, _y, _w, _h, _rows, _row_height, _root) : VCore(_x, _y, _w, _h, _root) constructor {
    rows = _rows;
    row_height = _row_height;
    
    // Initialize the tab rows - which are just empty VCores
    repeat (rows) {
        ds_list_add(contents, new VCore(0, 0, 0, 0, self));
    }
    
    active_tab = noone;
    
    AddTab = function(tab, row) {
        if (row > rows) {
            throw new VException("Tab row out of bounds", "Trying to add to tab row " + string(row) + ", but only up to " + string(rows) + " are available");
        }
        tab.root = self;
        ds_list_add(contents[| row].contents, tab);
        ArrangeTabs(row);
        return tab;
    }
    
    ArrangeTabs = function(row) {
        if (row > rows) {
            throw new VException("Tab row out of bounds", "Trying to arrange tab row " + string(row) + ", but only up to " + string(rows) + " are available");
        }
        
        var tab_row = contents[| row];
        for (var i = 0; i < ds_list_size(tab_row.contents); i++) {
            var tab = tab_row.contents[| i];
            tab.width = floor(width / ds_list_size(tab_row.contents));
            tab.height = row_height;
            tab.x = tab.width * i;
            tab.y = tab.height * row;
        }
    }
    
    Render = function(base_x, base_y) {
        var x1 = x + base_x;
        var y1 = y + base_y;
        var x2 = x1 + width;
        var y2 = y1 + height;
        
        DrawNineslice(spr_vanadium_nineslice, 0, x1, y1 + rows * row_height, x2, y2, color);
        
        for (var i = 0; i < ds_list_size(contents); i++) {
            contents[| i].Render(x1, y1);
        }
    }
    
    // Inherited:
    // SetTooltip()
    // Destroy()
}