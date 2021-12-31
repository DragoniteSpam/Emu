// Emu (c) 2020 @dragonitespam
// See the Github wiki for documentation: https://github.com/DragoniteSpam/Documentation/wiki/Emu
function EmuException(_message, _longMessage) constructor {
    message = _message;
    longMessage = _longMessage;
	var script_top = debug_get_callstack()[0];
	script = string_replace(string_copy(script_top, 1, string_pos(":", script_top) - 1), "gml_Script_", "");
    stacktrace = debug_get_callstack();
}