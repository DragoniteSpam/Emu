// Emu (c) 2020 @dragonitespam
// See the Github wiki for documentation: https://github.com/DragoniteSpam/Documentation/wiki/Emu

// feather use syntax-errors
function EmuException(message, longMessage) constructor {
	var script_top = debug_get_callstack()[0];
    self.message = message;
    self.longMessage = longMessage;
	self.script = string_replace(string_copy(script_top, 1, string_pos(":", script_top) - 1), "gml_Script_", "");
    self.stacktrace = debug_get_callstack();
}