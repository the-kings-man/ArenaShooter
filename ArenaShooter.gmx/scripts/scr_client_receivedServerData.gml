///Handle the data received from the server
{
    var buf = ds_map_find_value(async_load, "buffer");
    
    var command = buffer_read(buf, buffer_u8);
    
    switch (command) {
    /*
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
            */
        case SVR_SEND_GAME_DATA: //Game data sent every step
        
            //Update the visible player objects
            var numClients = buffer_read(buf, buffer_u8);
            
            for (var iCli = 0; iCli < numClients; iCli++) {
                var socket = buffer_read(buf, buffer_u8);
                var playerMap = ds_map_find_value(clientMap, socket);
                var numPlayers = buffer_read(buf, buffer_u8);
                
                for (var iPla = 0; iPla < numPlayers; iPla++) {
                    var pad_index = buffer_read(buf, buffer_u8);
                    var player = ds_map_find_value(playerMap, pad_index);
                    player.x = buffer_read(buf, buffer_s16);
                    player.y = buffer_read(buf, buffer_s16);
                    player.speed = buffer_read(buf, buffer_f32);
                    player.direction = buffer_read(buf, buffer_f32);
                }
            }
            break;
        case SVR_SEND_CONNECTION_DATA:
            var isPlayer = (buffer_read(buf, buffer_u8) == CONNECTION_DATA_PLAYER);
            
            if (isPlayer) { //Player is connecting
                var socket = buffer_read(buf, buffer_u8);
                var pad_index = buffer_read(buf, buffer_u8);
                var isConnected = buffer_read(buf, buffer_bool);
                var playerX = buffer_read(buf, buffer_s16);
                var playerY = buffer_read(buf, buffer_s16);
                
                //Add/remove player to/from playerMap in their client
                if (!ds_map_exists(clientMap, socket)) {
                    ds_map_add(clientMap, socket, ds_map_create());
                }
                
                var playerMap = ds_map_find_value(clientMap, socket);
                if (isConnected) { //Player has connected, add them to game
                    var player = instance_create(playerX, playerY, obj_cli_player);
                    ds_map_add(playerMap, pad_index, player);
                    player.socket = socket;
                    player.pad_index = pad_index;
                    player.is_client = true;
                    
                    //player is for this client, make controller follow it around
                    if (socket == clientSocketOnServer) {
                        if (ds_map_exists(players, pad_index)) { //TODO: test this extensively to see if this check doesn't allow the following of a player
                            players[? pad_index].visiblePlayerToFollow = player;
                        } else {
                            show_debug_message("Trying to setup on client a player to follow for pad_index: " + string(pad_index) + ". But it that player didn't exist in the players map.");
                        }
                    }
                } else {
                    with (playerMap[? pad_index]) instance_destroy();
                    ds_map_delete(playerMap, pad_index);
                }
            } else {
                var socket = buffer_read(buf, buffer_u8);
                var isConnected = buffer_read(buf, buffer_bool);
                
                if (isConnected) {
                    ds_map_add(clientMap, socket, ds_map_create());
                } else {
                    //destroy all player objects in playerMap
                    if (ds_map_exists(clientMap, socket)) {
                        var playerMap = ds_map_find_value(clientMap, socket);
                        if (ds_map_size(playerMap) > 0) {
                            var pad_index = ds_map_find_first(playerMap);
                            for (var iPadIdx = 0; iPadIdx < ds_map_size(playerMap); iPadIdx++) {
                                var player = ds_map_find_value(playerMap, pad_index);
                                with (player) instance_destroy();
                                pad_index = ds_map_find_next(playerMap, pad_index);
                            }
                        }
                    }
                    
                    //Delete maps
                    ds_map_destroy(ds_map_find_value(clientMap, socket)); //destroy the player map
                    ds_map_delete(clientMap, socket); //delete the socket from the map              
                }
            }
            
            break;
        case SVR_SEND_CLIENT_FIRST_CONNECT:
            var socket = buffer_read(buf, buffer_u8);
            clientSocketOnServer = socket;
            //TODO: Also update client of current game state
            
            var numClients = buffer_read(buf, buffer_u8); //Get number of clients to process
            
            for (var iClient = 0; iClient < numClients; iClient++) {
                var clientSocket = buffer_read(buf, buffer_u8);
                show_debug_message("Client Socket: " + string(clientSocket));
                
                if (!ds_map_exists(clientMap, clientSocket)) {
                    ds_map_add(clientMap, clientSocket, ds_map_create());
                }
                
                //Loop through players, create the client versions of them if needed
                // and setup their variables
                var playerMap = ds_map_find_value(clientMap, clientSocket);
                var numPlayers = buffer_read(buf, buffer_u8);
                for (var iPlayer = 0; iPlayer < numPlayers; iPlayer++) {
                    var pad_index = buffer_read(buf, buffer_u8);
                    show_debug_message("Pad Index: " + string(pad_index));
                    var player = noone;
                    if (ds_map_exists(playerMap, pad_index)) {
                        player = ds_map_find_value(playerMap, pad_index);
                    } else {
                        player = instance_create(0, 0, obj_cli_player);
                        ds_map_add(playerMap, pad_index, player);
                    }
                    player.x = buffer_read(buf, buffer_s16);
                    player.y = buffer_read(buf, buffer_s16);
                    player.speed = buffer_read(buf, buffer_f32);
                    player.direction = buffer_read(buf, buffer_f32);
                }
            }
            
            break;
        case SVR_SEND_PAD_INDEX_CHANGE:
            var socket = buffer_read(buf, buffer_u8);
            var old_pad_index = buffer_read(buf, buffer_u8);
            var pad_index = buffer_read(buf, buffer_u8);
            
            var playerMap = ds_map_find_value(clientMap, socket);
            playerMap[? pad_index] = playerMap[? old_pad_index];
            ds_map_delete(playerMap, old_pad_index);
            break;
    }
}
