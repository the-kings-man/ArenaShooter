//Handles the connecting/disconnecting of clients
{
    var socket = ds_map_find_value(async_load, "socket"); //The socket id of the connection
    var type = ds_map_find_value(async_load, "type"); //type is whether it's connecting or disconnecting
    switch (type) {
        case network_type_connect: //Connect a client
            ds_list_add(socketList, socket);
            ds_map_add(clientMap, socket, ds_map_create());
            
            //Update all clients of client connection
            buffer_seek(buff, buffer_seek_start, 0);
            
            buffer_write(buff, buffer_u8, SVR_SEND_CONNECTION_DATA);
            buffer_write(buff, buffer_u8, CONNECTION_DATA_CLIENT);
            buffer_write(buff, buffer_u8, socket);
            buffer_write(buff, buffer_u8, CONNECTION_DATA_CONNECTED);
            
            var bufferSize = buffer_tell(buff);
            for (var i = 0; i < ds_list_size(socketList); i++) {
                network_send_packet(ds_list_find_value(socketList, i), buff, bufferSize);
            }
            break;
        case network_type_disconnect: //Disconnect a client
            //destroy all player objects in playerMap
            var playerMap = ds_map_find_value(clientMap, socket);
            var pad_index = ds_map_find_first(playerMap);
            for (var iPadIdx = 0; iPadIdx < ds_map_size(playerMap); iPadIdx++) {
                var player = ds_map_find_value(playerMap, pad_index);
                with (player) instance_destroy();
                pad_index = ds_map_find_next(playerMap, pad_index);
            }
            
            //Delete lists and maps
            ds_list_delete(socketList, ds_list_find_index(socketList, socket));
            ds_map_destroy(ds_map_find_value(clientMap, socket)); //destroy the player map
            ds_map_delete(clientMap, socket); //delete the socket from the map
            
            //Update all clients of client disconnection
            buffer_seek(buff, buffer_seek_start, 0);
            
            buffer_write(buff, buffer_u8, SVR_SEND_CONNECTION_DATA);
            buffer_write(buff, buffer_u8, CONNECTION_DATA_CLIENT);
            buffer_write(buff, buffer_u8, socket);
            buffer_write(buff, buffer_bool, CONNECTION_DATA_DISCONNECTED);
            
            var bufferSize = buffer_tell(buff);
            for (var i = 0; i < ds_list_size(socketList); i++) {
                network_send_packet(ds_list_find_value(socketList, i), buff, bufferSize);
            }
            break;
        case network_type_data:
            //TODO: Handle data, not sure if we will ever use this? I have no idea of applications - DW
            break;
    }
}
