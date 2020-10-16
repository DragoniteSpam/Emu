/// Caches a text element given a string using Scribble's formatting
/// 
/// Returns: Scribble text element (which is really a complex array)
/// @param string             The string to be drawn
/// @param [occuranceName]    Unique identifier to differentiate particular occurances of a string within the game
/// @param [garbageCollect]   When set to <false>, Scribble will *not* automatically clean up this data and you will need to use scribble_flush() instead. Defaults to <true>
/// @param [freeze]           Whether to freeze the vertex buffers or not. Substantially increase up-front caching cost but makes drawing faster. Defaults to <false>
///
/// Please see scribble_draw() for inline formatting commands
function scribble_cache() {

	var _draw_string     = argument[0];
	var _occurance_name  = ((argument_count > 1) && (argument[1] != undefined))? argument[1] : SCRIBBLE_DEFAULT_OCCURANCE_NAME;
	var _garbage_collect = ((argument_count > 2) && (argument[2] != undefined))? argument[2] : true;
	var _freeze          = ((argument_count > 3) && (argument[3] != undefined))? argument[3] : false;

	var _build   = true;
	var _rebuild = false;

	//If the input string is an array (secret behaviour that Scribble uses!) then run some checking code
	if (is_array(_draw_string))
	{
	    var _scribble_array = _draw_string;
    
	    if ((array_length(_scribble_array) != SCRIBBLE.__SIZE)
	    || (_scribble_array[SCRIBBLE.VERSION] != __SCRIBBLE_VERSION))
	    {
	        show_error("Scribble:\nArray is not a valid Scribble text element\n ", false);
	        return undefined;
	    }
	    else if (_scribble_array[SCRIBBLE.FREED])
	    {
	        //This text element has had its memory freed already, rebuild it
	        _rebuild = true;
        
	        var _old_draw_state = scribble_get_state(true);
	        scribble_set_state(_scribble_array[SCRIBBLE.DRAW_STATE]);
	        _draw_string = _scribble_array[SCRIBBLE.STRING];
	        _garbage_collect = true; //Always garbage collect rebuilt
        
	        if (SCRIBBLE_VERBOSE) show_debug_message("Scribble: Rebuilding text element for \"" + string(_draw_string) + "\"");
	    }
	    else
	    {
	        _build = false;
	        _events_char_array = _scribble_array[SCRIBBLE.EVENT_CHAR_ARRAY];
	    }
	}

	if (_build)
	{
	    //Check if the string already exists in the cache
	    var _cache_string = string(_draw_string) + global.__scribble_cache_string;
	    if (ds_map_exists(global.__scribble_global_cache_map, _cache_string) && !_rebuild)
	    {
	        //Grab the text element from the cache
	        var _scribble_array = global.__scribble_global_cache_map[? _cache_string];
	    }
	    else
	    {
	        //Cache a new text element if we don't have a relevant one for this string

	        //Record the start time so we can get a duration later
	        if (SCRIBBLE_VERBOSE) var _timer_total = get_timer();

	        //Create a couple data structures
	        var _parameters_list       = ds_list_create();
	        var _texture_to_buffer_map = ds_map_create();



        #region Process input parameters

	        var _max_width         = global.scribble_state_max_width;
	        var _max_height        = global.scribble_state_max_height;
	        var _line_min_height   = global.scribble_state_line_min_height;
	        var _line_max_height   = global.scribble_state_line_max_height;
	        var _line_fixed_height = false;
	        var _def_colour        = global.scribble_state_starting_color;
	        var _def_font          = global.scribble_state_starting_font;
	        var _def_halign        = global.scribble_state_starting_halign;
        
	        //Check if the default font even exists
	        if (!ds_map_exists(global.__scribble_font_data, _def_font))
	        {
	            show_error("Scribble:\nDefault font \"" + string(_def_font) + "\" not recognised\n ", false);
	            exit;
	        }
        
	        var _font_data         = global.__scribble_font_data[? _def_font];
	        var _font_glyphs_map   = _font_data[__SCRIBBLE_FONT.GLYPHS_MAP  ];
	        var _font_glyphs_array = _font_data[__SCRIBBLE_FONT.GLYPHS_ARRAY];
	        var _font_glyphs_min   = _font_data[__SCRIBBLE_FONT.GLYPH_MIN   ];
	        var _font_glyphs_max   = _font_data[__SCRIBBLE_FONT.GLYPH_MAX   ];
        
	        var _glyph_texture = undefined;
	        var _glyph_array = (_font_glyphs_array == undefined)? _font_glyphs_map[? 32] : _font_glyphs_array[32 - _font_glyphs_min];
	        if (_glyph_array == undefined)
	        {
	            show_error("Scribble:\nThe space character is missing from font definition for \"" + _def_font + "\"\n ", true);
	            return undefined;
	        }
        
	        var _font_line_height = _glyph_array[SCRIBBLE_GLYPH.HEIGHT];
	        var _font_space_width = _glyph_array[SCRIBBLE_GLYPH.WIDTH ];
        
	        if (_line_min_height < 0) _line_min_height = _font_line_height;
        
	        if ((_line_max_height >= 0) && (_line_max_height <= _line_min_height))
	        {
	            if (_line_min_height >= 0)
	            {
	                _line_fixed_height = true;
	                var _half_fixed_height = _line_min_height div 2;
	            }
	        }
        
	        //Try to use a custom colour if the "startingColour" parameter is a string
	        if (is_string(_def_colour))
	        {
	            var _value = global.__scribble_colours[? _def_colour];
	            if (_value == undefined)
	            {
	                show_error("Scribble:\nThe starting colour (\"" + _def_colour + "\") has not been added as a custom colour. Defaulting to c_white.\n ", false);
	                _value = c_white;
	            }
            
	            _def_colour = _value;
	        }
        
        #endregion



        #region Create the base text element
        
	        var _meta_element_characters = 0;
	        var _meta_element_lines      = 0;
	        var _meta_element_pages      = 0;
	        var _element_height          = 0;
    
	        //Create a new array if we're no rebuilding, otherwise reuse the old one
	        if (!_rebuild) var _scribble_array = array_create(SCRIBBLE.__SIZE);
    
	        var _element_pages_array = []; //Stores each page of text
	        var _character_array     = SCRIBBLE_CREATE_CHARACTER_ARRAY? [] : undefined;
	        var _occurances_map      = ds_map_create();
        
	        var _events_char_array = []; //Stores each event's triggering character
	        var _events_name_array = []; //Stores each event's name
	        var _events_data_array = []; //Stores each event's parameters
    
	        _scribble_array[@ SCRIBBLE.__SECTION0      ] = "-- Parameters --";
	        _scribble_array[@ SCRIBBLE.VERSION         ] = __SCRIBBLE_VERSION;
	        _scribble_array[@ SCRIBBLE.STRING          ] = _draw_string;
	        _scribble_array[@ SCRIBBLE.CACHE_STRING    ] = _cache_string;
	        _scribble_array[@ SCRIBBLE.DRAW_STATE      ] = scribble_get_state(true);
	        _scribble_array[@ SCRIBBLE.GARBAGE_COLLECT ] = _garbage_collect;
    
	        _scribble_array[@ SCRIBBLE.__SECTION1      ] = "-- Statistics --";
	        _scribble_array[@ SCRIBBLE.WIDTH           ] = 0;
	        _scribble_array[@ SCRIBBLE.MIN_X           ] = 0;
	        _scribble_array[@ SCRIBBLE.MAX_X           ] = 0;
	        _scribble_array[@ SCRIBBLE.HEIGHT          ] = 0;
	        _scribble_array[@ SCRIBBLE.CHARACTERS      ] = 0;
	        _scribble_array[@ SCRIBBLE.LINES           ] = 0;
	        _scribble_array[@ SCRIBBLE.PAGES           ] = 0;
	        _scribble_array[@ SCRIBBLE.GLYPH_LTRB_ARRAY] = undefined;
	        _scribble_array[@ SCRIBBLE.CHARACTER_ARRAY ] = _character_array;
        
	        _scribble_array[@ SCRIBBLE.__SECTION2      ] = "-- State --";
	        _scribble_array[@ SCRIBBLE.DRAWN_TIME      ] = current_time;
	        _scribble_array[@ SCRIBBLE.FREED           ] = false;
	        _scribble_array[@ SCRIBBLE.OCCURANCES_MAP  ] = _occurances_map;
        
	        _scribble_array[@ SCRIBBLE.__SECTION3      ] = "-- Data --";
	        _scribble_array[@ SCRIBBLE.PAGES_ARRAY     ] = _element_pages_array;
	        _scribble_array[@ SCRIBBLE.EVENT_CHAR_ARRAY] = _events_char_array; //Stores each event's triggering character
	        _scribble_array[@ SCRIBBLE.EVENT_NAME_ARRAY] = _events_name_array; //Stores each event's name
	        _scribble_array[@ SCRIBBLE.EVENT_DATA_ARRAY] = _events_data_array; //Stores each event's parameters
        
        #endregion
    
    
    
        #region Register the text element in a cache group

	        if (__SCRIBBLE_DEBUG) show_debug_message("Scribble: Caching \"" + _cache_string + "\"");

	        //Add this text element to the global cache lookup
	        global.__scribble_global_cache_map[? _cache_string] = _scribble_array;
	        ds_list_add(global.__scribble_global_cache_list, _scribble_array);

        #endregion



        #region Add the first page to the text element
        
	        var _meta_page_lines = 0;
	        var _word_start_char = 0;
        
	        var _page_array        = array_create(__SCRIBBLE_PAGE.__SIZE);
	        var _page_lines_array  = []; //Stores each line of text (per page)
	        var _page_vbuffs_array = []; //Stores all the vertex buffers needed to render the text and sprites (per page)
        
	        _page_array[@ __SCRIBBLE_PAGE.LINES               ] = 0;
	        _page_array[@ __SCRIBBLE_PAGE.START_CHAR          ] = 0;
	        _page_array[@ __SCRIBBLE_PAGE.LAST_CHAR           ] = 0;
	        _page_array[@ __SCRIBBLE_PAGE.LINES_ARRAY         ] = _page_lines_array;
	        _page_array[@ __SCRIBBLE_PAGE.VERTEX_BUFFERS_ARRAY] = _page_vbuffs_array;
        
	        _element_pages_array[@ array_length(_element_pages_array)] = _page_array;
	        ++_meta_element_pages;
        
        #endregion



        #region Add the first line to the page
        
	        var _line_has_space = false;
	        var _line_width     = 0;
	        var _line_height    = _line_min_height;
        
	        var _line_array = array_create(__SCRIBBLE_LINE.__SIZE);
	        _line_array[@ __SCRIBBLE_LINE.START_CHAR] = 0;
	        _line_array[@ __SCRIBBLE_LINE.LAST_CHAR ] = 0;
	        _line_array[@ __SCRIBBLE_LINE.Y         ] = 0;
	        _line_array[@ __SCRIBBLE_LINE.WIDTH     ] = _line_width;
	        _line_array[@ __SCRIBBLE_LINE.HEIGHT    ] = _line_height;
	        _line_array[@ __SCRIBBLE_LINE.HALIGN    ] = _def_halign;
	        _page_lines_array[@ array_length(_page_lines_array)] = _line_array;
        
        #endregion



        #region Set the initial parser state
        
	        var _text_x            = 0;
	        var _text_y            = _line_fixed_height? _half_fixed_height : 0; //Use a y-offset if we've got a fixed line height
	        var _line_y            = 0;
	        var _text_font         = _def_font;
	        var _text_colour       = _def_colour;
	        var _text_halign       = _def_halign;
	        var _text_effect_flags = 0;
	        var _text_scale        = 1;
	        var _text_slant        = false;
        
        #endregion



        #region Parse the string
        
	        var _command_tag_start      = -1;
	        var _command_tag_parameters =  0;
	        var _command_name           = "";
	        var _force_newline          =  false;
	        var _force_newpage          =  false;
	        var _char_width             =  0;
	        var _add_character          =  true;

	        //Write the string into a buffer for faster reading
	        var _string_buffer = global.__scribble_buffer;
	        buffer_seek(_string_buffer, buffer_seek_start, 0);
	        buffer_write(_string_buffer, buffer_string, _draw_string);
	        buffer_seek(_string_buffer, buffer_seek_start, 0);

	        //Iterate over the entire string...
	        repeat(string_byte_length(_draw_string) + 1)
	        {
	            var _character_code = buffer_read(_string_buffer, buffer_u8);
	            if (_character_code == 0) break;
	            _add_character = true;
            
	            if (_command_tag_start >= 0) //If we're in a command tag
	            {
	                if (_character_code == SCRIBBLE_COMMAND_TAG_CLOSE) //If we've hit a command tag close character (usually ])
	                {
	                    _add_character = false;
                    
	                    //Increment the parameter count and place a null byte for string reading
	                    ++_command_tag_parameters;
	                    buffer_poke(_string_buffer, buffer_tell(_string_buffer)-1, buffer_u8, 0);
            
	                    //Jump back to the start of the command tag and read out strings for the command parameters
	                    buffer_seek(_string_buffer, buffer_seek_start, _command_tag_start);
	                    repeat(_command_tag_parameters) ds_list_add(_parameters_list, buffer_read(_string_buffer, buffer_string));
            
	                    //Reset command tag state
	                    _command_tag_start = -1;
        
                    #region Command tag handling
            
	                    var _new_halign = undefined;
	                    _command_name = _parameters_list[| 0];
	                    switch(_command_name)
	                    {
                        #region Reset formatting
	                        case "":
	                            _text_font         = _def_font;
	                            _text_colour       = _def_colour;
	                            _text_effect_flags = 0;
	                            _text_scale        = 1;
	                            _text_slant        = false;
                            
	                            _font_data         = global.__scribble_font_data[? _text_font];
	                            _font_glyphs_map   = _font_data[__SCRIBBLE_FONT.GLYPHS_MAP  ];
	                            _font_glyphs_array = _font_data[__SCRIBBLE_FONT.GLYPHS_ARRAY];
	                            _font_glyphs_min   = _font_data[__SCRIBBLE_FONT.GLYPH_MIN   ];
	                            _font_glyphs_max   = _font_data[__SCRIBBLE_FONT.GLYPH_MAX   ];
                            
	                            var _glyph_array = (_font_glyphs_array == undefined)? _font_glyphs_map[? 32] : _font_glyphs_array[32 - _font_glyphs_min];
	                            _font_space_width = _glyph_array[SCRIBBLE_GLYPH.WIDTH ];
	                            _font_line_height = _glyph_array[SCRIBBLE_GLYPH.HEIGHT];
                            
	                            continue; //Skip the rest of the parser step
	                        break;
                
	                        case "/font":
	                        case "/f":
	                            _text_font = _def_font;
                            
	                            _font_data         = global.__scribble_font_data[? _text_font];
	                            _font_glyphs_map   = _font_data[__SCRIBBLE_FONT.GLYPHS_MAP  ];
	                            _font_glyphs_array = _font_data[__SCRIBBLE_FONT.GLYPHS_ARRAY];
	                            _font_glyphs_min   = _font_data[__SCRIBBLE_FONT.GLYPH_MIN   ];
	                            _font_glyphs_max   = _font_data[__SCRIBBLE_FONT.GLYPH_MAX   ];
                            
	                            var _glyph_array = (_font_glyphs_array == undefined)? _font_glyphs_map[? 32] : _font_glyphs_array[32 - _font_glyphs_min];
	                            _font_space_width = _glyph_array[SCRIBBLE_GLYPH.WIDTH ];
	                            _font_line_height = _glyph_array[SCRIBBLE_GLYPH.HEIGHT];
                    
	                            continue; //Skip the rest of the parser step
	                        break;
                        
	                        case "/colour":
	                        case "/color":
	                        case "/c":
	                            _text_colour = _def_colour;
                    
	                            continue; //Skip the rest of the parser step
	                        break;
                
	                        case "/scale":
	                        case "/s":
	                            _text_scale = 1;
                    
	                            continue; //Skip the rest of the parser step
	                        break;
                
	                        case "/slant":
	                            _text_slant = false;
                    
	                            continue; //Skip the rest of the parser step
	                        break;
                        #endregion
                        
                        #region Page break
                        
	                        case "/page":
	                            _force_newline = true;
	                            _char_width = 0;
	                            _force_newpage = true;
	                        break;
                        
                        #endregion
                        
                        #region Scale
	                        case "scale":
	                            if (_command_tag_parameters <= 1)
	                            {
	                                show_error("Scribble:\nNot enough parameters for scale tag!", false);
	                            }
	                            else
	                            {
	                                var _text_scale = real(_parameters_list[| 1]);
	                            }
                    
	                            continue; //Skip the rest of the parser step
	                        break;
                        #endregion
                
                        #region Slant (italics emulation)
	                        case "slant":
	                            _text_slant = true;
                    
	                            continue; //Skip the rest of the parser step
	                        break;
                        #endregion
                
                        #region Font Alignment
                        
	                        case "fa_left":
	                            _new_halign = fa_left;
	                        break;
                        
	                        case "fa_center":
	                        case "fa_centre":
	                            _new_halign = fa_center;
	                        break;
                        
	                        case "fa_right":
	                            _new_halign = fa_right;
	                        break;
                        
	                        case "js_left":
	                        case "js_center":
	                        case "js_centre":
	                        case "js_right":
	                            show_error("Scribble:\n[js_*] tags have been deprecated. Please use [pin_*]\n ", false);
	                        break;
                        
	                        case "pin_left":
	                            _new_halign = __SCRIBBLE_PIN_LEFT;
	                        break;
                        
	                        case "pin_center":
	                        case "pin_centre":
	                            _new_halign = __SCRIBBLE_PIN_CENTRE;
	                        break;
                        
	                        case "pin_right":
	                            _new_halign = __SCRIBBLE_PIN_RIGHT;
	                        break;
                        
                        #endregion
                        
	                        default:
	                            if (ds_map_exists(global.__scribble_autotype_events, _command_name))
	                            {
                                #region Events
                                
	                                var _data = array_create(_command_tag_parameters-1);
	                                var _j = 1;
	                                repeat(_command_tag_parameters-1)
	                                {
	                                    _data[@ _j-1] = _parameters_list[| _j];
	                                    ++_j;
	                                }
                                
	                                var _count = array_length(_events_char_array);
	                                _events_char_array[@ _count] = _meta_element_characters;
	                                _events_name_array[@ _count] = _command_name;
	                                _events_data_array[@ _count] = _data;
                                
	                                continue; //Skip the rest of the parser step
                                
                                #endregion
	                            }
	                            else
	                            {
	                                if (ds_map_exists(global.__scribble_effects, _command_name))
	                                {
                                    #region Set effect
                                    
	                                    _text_effect_flags = _text_effect_flags | (1 << global.__scribble_effects[? _command_name]);
                                    
	                                    continue; //Skip the rest of the parser step
                                    
                                    #endregion
	                                }
	                                else
	                                {
	                                    //Check if this is a effect name, but with a forward slash at the front
	                                    if (ds_map_exists(global.__scribble_effects_slash, _command_name))
	                                    {
                                        #region Unset effect
                                        
	                                        _text_effect_flags = ~((~_text_effect_flags) | (1 << global.__scribble_effects_slash[? _command_name]));
                                        
	                                        continue; //Skip the rest of the parser step
                                        
                                        #endregion
	                                    }
	                                    else
	                                    {
	                                        if (ds_map_exists(global.__scribble_font_data, _command_name))
	                                        {
                                            #region Change font
                                            
	                                            _text_font = _command_name;
                                            
	                                            _font_data         = global.__scribble_font_data[? _command_name];
	                                            _font_glyphs_map   = _font_data[__SCRIBBLE_FONT.GLYPHS_MAP  ];
	                                            _font_glyphs_array = _font_data[__SCRIBBLE_FONT.GLYPHS_ARRAY];
	                                            _font_glyphs_min   = _font_data[__SCRIBBLE_FONT.GLYPH_MIN   ];
	                                            _font_glyphs_max   = _font_data[__SCRIBBLE_FONT.GLYPH_MAX   ];
                                            
	                                            var _glyph_array = (_font_glyphs_array == undefined)? _font_glyphs_map[? 32] : _font_glyphs_array[32 - _font_glyphs_min];
	                                            _font_space_width = _glyph_array[SCRIBBLE_GLYPH.WIDTH ];
	                                            _font_line_height = _glyph_array[SCRIBBLE_GLYPH.HEIGHT];
                                            
	                                            continue; //Skip the rest of the parser step
                                            
                                            #endregion
	                                        }
	                                        else
	                                        {
	                                            if (asset_get_type(_command_name) == asset_sprite)
	                                            {
                                                #region Write sprites
                                                
	                                                _line_width = max(_line_width, _text_x);
                                        
	        	                                    var _sprite_index  = asset_get_index(_command_name);
	        	                                    if (global.__scribble_sprite_whitelist && !ds_map_exists(global.__scribble_sprite_whitelist_map, _sprite_index))
	        	                                    {
	        	                                        show_error("Scribble:\nSprite \"" + string(_command_name) + "\" not whitelisted\n ", true);
	        	                                    }
	        	                                    else
	                                                {
	                                                    var _sprite_width  = _text_scale*sprite_get_width(_sprite_index);
	                                                    var _sprite_height = _text_scale*sprite_get_height(_sprite_index);
	                                                    var _sprite_number = sprite_get_number(_sprite_index);
                                            
	                                                    if (SCRIBBLE_ADD_SPRITE_ORIGINS)
	                                                    {
	                                                        var _sprite_x = _text_x - _text_scale*sprite_get_xoffset(_sprite_index) + (_sprite_width div 2);
	                                                        var _sprite_y = _text_y - _text_scale*sprite_get_yoffset(_sprite_index);
	                                                    }
	                                                    else
	                                                    {
	                                                        var _sprite_x = _text_x;
	                                                        var _sprite_y = _text_y - (_sprite_height div 2);
	                                                    }
                                            
	                                                    var _packed_indexes = _meta_element_characters*__SCRIBBLE_MAX_LINES + _meta_page_lines;
	                                                    _char_width  = _sprite_width;
	                                                    if (!_line_fixed_height) _line_height = max(_line_height, _sprite_height); //Change our line height if it's not fixed
                                            
	                                                    if (_sprite_number >= 256)
	                                                    {
	                                                        show_debug_message("Scribble: In-line sprites cannot have more than 256 frames (" + string(_command_name) + ")");
	                                                        _sprite_number = 256;
	                                                    }
                                            
                                                    #region Figure out what images to add to the buffer
                                                
	                                                    var _image_index = 0;
	                                                    var _image_speed = 0;
	                                                    switch(_command_tag_parameters)
	                                                    {
	                                                        case 1:
	                                                            _image_index = 0;
	                                                            _image_speed = SCRIBBLE_DEFAULT_SPRITE_SPEED;
	                                                        break;
                                                    
	                                                        case 2:
	                                                            _image_index = real(_parameters_list[| 1]);
	                                                            _image_speed = 0;
	                                                        break;
                                                    
	                                                        default:
	                                                            _image_index = real(_parameters_list[| 1]);
	                                                            _image_speed = real(_parameters_list[| 2]);
	                                                        break;
	                                                    }
                                                
	                                                    var _colour = SCRIBBLE_COLORIZE_SPRITES? _text_colour : c_white;
	                                                    if (_image_speed <= 0)
	                                                    {
	                                                        _image_speed = 0;
	                                                        _sprite_number = 1;
	                                                        _colour = $FF000000 | _colour;
	                                                    }
	                                                    else
	                                                    {
	                                                        //Set the "is sprite" effect flag only if we're animating the sprite
	                                                        _text_effect_flags = _text_effect_flags | 1;
                                                    
	                                                        //Encode image, sprite length, and image speed into the colour channels
	                                                        _colour = make_colour_rgb(0, _sprite_number-1, _image_speed*255);
                                                    
	                                                        //Encode the starting image into the alpha channel
	                                                        _colour = (_image_index << 24) | _colour;
                                                    
	                                                        //Make sure we store all frames from the sprite
	                                                        _image_index = 0;
	                                                    }
                                                
                                                    #endregion
                                            
                                                    #region Pre-create vertex buffer arrays for images for this sprite and update WORD_START_TELL at the same time
                                                
	                                                    var _image = _image_index;
	                                                    repeat(_sprite_number)
	                                                    {
	                                                        var _sprite_texture = sprite_get_texture(_sprite_index, _image);
                                                    
	                                                        var _vbuff_data = _texture_to_buffer_map[? _sprite_texture];
	                                                        if (_vbuff_data == undefined)
	                                                        {
	                                                            var _vbuff_line_start_list = ds_list_create();
	                                                            var _buffer = buffer_create(__SCRIBBLE_GLYPH_BYTE_SIZE, buffer_grow, 1);
                                                        
	                                                            _vbuff_data = array_create(__SCRIBBLE_VERTEX_BUFFER.__SIZE);
	                                                            _vbuff_data[@ __SCRIBBLE_VERTEX_BUFFER.BUFFER         ] = _buffer;
	                                                            _vbuff_data[@ __SCRIBBLE_VERTEX_BUFFER.VERTEX_BUFFER  ] = undefined;
	                                                            _vbuff_data[@ __SCRIBBLE_VERTEX_BUFFER.TEXTURE        ] = _sprite_texture;
	                                                            _vbuff_data[@ __SCRIBBLE_VERTEX_BUFFER.CHAR_START_TELL] = 0;
	                                                            _vbuff_data[@ __SCRIBBLE_VERTEX_BUFFER.WORD_START_TELL] = 0;
	                                                            _vbuff_data[@ __SCRIBBLE_VERTEX_BUFFER.WORD_X_OFFSET  ] = 0;
	                                                            _vbuff_data[@ __SCRIBBLE_VERTEX_BUFFER.LINE_START_LIST] = _vbuff_line_start_list;
	                                                            _vbuff_data[@ __SCRIBBLE_VERTEX_BUFFER.TEXEL_WIDTH    ] = texture_get_texel_width( _sprite_texture);
	                                                            _vbuff_data[@ __SCRIBBLE_VERTEX_BUFFER.TEXEL_HEIGHT   ] = texture_get_texel_height(_sprite_texture);
	                                                            _page_vbuffs_array[@ array_length(_page_vbuffs_array)] = _vbuff_data;
                                                        
	                                                            _texture_to_buffer_map[? _sprite_texture] = _vbuff_data;
	                                                        }
	                                                        else
	                                                        {
	                                                            var _buffer = _vbuff_data[__SCRIBBLE_VERTEX_BUFFER.BUFFER];
	                                                            _vbuff_data[@ __SCRIBBLE_VERTEX_BUFFER.CHAR_START_TELL] = buffer_tell(_buffer);
	                                                            _vbuff_data[@ __SCRIBBLE_VERTEX_BUFFER.WORD_START_TELL] = buffer_tell(_buffer);
	                                                            _vbuff_data[@ __SCRIBBLE_VERTEX_BUFFER.WORD_X_OFFSET  ] = 0;
	                                                            _vbuff_line_start_list = _vbuff_data[__SCRIBBLE_VERTEX_BUFFER.LINE_START_LIST];
	                                                        }
                                                
	                                                        //Fill link break list
	                                                        var _tell = buffer_tell(_buffer);
	                                                        repeat(array_length(_page_lines_array) - ds_list_size(_vbuff_line_start_list)) ds_list_add(_vbuff_line_start_list, _tell);
                                                    
	                                                        ++_image;
	                                                    }
                                                
                                                    #endregion
                                            
                                                    #region Add sprite to buffers
                                                
	                                                    var _image = _image_index;
	                                                    repeat(_sprite_number)
	                                                    {
	                                                        //Swap texture and buffer if needed
	                                                        var _sprite_texture = sprite_get_texture(_sprite_index, _image);
	                                                        if (_sprite_texture != _glyph_texture)
	                                                        {
	                                                            _glyph_texture = _sprite_texture;
	                                                            var _vbuff_data = _texture_to_buffer_map[? _sprite_texture];
	                                                            var _glyph_buffer = _vbuff_data[__SCRIBBLE_VERTEX_BUFFER.BUFFER];
	                                                        }
                                                    
	                                                        //Find the UVs and position of the sprite quad
	                                                        var _uvs = sprite_get_uvs(_sprite_index, _image);
	                                                        var _quad_l = _sprite_x + _uvs[4]*_text_scale;
	                                                        var _quad_t = _sprite_y + _uvs[5]*_text_scale;
	                                                        var _quad_r = _quad_l   + _uvs[6]*_sprite_width;
	                                                        var _quad_b = _quad_t   + _uvs[7]*_sprite_height;
                                                    
	                                                        var _slant_offset = SCRIBBLE_SLANT_AMOUNT*_text_scale*_text_slant*(_quad_b - _quad_t);
                                                    
	                                                        var _quad_cx = 0.5*(_quad_l + _quad_r);
	                                                        var _quad_cy = 0.5*(_quad_t + _quad_b);
	                                                        _quad_l -= _quad_cx;
	                                                        _quad_t -= _quad_cy;
	                                                        _quad_r -= _quad_cx;
	                                                        _quad_b -= _quad_cy;
                                                    
	                                                        //                                      Centre X                                           Centre Y                                         Character/Line Index                                                     Delta X                                                 Delta Y                                                 Flags                                                      Colour                                                 U                                                V
	                                                        buffer_write(_glyph_buffer, buffer_f32, _quad_cx); buffer_write(_glyph_buffer, buffer_f32, _quad_cy); buffer_write(_glyph_buffer, buffer_f32, _packed_indexes);    buffer_write(_glyph_buffer, buffer_f32, _quad_l + _slant_offset); buffer_write(_glyph_buffer, buffer_f32, _quad_t); buffer_write(_glyph_buffer, buffer_f32, _text_effect_flags);    buffer_write(_glyph_buffer, buffer_u32, _colour);    buffer_write(_glyph_buffer, buffer_f32, _uvs[0]); buffer_write(_glyph_buffer, buffer_f32, _uvs[1]);
	                                                        buffer_write(_glyph_buffer, buffer_f32, _quad_cx); buffer_write(_glyph_buffer, buffer_f32, _quad_cy); buffer_write(_glyph_buffer, buffer_f32, _packed_indexes);    buffer_write(_glyph_buffer, buffer_f32, _quad_r                ); buffer_write(_glyph_buffer, buffer_f32, _quad_b); buffer_write(_glyph_buffer, buffer_f32, _text_effect_flags);    buffer_write(_glyph_buffer, buffer_u32, _colour);    buffer_write(_glyph_buffer, buffer_f32, _uvs[2]); buffer_write(_glyph_buffer, buffer_f32, _uvs[3]);
	                                                        buffer_write(_glyph_buffer, buffer_f32, _quad_cx); buffer_write(_glyph_buffer, buffer_f32, _quad_cy); buffer_write(_glyph_buffer, buffer_f32, _packed_indexes);    buffer_write(_glyph_buffer, buffer_f32, _quad_l                ); buffer_write(_glyph_buffer, buffer_f32, _quad_b); buffer_write(_glyph_buffer, buffer_f32, _text_effect_flags);    buffer_write(_glyph_buffer, buffer_u32, _colour);    buffer_write(_glyph_buffer, buffer_f32, _uvs[0]); buffer_write(_glyph_buffer, buffer_f32, _uvs[3]);
	                                                        buffer_write(_glyph_buffer, buffer_f32, _quad_cx); buffer_write(_glyph_buffer, buffer_f32, _quad_cy); buffer_write(_glyph_buffer, buffer_f32, _packed_indexes);    buffer_write(_glyph_buffer, buffer_f32, _quad_r                ); buffer_write(_glyph_buffer, buffer_f32, _quad_b); buffer_write(_glyph_buffer, buffer_f32, _text_effect_flags);    buffer_write(_glyph_buffer, buffer_u32, _colour);    buffer_write(_glyph_buffer, buffer_f32, _uvs[2]); buffer_write(_glyph_buffer, buffer_f32, _uvs[3]);
	                                                        buffer_write(_glyph_buffer, buffer_f32, _quad_cx); buffer_write(_glyph_buffer, buffer_f32, _quad_cy); buffer_write(_glyph_buffer, buffer_f32, _packed_indexes);    buffer_write(_glyph_buffer, buffer_f32, _quad_l + _slant_offset); buffer_write(_glyph_buffer, buffer_f32, _quad_t); buffer_write(_glyph_buffer, buffer_f32, _text_effect_flags);    buffer_write(_glyph_buffer, buffer_u32, _colour);    buffer_write(_glyph_buffer, buffer_f32, _uvs[0]); buffer_write(_glyph_buffer, buffer_f32, _uvs[1]);
	                                                        buffer_write(_glyph_buffer, buffer_f32, _quad_cx); buffer_write(_glyph_buffer, buffer_f32, _quad_cy); buffer_write(_glyph_buffer, buffer_f32, _packed_indexes);    buffer_write(_glyph_buffer, buffer_f32, _quad_r + _slant_offset); buffer_write(_glyph_buffer, buffer_f32, _quad_t); buffer_write(_glyph_buffer, buffer_f32, _text_effect_flags);    buffer_write(_glyph_buffer, buffer_u32, _colour);    buffer_write(_glyph_buffer, buffer_f32, _uvs[2]); buffer_write(_glyph_buffer, buffer_f32, _uvs[1]);
                                                    
	                                                        ++_image;
	                                                        if (_image_speed > 0) { ++_colour; }
	                                                    }
                                                
                                                    #endregion
                                            
	                                                    //Record the first character in this word
	                                                    _word_start_char = _meta_element_characters;
                                            
	                                                    _text_effect_flags = ~((~_text_effect_flags) | 1); //Reset animated sprite effect flag specifically
                                            
	                                                    if (SCRIBBLE_CREATE_CHARACTER_ARRAY) _character_array[@ _meta_element_characters] = _command_name;
	                                                    ++_meta_element_characters;
	                                                }
                                        
                                                #endregion
	                                            }
	                                            else
	                                            {
	                                                if (ds_map_exists(global.__scribble_colours, _command_name))
	                                                {
                                                    #region Set a pre-defined colour
                                                    
	                                                    _text_colour = global.__scribble_colours[? _command_name];
                                                    
	                                                    continue; //Skip the rest of the parser step
                                                    
                                                    #endregion
	                                                }
	                                                else
	                                                {
	                                                    var _first_char = string_copy(_command_name, 1, 1);
	                                                    if ((string_length(_command_name) <= 7) && ((_first_char == "$") || (_first_char == "#")))
	                                                    {
                                                        #region Hex colour decoding
                                                        
	                                                        var _ord = ord(string_char_at(_command_name, 3));
	                                                        var _lsf = ((_ord >= global.__scribble_hex_min) && (_ord <= global.__scribble_hex_max))? global.__scribble_hex_array[_ord - global.__scribble_hex_min] : 0;
	                                                        var _ord = ord(string_char_at(_command_name, 2));
	                                                        var _hsf = ((_ord >= global.__scribble_hex_min) && (_ord <= global.__scribble_hex_max))? global.__scribble_hex_array[_ord - global.__scribble_hex_min] : 0;
                                                        
	                                                        var _red = _lsf + (_hsf << 4);
                                                        
	                                                        var _ord = ord(string_char_at(_command_name, 5));
	                                                        var _lsf = ((_ord >= global.__scribble_hex_min) && (_ord <= global.__scribble_hex_max))? global.__scribble_hex_array[_ord - global.__scribble_hex_min] : 0;
	                                                        var _ord = ord(string_char_at(_command_name, 4));
	                                                        var _hsf = ((_ord >= global.__scribble_hex_min) && (_ord <= global.__scribble_hex_max))? global.__scribble_hex_array[_ord - global.__scribble_hex_min] : 0;
                                                        
	                                                        var _green = _lsf + (_hsf << 4);
                                                        
	                                                        var _ord = ord(string_char_at(_command_name, 7));
	                                                        var _lsf = ((_ord >= global.__scribble_hex_min) && (_ord <= global.__scribble_hex_max))? global.__scribble_hex_array[_ord - global.__scribble_hex_min] : 0;
	                                                        var _ord = ord(string_char_at(_command_name, 6));
	                                                        var _hsf = ((_ord >= global.__scribble_hex_min) && (_ord <= global.__scribble_hex_max))? global.__scribble_hex_array[_ord - global.__scribble_hex_min] : 0;
                                                        
	                                                        var _blue = _lsf + (_hsf << 4);
                                                        
	                                                        if (SCRIBBLE_BGR_COLOR_HEX_CODES)
	                                                        {
	                                                            _text_colour = make_colour_rgb(_blue, _green, _red);
	                                                        }
	                                                        else
	                                                        {
	                                                            _text_colour = make_colour_rgb(_red, _green, _blue);
	                                                        }
                                                        
	                                                        continue; //Skip the rest of the parser step
                                                        
                                                        #endregion
	                                                    }
	                                                    else
	                                                    {
	                                                        var _second_char = string_copy(_command_name, 2, 1);
	                                                        if (((_first_char  == "d") || (_first_char  == "D"))
	                                                        &&  ((_second_char == "$") || (_second_char == "#")))
	                                                        {
                                                            #region Decimal colour decoding
                                                            
	                                                            //Check if this number is a real
	                                                            var _is_real = true;
	                                                            var _c = 3;
	                                                            repeat(string_length(_command_name) - 2)
	                                                            {
	                                                                var _ord = ord(string_char_at(_command_name, _c));
	                                                                if ((_ord < 48) || (_ord > 57))
	                                                                {
	                                                                    _is_real = false;
	                                                                    break;
	                                                                }
                                                                
	                                                                ++_c;
	                                                            }
                                                            
	                                                            if (_is_real)
	                                                            {
	                                                                _text_colour = real(string_delete(_command_name, 1, 2));
	                                                            }
	                                                            else
	                                                            {
	                                                                show_debug_message("Scribble: WARNING! Could not decode [" + _command_name + "], ensure it is a positive integer" );
	                                                            }
                                                            
	                                                            continue; //Skip the rest of the parser step
                                                            
                                                            #endregion
	                                                        }
	                                                        else
	                                                        {
	                                                            var _command_string = string(_command_name);
	                                                            var _j = 1;
	                                                            repeat(_command_tag_parameters-1) _command_string += "," + string(_parameters_list[| _j++]);
	                                                            show_debug_message("Scribble: WARNING! Unrecognised command tag [" + _command_string + "]" );
                                                        
	                                                            continue; //Skip the rest of the parser step
	                                                        }
	                                                    }
	                                                }
	                                            }
	                                        }
	                                    }
	                                }
	                            }
	                        break;
	                    }
            
	                    if ((_new_halign != undefined) && (_new_halign != _text_halign))
	                    {
	                        _text_halign = _new_halign;
                
	                        if (_text_x > 0)
	                        {
	                            _force_newline = true;
	                            _char_width    = 0;
	                            _line_width    = max(_line_width, _text_x);
	                            if (!_line_fixed_height) _line_height = max(_line_height, _font_line_height*_text_scale); //Change our line height if it's not fixed
	                        }
	                        else
	                        {
	                            _line_array[@ __SCRIBBLE_LINE.HALIGN] = _new_halign;
	                            continue; //Skip the rest of the parser step
	                        }
	                    }
        
                    #endregion
	                }
	                else if (_character_code == SCRIBBLE_COMMAND_TAG_ARGUMENT) //If we've hit a command tag argument delimiter character (usually ,)
	                {
	                    //Increment the parameter count and place a null byte for string reading later
	                    ++_command_tag_parameters;
	                    buffer_poke(_string_buffer, buffer_tell(_string_buffer)-1, buffer_u8, 0);
	                    continue;
	                }
	                else if ((_character_code == SCRIBBLE_COMMAND_TAG_OPEN) && (buffer_tell(_string_buffer) - _command_tag_start == 1))
	                {
	                    _command_tag_start = -1;
	                }
	                else
	                {
	                    //If we're in a command tag and we've not read a close character or an argument delimiter, skip everything else
	                    continue;
	                }
	            }
	            else if (_character_code == SCRIBBLE_COMMAND_TAG_OPEN) //If we've hit a command tag argument delimiter character (usually [)
	            {
	                //Record the start of the command tag in the string buffer
	                _command_tag_start = buffer_tell(_string_buffer);
	                _command_tag_parameters = 0;
	                ds_list_clear(_parameters_list);
	                continue;
	            }
	            else if ((_character_code == 10) //If we've hit a newline (\n)
	                    || (SCRIBBLE_HASH_NEWLINE && (_character_code == 35)) //If we've hit a hash, and hash newlines are on
	                    || ((_character_code == 13) && (buffer_peek(_string_buffer, buffer_tell(_string_buffer)+1, buffer_u8) != 10)))
	            {
	                _force_newline = true;
	                _char_width    = 0;
	                _line_width    = max(_line_width, _text_x);
	                if (!_line_fixed_height) _line_height = max(_line_height, _font_line_height*_text_scale); //Change our line height if it's not fixed
                
	                if (global.__scribble_character_delay)
	                {
	                    var _delay = global.__scribble_character_delay_map[? _character_code];
	                    if ((_delay != undefined) && (_delay > 0))
	                    {
	                        var _count = array_length(_events_char_array);
	                        _events_char_array[@ _count] = _meta_element_characters;
	                        _events_name_array[@ _count] = "delay";
	                        _events_data_array[@ _count] = [_delay];
	                    }
	                }
                
	                _add_character = false;
	            }
	            else if (_character_code == 32) //If we've hit a space
	            {
	                //Grab this characer's width/height
	                _char_width     = _font_space_width*_text_scale;
	                _line_has_space = true;
	                _line_width     = max(_line_width, _text_x);
	                if (!_line_fixed_height) _line_height = max(_line_height, _font_line_height*_text_scale); //Change our line height if it's not fixed
                
	                //Iterate over all the vertex buffers we've been using and reset the word start position
	                var _v = 0;
	                repeat(array_length(_page_vbuffs_array))
	                {
	                    var _data = _page_vbuffs_array[_v];
	                    _data[@ __SCRIBBLE_VERTEX_BUFFER.WORD_START_TELL] = buffer_tell(_data[__SCRIBBLE_VERTEX_BUFFER.BUFFER]);
	                    _data[@ __SCRIBBLE_VERTEX_BUFFER.WORD_X_OFFSET  ] = undefined;
	                    ++_v;
	                }
                
	                //Record the first character in this word
	                _word_start_char = _meta_element_characters;
        
	                if (SCRIBBLE_CREATE_CHARACTER_ARRAY) _character_array[@ _meta_element_characters] = _character_code;
	                ++_meta_element_characters;
                
	                if (global.__scribble_character_delay)
	                {
	                    var _delay = global.__scribble_character_delay_map[? _character_code];
	                    if ((_delay != undefined) && (_delay > 0))
	                    {
	                        var _count = array_length(_events_char_array);
	                        _events_char_array[@ _count] = _meta_element_characters;
	                        _events_name_array[@ _count] = "delay";
	                        _events_data_array[@ _count] = [_delay];
	                    }
	                }
                
	                _add_character = false;
	            }
	            else if (_character_code < 32) //If this character code is below a space then ignore it
	            {
	                continue;
	            }
    
	            if (_add_character) //If this character is literally any other character at all
	            {
                #region Decode UTF8
        
	                if ((_character_code & $E0) == $C0) //two-byte
	                {
	                    _character_code  = (                       _character_code & $1F) <<  6;
	                    _character_code += (buffer_read(_string_buffer, buffer_u8) & $3F);
	                }
	                else if ((_character_code & $F0) == $E0) //three-byte
	                {
	                    _character_code  = (                       _character_code & $0F) << 12;
	                    _character_code += (buffer_read(_string_buffer, buffer_u8) & $3F) <<  6;
	                    _character_code +=  buffer_read(_string_buffer, buffer_u8) & $3F;
	                }
	                else if ((_character_code & $F8) == $F0) //four-byte
	                {
	                    _character_code  = (                       _character_code & $07) << 18;
	                    _character_code += (buffer_read(_string_buffer, buffer_u8) & $3F) << 12;
	                    _character_code += (buffer_read(_string_buffer, buffer_u8) & $3F) <<  6;
	                    _character_code +=  buffer_read(_string_buffer, buffer_u8) & $3F;
	                }
        
                #endregion
        
                #region Find glyph data
        
	        	    if (_font_glyphs_array == undefined)
	        	    {
	        	        var _glyph_array = _font_glyphs_map[? _character_code];
	        		    if (_glyph_array == undefined) _glyph_array = _font_glyphs_map[? ord(SCRIBBLE_MISSING_CHARACTER)];
	        	    }
	        	    else
	        	    {
	        		    if ((_character_code < _font_glyphs_min) || (_character_code > _font_glyphs_max))
	        	        {
	        	            _character_code = ord(SCRIBBLE_MISSING_CHARACTER);
	        	            if ((_character_code < _font_glyphs_min) || (_character_code > _font_glyphs_max))
	        	            {
	        	                _glyph_array = undefined;
	        	            }
	        	            else
	        	            {
	        		            var _glyph_array = _font_glyphs_array[_character_code - _font_glyphs_min];
	        	            }
	        	        }
	        	        else
	        	        {
	        		        var _glyph_array = _font_glyphs_array[_character_code - _font_glyphs_min];
	        	        }
	        	    }
        
                #endregion
        
	                if (_glyph_array == undefined)
	                {
	                   if (SCRIBBLE_VERBOSE) show_debug_message("Scribble: scribble_cache() couldn't find glyph data for character code " + string(_character_code) + " (" + chr(_character_code) + ") in font \"" + string(_text_font) + "\"");
	                }
	                else
	                {
                    #region Swap texture and buffer if needed
        
	            	    if (_glyph_array[SCRIBBLE_GLYPH.TEXTURE] != _glyph_texture)
	            	    {
	            	        _glyph_texture = _glyph_array[SCRIBBLE_GLYPH.TEXTURE];
                
	                        var _vbuff_data = _texture_to_buffer_map[? _glyph_texture];
	                        if (_vbuff_data == undefined)
	                        {
	                            var _vbuff_line_start_list = ds_list_create();
	                            var _glyph_buffer = buffer_create(__SCRIBBLE_EXPECTED_GLYPHS*__SCRIBBLE_GLYPH_BYTE_SIZE, buffer_grow, 1);
                        
	                            _vbuff_data = array_create(__SCRIBBLE_VERTEX_BUFFER.__SIZE);
	                            _vbuff_data[@ __SCRIBBLE_VERTEX_BUFFER.BUFFER         ] = _glyph_buffer;
	                            _vbuff_data[@ __SCRIBBLE_VERTEX_BUFFER.VERTEX_BUFFER  ] = undefined;
	                            _vbuff_data[@ __SCRIBBLE_VERTEX_BUFFER.TEXTURE        ] = _glyph_texture;
	                            _vbuff_data[@ __SCRIBBLE_VERTEX_BUFFER.CHAR_START_TELL] = 0;
	                            _vbuff_data[@ __SCRIBBLE_VERTEX_BUFFER.WORD_START_TELL] = 0;
	                            _vbuff_data[@ __SCRIBBLE_VERTEX_BUFFER.WORD_X_OFFSET  ] = undefined;
	                            _vbuff_data[@ __SCRIBBLE_VERTEX_BUFFER.LINE_START_LIST] = _vbuff_line_start_list;
	                            _vbuff_data[@ __SCRIBBLE_VERTEX_BUFFER.TEXEL_WIDTH    ] = texture_get_texel_width( _glyph_texture);
	                            _vbuff_data[@ __SCRIBBLE_VERTEX_BUFFER.TEXEL_HEIGHT   ] = texture_get_texel_height(_glyph_texture);
	                            _page_vbuffs_array[@ array_length(_page_vbuffs_array)] = _vbuff_data;
                        
	                            _texture_to_buffer_map[? _glyph_texture] = _vbuff_data;
	                        }
	                        else
	                        {
	                            var _glyph_buffer = _vbuff_data[__SCRIBBLE_VERTEX_BUFFER.BUFFER];
	                            _vbuff_line_start_list = _vbuff_data[__SCRIBBLE_VERTEX_BUFFER.LINE_START_LIST];
	                        }
            
	                        //Fill link break list
	                        var _tell = buffer_tell(_glyph_buffer);
	                        repeat(array_length(_page_lines_array) - ds_list_size(_vbuff_line_start_list)) ds_list_add(_vbuff_line_start_list, _tell);
	                    }
            
	                    //Update CHAR_START_TELL, and WORD_START_TELL if needed
	                    _vbuff_data[@ __SCRIBBLE_VERTEX_BUFFER.CHAR_START_TELL] = buffer_tell(_glyph_buffer);
	                    if (global.scribble_state_character_wrap)
	                    {
	                        _vbuff_data[@ __SCRIBBLE_VERTEX_BUFFER.WORD_START_TELL] = buffer_tell(_glyph_buffer);
	                        _vbuff_data[@ __SCRIBBLE_VERTEX_BUFFER.WORD_X_OFFSET  ] = undefined;
	                        _line_width = max(_line_width, _text_x);
                
	                        //Record the first character in this word
	                        _word_start_char = _meta_element_characters;
	                    }
            
                    #endregion
            
                    #region Add glyph to buffer
            
	                    var _quad_l = _glyph_array[SCRIBBLE_GLYPH.X_OFFSET]*_text_scale;
	                    if (_vbuff_data[__SCRIBBLE_VERTEX_BUFFER.WORD_X_OFFSET] == undefined) _vbuff_data[@ __SCRIBBLE_VERTEX_BUFFER.WORD_X_OFFSET] = _quad_l;
            
	                        _quad_l += _text_x;
	                    var _quad_t  = _text_y + _glyph_array[SCRIBBLE_GLYPH.Y_OFFSET]*_text_scale - ((_font_line_height*_text_scale) div 2); //TODO - Cache scaled font line height
	                    var _quad_r  = _quad_l + _glyph_array[SCRIBBLE_GLYPH.WIDTH   ]*_text_scale;
	                    var _quad_b  = _quad_t + _glyph_array[SCRIBBLE_GLYPH.HEIGHT  ]*_text_scale;
            
	                    var _quad_cx = 0.5*(_quad_l + _quad_r);
	                    var _quad_cy = 0.5*(_quad_t + _quad_b);
	                    _quad_l -= _quad_cx;
	                    _quad_t -= _quad_cy;
	                    _quad_r -= _quad_cx;
	                    _quad_b -= _quad_cy;
            
	                    var _packed_indexes = _meta_element_characters*__SCRIBBLE_MAX_LINES + _meta_page_lines;
	                    var _colour = $FF000000 | _text_colour;
	                    var _slant_offset = SCRIBBLE_SLANT_AMOUNT*_text_scale*_text_slant*(_quad_b - _quad_t);
            
	                    var _quad_u0 = _glyph_array[SCRIBBLE_GLYPH.U0];
	                    var _quad_v0 = _glyph_array[SCRIBBLE_GLYPH.V0];
	                    var _quad_u1 = _glyph_array[SCRIBBLE_GLYPH.U1];
	                    var _quad_v1 = _glyph_array[SCRIBBLE_GLYPH.V1];
            
	                    //                                      Centre X                                           Centre Y                                         Character/Line Index                                                     Delta X                                                 Delta Y                                                 Flags                                                      Colour                                                  U                                                  V
	                    buffer_write(_glyph_buffer, buffer_f32, _quad_cx); buffer_write(_glyph_buffer, buffer_f32, _quad_cy); buffer_write(_glyph_buffer, buffer_f32, _packed_indexes);    buffer_write(_glyph_buffer, buffer_f32, _quad_l + _slant_offset); buffer_write(_glyph_buffer, buffer_f32, _quad_t); buffer_write(_glyph_buffer, buffer_f32, _text_effect_flags);    buffer_write(_glyph_buffer, buffer_u32, _colour);    buffer_write(_glyph_buffer, buffer_f32, _quad_u0); buffer_write(_glyph_buffer, buffer_f32, _quad_v0);
	                    buffer_write(_glyph_buffer, buffer_f32, _quad_cx); buffer_write(_glyph_buffer, buffer_f32, _quad_cy); buffer_write(_glyph_buffer, buffer_f32, _packed_indexes);    buffer_write(_glyph_buffer, buffer_f32, _quad_r                ); buffer_write(_glyph_buffer, buffer_f32, _quad_b); buffer_write(_glyph_buffer, buffer_f32, _text_effect_flags);    buffer_write(_glyph_buffer, buffer_u32, _colour);    buffer_write(_glyph_buffer, buffer_f32, _quad_u1); buffer_write(_glyph_buffer, buffer_f32, _quad_v1);
	                    buffer_write(_glyph_buffer, buffer_f32, _quad_cx); buffer_write(_glyph_buffer, buffer_f32, _quad_cy); buffer_write(_glyph_buffer, buffer_f32, _packed_indexes);    buffer_write(_glyph_buffer, buffer_f32, _quad_l                ); buffer_write(_glyph_buffer, buffer_f32, _quad_b); buffer_write(_glyph_buffer, buffer_f32, _text_effect_flags);    buffer_write(_glyph_buffer, buffer_u32, _colour);    buffer_write(_glyph_buffer, buffer_f32, _quad_u0); buffer_write(_glyph_buffer, buffer_f32, _quad_v1);
	                    buffer_write(_glyph_buffer, buffer_f32, _quad_cx); buffer_write(_glyph_buffer, buffer_f32, _quad_cy); buffer_write(_glyph_buffer, buffer_f32, _packed_indexes);    buffer_write(_glyph_buffer, buffer_f32, _quad_r                ); buffer_write(_glyph_buffer, buffer_f32, _quad_b); buffer_write(_glyph_buffer, buffer_f32, _text_effect_flags);    buffer_write(_glyph_buffer, buffer_u32, _colour);    buffer_write(_glyph_buffer, buffer_f32, _quad_u1); buffer_write(_glyph_buffer, buffer_f32, _quad_v1);
	                    buffer_write(_glyph_buffer, buffer_f32, _quad_cx); buffer_write(_glyph_buffer, buffer_f32, _quad_cy); buffer_write(_glyph_buffer, buffer_f32, _packed_indexes);    buffer_write(_glyph_buffer, buffer_f32, _quad_l + _slant_offset); buffer_write(_glyph_buffer, buffer_f32, _quad_t); buffer_write(_glyph_buffer, buffer_f32, _text_effect_flags);    buffer_write(_glyph_buffer, buffer_u32, _colour);    buffer_write(_glyph_buffer, buffer_f32, _quad_u0); buffer_write(_glyph_buffer, buffer_f32, _quad_v0);
	                    buffer_write(_glyph_buffer, buffer_f32, _quad_cx); buffer_write(_glyph_buffer, buffer_f32, _quad_cy); buffer_write(_glyph_buffer, buffer_f32, _packed_indexes);    buffer_write(_glyph_buffer, buffer_f32, _quad_r + _slant_offset); buffer_write(_glyph_buffer, buffer_f32, _quad_t); buffer_write(_glyph_buffer, buffer_f32, _text_effect_flags);    buffer_write(_glyph_buffer, buffer_u32, _colour);    buffer_write(_glyph_buffer, buffer_f32, _quad_u1); buffer_write(_glyph_buffer, buffer_f32, _quad_v0);
            
                    #endregion
            
	                    if (SCRIBBLE_CREATE_CHARACTER_ARRAY) _character_array[@ _meta_element_characters] = _character_code;
	                    ++_meta_element_characters;
            
	                    _char_width = _glyph_array[SCRIBBLE_GLYPH.SEPARATION]*_text_scale;
	                }
        
	                //Choose the height of a space for the character's height
	                if (!_line_fixed_height) _line_height = max(_line_height, _font_line_height*_text_scale); //Change our line height if it's not fixed
                
	                if (global.__scribble_character_delay)
	                {
	                    var _delay = global.__scribble_character_delay_map[? _character_code];
	                    if ((_delay != undefined) && (_delay > 0))
	                    {
	                        var _count = array_length(_events_char_array);
	                        _events_char_array[@ _count] = _meta_element_characters;
	                        _events_name_array[@ _count] = "delay";
	                        _events_data_array[@ _count] = [_delay];
	                    }
	                }
	            }
    
    
    
            #region Handle new line creation
            
	            if (_force_newline
	            || ((_char_width + _text_x > _max_width) && (_max_width >= 0) && (_character_code > 32)))
	            {
	                var _line_offset_x = -_text_x;
                
	                var _v = 0;
	                repeat(array_length(_page_vbuffs_array))
	                {
	                    var _data = _page_vbuffs_array[_v];
                    
	                    var _vbuff_line_start_list = _data[__SCRIBBLE_VERTEX_BUFFER.LINE_START_LIST];
	                    var _buffer                = _data[__SCRIBBLE_VERTEX_BUFFER.BUFFER         ];
                    
	                    if (_force_newline)
	                    {
	                        ds_list_add(_vbuff_line_start_list, buffer_tell(_buffer));
	                    }
	                    else
	                    {
	                        //If the line has no space character on it then we know that entire word is longer than the textbox max width
	                        //We fall back to use the character start position for this vertex buffer instead
	                        if (_line_has_space)
	                        {
	                            var _tell_a = _data[__SCRIBBLE_VERTEX_BUFFER.WORD_START_TELL];
	                        }
	                        else
	                        {
	                            var _tell_a = _data[__SCRIBBLE_VERTEX_BUFFER.CHAR_START_TELL];
	                        }
                        
	                        var _tell_b = buffer_tell(_buffer);
	                        ds_list_add(_vbuff_line_start_list, _tell_a);
                        
	                        //If we've added anything to this buffer
	                        if (_tell_a < _tell_b)
	                        {
	                            //If the line has no space character on it then we know that entire word is longer than the textbox max width
	                            //We fall back to use the character start position for this vertex buffer instead
	                            if (!_line_has_space)
	                            {
	                                //Set our word start tell position to be the same as the character start tell
	                                //This allows us to handle single words that exceed the maximum textbox width multiple times (!)
	                                _data[@ __SCRIBBLE_VERTEX_BUFFER.WORD_START_TELL] = _tell_a;
	                                _line_width = max(_line_width, _text_x);
	                            }
	                            else
	                            {
	                                //If our line didn't have a space then set our word/character start position to be the current tell for this buffer
	                                _data[@ __SCRIBBLE_VERTEX_BUFFER.CHAR_START_TELL] = _tell_b;
	                                _data[@ __SCRIBBLE_VERTEX_BUFFER.WORD_START_TELL] = _tell_b;
	                            }
                            
	                            //Note the negative sign!
	                            var _word_x_offset = _data[__SCRIBBLE_VERTEX_BUFFER.WORD_X_OFFSET];
	                            if (_word_x_offset == undefined) _word_x_offset = 0;
                            
	                            _line_offset_x = _word_x_offset - (buffer_peek(_buffer, _tell_a + __SCRIBBLE_VERTEX.CENTRE_X, buffer_f32) + buffer_peek(_buffer, _tell_a + __SCRIBBLE_VERTEX.DELTA_X, buffer_f32));
	                            if (_line_offset_x < 0)
	                            {
	                                //Retroactively move the last word to a new line
	                                var _tell = _tell_a;
	                                repeat((_tell_b - _tell_a) / __SCRIBBLE_VERTEX.__SIZE)
	                                {
	                                    //Increment the line _index by 1
	                                    buffer_poke(_buffer, _tell + __SCRIBBLE_VERTEX.PACKED_INDEXES, buffer_f32, buffer_peek(_buffer, _tell + __SCRIBBLE_VERTEX.PACKED_INDEXES, buffer_f32) + 1);
                            
	                                    //Adjust glyph centre position
	                                    buffer_poke(_buffer, _tell + __SCRIBBLE_VERTEX.CENTRE_X, buffer_f32, buffer_peek(_buffer, _tell + __SCRIBBLE_VERTEX.CENTRE_X, buffer_f32) + _line_offset_x);
                            
	                                     //If we're using a fixed line height, ensure that the glyph y-position is updated too
	                                    if (_line_fixed_height)
	                                    {
	                                        buffer_poke(_buffer, _tell + __SCRIBBLE_VERTEX.CENTRE_Y, buffer_f32, buffer_peek(_buffer, _tell + __SCRIBBLE_VERTEX.CENTRE_Y, buffer_f32) + _line_height);
	                                    }
                            
	                                    _tell += __SCRIBBLE_VERTEX.__SIZE;
	                                }
	                            }
                            
	                            _data[@ __SCRIBBLE_VERTEX_BUFFER.WORD_X_OFFSET] = undefined;
	                        }
	                    }
                    
	                    ++_v;
	                }
        
	                //Limit the height of the line
	                if (_line_max_height >= 0) _line_height = min(_line_height, _line_max_height);
        
	                ++_meta_element_lines;
	                ++_meta_page_lines;
        
	                //Update the last line
	                _line_array[@ __SCRIBBLE_LINE.LAST_CHAR] = _force_newline? (_meta_element_characters-1) : _word_start_char;
	                _line_array[@ __SCRIBBLE_LINE.Y        ] = _line_y + (_line_height div 2);
	                _line_array[@ __SCRIBBLE_LINE.WIDTH    ] = _line_width;
	                _line_array[@ __SCRIBBLE_LINE.HEIGHT   ] = _line_height;
        
	                //Reset state
	                _text_x        += _line_offset_x;
	                _line_y        += _line_height;
	                _line_has_space = false;
	                _line_width     = 0;
	                _line_height    = _line_min_height;
	                if (_line_fixed_height) _text_y += _line_height;
                
	                //Create a new line
	                var _line_array = array_create(__SCRIBBLE_LINE.__SIZE);
	                _line_array[@ __SCRIBBLE_LINE.START_CHAR] = _force_newline? _meta_element_characters : (_word_start_char+1);
	                _line_array[@ __SCRIBBLE_LINE.LAST_CHAR ] = _meta_element_characters;
	                _line_array[@ __SCRIBBLE_LINE.Y         ] = _line_y;
	                _line_array[@ __SCRIBBLE_LINE.WIDTH     ] = 0;
	                _line_array[@ __SCRIBBLE_LINE.HEIGHT    ] = _line_height;
	                _line_array[@ __SCRIBBLE_LINE.HALIGN    ] = _text_halign;
	                _page_lines_array[@ array_length(_page_lines_array)] = _line_array; //Add this line to the page
                
	                _force_newline = false;
	            }
    
            #endregion
    
    
    
            #region Handle new page creation
            
	            if (_force_newpage
	            || ((_line_height + _line_y > _max_height) && (_max_height >= 0)))
	            {
	                //Wipe the texture -> vertex buffer map
	                ds_map_clear(_texture_to_buffer_map);
                
	                //Create a new page
	                var _new_page_array        = array_create(__SCRIBBLE_PAGE.__SIZE);
	                var _new_page_lines_array  = []; //Stores each line of text (per page)
	                var _new_page_vbuffs_array = []; //Stores all the vertex buffers needed to render the text and sprites (per page)
        
	                _new_page_array[@ __SCRIBBLE_PAGE.LINES               ] = 1;
	                _new_page_array[@ __SCRIBBLE_PAGE.START_CHAR          ] = _meta_element_characters; //We'll update this later to a more accurate value
	                _new_page_array[@ __SCRIBBLE_PAGE.LAST_CHAR           ] = _meta_element_characters;
	                _new_page_array[@ __SCRIBBLE_PAGE.LINES_ARRAY         ] = _new_page_lines_array;
	                _new_page_array[@ __SCRIBBLE_PAGE.VERTEX_BUFFERS_ARRAY] = _new_page_vbuffs_array;
        
	                _element_pages_array[@ array_length(_element_pages_array)] = _new_page_array;
	                ++_meta_element_pages;
        
	                //Steal the last line from the _previous page
	                _page_array[@ __SCRIBBLE_PAGE.LINES] = _meta_page_lines - 1;
	                _page_lines_array[@ array_length(_page_lines_array)-1] = undefined;
        
	                //Figure out last/start chars for pages
	                _page_array[@ __SCRIBBLE_PAGE.LAST_CHAR] = _line_array[@ __SCRIBBLE_LINE.START_CHAR] - 1;
	                _new_page_array[@ __SCRIBBLE_PAGE.START_CHAR] = _line_array[__SCRIBBLE_LINE.START_CHAR];
        
	                if (_force_newpage)
	                {
	                    //Reset state
	                    _text_x      = 0;
	                    _line_width  = 0;
	                    _line_height = _line_min_height;
	                }
	                else
	                {
	                    //Iterate over every vertex buffer on the _previous page and steal vertices where we need to
	                    var _v = 0;
	                    repeat(array_length(_page_vbuffs_array))
	                    {
	                        var _vbuff_data = _page_vbuffs_array[_v];
                        
	                        var _buffer                = _vbuff_data[__SCRIBBLE_VERTEX_BUFFER.BUFFER         ];
	                        var _vbuff_line_start_list = _vbuff_data[__SCRIBBLE_VERTEX_BUFFER.LINE_START_LIST];
	                        var _line_tell_prev        = _vbuff_line_start_list[| _meta_page_lines];
	                        var _line_tell             = buffer_tell(_buffer);
                        
	                        if (_line_tell_prev < _line_tell) //If we've added anything to this buffer on the _previous line
	                        {
	                            var _bytes = _line_tell - _line_tell_prev;
                            
	                            //Make a new vertex buffer for the new page
	                            var _new_vbuff_data = array_create(__SCRIBBLE_VERTEX_BUFFER.__SIZE);
	                            _new_page_vbuffs_array[@ array_length(_new_page_vbuffs_array)] = _new_vbuff_data;
	                            _texture_to_buffer_map[? _vbuff_data[@ __SCRIBBLE_VERTEX_BUFFER.TEXTURE]] = _new_vbuff_data;
                            
	                            //Create new data structures
	                            var _new_buffer = buffer_create(max(_bytes, __SCRIBBLE_EXPECTED_GLYPHS*__SCRIBBLE_GLYPH_BYTE_SIZE), buffer_grow, 1);
	                            var _new_vbuff_line_start_list = ds_list_create();
	                            ds_list_add(_new_vbuff_line_start_list, 0);
                            
	                            //Fill in vertex buffer data
	                            _new_vbuff_data[@ __SCRIBBLE_VERTEX_BUFFER.BUFFER         ] = _new_buffer;
	                            _new_vbuff_data[@ __SCRIBBLE_VERTEX_BUFFER.VERTEX_BUFFER  ] = undefined;
	                            _new_vbuff_data[@ __SCRIBBLE_VERTEX_BUFFER.TEXTURE        ] = _vbuff_data[__SCRIBBLE_VERTEX_BUFFER.TEXTURE        ];
	                            _new_vbuff_data[@ __SCRIBBLE_VERTEX_BUFFER.CHAR_START_TELL] = _vbuff_data[__SCRIBBLE_VERTEX_BUFFER.CHAR_START_TELL] - _line_tell_prev;
	                            _new_vbuff_data[@ __SCRIBBLE_VERTEX_BUFFER.WORD_START_TELL] = _vbuff_data[__SCRIBBLE_VERTEX_BUFFER.WORD_START_TELL] - _line_tell_prev;
	                            _new_vbuff_data[@ __SCRIBBLE_VERTEX_BUFFER.WORD_X_OFFSET  ] = _vbuff_data[__SCRIBBLE_VERTEX_BUFFER.WORD_X_OFFSET  ];
	                            _new_vbuff_data[@ __SCRIBBLE_VERTEX_BUFFER.LINE_START_LIST] = _new_vbuff_line_start_list;
	                            _new_vbuff_data[@ __SCRIBBLE_VERTEX_BUFFER.TEXEL_WIDTH    ] = _vbuff_data[__SCRIBBLE_VERTEX_BUFFER.TEXEL_WIDTH    ];
	                            _new_vbuff_data[@ __SCRIBBLE_VERTEX_BUFFER.TEXEL_HEIGHT   ] = _vbuff_data[__SCRIBBLE_VERTEX_BUFFER.TEXEL_HEIGHT   ];
                            
	                            //Copy the relevant vertices of the old buffer to the new buffer
	                            buffer_copy(_buffer, _line_tell_prev, _bytes, _new_buffer, 0);
	                            buffer_seek(_new_buffer, buffer_seek_start, _bytes);
                            
	                            //Resize the old buffer to clip off the vertices we've stolen
	                            buffer_resize(_buffer, _line_tell_prev);
	                            buffer_seek(_buffer, buffer_seek_start, _line_tell_prev); //Resizing a buffer resets its tell
	                            ds_list_delete(_vbuff_line_start_list, ds_list_size(_vbuff_line_start_list)-1);
                    
	                            var _tell = 0;
	                            repeat(_bytes / __SCRIBBLE_VERTEX.__SIZE)
	                            {
	                                //Go through every vertex and set its line _index to 0
	                                buffer_poke(_new_buffer, _tell + __SCRIBBLE_VERTEX.PACKED_INDEXES, buffer_f32,
	                                            __SCRIBBLE_MAX_LINES*(buffer_peek(_new_buffer, _tell + __SCRIBBLE_VERTEX.PACKED_INDEXES, buffer_f32) div __SCRIBBLE_MAX_LINES));
                        
	                                //If we're using a fixed line height, reset this glyph's y-position
	                                if (_line_fixed_height) buffer_poke(_new_buffer, _tell + __SCRIBBLE_VERTEX.CENTRE_Y, buffer_f32, _half_fixed_height);
                        
	                                _tell += __SCRIBBLE_VERTEX.__SIZE;
	                            }
	                        }
                        
	                        ++_v;
	                    }
	                }
                
	                //Add the line array to this page
	                _new_page_lines_array[@ array_length(_new_page_lines_array)] = _line_array;
                
	                //Transfer new page variables into current page variables
	                _page_array        = _new_page_array;
	                _page_lines_array  = _new_page_lines_array;
	                _page_vbuffs_array = _new_page_vbuffs_array;
                
	                //Reset some state variables
	                _element_height        = max(_element_height, _line_y);
	                _meta_page_lines       =  0;
	                _line_y                =  0;
	                _glyph_texture         = -1;
	                _vbuff_line_start_list = -1;
        
	                if (_line_fixed_height) _text_y = _half_fixed_height;
        
	                _force_newpage = false;
	            }
    
            #endregion
    
    
    
	            _text_x += _char_width;
	        }

	        _line_width = max(_line_width, _text_x);
	        if (_line_max_height >= 0) _line_height = min(_line_height, _line_max_height);

	        _line_array[@ __SCRIBBLE_LINE.LAST_CHAR] = _meta_element_characters - 1;
	        _line_array[@ __SCRIBBLE_LINE.Y        ] = _line_y + (_line_height div 2);
	        _line_array[@ __SCRIBBLE_LINE.WIDTH    ] = _line_width;
	        _line_array[@ __SCRIBBLE_LINE.HEIGHT   ] = _line_height;

	        ++_meta_page_lines;
	        ++_meta_element_lines;
	        _element_height = max(_element_height, _line_y + _line_height);

	        //Update metadata
	        _page_array[@ __SCRIBBLE_PAGE.LINES    ] = _meta_page_lines;
	        _page_array[@ __SCRIBBLE_PAGE.LAST_CHAR] = _meta_element_characters - 1;

	        _scribble_array[@ SCRIBBLE.LINES     ] = _meta_element_lines;
	        _scribble_array[@ SCRIBBLE.CHARACTERS] = _meta_element_characters;
	        _scribble_array[@ SCRIBBLE.PAGES     ] = _meta_element_pages;
	        _scribble_array[@ SCRIBBLE.HEIGHT    ] = _element_height;

        #endregion



        #region Find the actual width of the text element

	        //Iterate over every page
	        var _element_min_x     = 0;
	        var _element_max_x     = 0;
	        var _justify_max_width = 0;

	        var _p = 0;
	        repeat(array_length(_element_pages_array))
	        {
	            var _page_array = _element_pages_array[_p];
	            _page_lines_array = _page_array[__SCRIBBLE_PAGE.LINES_ARRAY];
    
	            //Iterate over every line on the page
	            var _l = 0;
	            repeat(array_length(_page_lines_array))
	            {
	                var _line_data = _page_lines_array[_l];
	                if (is_array(_line_data)) //Someimtes the array can contain <undefined> if a line is moved from one page to another
	                {
	                    var _line_width = _line_data[__SCRIBBLE_LINE.WIDTH];
	                    switch(_line_data[__SCRIBBLE_LINE.HALIGN])
	                    {
	                        case fa_left:
	                            _element_max_x = max(_element_max_x, _line_width);
	                        break;
                
	                        case fa_center:
	                            _element_min_x = min(_element_min_x, -(_line_width div 2));
	                            _element_max_x = max(_element_max_x,   _line_width div 2 );
	                        break;
                
	                        case fa_right:
	                            _element_min_x = min(_element_min_x, -_line_width);
	                        break;
                
	                        case __SCRIBBLE_PIN_LEFT:
	                        case __SCRIBBLE_PIN_CENTRE:
	                        case __SCRIBBLE_PIN_RIGHT:
	                            _justify_max_width = max(_justify_max_width, _line_width);
	                        break;
	                    }
	                }
        
	                ++_l;
	            }
    
	            ++_p;
	        }

	        var _fixed_width = _element_max_x - _element_min_x;
	        if (_justify_max_width > _fixed_width)
	        {
	            var _delta = _justify_max_width - _fixed_width;
	            if (_element_min_x >= 0)
	            {
	                _element_max_x += _delta;
	            }
	            else if (_element_max_x <= 0)
	            {
	                _element_min_x -= _delta;
	            }
	            else
	            {
	                _element_min_x -= _delta div 2;
	                _element_max_x += _delta div 2;
	            }
	        }

	        _scribble_array[@ SCRIBBLE.MIN_X] = _element_min_x;
	        _scribble_array[@ SCRIBBLE.MAX_X] = _element_max_x;
	        _scribble_array[@ SCRIBBLE.WIDTH] = _element_max_x - _element_min_x;

        #endregion



        #region Move glyphs around on a line to finalise alignment
        
	        //Iterate over every page
	        var _p = 0;
	        repeat(array_length(_element_pages_array))
	        {
	            var _page_array = _element_pages_array[_p];
	            _page_lines_array  = _page_array[__SCRIBBLE_PAGE.LINES_ARRAY         ];
	            _page_vbuffs_array = _page_array[__SCRIBBLE_PAGE.VERTEX_BUFFERS_ARRAY];
            
	            //Iterate over every vertex buffer for that page
	            var _v = 0;
	            repeat(array_length(_page_vbuffs_array))
	            {
	                var _data = _page_vbuffs_array[_v];
                
	                var _vbuff_line_start_list = _data[__SCRIBBLE_VERTEX_BUFFER.LINE_START_LIST];
	                var _buffer                = _data[__SCRIBBLE_VERTEX_BUFFER.BUFFER         ];
                
	                var _buffer_tell = buffer_tell(_buffer);
	                ds_list_add(_vbuff_line_start_list, _buffer_tell);
        
	                //Iterate over every line on the page
	                var _l = 0;
	                repeat(ds_list_size(_vbuff_line_start_list)-1)
	                {
	                    var _line_data = _page_lines_array[_l];
	                    if (is_array(_line_data)) //Someimtes the array can contain <undefined> if a line is moved from one page to another
	                    {
	                        var _tell_a = _vbuff_line_start_list[| _l  ];
	                        var _tell_b = _vbuff_line_start_list[| _l+1];
                
	                        if (_tell_b - _tell_a > 0)
	                        {
	                            var _line_halign = _line_data[__SCRIBBLE_LINE.HALIGN];
                    
	                            //If we're not left-aligned then we need to do some work!
	                            if (_line_halign != fa_left)
	                            {
	                                var _line_width = _line_data[__SCRIBBLE_LINE.WIDTH];
                        
	                                var _offset = 0;
	                                switch(_line_halign)
	                                {
	                                    case fa_center:
	                                        _offset = -(_line_width div 2);
	                                    break;
                            
	                                    case fa_right:
	                                        _offset = -_line_width;
	                                    break;
                            
	                                    case __SCRIBBLE_PIN_LEFT:
	                                        _offset = _element_min_x;
	                                    break;
                            
	                                    case __SCRIBBLE_PIN_CENTRE:
	                                        _offset = ((_element_min_x + _element_max_x) div 2) - (_line_width div 2);
	                                    break;
                            
	                                    case __SCRIBBLE_PIN_RIGHT:
	                                        _offset = _element_max_x - _line_width;
	                                    break;
	                                }
                        
	                                if (_offset != 0)
	                                {
	                                    //We want to write to the CENTRE_X property of every vertex for horizontal alignment
	                                    var _tell = _tell_a + __SCRIBBLE_VERTEX.CENTRE_X;
	                                    repeat((_tell_b - _tell_a) / __SCRIBBLE_VERTEX.__SIZE)
	                                    {
	                                        //Poke the new value by adding the offset to the old value
	                                        buffer_poke(_buffer, _tell, buffer_f32, _offset + buffer_peek(_buffer, _tell, buffer_f32));
                                
	                                        //Now jump ahead to the _next vertex. This means we're always writing to CENTRE_X!
	                                        _tell += __SCRIBBLE_VERTEX.__SIZE;
	                                    }
	                                }
	                            }
                    
	                            //Only update glyph y-positions if we're not using fixed line heights
	                            if (!_line_fixed_height)
	                            {
	                                //Now let's do vertical alignment by writing to CENTRE_Y
	                                var _line_y = _line_data[__SCRIBBLE_LINE.Y];
	                                var _tell   = _tell_a + __SCRIBBLE_VERTEX.CENTRE_Y;
	                                repeat((_tell_b - _tell_a) / __SCRIBBLE_VERTEX.__SIZE)
	                                {
	                                    //Poke the new value by adding the offset to the old value
	                                    buffer_poke(_buffer, _tell, buffer_f32, _line_y + buffer_peek(_buffer, _tell, buffer_f32));
                            
	                                    //Now jump ahead to the _next vertex. This means we're always writing to CENTRE_Y!
	                                    _tell += __SCRIBBLE_VERTEX.__SIZE;
	                                }
	                            }
	                        }
	                    }
                    
	                    ++_l;
	                }
                
	                //Wipe buffer start positions
	                _data[@ __SCRIBBLE_VERTEX_BUFFER.LINE_START_LIST] = undefined;
	                ds_list_destroy(_vbuff_line_start_list);
                
	                //Wipe CHAR_START_TELL and WORD_START_TELL
	                _data[@ __SCRIBBLE_VERTEX_BUFFER.CHAR_START_TELL] = undefined;
	                _data[@ __SCRIBBLE_VERTEX_BUFFER.WORD_START_TELL] = undefined;
	                _data[@ __SCRIBBLE_VERTEX_BUFFER.WORD_X_OFFSET  ] = undefined;
                
	                //Create vertex buffer
	                var _vertex_buffer = vertex_create_buffer_from_buffer_ext(_buffer, global.__scribble_vertex_format, 0, _buffer_tell / __SCRIBBLE_VERTEX.__SIZE);
	                if (_freeze) vertex_freeze(_vertex_buffer);
	                _data[@ __SCRIBBLE_VERTEX_BUFFER.VERTEX_BUFFER] = _vertex_buffer;
                
	                if (!SCRIBBLE_CREATE_GLYPH_LTRB_ARRAY)
	                {
	                    //Delete the actual buffer
	                    _data[@ __SCRIBBLE_VERTEX_BUFFER.BUFFER] = undefined;
	                    buffer_delete(_buffer);
	                }
                
	                ++_v;
	            }
            
	            ++_p;
	        }
        
        #endregion



	        if (SCRIBBLE_CREATE_GLYPH_LTRB_ARRAY)
	        {
            #region Generate glyph LTRB array if requested
            
	            var _glyph_ltrb_array = array_create(_meta_element_characters, undefined);
            
	            //Iterate over every page
	            var _p = 0;
	            repeat(array_length(_element_pages_array))
	            {
	                var _page_array = _element_pages_array[_p];
	                _page_vbuffs_array = _page_array[__SCRIBBLE_PAGE.VERTEX_BUFFERS_ARRAY];
                
	                //Iterate over every vertex buffer for that page
	                var _v = 0;
	                repeat(array_length(_page_vbuffs_array))
	                {
	                    //Grab the vertex buffer
	                    var _data = _page_vbuffs_array[_v];
	                    var _buffer = _data[__SCRIBBLE_VERTEX_BUFFER.BUFFER];
                    
	                    if (_buffer != undefined)
	                    {
	                        //Start at the start...
	                        var _tell = 0;
	                        repeat(buffer_get_size(_buffer) div __SCRIBBLE_GLYPH_BYTE_SIZE)
	                        {
	                            //Get which character we're reading
	                            var _packed_indexes = buffer_peek(_buffer, _tell + __SCRIBBLE_VERTEX.PACKED_INDEXES, buffer_f32);
                            
	                            //Read the top-left corner
	                            var _l = buffer_peek(_buffer, _tell + __SCRIBBLE_VERTEX.CENTRE_X, buffer_f32) + buffer_peek(_buffer, _tell + __SCRIBBLE_VERTEX.DELTA_X, buffer_f32);
	                            var _t = buffer_peek(_buffer, _tell + __SCRIBBLE_VERTEX.CENTRE_Y, buffer_f32) + buffer_peek(_buffer, _tell + __SCRIBBLE_VERTEX.DELTA_Y, buffer_f32);
                            
	                            //Read out the bottom-right corner
	                            _tell += __SCRIBBLE_VERTEX.__SIZE;
	                            var _r = buffer_peek(_buffer, _tell + __SCRIBBLE_VERTEX.CENTRE_X, buffer_f32) + buffer_peek(_buffer, _tell + __SCRIBBLE_VERTEX.DELTA_X, buffer_f32);
	                            var _b = buffer_peek(_buffer, _tell + __SCRIBBLE_VERTEX.CENTRE_Y, buffer_f32) + buffer_peek(_buffer, _tell + __SCRIBBLE_VERTEX.DELTA_Y, buffer_f32);
                            
	                            //Move to the _next quad
	                            _tell += __SCRIBBLE_GLYPH_BYTE_SIZE - __SCRIBBLE_VERTEX.__SIZE;
                            
	                            //Ignore null data in the vertex buffer
	                            if ((_packed_indexes != 0) || (_l != 0) || (_t != 0) || (_r != 0) || (_b != 0))
	                            {
	                                //Unpack the character and line indexes
	                                var _char = _packed_indexes div __SCRIBBLE_MAX_LINES;
	                                var _line = _packed_indexes - __SCRIBBLE_MAX_LINES*_char;
                                
	                                //Find out if an LTRB definition exists for this character already
	                                var _old_ltrb = _glyph_ltrb_array[_char];
	                                if (!is_array(_old_ltrb))
	                                {
	                                    //If we don't have any pre-existing data, use the current glyph's LTRB
	                                    _glyph_ltrb_array[@ _char] = [_l, _t, _r, _b, _line];
	                                }
	                                else
	                                {
	                                    //If we found some _previous data, we need to add info to the multi array to figure out later
	                                    _glyph_ltrb_array[@ _char] = [min(_old_ltrb[0], _l   ),
	                                                                  min(_old_ltrb[1], _t   ),
	                                                                  max(_old_ltrb[2], _r   ),
	                                                                  max(_old_ltrb[3], _b   ),
	                                                                  max(_old_ltrb[4], _line),
	                                                                  _p];
	                                }
	                            }
	                        }
                        
	                        //Delete the actual buffer
	                        _data[@ __SCRIBBLE_VERTEX_BUFFER.BUFFER] = undefined;
	                        buffer_delete(_buffer);
	                    }
                    
	                    ++_v;
	                }
                
	                ++_p;
	            }
            
	            _glyph_ltrb_array[@ array_length(_glyph_ltrb_array)] = _glyph_ltrb_array[array_length(_glyph_ltrb_array)-1];
	            _scribble_array[@ SCRIBBLE.GLYPH_LTRB_ARRAY] = _glyph_ltrb_array;
            
            #endregion
	        }



	        ds_map_destroy(_texture_to_buffer_map);
	        ds_list_destroy(_parameters_list);



	        if (SCRIBBLE_VERBOSE) show_debug_message("Scribble: scribble_cache() create took " + string((get_timer() - _timer_total)/1000) + "ms for " + string(_scribble_array[SCRIBBLE.CHARACTERS]) + " characters");
	    }
	}



#region Create an occurance array if necessary

	var _occurance_map = _scribble_array[SCRIBBLE.OCCURANCES_MAP];
	if (!ds_map_exists(_occurance_map, _occurance_name))
	{
	    var _occurance_array = array_create(__SCRIBBLE_OCCURANCE.__SIZE);
    
	    _occurance_array[@ __SCRIBBLE_OCCURANCE.PAGE               ] =  0;
	    _occurance_array[@ __SCRIBBLE_OCCURANCE.FADE_IN            ] = -1;
	    _occurance_array[@ __SCRIBBLE_OCCURANCE.SKIP               ] =  false;
	    _occurance_array[@ __SCRIBBLE_OCCURANCE.SPEED              ] =  0;
	    _occurance_array[@ __SCRIBBLE_OCCURANCE.WINDOW             ] =  0;
	    _occurance_array[@ __SCRIBBLE_OCCURANCE.WINDOW_ARRAY       ] =  array_create(2*__SCRIBBLE_WINDOW_COUNT, 0.0);
	    _occurance_array[@ __SCRIBBLE_OCCURANCE.METHOD             ] =  0; //No fade in/out set
	    _occurance_array[@ __SCRIBBLE_OCCURANCE.SMOOTHNESS         ] =  0;
	    _occurance_array[@ __SCRIBBLE_OCCURANCE.SOUND_ARRAY        ] = -1;
	    _occurance_array[@ __SCRIBBLE_OCCURANCE.SOUND_OVERLAP      ] =  0;
	    _occurance_array[@ __SCRIBBLE_OCCURANCE.SOUND_PER_CHAR     ] =  false;
	    _occurance_array[@ __SCRIBBLE_OCCURANCE.SOUND_MIN_PITCH    ] =  1.0;
	    _occurance_array[@ __SCRIBBLE_OCCURANCE.SOUND_MAX_PITCH    ] =  1.0;
	    _occurance_array[@ __SCRIBBLE_OCCURANCE.PAUSED             ] =  false;
	    _occurance_array[@ __SCRIBBLE_OCCURANCE.DELAY_PAUSED       ] =  false;
	    _occurance_array[@ __SCRIBBLE_OCCURANCE.DELAY_END          ] = -1;
	    _occurance_array[@ __SCRIBBLE_OCCURANCE.FUNCTION           ] =  undefined;
	    _occurance_array[@ __SCRIBBLE_OCCURANCE.SOUND_FINISH_TIME  ] =  current_time;
	    _occurance_array[@ __SCRIBBLE_OCCURANCE.DRAWN_TIME         ] =  current_time;
	    _occurance_array[@ __SCRIBBLE_OCCURANCE.ANIMATION_TIME     ] =  current_time;
	    _occurance_array[@ __SCRIBBLE_OCCURANCE.EVENT_PREVIOUS     ] = -1;
	    _occurance_array[@ __SCRIBBLE_OCCURANCE.EVENT_CHAR_PREVIOUS] = -1;
	    _occurance_array[@ __SCRIBBLE_OCCURANCE.EVENT_VISITED_ARRAY] = array_create(array_length(_events_char_array), false);
    
	    _occurance_map[? _occurance_name] = _occurance_array;
	}

#endregion



	if (_rebuild)
	{
	    scribble_set_state(_old_draw_state);
	}



	return _scribble_array;


}
