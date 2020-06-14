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
        
        if (file_exists(_texturefile)) {
            own_texture = true;
            texture_sprite = sprite_add(_texturefile, 0, false, false, 0, 0);
        } else {
            own_textrue = false;
        }
        
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
            if (own_texture) {
                sprite_delete(texture_sprite);
            }
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
    
    camera_distance = 96;
    camera_angle = 0;
    camera_position = {
        x: camera_distance * dcos(camera_angle),
        y: camera_distance * -dsin(camera_angle),
        z: 32
    };
    
    ds_list_add(mesh_list,
        new MeshInstance("emu\\floor.d3d", format, 0, 0, 0),
        new MeshInstance("emu\\campfire.d3d", format, 20, 20, 0),
        new MeshInstance("emu\\logstack.d3d", format, 20, 20, 0),
        new MeshInstance("emu\\tent.d3d", format, -20, -20, 0),
        new MeshInstance("emu\\logstackbig.d3d", format, 0, -20, 0),
    );
    
    repeat (32) {
        var dist = random_range(80, 200);
        var angle = random(360);
        var mesh = new MeshInstance("emu\\tree" + string(irandom(4)) + ".d3d", format, dist * dcos(angle), -dist * dsin(angle), 0);
        mesh.rotation.z = random(360);
        mesh.scale.x = random_range(0.9, 1.1);
        mesh.scale.y = mesh.scale.x;
        mesh.scale.z = mesh.scale.x;
        ds_list_add(mesh_list, mesh);
    }
    
    repeat (6) {
        var dist = random_range(40, 200);
        var angle = random(360);
        ds_list_add(mesh_list, new MeshInstance("emu\\rock" + string(irandom(3)) + ".d3d", format, dist * dcos(angle), -dist * dsin(angle), 0));
        mesh.rotation.z = random(360);
        mesh.scale.x = random_range(0.9, 1.1);
        mesh.scale.y = mesh.scale.x;
        mesh.scale.z = mesh.scale.x;
        ds_list_add(mesh_list, mesh);
    }
    
    repeat (64) {
        var dist = random_range(36, 200);
        var angle = random(360);
        ds_list_add(mesh_list, new MeshInstance("emu\\plant" + string(irandom(7)) + ".d3d", format, dist * dcos(angle), -dist * dsin(angle), 0));
        mesh.rotation.z = random(360);
        mesh.scale.x = random_range(0.9, 1.1);
        mesh.scale.y = mesh.scale.x;
        mesh.scale.z = mesh.scale.x;
        ds_list_add(mesh_list, mesh);
    }
    
    birb = new MeshTexturedInstance("emu\\birb.d3d", format_texture, 0, 16, 0, "");
    birb.texture_sprite = spr_emu_demo_birb_blue;
    
    skybox = new MeshTexturedInstance("emu\\skybox.d3d", format_texture, 0, 0, 0, "emu\\skybox.png");
    
    Control = function() {
        camera_angle += 0.3;
        camera_position.x = camera_distance * dcos(camera_angle);
        camera_position.y = camera_distance * -dsin(camera_angle);
        
        birb.scale.x = obj_emu_demo.data.size;
        birb.scale.y = obj_emu_demo.data.size;
        birb.scale.z = obj_emu_demo.data.size;
        birb.texture_sprite = obj_emu_demo.data.sprite;
    }
    
    Render = function() {
        var camera = camera_get_active();
        camera_set_view_mat(camera, matrix_build_lookat(camera_position.x, camera_position.y, camera_position.z, 0, 0, 32, 0, 0, 1));
        camera_set_proj_mat(camera, matrix_build_projection_perspective_fov(-60, 4 / 3, 1, 1000));
        camera_apply(camera);
        draw_clear(c_black);
        shader_set(shd_emu_demo_mesh);
        gpu_set_cullmode(cull_clockwise);
        gpu_set_ztestenable(false);
        gpu_set_zwriteenable(false);
        
        skybox.position = camera_position;
        skybox.Render();
        
        camera_set_proj_mat(camera, matrix_build_projection_perspective_fov(-60, 4 / 3, 32, 1000));
        camera_apply(camera);
        
        gpu_set_ztestenable(true);
        gpu_set_zwriteenable(true);
        shader_set(shd_emu_demo_lighting);
        
        for (var i = 0; i < ds_list_size(mesh_list); i++) {
            mesh_list[| i].Render();
        }
        
        shader_set(shd_emu_demo_mesh);
        
        birb.Render();
        
        shader_reset();
    }
    
    Destroy = function() {
        for (var i = 0; i < ds_list_size(mesh_list); i++) {
            mesh_list[| i].Destroy();
        }
        ds_list_destroy(mesh_list);
        skybox.Destroy();
        birb.Destroy();
        vertex_format_delete(format);
        vertex_format_delete(format_texture);
    }
}