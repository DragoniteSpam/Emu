function EmuDemoMeshScene() constructor {
    MeshInstance = function(_filename, _format, _x, _y, _z) constructor {
        model = vertex_create_buffer();
        vertex_begin(model, _format);
        
        var file = file_text_open_read(_filename);
        file_text_read_real(file);
        var n = file_text_read_real(file);
        file_text_readln(file);
        
        var line = array_create(10, 0);
        
        for (var i = 0; i < n; i++){
        	for (var j = 0; j < 11; j++){
        		line[j] = file_text_read_real(file);
        	}
    	    
        	if (line[0] == 9) {
        		vertex_position_3d(model, line[1], line[2], line[3]);
                vertex_normal(model, line[4], line[5], line[6]);
                vertex_color(model, line[9], line[10]);
        	}
        }
        
        file_text_close(file);
        vertex_end(model);
        vertex_freeze(model);
        
        position = { x: _x, y: _y, z: _z };
        rotation = { x: 0, y: 0, z: 0 };
        scale = { x: 1, y: 1, z: 1 };
        
        Render = function() {
            matrix_set(matrix_world, matrix_build(position.x, position.y, position.z, rotation.x, rotation.y, rotation.z, scale.x, scale.y, scale.z));
            vertex_submit(model, pr_trianglelist, -1);
            matrix_set(matrix_world, matrix_build_identity());
        }
        
        Destroy = function() {
            vertex_delete_buffer(model);
        }
    }
    
    MeshTexturedInstance = function(_filename, _format, _x, _y, _z, _texturefile) constructor {
        model = vertex_create_buffer();
        vertex_begin(model, _format);
        
        var file = file_text_open_read(_filename);
        file_text_read_real(file);
        var n = file_text_read_real(file);
        file_text_readln(file);
        
        var line = array_create(10, 0);
        
        for (var i = 0; i < n; i++){
        	for (var j = 0; j < 11; j++){
        		line[j] = file_text_read_real(file);
        	}
    	    
        	if (line[0] == 9) {
        		vertex_position_3d(model, line[1], line[2], line[3]);
                vertex_texcoord(model, line[7], line[8]);
        	}
        }
        
        file_text_close(file);
        vertex_end(model);
        vertex_freeze(model);
        
        texture_sprite = sprite_add(_texturefile, 0, false, false, 0, 0);
        
        position = { x: _x, y: _y, z: _z };
        rotation = { x: 0, y: 0, z: 0 };
        scale = { x: 1, y: 1, z: 1 };
        
        Render = function() {
            matrix_set(matrix_world, matrix_build(position.x, position.y, position.z, rotation.x, rotation.y, rotation.z, scale.x, scale.y, scale.z));
            vertex_submit(model, pr_trianglelist, sprite_get_texture(texture_sprite, 0));
            matrix_set(matrix_world, matrix_build_identity());
        }
        
        Destroy = function() {
            vertex_delete_buffer(model);
            sprite_delete(texture_sprite);
        }
    }
    
    vertex_format_begin();
    vertex_format_add_position_3d();
    vertex_format_add_normal();
    vertex_format_add_color();
    format = vertex_format_end();
    
    vertex_format_begin();
    vertex_format_add_position_3d();
    vertex_format_add_texcoord();
    format_texture = vertex_format_end();
    
    mesh_list = ds_list_create();
    
    camera_distance = 120;
    camera_angle = 0;
    camera_position = {
        x: camera_distance * dcos(camera_angle),
        y: camera_distance * -dsin(camera_angle),
        z: 64
    };
    
    ds_list_add(mesh_list,
        new MeshInstance("emu\\mothertree.d3d", format, 0, 0, 0),
        new MeshInstance("emu\\pine04.d3d", format, -20, -40, 0),
        new MeshInstance("emu\\pine04.d3d", format, 64, -40, 0),
        new MeshInstance("emu\\pine04.d3d", format, 32, -64, 0),
        new MeshInstance("emu\\pine04.d3d", format, 0, 64, 0),
        new MeshInstance("emu\\rock01.d3d", format, 80, 40, 0),
        new MeshInstance("emu\\rock02.d3d", format, -64, 32, 0),
        new MeshInstance("emu\\rock03.d3d", format, 48, -48, 0),
        new MeshInstance("emu\\rock04.d3d", format, -72, 16, 0),
    );
    
    mesh_list[| 2].scale = { x: 1.25, y: 1.25, z: 1.25 };
    mesh_list[| 3].scale = { x: 1.5, y: 1.5, z: 1.5 };
    mesh_list[| 4].scale = { x: 2, y: 2, z: 2 };
    
    skybox = new MeshTexturedInstance("emu\\skybox.d3d", format_texture, 0, 0, 0, "emu\\skybox.png");
    ground = new MeshInstance("emu\\floor.d3d", format, 0, 0, 0);
    
    Control = function() {
        camera_angle += 0.3;
        camera_position.x = camera_distance * dcos(camera_angle);
        camera_position.y = camera_distance * -dsin(camera_angle);
    }
    
    Render = function() {
        var camera = camera_get_active();
        var old_view_mat = camera_get_view_mat(camera);
        var old_proj_mat = camera_get_proj_mat(camera);
        var old_state = gpu_get_state();
        camera_set_view_mat(camera, matrix_build_lookat(camera_position.x, camera_position.y, camera_position.z, 0, 0, 40, 0, 0, 1));
        camera_set_proj_mat(camera, matrix_build_projection_perspective_fov(-60, 4 / 3, 1, 1000));
        camera_apply(camera);
        draw_clear(c_black);
        shader_set(shd_emu);
        gpu_set_ztestenable(false);
        gpu_set_zwriteenable(false);
        
        skybox.position = camera_position;
        skybox.Render();
        
        shader_set(shd_emu_lighting);
        gpu_set_ztestenable(true);
        gpu_set_zwriteenable(true);
        
        ground.Render();
        
        for (var i = 0; i < ds_list_size(mesh_list); i++) {
            mesh_list[| i].Render();
        }
        
        shader_reset();
        
        camera_set_view_mat(camera, old_view_mat);
        camera_set_proj_mat(camera, old_proj_mat);
        camera_apply(camera);
        gpu_set_state(old_state);
        ds_map_destroy(old_state);
    }
    
    Destroy = function() {
        for (var i = 0; i < ds_list_size(mesh_list); i++) {
            mesh_list[| i].Destroy();
        }
        ds_list_destroy(mesh_list);
        skybox.Destroy();
        vertex_format_delete(format);
        vertex_format_delete(format_texture);
    }
}