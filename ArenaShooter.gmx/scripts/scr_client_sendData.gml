///Checks whether the client should send data to the server for this step, collects all data, and sends it
{    
    buffer_seek(buff, buffer_seek_start, 0);
    
    buffer_write(buff, buffer_u8, TEST_SEND_PLAYER_DATA); //Command
    
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
            buffer_write(buff, buffer_s16, player.speed);
            buffer_write(buff, buffer_s16, player.direction);
        }
        
        pad_index = ds_map_find_next(players, pad_index);
    }
    
    if (doSend) {
        buffer_seek(buff, buffer_seek_start, 1); // TODO: Check if this is correct syntax to overwrite number players data
        buffer_write(buff, buffer_u8, numPlayers);
        
        network_send_packet(clientSocket, buff, buffer_tell(buff));
    }
}
