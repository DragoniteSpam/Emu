if (async_load[? "id"] == self.buffer_id)  {
    if (async_load[? "status"]) {
        try {
            var json = json_parse(buffer_read(self.buffer, buffer_text));
            buffer_delete(self.buffer);
            var validate = function(json, key, def, value_min, value_max) {
                var value = json[$ key];
                if (is_numeric(value) && is_numeric(def)) {
                    return clamp(value, value_min, value_max);
                }
                if (is_string(value) && is_string(def)) {
                    return value;
                }
                return def;
            }
            
            global.__emu_settings.color_picker_all_colors = validate(json, "color_picker_all_colors", 1, 0, 1);
            
            show_debug_message($"emu settings loaded successfully!!!");
        } catch (e) {
            show_debug_message($"couldn't load the emu settings for some reason: {e.message}");
        }
    }
    instance_destroy();
}