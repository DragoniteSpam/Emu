function VTabGroup(_x, _y, _w, _h, _rows, _row_height, _root) : VCore(_x, _y, _w, _h, _root) constructor {
    rows = _rows;
    row_height = _row_height;
    
    // Initialize the tab rows - which are just empty VCores
    repeat (rows) {
        ds_list_add(contents, new VCore(0, 0, 0, 0, self));
    }
    
    active_tab = noone;
    
    AddTab = function(tab, tab_row) {
        if (tab_row > rows) {
            throw new VException("Tab row out of bounds", "Trying to add to tab row " + string(row) + ", but only up to " + string(rows) + " are available");
        }
        ds_list_add(contents[| row].contents, tab);
    }
    
    Render = function(base_x, base_y) {
        var x1 = x + base_x;
        var y1 = y + base_y;
        var x2 = x1 + width;
        var y2 = y1 + height;
    }
    
    // Inherited:
    // SetTooltip()
    // Destroy()
}