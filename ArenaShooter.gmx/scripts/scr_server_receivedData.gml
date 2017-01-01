//This will handle when the server receives data
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
        case TEST_SEND_PLAYER_DATA:
            //TODO: Fill this in sso that player move h and move v data will be processed
            show_debug_message("Received player data");
            var numPlayers = buffer_read(buf, buffer_u8);
            
            //Find the player map
            var socket = ds_map_find_value(async_load, "id");
            var playerMap = ds_map_find_value(clientMap, socket);
            
            for (var i = 0; i < numPlayers; i++) {
                var pad_index = buffer_read(buf, buffer_u8);
                var player = playerMap[? pad_index];
                
                player.move_h = buffer_read(buf, buffer_f32);
                player.move_v = buffer_read(buf, buffer_f32);
            }
            break;
        case TEST_SEND_PLAYER_CONNECTION:
            var pad_index = buffer_read(buf, buffer_u8);
            var isConnected = buffer_read(buf, buffer_bool);
            show_debug_message("SERVER HAS RECOGNISED PLAYER CONNECTION. #pad_index: " +  string(pad_index) + ", isConnected: " + string(isConnected));
            
            //Find the player map
            var socket = ds_map_find_value(async_load, "id");
            var playerMap = ds_map_find_value(clientMap, socket);
            
            if (isConnected) {
                var player = instance_create(100, 100 + 50 * pad_index, obj_svr_player);
                ds_map_add(playerMap, pad_index, player);
                player.pad_index = pad_index;
                player.is_client = false;
            } else {
                with (playerMap[? pad_index]) instance_destroy();
                ds_map_delete(playerMap, pad_index);
            }
            
            //Update all clients of connection/disconnection of player
            buffer_seek(buff, buffer_seek_start, 0);
            
            buffer_write(buff, buffer_u8, SVR_SEND_CONNECTION_DATA); //Command
            
            buffer_write(buff, buffer_u8, CONNECTION_DATA_PLAYER); //Whether it's player or client connection data
            buffer_write(buff, buffer_u8, socket);
            buffer_write(buff, buffer_u8, pad_index);
            buffer_write(buff, buffer_bool, isConnected);
            buffer_write(buff, buffer_s16, playerMap[? pad_index].x); //x of player instance
            buffer_write(buff, buffer_s16, playerMap[? pad_index].y); //y of player instance
            
            var bufferSize = buffer_tell(buff);
            for (var i = 0; i < ds_list_size(socketList); i++) {
                network_send_packet(ds_list_find_value(socketList, i), buff, bufferSize);
            }
            
            break;
    }
}
