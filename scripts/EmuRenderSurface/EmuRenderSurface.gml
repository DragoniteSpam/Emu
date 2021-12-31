// Emu (c) 2020 @dragonitespam
// See the Github wiki for documentation: https://github.com/DragoniteSpam/Documentation/wiki/Emu
function EmuRenderSurface(x, y, w, h, render, step, create) : EmuCore(x, y, w, h) constructor {
    static SetRender = function(render) {
        callback_render = method(self, render);
        return self;
    };
    
    static SetStep = function(step) {
        callback_step = method(self, step);
        return self;
    };
    
    static SetRecreate = function(recreate) {
        callback_recreate = method(self, recreate);
        return self;
    };
    
    SetRender(render);
    SetStep(step);
    
    static callback_recreate = function() {
        draw_clear(c_black);
        return self;
    };
    
    self.surface = self.surfaceVerify(-1, self.width, self.height).surface;
    surface_set_target(self.surface);
    draw_clear(c_black);
    method(self, create)();
    surface_reset_target();
    
    static GetSurface = function() {
        return surface;
    };
    
    static Recreate = function() {
        
    };
    
    static Render = function(base_x, base_y) {
        self.gc.Clean();
        processAdvancement();
        
        var x1 = x + base_x;
        var y1 = y + base_y;
        var x2 = x1 + width;
        var y2 = y1 + height;
        var mx = device_mouse_x_to_gui(0) - x1;
        var my = device_mouse_y_to_gui(0) - y1;
        
        var verify = self.surfaceVerify(self.surface, self.width, self.height);
        self.surface = verify.surface;
        
        if (verify.changed) {
            surface_set_target(self.surface);
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
    };
}