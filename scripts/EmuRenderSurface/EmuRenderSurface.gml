// Emu (c) 2020 @dragonitespam
// See the Github wiki for documentation: https://github.com/DragoniteSpam/Emu/wiki
function EmuRenderSurface(x, y, w, h, render, step, create, destroy) : EmuCore(x, y, w, h) constructor {
    SetRender = function(render) {
        callback_render = method(self, render);
    }
    
    SetStep = function(step) {
        callback_step = method(self, step);
    }
    
    SetRecreate = function(recreate) {
        callback_recreate = method(self, recreate);
    }
    
    SetRender(render);
    SetStep(step);
    callback_destroy = method(self, destroy);
    
    callback_recreate = function() {
        draw_clear(c_black);
    }
    
    self._surface = surface_create(self.width, self.height);
    surface_set_target(self._surface);
    draw_clear(c_black);
    method(self, create)();
    surface_reset_target();
    
    GetSurface = function() {
        return _surface;
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
        
        if (!surface_exists(_surface)) {
            _surface = surface_create(width, height);
            surface_set_target(_surface);
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
        
        surface_set_target(_surface);
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
        
        draw_surface(_surface, x1, y1);
    }
    
    Destroy = function() {
        destroyContent();
        if (surface_exists(_surface)) surface_free(_surface);
        callback_destroy();
    }
}