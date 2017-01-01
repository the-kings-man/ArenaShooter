///Handle the data received from the server
{
    var buf = ds_map_find_value(async_load, "buffer");
    
    var command = buffer_read(buf, buffer_u8);
    
    switch (command) {
        case TEST_SEND_DATA:
            testName = buffer_read(buf, buffer_string);
            
            var numTestObjs = buffer_read(buf, buffer_u8);
            ds_list_clear(testObjList);
            for (var i = 0; i < numTestObjs; i++) {
                ds_list_add(testObjList, buffer_read(buf, buffer_s16)); //color
                ds_list_add(testObjList, buffer_read(buf, buffer_s16)); //x
                ds_list_add(testObjList, buffer_read(buf, buffer_s16)); //y
            }
            break;
        case SVR_SEND_GAME_DATA:
            
            break;
        case SVR_SEND_CONNECTION_DATA:
            var isPlayer = (buffer_read(buf, buffer_u8) == CONNECTION_DATA_PLAYER);
            
            if (isPlayer) {
                var socket = buffer_read(buf, buffer_u8);
                var pad_index = buffer_read(buf, buffer_u8);
                var isConnected = buffer_read(buf, buffer_u8);
                var playerX = buffer_read(buf, buffer_s16);
                var playerY = buffer_read(buf, buffer_s16);
                
                //Add/remove player to/from playerMap in their client
                if (!ds_map_exists(clientMap, socket)) {
                    ds_map_add(clientMap, socket, ds_map_create());
                }
                
                var playerMap = ds_map_find_value(clientMap, socket);
                if (isConnected) {
                    var player = instance_create(playerX, playerY, obj_cli_player);
                    ds_map_add(playerMap, pad_index, player);
                    //TODO: Make visible player on clientside track what client socket he's from
                    player.pad_index = pad_index;
                    player.is_client = true;
                } else {
                    with (playerMap[? pad_index]) instance_destroy();
                    ds_map_delete(playerMap, pad_index);
                }
            } else {
                //TODO: Fill this in for client (fill it in on server first)
            }
            
            break;
    }
}
