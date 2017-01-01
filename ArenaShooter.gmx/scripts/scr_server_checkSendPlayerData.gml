///Runs checks on the player passed as argument 0 which will show whether data should be sent
{
    var player = argument0;
    var doSend = false;
    with (player) {
        if (speed != speed_prev || direction != direction_prev)
            doSend = true;
    }
    return doSend;
}
