// Emu (c) 2020 @dragonitespam
// See the Github wiki for documentation: https://github.com/DragoniteSpam/Emu/wiki
function EmuException(_message, _longMessage) constructor {
    message = _message;
    longMessage = _longMessage;
	var script_stack = debug_get_callstack();
	var script_count = array_length(script_stack);
	var script_top = script_stack[0];
	script = string_replace(string_copy(script_top, 1, string_pos(":", script_top) - 1), "gml_Script_", "");
    stacktrace = debug_get_callstack();
}