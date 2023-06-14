// Emu (c) 2020 @dragonitespam
// See the Github wiki for documentation: https://github.com/DragoniteSpam/Documentation/wiki/Emu

// feather use syntax-errors
function EmuRenderSurface(x, y, width, height, render, step = function() { }, create = function() { }) : EmuCore(x, y, width, height, "") constructor {
    /// @ignore
    self.use_surface_depth = true;
    /// @ignore
    self.callback_render = method(self, render);
    /// @ignore
    self.callback_step = method(self, step);
    /// @ignore
    self.callback_recreate = function() {
        draw_clear(c_black);
        return self;
    };
    
    self.surface = self.surfaceVerify(-1, self.width, self.height).surface;
    surface_set_target(self.surface);
    draw_clear(c_black);
    method(self, create)();
    surface_reset_target();
    
    #region mutators
    self.SetRender = function(render) {
        self.callback_render = method(self, render);
        return self;
    };
    
    self.SetStep = function(step) {
        self.callback_step = method(self, step);
        return self;
    };
    
    self.SetRecreate = function(recreate) {
        self.callback_recreate = method(self, recreate);
        return self;
    };
    #endregion
    
    #region accessors
    self.GetSurface = function() {
        return self.surface;
    };
    #endregion
    
    #region other methods
    self.Render = function(x, y, debug_render = false) {
        self.update_script();
        self.processAdvancement();
        
        var x1 = self.x + x;
        var y1 = self.y + y;
        var x2 = x1 + self.width;
        var y2 = y1 + self.height;
        var mx = device_mouse_x_to_gui(0) - x1;
        var my = device_mouse_y_to_gui(0) - y1;
        
        var verify = self.surfaceVerify(self.surface, self.width, self.height);
        self.surface = verify.surface;
        
        if (verify.changed) {
            surface_set_target(self.surface);
            self.callback_recreate();
            surface_reset_target();
        }
        
        if (self.getMouseHover(x1, y1, x2, y2)) {
            self.ShowTooltip();
            if (self.getMousePressed(x1, y1, x2, y2) || self.getMouseMiddlePressed(x1, y1, x2, y2) || self.GetMouseRightPressed(x1, y1, x2, y2)) {
                self.Activate();
            }
        }
        
        self.callback_step(mx, my);
        
        surface_set_target(self.surface);
        var camera = camera_get_active();
        var old_view_mat = camera_get_view_mat(camera);
        var old_proj_mat = camera_get_proj_mat(camera);
        var old_state = gpu_get_state();
        self.callback_render(mx, my);
        camera_set_view_mat(camera, old_view_mat);
        camera_set_proj_mat(camera, old_proj_mat);
        camera_apply(camera);
        gpu_set_state(old_state);
        ds_map_destroy(old_state);
        surface_reset_target();
        
        draw_surface(self.surface, x1, y1);
        
        if (debug_render) self.renderDebugBounds(x1, y1, x2, y2);
    };
    #endregion
}