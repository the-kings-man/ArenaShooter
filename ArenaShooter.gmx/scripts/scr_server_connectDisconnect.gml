//Handles the connecting/disconnecting of clients
{
    var socket = ds_map_find_value(async_load, "socket"); //The socket id of the connection
    var type = ds_map_find_value(async_load, "type"); //type is whether it's connecting or disconnecting
    switch (type) {
        case network_type_connect: //Connect a client
            ds_list_add(socketList, socket);
            break;
        case network_type_disconnect: //Disconnect a client
            ds_list_delete(socketList, ds_list_find_index(socketList, socket));
            break;
        case network_type_data:
            //TODO: Handle data, not sure if we will ever use this? I have no idea of applications - DW
            break;
    }
}
