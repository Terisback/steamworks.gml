#define steam_id_create
/// steam_id_create(high, low) : Creates an immutable Steam ID.
//#macro steam_id_use_int64 true
// (in versions 1.4.1757 and earlier, you'll need to set steam_id_use_int64 to false)
if (steam_id_use_int64) {
	return (argument0 << 32) | argument1;
} else {
	var r;
	r[1] = argument1;
	r[0] = argument0;
	return r;
}

#define steam_id_get_high
/// steam_id_get_high(steam_id) : Returns higher 32 bits of a Steam ID
if (steam_id_use_int64) {
	return (argument0 >> 32) & $FFFFFFFF;
} else return argument0[0];

#define steam_id_get_low
/// steam_id_get_low(steam_id) : Returns lower 32 bits of a Steam ID
if (steam_id_use_int64) {
	return argument0 & $FFFFFFFF;
} else return argument0[1];

#define steam_id_equals
/// steam_id_equals(id1, id2) : Returns whether two IDs match up.
if (steam_id_use_int64) {
	return argument0 == argument1;
} else return argument0[0] == argument1[0] && argument0[1] == argument1[1];

#define steam_id_from_int64
/// steam_id_from_int64(value) : Creates a Steam ID from an int64
if (steam_id_use_int64) {
	return argument0;
} else {
	var s = string(argument0);
	return steam_id_create(int64_from_string_high(s), int64_from_string_low(s));
}

#define steam_id_to_int64
/// steam_id_to_int64(steam_id) : Converts a Steam ID to int64
if (steam_id_use_int64) {
	return argument0;
} else {
	var q = argument0;
	return int64(int64_combine_string(steam_id_get_high(q), steam_id_get_low(q)));
}

#define steam_gml_check_version
/// steam_gml_check_version() : Returns whether the DLL matches the extension version.
return steam_net_version == steam_gml_get_version();

#define steam_net_accept_p2p_session
/// steam_net_accept_p2p_session(user_id) : Accepts a P2P session with the given user. Should only be called in the "p2p_session_request" event.
var user_id = argument0;
return steam_net_accept_p2p_session_raw(steam_id_get_high(user_id), steam_id_get_low(user_id));

#define steam_net_close_p2p_session
/// steam_net_close_p2p_session(user_id) : Closes the P2P session with the given user (if any)
var user_id = argument0;
return steam_net_close_p2p_session_raw(steam_id_get_high(user_id), steam_id_get_low(user_id));
//{ Packet

#define steam_net_packet_get_sender_id
/// steam_net_packet_get_sender_id() : Returns the sender ID (int64) of the last received packet.
return steam_id_create(steam_net_packet_get_sender_id_high(), steam_net_packet_get_sender_id_low());

#define steam_net_packet_get_data
/// steam_net_packet_get_data(buffer) : Copies the current packet data to the given buffer.
var buf = argument0;
var size = steam_net_packet_get_size();
if (buffer_get_size(buf) < size) buffer_resize(buf, size);
var addr = buffer_get_address(buf);
return steam_net_packet_get_data_raw(addr);

#define steam_net_packet_send
/// steam_net_packet_send(steam_id, buffer, size, type) : Sends a packet to the given destination.
var steam_id = argument0;
var addr = buffer_get_address(argument1);
var size = argument2;
steam_net_packet_set_type(argument3);
return steam_net_packet_send_raw(steam_id_get_high(steam_id), steam_id_get_low(steam_id), addr, size);
//}
//{ Lobby

#define steam_lobby_join_id
/// steam_lobby_join_id(lobby_id)->ok? : Joins the given lobby
var lobby_id = argument0;
return steam_lobby_join_id_raw(steam_id_get_high(lobby_id), steam_id_get_low(lobby_id));

#define steam_lobby_get_lobby_id
/// steam_lobby_get_lobby_id()->lobby_id : Returns the lobby ID of the current lobby
return steam_id_create(steam_lobby_get_lobby_id_high(), steam_lobby_get_lobby_id_low());

#define steam_lobby_get_owner_id
/// steam_lobby_get_owner_id()->user_id : Returns the user ID of the authoritative user in the lobby.
return steam_id_create(steam_lobby_get_owner_id_high(), steam_lobby_get_owner_id_low());

#define steam_lobby_get_member_id
/// steam_lobby_get_member_id(index)->user_id : Returns the user ID of the given user in the lobby.
var i = argument0;
return steam_id_create(steam_lobby_get_member_id_high(i), steam_lobby_get_member_id_low(i));

#define steam_lobby_list_get_lobby_id
/// steam_lobby_list_get_lobby_id(index)->lobby_id : Returns the ID of the given lobby.
var i = argument0;
return steam_id_create(steam_lobby_list_get_lobby_id_high(i), steam_lobby_list_get_lobby_id_low(i));

#define steam_lobby_list_get_lobby_owner_id
/// steam_lobby_list_get_lobby_owner_id(index)->user_id : Returns the user ID of the owner of the given lobby.
var i = argument0;
return steam_id_create(steam_lobby_list_get_lobby_owner_id_high(i), steam_lobby_list_get_lobby_owner_id_low(i));

#define steam_lobby_list_get_lobby_member_id
/// steam_lobby_list_get_lobby_owner_id(lobby_index, member_index)->user_id : Returns the user ID of the given member of the given lobby.
var i = argument0, k = argument1;
return steam_id_create(steam_lobby_list_get_lobby_member_id_high(i, k), steam_lobby_list_get_lobby_member_id_low(i, k));
//}

#define steam_gml_prepare_buffer
/// steam_gml_prepare_buffer(min_size)->buffer~
var b = global.g_steam_net_buffer;
if (b < 0) {
	b = buffer_create(argument0, buffer_grow, 1);
	global.g_steam_net_buffer = b;
} else if (buffer_get_size(b) < argument0) {
	buffer_resize(b, argument0);
}
buffer_seek(b, buffer_seek_start, 0);
return b;
//{ Controller

#define steam_controller_get_max_count
/// steam_controller_get_max_count()->int: Returns the maximum number of controllers
var n = global.g_steam_controller_get_max_count;
if (n < 0) {
	n = steam_controller_get_max_count_raw();
	global.g_steam_controller_get_max_count = n;
}
return n;

#define steam_controller_get_ids
/// steam_controller_get_ids(?out:array<index>)->array
var b = steam_gml_prepare_buffer(steam_controller_get_max_count() * 4);
var n = steam_controller_get_ids_raw(buffer_get_address(b));
var w, r;
if (argument_count > 0) {
	w = argument[1]; r = n;
} else {
	w = array_create(n); r = w;
}
for (var i = 0; i < n; i++) {
	w[@i] = buffer_read(b, buffer_s32);
}
return r;

#define steam_controller_get_max_origins
/// steam_controller_get_max_origins()->int
var n = global.g_steam_controller_get_max_origins;
if (n < 0) {
	n = steam_controller_get_max_origins_raw();
	global.g_steam_controller_get_max_origins = n;
}
return n;

#define steam_controller_get_origins_raw
/// steam_controller_get_origins_raw(found, buffer, out)->array
var n = argument0;
var b = argument1;
var w = argument2;
if (!is_array(w)) {
    w = array_create(n); r = w;
} else r = n;
for (var i = 0; i < n; i++) {
	w[@i] = buffer_read(b, buffer_s32);
}
return r;

#define steam_controller_get_digital_origins
/// steam_controller_get_digital_origins(controller, actionset_id, digital_id, ?out:array<origin>): as per GetDigitalActionOrigins
var b = steam_gml_prepare_buffer(steam_controller_get_max_origins() * 4);
var n = steam_controller_get_digital_origins_raw(argument[0], argument[1], argument[2], buffer_get_address(b));
var w; if (argument_count > 3) w = argument[3]; else w = undefined;
return steam_controller_get_origins_raw(n, b, w);

#define steam_controller_get_analog_origins
/// steam_controller_get_digital_origins(controller, actionset_id, analog_id, ?out:array<origin>): as per GetDigitalActionOrigins
var b = steam_gml_prepare_buffer(steam_controller_get_max_origins() * 4);
var n = steam_controller_get_analog_origins_raw(argument[0], argument[1], argument[2], buffer_get_address(b));
var w; if (argument_count > 3) w = argument[3]; else w = undefined;
return steam_controller_get_origins_raw(n, b, w);

#define steam_controller_get_analog_x
/// steam_controller_get_analog_x(controller, analog_id)->number: (-1..1) for sticks, delta for mouse
return steam_controller_get_analog_data(argument0, argument1, 2);

#define steam_controller_get_analog_y
/// steam_controller_get_analog_y(controller, analog_id)->number: (-1..1) for sticks, delta for mouse
return steam_controller_get_analog_data(argument0, argument1, 3);

#define steam_controller_get_analog_mode
/// steam_controller_get_analog_mode(controller, analog_id)->EControllerSourceMode
return steam_controller_get_analog_data(argument0, argument1, 1);

#define steam_controller_get_analog_status
/// steam_controller_get_analog_status(controller, analog_id)->bool
return steam_controller_get_analog_data(argument0, argument1, 0);
//}

#define steam_get_friends_game_info
/// ()->array<[user_id, game_id, lobby_id]>
var n = steam_get_friends_game_info_1();
var b = steam_gml_prepare_buffer(n * (8 * 3));
steam_get_friends_game_info_2(buffer_get_address(b));
var r = array_create(n);
for (var i = 0; i < n; i++) {
	var l_user_id = buffer_read(b, buffer_u64);
	var l_game_id = buffer_read(b, buffer_u64);
	var l_lobby_id = buffer_read(b, buffer_u64);
	r[i] = [l_user_id, l_game_id, l_lobby_id];
}
return r;

#define steam_get_app_ownership_ticket_data
/// (buffer, ?app_id)->[size_total, ofs_app_id, ofs_steam_id, ofs_signature, size_signature]
var l_buf = argument[0];
var l_app_id = argument_count > 1 ? argument[1] : steam_get_app_id();
var b = steam_gml_prepare_buffer(4 * 5);
buffer_seek(b, 0, 0);
buffer_write(b, buffer_u32, l_app_id);
buffer_write(b, buffer_u32, buffer_get_size(l_buf));
steam_get_app_ownership_ticket_data_raw(buffer_get_address(l_buf), buffer_get_address(b));
buffer_seek(b, 0, 0);
var r = array_create(5);
for (var i = 0; i < 5; i++) {
	r[i] = buffer_read(b, buffer_u32);
}
return r;

#define steam_user_request_encrypted_app_ticket
/// (?bufferOrStringToInclude, ?bufferToIncludeSize)
var l_data = argument_count > 0 ? argument[0] : undefined;
var l_size = argument_count > 1 ? argument[1] : undefined;
if (l_data == undefined) {
	l_data = "";
	l_size = 0;
} else if (is_string(l_data)) {
	if (l_size == undefined) l_size = string_byte_length(l_data);
} else {
	if (l_size == undefined) l_size = buffer_get_size(l_data);
	l_data = buffer_get_address(l_data);
}
return steam_user_request_encrypted_app_ticket_raw(l_data, l_size);

#define steam_gml_init_gml
/// steam_gml_init_gml()
/// steam_gml_initialized = global.g_steam_gml_initialized : Whether the extension is initialized.
/// steam_net_initialized = global.g_steam_gml_initialized
global.g_steam_net_buffer = -1;
global.g_steam_controller_get_max_count = -1;
global.g_steam_controller_get_max_origins = -1;
var app_id = steam_get_app_id();
show_debug_message("Initializing steamworks.gml with app_id " + string(app_id) + "...");
//
var r = 0;
if (steam_gml_is_available()) {
	r = steam_gml_init_cpp(app_id) > 0;
	if (!r) show_debug_message("Failed to initialize steamworks.gml.");
} else show_debug_message("Steamworks.gml binary is not loaded.");
global.g_steam_gml_initialized = r;
if (!r) return 0;
// parse:
var n = parameter_count();
for (var i = 0; i < n; i += 1) {
	var s = parameter_string(i);
	if (s == "+connect_lobby") {
		s = parameter_string(++i);
		var lobby_id_high = int64_from_string_high(s);
		var lobby_id_low = int64_from_string_low(s);
		steam_lobby_join_id_raw(lobby_id_high, lobby_id_low);
		break;
	}
}
// Legacy scripts:

#define steam_net_is_available
/// steam_net_is_available()->bool
return steam_gml_is_available();

#define steam_net_update
/// steam_net_update()->bool
return steam_gml_update();

#define steam_net_check_version
return steam_gml_check_version();

