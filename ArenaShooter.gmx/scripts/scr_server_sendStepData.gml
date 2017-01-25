///Send data to client every step if there is data that needs to be updated
{
    buffer_seek(buff, buffer_seek_start, 0);
    
    buffer_write(buff, buffer_u8, SVR_SEND_GAME_DATA); //Command
    
    buffer_write(buff, buffer_u8, 0); //Placeholder for number of clients data to process
    
    var doSend = false;
    var numClients = 0;
    var hasAddedClient = false;
    
    //Loop through all players on all different clients,
    //check if there is data which needs to be sent to all clients
    //if there is, add it to the buffer and send it
    var socket = ds_map_find_first(clientMap);
    for (var iSocket = 0; iSocket < ds_map_size(clientMap); iSocket++) {
        var playerMap = ds_map_find_value(clientMap, socket);
        
        // Loop through playerMap for this client
        var pad_index = ds_map_find_first(playerMap);
        var numPlayers = 0;
        var placeholderOffset_numPlayers = -1;
        
        hasAddedClient = false;
        
        for (var iPadIdx = 0; iPadIdx < ds_map_size(playerMap); iPadIdx++) {
            var player = ds_map_find_value(playerMap, pad_index);
            
            //Check if data should be sent to client, if so, add data to buffer
            if (scr_server_checkSendPlayerData(player)) {
                if (!hasAddedClient) {
                    doSend = true;
                    numClients++;
                    hasAddedClient = true;
                    
                    buffer_write(buff, buffer_u8, socket); //Client socket data
                    placeholderOffset_numPlayers = buffer_tell(buff);
                    buffer_write(buff, buffer_u8, 0); //number of players placeholder
                }
                numPlayers++;
                buffer_write(buff, buffer_u8, pad_index);
                buffer_write(buff, buffer_s16, player.x);
                buffer_write(buff, buffer_s16, player.y);
                buffer_write(buff, buffer_f32, player.speed);
                buffer_write(buff, buffer_f32, player.direction);
            }
            
            //Add in number of players placeholder for this client
            if (hasAddedClient) buffer_poke(buff, placeholderOffset_numPlayers, buffer_u8, numPlayers);
            
            pad_index = ds_map_find_next(playerMap, pad_index);
        }
        
        socket = ds_map_find_next(clientMap, socket);
    }
    
    if (doSend) {
        //bufferSize is set here so that we send only data relevant to this script call,
        //as the buffer can be bigger than this as we keep writing to it on and off
        //throughout the existance of this client instance
        var bufferSize = buffer_tell(buff);
        
        //Write the number of players in it's position
        buffer_poke(buff, 1, buffer_u8, numClients);
        
        for (var i = 0; i < ds_list_size(socketList); i++) {
            network_send_packet(ds_list_find_value(socketList, i), buff, bufferSize);
        }
    }
}
