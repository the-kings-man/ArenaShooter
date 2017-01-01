///Notifies the server of a player connection/disconnection
{
    var pad_index = argument0;
    var isConnection = argument1;
    
    buffer_seek(buff, buffer_seek_start, 0);
    
    buffer_write(buff, buffer_u8, TEST_SEND_PLAYER_CONNECTION); // Command
    
    buffer_write(buff, buffer_u8, pad_index); // Pad Index
    
    buffer_write(buff, buffer_bool, isConnection); //Was a connection or not
    
    network_send_packet(clientSocket, buff, buffer_tell(buff));
}
