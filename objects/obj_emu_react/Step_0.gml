/// @description 
for (var i = 1; i < array_length(allTabs); i++) {
	if (allTabs[i].MouseIsHovering()) {
		show_debug_message("Hover");
		break;
	}
}

show_debug_message(array_length(allTabs));
