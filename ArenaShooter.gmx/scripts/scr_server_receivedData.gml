//TODO: This will handle when the server receives data
{
    var buf = ds_map_find_value(async_load, "buffer");
    
    var command = buffer_read(buf, buffer_u8);
    
    switch (command) {
        case TEST_SEND_DATA:
            var key = buffer_read(buf, buffer_s16);
            var isPressed = buffer_read(buf, buffer_bool);
            
            if (key == vk_space) {
                if (isPressed) {
                    with (obj_test) {
                        color = c_red;
                    }
                } else {
                    with (obj_test) {
                        color = c_black;
                    }                
                }
            }
            break;
    }
}
