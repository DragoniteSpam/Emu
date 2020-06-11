container.Render(0, 0);

for (var i = 0; i < ds_list_size(global.__emu_dialogs); i++) {
    global.__emu_dialogs[| i].Render();
}