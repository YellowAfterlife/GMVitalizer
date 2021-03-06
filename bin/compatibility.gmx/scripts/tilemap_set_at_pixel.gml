/// tilemap_set_at_pixel(tilemap_element_id, tiledata, x, y)
if (argument0) with (argument0) {
	var l_ts/*:gmv_tileset_t*/ = tileSet;
	if (!is_array(l_ts)) return -1;
	//
	var l_tw = l_ts[gmv_tileset_t.tileWidth];
	var l_x = 0|((argument2 - x) / l_tw);
	if (l_x < 0 || l_x >= tileCols) return -1;
	//
	var l_th = l_ts[gmv_tileset_t.tileHeight];
	var l_y = 0|((argument3 - y) / l_th);
	if (l_y < 0 || l_y >= tileRows) return -1;
	//
	var l_tile = tile_layer_find(depth, argument2, argument3);
	//
	var l_td = argument1;
	var l_tk = l_td & gmv_tile.maskIndex;
	var l_tcount = l_ts[gmv_tileset_t.tileCount];
	//
	var l_anim_1;
	if (l_ts[gmv_tileset_t.tilesetHasAnim]) {
		var l_tileIsAnimated = l_ts[gmv_tileset_t.tileIsAnimated];
		l_anim_1 = l_tileIsAnimated[l_tk];
		if (l_tile) {
			var l_tk_old = (tile_get_left(l_tile) - l_ts[gmv_tileset_t.tileSepX]) div l_ts[gmv_tileset_t.tileMulX]
				+ ((tile_get_top(l_tile) - l_ts[gmv_tileset_t.tileSepY]) div l_ts[gmv_tileset_t.tileMulY]) * l_ts[gmv_tileset_t.tileCols];
			if (l_tk_old < 0 || l_tk_old >= l_tcount) l_tk_old = 0;
			//
			var l_anim_0 = l_tileIsAnimated[l_tk_old];
			if (l_anim_0) {
				if (!l_anim_1) {
					var l_anim_ind = ds_list_find_index(tileAnimList, l_tile);
					if (l_anim_ind >= 0) ds_list_delete(tileAnimList, l_anim_ind);
				}
			} else if (l_anim_1) {
				ds_list_add(tileAnimList, l_tile);
			}
		} else {
			l_tk_old = 0;
		}
	} else l_anim_1 = false;
	//
	if (l_tk != 0) {
		//
		var l_tc = l_ts[gmv_tileset_t.tileCols];
		var l_tl = l_ts[gmv_tileset_t.tileSepX] + (l_tk mod l_tc) * l_ts[gmv_tileset_t.tileMulX];
		var l_tt = l_ts[gmv_tileset_t.tileSepY] + (l_tk div l_tc) * l_ts[gmv_tileset_t.tileMulY];
		var l_tx = x + l_x * l_tw;
		var l_ty = y + l_y * l_th;
		var l_zx = (l_td & gmv_tile.maskMirror) != 0;
		var l_zy = (l_td & gmv_tile.maskFlip) != 0;
		if (l_zx) l_tx += l_tw;
		if (l_zy) l_ty += l_th;
		//
		if (l_tile < 0) {
			// new tile
			l_tile = tile_add(l_ts[gmv_tileset_t.tileBack], l_tl, l_tt, l_tw, l_th, l_tx, l_ty, depth);
			if (l_anim_1) ds_list_add(tileAnimList, l_tile);
		} else {
			// mod tile
			tile_set_region(l_tile, l_tl, l_tt, l_tw, l_th);
			tile_set_position(l_tile, l_tx, l_ty);
		}
		tile_set_scale(l_tile, 1 - l_zx * 2, 1 - l_zy * 2);
	} else if (l_tile >= 0) {
		// a tile but we don't want it
		tile_delete(l_tile);
	}
	//
	return true;
}
return false;
