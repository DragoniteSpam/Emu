// Emu (c) 2020 @dragonitespam
// See the Github wiki for documentation: https://github.com/DragoniteSpam/Documentation/wiki/Emu

// I wanted to make this inherit from EmuInput but that made GameMaker cranky
// for some reason
// feather use syntax-errors
function EmuColorPicker(x, y, width, height, text, value, callback) : EmuCallback(x, y, width, height, text, value, callback) constructor {
    self.allow_alpha = false;
    
    self.box = {
        x1: self.width / 2,
        y1: 0,
        x2: self.width,
        y2: self.height,
    };
    
    self.color_back = function() { return EMU_COLOR_BACK; };
    
    self.SetAlphaUsed = function(alpha_used) {
        self.allow_alpha = alpha_used;
        return self;
    };
    
    self.SetInputBoxPosition = function(vx1, vy1, vx2, vy2) {
        self.box.x1 = vx1;
        self.box.y1 = vy1;
        self.box.x2 = vx2;
        self.box.y2 = vy2;
        return self;
    };
    
    self.GetColorCode = function() {
        var color_string = string(ptr(self.value));
        var rr = string_copy(color_string, string_length(color_string) - 1, 2);
        var gg = string_copy(color_string, string_length(color_string) - 3, 2);
        var bb = string_copy(color_string, string_length(color_string) - 5, 2);
        return rr + gg + bb;
    };
    
    self.Render = function(base_x, base_y, debug_render = false) {
        self.update_script();
        self.processAdvancement();
        
        var x1 = x + base_x;
        var y1 = y + base_y;
        var x2 = x1 + self.width;
        var y2 = y1 + self.height;
        var col_main = self.color();
        
        var vx1 = x1 + self.box.x1;
        var vy1 = y1 + self.box.y1;
        var vx2 = x1 + self.box.x2;
        var vy2 = y1 + self.box.y2;
        var ww = vx2 - vx1;
        var hh = vy2 - vy1;
        
        var tx = self.getTextX(x1);
        var ty = self.getTextY(y1);
        
        scribble(self.text)
            .wrap(self.width, self.height)
            .align(fa_left, fa_middle)
            .draw(tx, ty);
        
        draw_sprite_stretched_ext(self.sprite_nineslice, 1, vx1 + 1, vy1 + 1, vx2 - vx1 - 1, vy2 - vy1 - 1, self.color_back(), 1);
        self.drawCheckerbox(vx1 + 2, vy1 + 2, (vx2 - vx1) - 4, (vy2 - vy1) - 4);
        draw_sprite_stretched_ext(self.sprite_nineslice, 1, vx1 + 2, vy1 + 2, vx2 - vx1 - 2, vy2 - vy1 - 2, self.value, self.allow_alpha ? (((self.value & 0xff000000) >> 24) / 0xff) : 1);
        draw_sprite_stretched_ext(self.sprite_nineslice, 0, vx1 + 1, vy1 + 1, vx2 - vx1 - 1, vy2 - vy1 - 1, col_main, 1);
        
        if (self.GetInteractive()) {
            if (self.getMouseHover(vx1, vy1, vx2, vy2)) {
                if (self.getMouseReleased(vx1, vy1, vx2, vy2)) {
                    self.Activate();
                    self.ShowPickerDialog();
                }
                self.ShowTooltip();
            }
        }
        
        if (debug_render) self.renderDebugBounds(x1, y1, x2, y2);
    };
    
    self.ShowPickerDialog = function() {
        var dialog = new EmuDialog(480, 400, "Pick a col_main");
        dialog.base_color_element = self;
                    
        var ew = 256;
        var eh = 32;
                    
        var vx1 = 120;
        var vy1 = 0;
        var vx2 = ew;
        var vy2 = eh;
                    
        var yy = 64;
        var spacing = 16;
                    
        static controls = function(x, y, width, height, value, allow_alpha, callback) : EmuCallback(x, y, width, height, "", value, callback) constructor {
            enum EmuColorChannels { R, G, B, H, S, V }
                        
            self.axis_value = 0;
            self.axis_w = 0;
            self.axis_h = 0;
            self.axis_channel = EmuColorChannels.R;
            self.all_colors = true;
            self.alpha = 1;
                        
            self.allow_alpha = allow_alpha;
            self.override_escape = true;
                        
            self.color_x = 0;
            self.color_y = 0;
            self.main_size = 176;
            self.selecting_color = false;
                        
            self.sprite_crosshair = EMU_SPRITE_CROSSHAIR;
            self.sprite_mask_bar_h = EMU_SPRITE_MENU_BAR_H;
            self.sprite_mask_bar_v = EMU_SPRITE_MENU_BAR_V;
                        
            self.axis_x = self.color_x + self.main_size + 16;
            self.axis_y = self.color_y;
            self.axis_width = 32;
            // axis_height is main_size
            self.selecting_axis = false;
                        
            self.output_x = self.color_x + 48;
            self.output_y = self.color_y + self.main_size + 8;
            // output_width is main_size
            self.output_height = 16;
                        
            self.alpha_x = self.color_x + 48;
            self.alpha_y = self.output_y + self.output_height + 8;
            // alpha_width is main_size
            self.alpha_height = 16;
            self.selecting_alpha = false;
            
            self.last_non_black_value = value;
                        
            self.SetValue = function(value) {
                self.value = value;
                            
                switch (self.axis_channel) {
                    case EmuColorChannels.R:
                        self.axis_value = (value & 0x0000ff) / 0xff;
                        self.axis_w = ((value & 0x00ff00) >> 8) / 0xff;
                        self.axis_h = ((value & 0xff0000) >> 16) / 0xff;
                        break;
                    case EmuColorChannels.G:
                        self.axis_h = (value & 0x0000ff) / 0xff;
                        self.axis_value = ((value & 0x00ff00) >> 8) / 0xff;
                        self.axis_w = ((value & 0xff0000) >> 16) / 0xff;
                        break;
                    case EmuColorChannels.B:
                        self.axis_w = (value & 0x0000ff) / 0xff;
                        self.axis_h = ((value & 0x00ff00) >> 8) / 0xff;
                        self.axis_value = ((value & 0xff0000) >> 16) / 0xff;
                        break;
                    case EmuColorChannels.H:
                        self.axis_w = colour_get_saturation(value) / 0xff;
                        self.axis_h = colour_get_value(value) / 0xff;
                        self.axis_value = colour_get_hue(value) / 0xff;
                        break;
                    case EmuColorChannels.S:
                        self.axis_w = colour_get_value(value) / 0xff;
                        self.axis_h = colour_get_hue(value) / 0xff;
                        self.axis_value = colour_get_saturation(value) / 0xff;
                        break;
                    case EmuColorChannels.V:
                        self.axis_w = colour_get_value(value) / 0xff;
                        self.axis_h = colour_get_hue(value) / 0xff;
                        self.axis_value = colour_get_value(value) / 0xff;
                        break;
                }
            };
                        
            self.Render = function(base_x, base_y, debug_render = false) {
                var x1 = x + base_x;
                var y1 = y + base_y;
                var x2 = x1 + self.width;
                var y2 = y1 + self.height;
                var buckets = self.all_colors ? 255 : 8;
                var col_main = self.color();
                
                var color_initial = self.value;
                var alpha_initial = self.alpha;
                
                #region color picker
                var vx1 = x1 + self.color_x;
                var vy1 = y1 + self.color_y;
                var vx2 = vx1 + self.main_size;
                var vy2 = vy1 + self.main_size;
                var w = vx2 - vx1;
                var h = vy2 - vy1;
                
                var colour_replace_red = function(original, value) { return value | (original & 0xffff00); }
                var colour_replace_green = function(original, value) { return (value << 8) | (original & 0xff00ff); }
                var colour_replace_blue = function(original, value) { return (value << 16) | (original & 0x00ffff); }
                var colour_replace_hue = function(original, h) {
                    var s = colour_get_saturation(original);
                    var v = colour_get_value(original);
                    return make_colour_hsv(h, s, v);
                };
                var colour_replace_sat = function(original, s) {
                    var h = colour_get_hue(original);
                    var v = colour_get_value(original);
                    return make_colour_hsv(h, s, v);
                };
                var colour_replace_val = function(original, v) {
                    var h = colour_get_hue(original);
                    var s = colour_get_saturation(original);
                    return make_colour_hsv(h, s, v);
                };
                
                static shader_mode_def = 0;
                static shader_mode_hue = 1;
                static shader_mode_sat = 2;
                static shader_mode_val = 3;
                static shader_mode_hue_bar = 4;
                
                var shader_mode = shader_mode_def;
                var shader_color_base = 0;
                
                var c1 = c_white, c2 = c_white, c3 = c_white, c4 = c_white;
                
                switch (self.axis_channel) {
                    case EmuColorChannels.R:
                        c2 = colour_replace_red(c_white, self.axis_value * 0xff);
                        c1 = colour_replace_green(c2, 0);
                        c3 = colour_replace_blue(c2, 0);
                        c4 = self.axis_value * 0xff;
                        break;
                    case EmuColorChannels.G:
                        c2 = colour_replace_green(c_white, self.axis_value * 0xff);
                        c1 = colour_replace_blue(c2, 0);
                        c3 = colour_replace_red(c2, 0);
                        c4 = (self.axis_value * 0xff) << 8;
                        break;
                    case EmuColorChannels.B:
                        c2 = colour_replace_blue(c_white, self.axis_value * 0xff);
                        c1 = colour_replace_red(c2, 0);
                        c3 = colour_replace_green(c2, 0);
                        c4 = (self.axis_value * 0xff) << 16;
                        break;
                    case EmuColorChannels.H:
                        shader_mode = shader_mode_hue;
                        break;
                    case EmuColorChannels.S:
                        shader_mode = shader_mode_sat;
                        break;
                    case EmuColorChannels.V:
                        shader_mode = shader_mode_val;
                        break;
                };
                
                static rectangle = undefined;
                
                if (rectangle == undefined) {
                    var s = surface_create(1, 1);
                    surface_set_target(s);
                    draw_clear(c_white);
                    surface_reset_target();
                    rectangle = sprite_create_from_surface(s, 0, 0, 1, 1, false, false, 0, 0);
                    surface_free(s);
                }
                
                shader_set(shd_emu_color_buckets);
                shader_set_uniform_f(shader_get_uniform(shd_emu_color_buckets, "u_Buckets"), buckets);
                shader_set_uniform_i(shader_get_uniform(shd_emu_color_buckets, "u_Mode"), shader_mode);
                shader_set_uniform_f(shader_get_uniform(shd_emu_color_buckets, "u_ColorBase"), self.axis_value);
                draw_sprite_general(rectangle, 0, 0, 0, 1, 1, vx1, vy1, vx2 - vx1, vy2 - vy1, 0, c1, c2, c3, c4, 1);
                shader_reset();
                draw_rectangle_colour(vx1, vy1, vx2, vy2, col_main, col_main, col_main, col_main, true);
                
                if (self.getMouseHover(vx1, vy1, vx2, vy2)) {
                    if (self.getMouseHold(vx1, vy1, vx2, vy2)) {
                        self.selecting_color = true;
                    }
                }
                
                if (self.selecting_color) {
                    self.axis_w = clamp((mouse_x - vx1) / w, 0, 1);
                    self.axis_h = 1 - clamp((mouse_y - vy1) / h, 0, 1);
                    self.selecting_color = self.getMouseHold(0, 0, window_get_width(), window_get_height());
                }
                
                var current_axis = floor(self.axis_value * buckets) * 0xff / buckets;
                var ww = floor(self.axis_w * buckets) * 0xff / buckets;
                var hh = floor(self.axis_h * buckets) * 0xff / buckets;
                
                switch (self.axis_channel) {
                    case EmuColorChannels.R: self.value = make_colour_rgb(current_axis, ww, hh); break;
                    case EmuColorChannels.G: self.value = make_colour_rgb(hh, current_axis, ww); break;
                    case EmuColorChannels.B: self.value = make_colour_rgb(ww, hh, current_axis); break;
                    case EmuColorChannels.H: self.value = make_colour_hsv(current_axis, ww, hh); break;
                    case EmuColorChannels.S: self.value = make_colour_hsv(ww, current_axis, hh); break;
                    case EmuColorChannels.V: self.value = make_colour_hsv(ww, hh, current_axis); break;
                }
                
                if (self.value != c_black && self.value != c_white) {
                    self.last_non_black_value = self.value;
                }
                
                gpu_set_blendmode_ext(bm_inv_dest_color, bm_inv_src_color);
                var chx = vx1 + self.axis_w * w;
                var chy = vy1 + (1 - self.axis_h) * h;
                draw_sprite(self.sprite_crosshair, 0, chx, chy);
                gpu_set_blendmode(bm_normal);
                #endregion
                            
                #region color axis
                vx1 = x1 + self.axis_x;
                vy1 = y1 + self.axis_y;
                vx2 = vx1 + self.axis_width;
                vy2 = vy1 + main_size;
                w = vx2 - vx1;
                h = vy2 - vy1;
                            
                if (self.getMouseHover(vx1, vy1, vx2, vy2)) {
                    if (self.getMousePressed(vx1, vy1, vx2, vy2)) {
                        self.selecting_axis = true;
                    }
                }
                            
                if (self.selecting_axis) {
                    self.axis_value = clamp((mouse_y - vy1) / h, 0, 1);
                    self.selecting_axis = self.getMouseHold(0, 0, window_get_width(), window_get_height());
                }
                            
                shader_set(shd_emu_color_buckets);
                shader_set_uniform_f(shader_get_uniform(shd_emu_color_buckets, "u_Buckets"), buckets);
                
                var hue, ct, cb;
                
                switch (self.axis_channel) {
                    case EmuColorChannels.R:
                    case EmuColorChannels.G:
                    case EmuColorChannels.B:
                        var channels = [0x000000ff, 0x0000ff00, 0x00ff0000];
                        var c = channels[self.axis_channel];
                        draw_rectangle_colour(vx1, vy1, vx2, vy2, c_black, c_black, c, c, false);
                        break;
                    case EmuColorChannels.H:
                        shader_set(shd_emu_color_buckets);
                        shader_set_uniform_i(shader_get_uniform(shd_emu_color_buckets, "u_Mode"), shader_mode_hue_bar);
                        draw_sprite_stretched(rectangle, 0, vx1, vy1, vx2 - vx1, vy2 - vy1);
                        break;
                    case EmuColorChannels.S:
                        shader_set_uniform_i(shader_get_uniform(shd_emu_color_buckets, "u_Mode"), shader_mode_def);
                        hue = colour_get_hue(self.last_non_black_value);
                        ct = make_colour_hsv(hue, 255, 255);
                        cb = make_colour_hsv(hue,   0, 255);
                        draw_rectangle_colour(vx1, vy1, vx2, vy2, cb, cb, ct, ct, false);
                        break;
                    case EmuColorChannels.V:
                        shader_set_uniform_i(shader_get_uniform(shd_emu_color_buckets, "u_Mode"), shader_mode_def);
                        hue = colour_get_hue(self.last_non_black_value);
                        ct = make_colour_hsv(hue, 255, 255);
                        cb = make_colour_hsv(hue, 255,   0);
                        draw_rectangle_colour(vx1, vy1, vx2, vy2, cb, cb, ct, ct, false);
                        break;
                }
                
                shader_reset();
                draw_rectangle_colour(vx1, vy1, vx2, vy2, c_black, c_black, c_black, c_black, true);
                            
                var f = min(vy1 + h * self.axis_value, vy2 - 1);
                gpu_set_blendmode_ext(bm_inv_dest_color, bm_inv_src_color);
                draw_sprite_ext(self.sprite_mask_bar_h, 0, vx1, f, (vx2 - vx1) / sprite_get_width(self.sprite_mask_bar_h), 1, 0, c_white, 1);
                gpu_set_blendmode(bm_normal);
                #endregion
                            
                #region output color
                vx1 = x1 + self.output_x;
                vy1 = y1 + self.output_y;
                vx2 = vx1 + self.main_size;
                vy2 = vy1 + self.output_height;
                w = vx2 - vx1;
                h = vy2 - vy1;
                            
                self.drawCheckerbox(vx1, vy1, vx2 - vx1, vy2 - vy1, 0.4, 0.4);
                draw_set_alpha(self.alpha);
                draw_rectangle_colour(vx1, vy1, vx2, vy2, self.value, self.value, self.value, self.value, false);
                draw_set_alpha(1);
                draw_rectangle_colour(vx1, vy1, vx2, vy2, col_main, col_main, col_main, col_main, true);
                #endregion
                            
                #region alpha
                if (self.allow_alpha) {
                    vx1 = x1 + self.alpha_x;
                    vy1 = y1 + self.alpha_y;
                    vx2 = vx1 + self.main_size;
                    vy2 = vy1 + self.alpha_height;
                    w = vx2 - vx1;
                    h = vy2 - vy1;
                                
                    if (self.getMouseHover(vx1, vy1, vx2, vy2)) {
                        if (self.getMousePressed(vx1, vy1, vx2, vy2)) {
                            self.selecting_alpha = true;
                        }
                    }
                                
                    if (self.selecting_alpha) {
                        self.alpha = clamp((mouse_x - vx1) / w, 0, 1);
                        self.selecting_alpha = self.getMouseHold(0, 0, window_get_width(), window_get_height());
                    }
                                
                    scribble("A:")
                        .draw(self.getTextX(x + base_x), floor(mean(vy1, vy2)));
                    self.drawCheckerbox(vx1, vy1, vx2 - vx1, vy2 - vy1, 0.4, 0.4);
                    draw_primitive_begin(pr_trianglelist);
                    draw_vertex_colour(vx1, vy1, self.value, 0);
                    draw_vertex_colour(vx2 + 1, vy1, self.value, 1);
                    draw_vertex_colour(vx2 + 1, vy2 + 1, self.value, 1);
                    draw_vertex_colour(vx2 + 1, vy2 + 1, self.value, 1);
                    draw_vertex_colour(vx1, vy2 + 1, self.value, 0);
                    draw_vertex_colour(vx1, vy1, self.value, 0);
                    draw_primitive_end();
                    draw_rectangle_colour(vx1, vy1, vx2, vy2, c_black, c_black, c_black, c_black, true);
                                
                    f = min(vx1 + w * self.alpha, vx2 - 1);
                    gpu_set_blendmode_ext(bm_inv_dest_color, bm_inv_src_color);
                    draw_sprite_ext(self.sprite_mask_bar_v, 0, f, vy1, 1, (vy2 - vy1) / sprite_get_height(self.sprite_mask_bar_v), 0, c_white, 1);
                    gpu_set_blendmode(bm_normal);
                }
                #endregion
                            
                if (color_initial != self.value || alpha_initial != self.alpha) {
                    self.callback();
                }
                            
                if (debug_render) self.renderDebugBounds(x1, y1, x2, y2);
            }
        }
                    
        dialog.el_picker_code = new EmuInput(32, 32, ew, eh, "color:", emu_string_hex(((self.value & 0xff0000) >> 16) | (self.value & 0x00ff00) | (self.value & 0x0000ff) << 16, 6), "RRGGBB", 6, E_InputTypes.HEX, function() {
            if (string_length(self.value) == 6) {
                var value_as_real = emu_hex(string_copy(self.value, 5, 2) + string_copy(self.value, 3, 2) + string_copy(self.value, 1, 2));
                self.root.el_picker.SetValue(((value_as_real & 0xff0000) >> 16) | (value_as_real & 0x00ff00) | (value_as_real & 0x0000ff) << 16);
                self.root.base_color_element.value = value_as_real | (floor(self.root.el_picker.alpha * 0xff) << 24);
                self.root.base_color_element.last_non_black_value = self.root.base_color_element.value;
                self.root.base_color_element.callback();
            }
        })
            .SetUpdate(function() {
                if (keyboard_check(vk_control) && keyboard_check_pressed(ord("V"))) {
                    var text = clipboard_get_text();
                    if (string_copy(text, 1, 1) == "#") {
                        text = string_copy(text, 2, string_length(text) - 1);
                    }
                    if (string_length(text) == 6) {
                        var current_value = self.value;
                        try {
                            var color = int64(ptr(text));
                            var rr = colour_get_red(color);
                            var gg = colour_get_green(color);
                            var bb = colour_get_blue(color);
                            color = make_colour_rgb(bb, gg, rr);
                            self.value = text;
                            self.root.el_picker.SetValue(color);
                            self.root.base_color_element.value = color;
                            self.root.base_color_element.callback();
                            self.root.base_color_element.last_non_black_value = self.root.base_color_element.value;
                        } catch (e) {
                            self.value = current_value;
                        }
                    }
                }
            });
        dialog.el_picker_code.SetInputBoxPosition(vx1, vy1, vx2, vy2);
        dialog.el_picker_code.SetRealNumberBounds(0, 0xffffff);
                    
        dialog.el_picker = new controls(32, EMU_AUTO, ew, eh, self.value, self.allow_alpha, function() {
            self.root.base_color_element.value = self.value | (self.root.base_color_element.allow_alpha ? (floor(self.alpha * 0xff) << 24) : 0);
            self.root.el_picker_code.SetValue(emu_string_hex(((self.value & 0xff0000) >> 16) | (self.value & 0x00ff00) | ((self.value & 0x0000ff) << 16), 6));
            self.root.base_color_element.callback();
        });
                    
        dialog.el_picker.alpha = self.allow_alpha ? (((self.value & 0xff000000) >> 24) / 0xff) : 1;
        dialog.el_picker.axis_value = (self.value & 0x0000ff) / 0xff;
        dialog.el_picker.axis_w = ((self.value & 0x00ff00) >> 8) / 0xff;
        dialog.el_picker.axis_h = ((self.value & 0xff0000) >> 16) / 0xff;
                    
        dialog.el_channels = new EmuRadioArray(320, 32, ew / 2, eh, "Axis Channel", 0, function() {
            self.root.el_picker.axis_channel = self.value;
        });
        dialog.el_channels.AddOptions(["Red", "Green", "Blue", "Hue", "Saturation", "Value"]);
        dialog.el_all = new EmuCheckbox(320, EMU_AUTO, ew / 2, eh, "All colors?", true, function() {
            self.root.el_picker.all_colors = self.value;
        });
                    
        var b_width = 128;
        var b_height = 32;
        var el_confirm = new EmuButton(dialog.width / 2 - b_width / 2, dialog.height - 32 - b_height / 2, b_width, b_height, "Done", emu_dialog_close_auto);
                    
        dialog.AddContent([dialog.el_picker_code, dialog.el_picker, dialog.el_channels, dialog.el_all, el_confirm]);
        
        return dialog;
    };
}