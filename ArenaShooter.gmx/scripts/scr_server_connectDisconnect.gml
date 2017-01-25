//Handles the connecting/disconnecting of clients
{
    var socket = ds_map_find_value(async_load, "socket"); //The socket id of the connection
    var type = ds_map_find_value(async_load, "type"); //type is whether it's connecting or disconnecting
    switch (type) {
        case network_type_connect: //Connect a client
            ds_list_add(socketList, socket);
            ds_map_add(clientMap, socket, ds_map_create());
            
            //Update the connected client, telling it it's socket number and updating client of current game state
            //TODO: Also update client of current game state
            buffer_seek(buff, buffer_seek_start, 0);
            buffer_write(buff, buffer_u8, SVR_SEND_CLIENT_FIRST_CONNECT);
            
            buffer_write(buff, buffer_u8, socket); // Tell client it's socket number
            
            //Tell client current game state
            var numClients = ds_map_size(clientMap);
            buffer_write(buff, buffer_u8, numClients); //Number of clients data to process
            
            //Loop through all players on all different clients,
            //send all data to client
            var _socket = ds_map_find_first(clientMap);
            show_debug_message("SVR, Client Socket: " + string(_socket));
            for (var iSocket = 0; iSocket < numClients; iSocket++) {
                buffer_write(buff, buffer_u8, _socket); //Client socket data
                
                // Loop through playerMap for this client
                var playerMap = ds_map_find_value(clientMap, _socket);
                var pad_index = ds_map_find_first(playerMap);
                var numPlayers = ds_map_size(playerMap);
                buffer_write(buff, buffer_u8, numPlayers); //number of players placeholder
                
                for (var iPadIdx = 0; iPadIdx < numPlayers; iPadIdx++) {
                    var player = ds_map_find_value(playerMap, pad_index);
                    show_debug_message("SVR, Pad Index: " + string(pad_index));
                    
                    buffer_write(buff, buffer_u8, pad_index);
                    buffer_write(buff, buffer_s16, player.x);
                    buffer_write(buff, buffer_s16, player.y);
                    buffer_write(buff, buffer_f32, player.speed);
                    buffer_write(buff, buffer_f32, player.direction);
                    
                    pad_index = ds_map_find_next(playerMap, pad_index);
                }
                    
                _socket = ds_map_find_next(clientMap, _socket);
            }
            network_send_packet(socket, buff, buffer_tell(buff));
            
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
