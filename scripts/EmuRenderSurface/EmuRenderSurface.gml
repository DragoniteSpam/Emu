function EmuRenderSurface(_x, _y, _w, _h, _render, _step, _create, _destroy) : EmuCore(_x, _y, _w, _h) constructor {
    SetRender = function(_render) {
        callback_render = method(self, _render);
    }
    
    SetStep = function(_step) {
        callback_step = method(self, _step);
    }
    
    SetRecreate = function(_recreate) {
        callback_recreate = method(self, _recreate);
    }
    
    SetRender(_render);
    SetStep(_step);
    callback_destroy = method(self, _destroy);
    
    callback_recreate = function() {
        draw_clear(c_black);
    }
    
    surface = surface_create(width, height);
    surface_set_target(surface);
    draw_clear(c_black);
    method(self, _create)();
    surface_reset_target();
    
    GetSurface = function() {
        return surface;
    }
    
    Recreate = function() {
        
    }
    
    Render = function(base_x, base_y) {
        processAdvancement();
        
        var x1 = x + base_x;
        var y1 = y + base_y;
        var x2 = x1 + width;
        var y2 = y1 + height;
        var mx = window_mouse_get_x() - x1;
        var my = window_mouse_get_y() - y1;
        
        if (!surface_exists(surface)) {
            surface = surface_create(width, height);
            surface_set_target(surface);
            callback_recreate();
            surface_reset_target();
        }
        
        if (getMouseHover(x1, y1, x2, y2)) {
            ShowTooltip();
            if (getMousePressed(x1, y1, x2, y2)) {
                Activate();
            }
        }
        
        callback_step(mx, my);
        
        surface_set_target(surface);
        var camera = camera_get_active();
        var old_view_mat = camera_get_view_mat(camera);
        var old_proj_mat = camera_get_proj_mat(camera);
        var old_state = gpu_get_state();
        callback_render(mx, my);
        camera_set_view_mat(camera, old_view_mat);
        camera_set_proj_mat(camera, old_proj_mat);
        camera_apply(camera);
        gpu_set_state(old_state);
        ds_map_destroy(old_state);
        surface_reset_target();
        
        draw_surface(surface, x1, y1);
    }
    
    Destroy = function() {
        destroyContent();
        if (surface_exists(surface)) surface_free(surface);
        callback_destroy();
    }
}