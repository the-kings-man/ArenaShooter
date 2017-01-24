///Sends pad_index change data to the server,
///Takes the old padindex and the new pad index
{
    var old_pad_index = argument0;
    var pad_index = argument1;
    
    buffer_seek(buff, buffer_seek_start, 0);
    
    buffer_write(buff, buffer_u8, CLI_SEND_PAD_INDEX_CHANGE); //Command
    
    buffer_write(buff, buffer_u8, old_pad_index);
    buffer_write(buff, buffer_u8, pad_index);
    
    network_send_packet(clientSocket, buff, buffer_tell(buff));
}
