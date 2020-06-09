I've changed some of Scribble's default values. If you ever manually update
the version of Scribble that this system uses, you will most likely want to
re-edit the default values otherwise the visual appearance may change.

    SCRIBBLE_COLORIZE_SPRITES is now false
    global.scribble_state_starting_color in scribble_reset is now VANADIUM_COLOR_DEFAULT
    all occurrences of array_length_1d have been changed to array_length (although this does not make a difference in terms of functionality)