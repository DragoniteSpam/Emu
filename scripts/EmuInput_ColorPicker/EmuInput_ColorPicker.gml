// Emu (c) 2020 @dragonitespam
// See the Github wiki for documentation: https://github.com/DragoniteSpam/Documentation/wiki/Emu

// I wanted to make this inherit from EmuInput but that made GameMaker cranky
// for some reason
function EmuColorPicker(x, y, w, h, text, value, callback) : EmuCallback(x, y, w, h, text, value, callback) constructor {
    self.allow_alpha = false;
    
    self.box = {
        x1: self.width / 2,
        y1: 0,
        x2: self.width,
        y2: self.height,
    };
    
    self.color_back = function() { return EMU_COLOR_BACK };
    
    static SetAlphaUsed = function(alpha_used) {
        allow_alpha = self.alpha_used;
        return self;
    };
    
    static SetInputBoxPosition = function(vx1, vy1, vx2, vy2) {
        self.box.x1 = vx1;
        self.box.y1 = vy1;
        self.box.x2 = vx2;
        self.box.y2 = vy2;
        return self;
    };
    
    static Render = function(base_x, base_y) {
        self.gc.Clean();
        processAdvancement();
        
        var x1 = x + base_x;
        var y1 = y + base_y;
        var x2 = x1 + width;
        var y2 = y1 + height;
        var col_main = self.color();
        
        var vx1 = x1 + box.x1;
        var vy1 = y1 + box.y1;
        var vx2 = x1 + box.x2;
        var vy2 = y1 + box.y2;
        var ww = vx2 - vx1;
        var hh = vy2 - vy1;
        
        var tx = getTextX(x1);
        var ty = getTextY(y1);
        
        scribble(self.text)
            .wrap(self.width, self.height)
            .align(fa_left, fa_middle)
            .draw(tx, ty);
        
        draw_sprite_stretched_ext(sprite_nineslice, 1, vx1 + 1, vy1 + 1, vx2 - vx1 - 1, vy2 - vy1 - 1, self.color_back(), 1);
        drawCheckerbox(vx1 + 2, vy1 + 2, (vx2 - vx1) - 4, (vy2 - vy1) - 4);
        draw_sprite_stretched_ext(sprite_nineslice, 1, vx1 + 2, vy1 + 2, vx2 - vx1 - 2, vy2 - vy1 - 2, value, allow_alpha ? (((value & 0xff000000) >> 24) / 0xff) : 1);
        draw_sprite_stretched_ext(sprite_nineslice, 0, vx1 + 1, vy1 + 1, vx2 - vx1 - 1, vy2 - vy1 - 1, col_main, 1);
        
        if (GetInteractive()) {
            if (getMouseHover(vx1, vy1, vx2, vy2)) {
                if (getMouseReleased(vx1, vy1, vx2, vy2)) {
                    Activate();
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
                    
                    var controls = function(x, y, w, h, value, allow_alpha, callback) : EmuCallback(x, y, w, h, "", value, callback) constructor {
                        enum EmuColorChannels { R, G, B, A }
                        
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
                        
                        self.sprite_crosshair = spr_emu_mask_crosshair;
                        self.sprite_mask_bar_h = spr_emu_mask_bar_h;
                        self.sprite_mask_bar_v = spr_emu_mask_bar_v;
                        
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
                        
                        static SetValue = function(value) {
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
                            }
                        };
                        
                        static Render = function(base_x, base_y) {
                            self.gc.Clean();
                            var x1 = x + base_x;
                            var y1 = y + base_y;
                            var x2 = x1 + width;
                            var y2 = y1 + height;
                            var buckets = all_colors ? 255 : 8;
                            var col_main = self.color();
                            
                            var color_initial = value;
                            var alpha_initial = alpha;
                            
                            #region color picker
                            var vx1 = x1 + color_x;
                            var vy1 = y1 + color_y;
                            var vx2 = vx1 + main_size;
                            var vy2 = vy1 + main_size;
                            var w = vx2 - vx1;
                            var h = vy2 - vy1;
                            
                            var colour_replace_red = function(original, value) { return value | (original & 0xffff00); }
                            var colour_replace_green = function(original, value) { return (value << 8) | (original & 0xff00ff); }
                            var colour_replace_blue = function(original, value) { return (value << 16) | (original & 0x00ffff); }
                            
                            switch (axis_channel) {
                                case EmuColorChannels.R:
                                    var c2 = colour_replace_red(c_white, axis_value * 0xff);
                                    var c1 = colour_replace_green(c2, 0);
                                    var c3 = colour_replace_blue(c2, 0);
                                    var c4 = axis_value * 0xff;
                                    break;
                                case EmuColorChannels.G:
                                    var c2 = colour_replace_green(c_white, axis_value * 0xff);
                                    var c1 = colour_replace_blue(c2, 0);
                                    var c3 = colour_replace_red(c2, 0);
                                    var c4 = (axis_value * 0xff) << 8;
                                    break;
                                case EmuColorChannels.B:
                                    var c2 = colour_replace_blue(c_white, axis_value * 0xff);
                                    var c1 = colour_replace_red(c2, 0);
                                    var c3 = colour_replace_green(c2, 0);
                                    var c4 = (axis_value * 0xff) << 16;
                                    break;
                            };
                            
                            if (getMouseHover(vx1, vy1, vx2, vy2)) {
                                if (getMouseHold(vx1, vy1, vx2, vy2)) {
                                    selecting_color = true;
                                }
                            }
                            
                            if (selecting_color) {
                                axis_w = clamp((mouse_x - vx1) / w, 0, 1);
                                axis_h = 1 - clamp((mouse_y - vy1) / h, 0, 1);
                                selecting_color = getMouseHold(0, 0, window_get_width(), window_get_height());
                            }
                            
                            var current_axis = floor(axis_value * buckets) * 0xff / buckets;
                            var ww = floor(axis_w * buckets) * 0xff / buckets;
                            var hh = floor(axis_h * buckets) * 0xff / buckets;
                            
                            switch (axis_channel) {
                                case EmuColorChannels.R: value = (hh << 16) | (ww << 8) | current_axis; break;
                                case EmuColorChannels.G: value = (ww << 16) | (current_axis << 8) | hh; break;
                                case EmuColorChannels.B: value = (current_axis << 16) | (hh << 8) | ww; break;
                            }
                            
                            shader_set(shd_emu_color_buckets);
                            shader_set_uniform_f(shader_get_uniform(shd_emu_color_buckets, "buckets"), buckets);
                            draw_rectangle_colour(vx1, vy1, vx2, vy2, c1, c2, c3, c4, false);
                            shader_reset();
                            draw_rectangle_colour(vx1, vy1, vx2, vy2, col_main, col_main, col_main, col_main, true);

                            gpu_set_blendmode_ext(bm_inv_dest_color, bm_inv_src_color);
                            var chx = vx1 + axis_w * w;
                            var chy = vy1 + (1 - axis_h) * h;
                            draw_sprite(sprite_crosshair, 0, chx, chy);
                            gpu_set_blendmode(bm_normal);
                            #endregion
                            
                            #region color axis
                            vx1 = x1 + self.axis_x;
                            vy1 = y1 + self.axis_y;
                            vx2 = vx1 + self.axis_width;
                            vy2 = vy1 + main_size;
                            var w = vx2 - vx1;
                            var h = vy2 - vy1;
                            
                            if (getMouseHover(vx1, vy1, vx2, vy2)) {
                                if (getMousePressed(vx1, vy1, vx2, vy2)) {
                                    self.selecting_axis = true;
                                }
                            }
                            
                            if (selecting_axis) {
                                axis_value = clamp((mouse_y - vy1) / h, 0, 1);
                                self.selecting_axis = getMouseHold(0, 0, window_get_width(), window_get_height());
                            }
                            
                            shader_set(shd_emu_color_buckets);
                            shader_set_uniform_f(shader_get_uniform(shd_emu_color_buckets, "buckets"), buckets);
                            var channels = [0x000000ff, 0x0000ff00, 0x00ff0000, 0xff000000];
                            var c = channels[axis_channel];
                            draw_rectangle_colour(vx1, vy1, vx2, vy2, c_black, c_black, c, c, false);
                            shader_reset();
                            draw_rectangle_colour(vx1, vy1, vx2, vy2, c_black, c_black, c_black, c_black, true);
                            
                            var f = min(vy1 + h * axis_value, vy2 - 1);
                            gpu_set_blendmode_ext(bm_inv_dest_color, bm_inv_src_color);
                            draw_sprite_ext(sprite_mask_bar_h, 0, vx1, f, (vx2 - vx1) / sprite_get_width(sprite_mask_bar_h), 1, 0, c_white, 1);
                            gpu_set_blendmode(bm_normal);
                            #endregion
                            
                            #region output color
                            vx1 = x1 + self.output_x;
                            vy1 = y1 + self.output_y;
                            vx2 = vx1 + main_size;
                            vy2 = vy1 + self.output_height;
                            var w = vx2 - vx1;
                            var h = vy2 - vy1;
                            
                            drawCheckerbox(vx1, vy1, vx2 - vx1, vy2 - vy1, 0.4, 0.4);
                            draw_set_alpha(alpha);
                            draw_rectangle_colour(vx1, vy1, vx2, vy2, value, value, value, value, false);
                            draw_set_alpha(1);
                            draw_rectangle_colour(vx1, vy1, vx2, vy2, col_main, col_main, col_main, col_main, true);
                            #endregion
                            
                            #region alpha
                            if (allow_alpha) {
                                vx1 = x1 + alpha_x;
                                vy1 = y1 + alpha_y;
                                vx2 = vx1 + main_size;
                                vy2 = vy1 + self.alpha_height;
                                var w = vx2 - vx1;
                                var h = vy2 - vy1;
                                
                                if (getMouseHover(vx1, vy1, vx2, vy2)) {
                                    if (getMousePressed(vx1, vy1, vx2, vy2)) {
                                        self.selecting_alpha = true;
                                    }
                                }
                                
                                if (selecting_alpha) {
                                    alpha = clamp((mouse_x - vx1) / w, 0, 1);
                                    self.selecting_alpha = getMouseHold(0, 0, window_get_width(), window_get_height());
                                }
                                
                                scribble("A:")
                                    .draw(self.getTextX(x + base_x), floor(mean(vy1, vy2)));
                                drawCheckerbox(vx1, vy1, vx2 - vx1, vy2 - vy1, 0.4, 0.4);
                                draw_primitive_begin(pr_trianglelist);
                                draw_vertex_colour(vx1, vy1, value, 0);
                                draw_vertex_colour(vx2 + 1, vy1, value, 1);
                                draw_vertex_colour(vx2 + 1, vy2 + 1, value, 1);
                                draw_vertex_colour(vx2 + 1, vy2 + 1, value, 1);
                                draw_vertex_colour(vx1, vy2 + 1, value, 0);
                                draw_vertex_colour(vx1, vy1, value, 0);
                                draw_primitive_end();
                                draw_rectangle_colour(vx1, vy1, vx2, vy2, c_black, c_black, c_black, c_black, true);
                                
                                var f = min(vx1 + w * alpha, vx2 - 1);
                                gpu_set_blendmode_ext(bm_inv_dest_color, bm_inv_src_color);
                                draw_sprite_ext(sprite_mask_bar_v, 0, f, vy1, 1, (vy2 - vy1) / sprite_get_height(sprite_mask_bar_v), 0, c_white, 1);
                                gpu_set_blendmode(bm_normal);
                            }
                            #endregion
                            
                            if (color_initial != value || alpha_initial != alpha) {
                                callback();
                            }
                        }
                    }
                    
                    dialog.el_picker_code = new EmuInput(32, 32, ew, eh, "color:", emu_string_hex(((value & 0xff0000) >> 16) | (value & 0x00ff00) | (value & 0x0000ff) << 16, 6), "RRGGBB", 6, E_InputTypes.HEX, function() {
                        if (string_length(value) == 6) {
                            var value_as_real = emu_hex(string_copy(value, 5, 2) + string_copy(value, 3, 2) + string_copy(value, 1, 2));
                            root.el_picker.SetValue(((value_as_real & 0xff0000) >> 16) | (value_as_real & 0x00ff00) | (value_as_real & 0x0000ff) << 16);
                            root.base_color_element.value = value_as_real | (floor(root.el_picker.alpha * 0xff) << 24);
                            root.base_color_element.callback();
                        }
                    });
                    dialog.el_picker_code.SetInputBoxPosition(vx1, vy1, vx2, vy2);
                    dialog.el_picker_code.SetRealNumberBounds(0, 0xffffff);
                    
                    dialog.el_picker = new controls(32, EMU_AUTO, ew, eh, value, allow_alpha, function() {
                        root.base_color_element.value = value | (self.root.base_color_element.allow_alpha ? (floor(alpha * 0xff) << 24) : 0);
                        root.el_picker_code.SetValue(emu_string_hex(((value & 0xff0000) >> 16) | (value & 0x00ff00) | ((value & 0x0000ff) << 16), 6));
                        root.base_color_element.callback();
                    });
                    
                    dialog.el_picker.alpha = self.allow_alpha ? (((value & 0xff000000) >> 24) / 0xff) : 1;
                    dialog.el_picker.axis_value = (value & 0x0000ff) / 0xff;
                    dialog.el_picker.axis_w = ((value & 0x00ff00) >> 8) / 0xff;
                    dialog.el_picker.axis_h = ((value & 0xff0000) >> 16) / 0xff;
                    
                    dialog.el_channels = new EmuRadioArray(320, 32, ew / 2, eh, "Axis Channel", 0, function() {
                        root.el_picker.axis_channel = value;
                    });
                    dialog.el_channels.AddOptions(["Red", "Green", "Blue"]);
                    dialog.el_all = new EmuCheckbox(320, EMU_AUTO, ew / 2, eh, "All colors?", true, function() {
                        root.el_picker.all_colors = value;
                    });
                    
                    var b_width = 128;
                    var b_height = 32;
                    var el_confirm = new EmuButton(dialog.width / 2 - b_width / 2, dialog.height - 32 - b_height / 2, b_width, b_height, "Done", emu_dialog_close_auto);
                    
                    dialog.AddContent([dialog.el_picker_code, dialog.el_picker, dialog.el_channels, dialog.el_all, el_confirm]);
                }
                ShowTooltip();
            }
        }
    };
}