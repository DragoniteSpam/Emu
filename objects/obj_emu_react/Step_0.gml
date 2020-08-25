/// @description Reactive events.

// Generate an unparented container.
function FlyWindow(_x, _y, _width, _height, _flyWindows) constructor {
	// Initialize coordinate values.
	x = _x;
	y = _y;
	width = _width;
	height = _height;
	dragging = false;
	
	container = new EmuCore(_x, _y, _width, _height);
	ds_list_add(_flyWindows, self);
	
	UpdateContainer = function() {
		container.x = self.x;
		container.y = self.y;
		container.width = self.width;
		container.height = self.height;
	}
	
	AddContent = function(elements) {
		container.AddContent(elements);
	}
	
	Render = function(base_x, base_y) {
		container.Render(base_x, base_y);
	}
}

// Dragging fly windows.
for (var i = 0; i < ds_list_size(flyWindows); i++) {
	show_debug_message(i);
	if (flyWindows[| i].dragging) {
		flyWindows[| i].x = mouse_x;
		flyWindows[| i].y = mouse_y;
		flyWindows[| i].UpdateContainer();
		flyWindows[| i].Render();
		break;
	}
}

// Mouse-driven events.
if (mouse_check_button_pressed(mb_left)) {
	for (var i = 0; i < ds_list_size(allTabs); i++) {
		if (allTabs[| i].parent_group_id != 0) {
			if (allTabs[| i].MouseIsHovering()) {
				_pressed_id = allTabs[| i];
				break;
			}
		}
	}
}

// Drag a tab out of its container.
if (_pressed_id != 0) {
	// TODO: Do something better than this.
	if (mouse_check_button_released(mb_left)) {
		for (var i = 0; i < ds_list_size(flyWindows); i++) {
			flyWindows[| i].dragging = false;
		}
		
		_pressed_id = 0;
	}
	
	if (mouse_check_button(mb_left)) {
		if (
			// TODO: Give this correct coordinates.
			mouse_y > _pressed_id.y + _pressed_id.header_height
			|| mouse_y < _pressed_id.y
			|| mouse_x < _pressed_id.x
			|| mouse_x > _pressed_id.x + _pressed_id.header_width
		) {
			//show_debug_message(_pressed_id.parent_group_id);
			//_pressed_id.parent_group_id.RemoveTabs(_pressed_id);

			var newWindow = new FlyWindow(mouse_x, mouse_y, 200, 80, flyWindows);
			var tabs = new EmuTabGroup(0, 0, newWindow.width, newWindow.height, 1, 1);
			tabs.AddTabs(0, _pressed_id);
			newWindow.AddContent(tabs);
			newWindow.dragging = true;
		}
	}
}
