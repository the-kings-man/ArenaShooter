///Adds a local player
{
    var pad_index = argument0;
    var isGamepadControlled = argument1;
    
    var player = instance_create(100, 100 + 50 * pad_index, obj_cli_playerController);
    ds_map_add(players, pad_index, player);
    player.isGamepadControlled = isGamepadControlled;
    player.pad_index = pad_index;
    gamepad_set_axis_deadzone(pad_index, global.gamepad_deadzone);
    
    scr_client_sendPlayerConnection(pad_index, CONNECTION_DATA_CONNECTED);
}
