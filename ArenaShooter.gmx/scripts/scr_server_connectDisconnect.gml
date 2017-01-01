//Handles the connecting/disconnecting of clients
{
    var socket = ds_map_find_value(async_load, "socket"); //The socket id of the connection
    var type = ds_map_find_value(async_load, "type"); //type is whether it's connecting or disconnecting
    switch (type) {
        case network_type_connect: //Connect a client
            ds_list_add(socketList, socket);
            ds_map_add(clientMap, socket, ds_map_create());
            
            //TODO: Update all clients of client connection
            break;
        case network_type_disconnect: //Disconnect a client
            ds_list_delete(socketList, ds_list_find_index(socketList, socket));
            ds_map_destroy(ds_map_find_value(clientMap, socket)); //destroy the player map
            ds_map_delete(clientMap, socket); //delete the socket from the map
            
            //TODO: Update all clients of client disconnection
            break;
        case network_type_data:
            //TODO: Handle data, not sure if we will ever use this? I have no idea of applications - DW
            break;
    }
}
