function EmuDemoMeshScene() constructor {
    MeshInstance = function(filename, x, y, z, texturefile = "") constructor {
        static format = undefined;
        if (format == undefined) {
            vertex_format_begin();
            vertex_format_add_position_3d();
            vertex_format_add_normal();
            vertex_format_add_texcoord();
            vertex_format_add_color();
            format = vertex_format_end();
        }
        
        model = scr_emu_demo_load_vbuff(filename, format);
        own_textue = false;
        texture = -1;
        
        if (file_exists(texturefile)) {
            own_texture = true;
            texture = sprite_get_texture(sprite_add(texturefile, 0, false, false, 0, 0), 0);
        }
        
        position = { x: x, y: y, z: z };
        rotation = { x: 0, y: 0, z: 0 };
        scale = { x: 1, y: 1, z: 1 };
        
        Render = function() {
            matrix_set(matrix_world, matrix_build(position.x, position.y, position.z, rotation.x, rotation.y, rotation.z, scale.x, scale.y, scale.z));
            vertex_submit(model, pr_trianglelist, texture);
            matrix_set(matrix_world, matrix_build_identity());
        };
    }
    
    mesh_list = ds_list_create();
    
    camera_distance = 96;
    camera_angle = 0;
    camera_position = {
        x: camera_distance * dcos(camera_angle),
        y: camera_distance * -dsin(camera_angle),
        z: 32
    };
    
    ds_list_add(mesh_list,
        new MeshInstance("emu/floor.vbuff", 0, 0, 0),
        new MeshInstance("emu/campfire.vbuff", 20, 20, 0),
        new MeshInstance("emu/logstack.vbuff", 20, 20, 0),
        new MeshInstance("emu/tent.vbuff", -20, -20, 0),
        new MeshInstance("emu/logstackbig.vbuff", 0, -20, 0),
    );
    
    repeat (32) {
        var dist = random_range(80, 200);
        var angle = random(360);
        var mesh = new MeshInstance("emu/tree" + string(irandom(4)) + ".vbuff", dist * dcos(angle), -dist * dsin(angle), 0);
        mesh.rotation.z = random(360);
        mesh.scale.x = random_range(0.9, 1.1);
        mesh.scale.y = mesh.scale.x;
        mesh.scale.z = mesh.scale.x;
        ds_list_add(mesh_list, mesh);
    }
    
    repeat (6) {
        var dist = random_range(40, 200);
        var angle = random(360);
        ds_list_add(mesh_list, new MeshInstance("emu/rock" + string(irandom(3)) + ".vbuff", dist * dcos(angle), -dist * dsin(angle), 0));
        mesh.rotation.z = random(360);
        mesh.scale.x = random_range(0.9, 1.1);
        mesh.scale.y = mesh.scale.x;
        mesh.scale.z = mesh.scale.x;
        ds_list_add(mesh_list, mesh);
    }
    
    repeat (64) {
        var dist = random_range(36, 200);
        var angle = random(360);
        ds_list_add(mesh_list, new MeshInstance("emu/plant" + string(irandom(7)) + ".vbuff", dist * dcos(angle), -dist * dsin(angle), 0));
        mesh.rotation.z = random(360);
        mesh.scale.x = random_range(0.9, 1.1);
        mesh.scale.y = mesh.scale.x;
        mesh.scale.z = mesh.scale.x;
        ds_list_add(mesh_list, mesh);
    }
    
    birb = new MeshInstance("emu/birb.vbuff", 0, 16, 0);
    birb.texture = sprite_get_texture(spr_emu_demo_birb_blue, 0);
    
    skybox = new MeshInstance("emu/skybox.vbuff", 0, 0, 0, "emu/skybox.png");
    
    Control = function() {
        camera_angle += 0.3;
        camera_position.x = camera_distance * dcos(camera_angle);
        camera_position.y = camera_distance * -dsin(camera_angle);
        
        birb.scale.x = obj_emu_demo.data.size;
        birb.scale.y = obj_emu_demo.data.size;
        birb.scale.z = obj_emu_demo.data.size;
        birb.texture = sprite_get_texture(obj_emu_demo.data.sprite, 0);
    }
    
    Render = function() {
        var camera = camera_get_active();
        camera_set_view_mat(camera, matrix_build_lookat(camera_position.x, camera_position.y, camera_position.z, 0, 0, 32, 0, 0, 1));
        camera_set_proj_mat(camera, matrix_build_projection_perspective_fov(-60, 4 / 3, 1, 1000));
        camera_apply(camera);
        draw_clear(c_black);
        
        shader_set(shd_emu_demo);
        gpu_set_cullmode(cull_clockwise);
        gpu_set_ztestenable(false);
        gpu_set_zwriteenable(false);
        shader_set_uniform_f(shader_get_uniform(shd_emu_demo, "u_lightEnabled"), 0);
        
        skybox.position = camera_position;
        skybox.Render();
        
        camera_set_proj_mat(camera, matrix_build_projection_perspective_fov(-60, 4 / 3, 32, 1000));
        camera_apply(camera);
        
        gpu_set_ztestenable(true);
        gpu_set_zwriteenable(true);
        shader_set_uniform_f(shader_get_uniform(shd_emu_demo, "u_lightEnabled"), 1);
        
        for (var i = 0; i < ds_list_size(mesh_list); i++) {
            mesh_list[| i].Render();
        }
        
        birb.Render();
        
        shader_reset();
    };
}