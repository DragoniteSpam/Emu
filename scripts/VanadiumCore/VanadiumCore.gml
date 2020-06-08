function VCore(_x, _y, _w, _h, _root) constructor {
    x = _x;
    y = _y;
    width = _w;
    height = _h;
    root = _root;
    
    contents = ds_list_create();
    enabled = true;
    interactive = true;
    outline = true;             // not used in all element types
    tooltip = "";               // not used by all element types
    
    active_element = noone;
    
    text = "core";
    offset = 12;
    
    color = c_black;
    alignment = fa_left;
    valignment = fa_middle;
    
    // if you have a list of ui things in a list, and want to iterate over the
    // list, but want to ignore this one
    is_aux = false;
    
    // if this is set to true the mouse click check will use mouse_within_rectangle_adjusted
    // instead of mouse_within_rectangle_view
    adjust_view = false;
    
    override_escape = false;
    
    next = noone;
    previous = noone;
    
    Render = function(base_x, base_y) {
        for (var i = 0; i < ds_list_size(contents); i++) {
            var what = contents[| i];
            if (what.enabled) {
                what.Render(x + base_x, y + base_y);
            }
        }
    }
    
    Destroy = function() {
        for (var i = 0; i < ds_list_size(contents); i++) {
            contents[| i].Destroy();
        }
    }
    
    SetTooltip = function() {
        // The implementation of this is up to you - but you probably want to
        // assign the element's "tooltip" text to be drawn on the UI somewhere
    }
}