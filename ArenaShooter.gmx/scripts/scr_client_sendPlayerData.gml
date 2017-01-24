///Checks whether the client should send data to the server for this step, collects all data, and sends it
{    
    buffer_seek(buff, buffer_seek_start, 0);
    
    buffer_write(buff, buffer_u8, CLI_SEND_PLAYER_DATA); //Command
    
    buffer_write(buff, buffer_u8, 0); //Placeholder for number of players data to process

    var doSend = false;
    var numPlayers = 0;
    
    var pad_index = ds_map_find_first(players);
    for (var i = 0; i < ds_map_size(players) && !doSend; i++) {
        var player = ds_map_find_value(players, pad_index);
        
        if (scr_client_checkSendPlayerData(player)) {
            doSend = true;
            numPlayers++;
            buffer_write(buff, buffer_u8, pad_index);
            buffer_write(buff, buffer_f32, player.move_h);
            buffer_write(buff, buffer_f32, player.move_v);
        }
        
        pad_index = ds_map_find_next(players, pad_index);
    }
    
    if (doSend) {
        //bufferSize is set here so that we send only data relevant to this script call,
        //as the buffer can be bigger than this as we keep writing to it on and off
        //throughout the existance of this client instance
        var bufferSize = buffer_tell(buff);
        
        //Write the number of players in it's position
        buffer_seek(buff, buffer_seek_start, 1);
        buffer_write(buff, buffer_u8, numPlayers);
        
        network_send_packet(clientSocket, buff, bufferSize);
        
        show_debug_message("CLIENT IS SENDING PLAYER DATA TO SERVER: buffer size:" + string(bufferSize));
    }
}
