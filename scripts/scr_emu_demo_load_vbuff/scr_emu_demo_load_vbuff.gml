function scr_emu_demo_load_vbuff(filename, format) {
    var buffer = buffer_load(filename);
    var vbuff = vertex_create_buffer_from_buffer(buffer, format);
    buffer_delete(buffer);
    vertex_freeze(vbuff);
    return vbuff;
}