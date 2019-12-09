//{ views
remap __view_get( e__VW.XView, $1 ) -> view_xview[$1]
remap __view_get( e__VW.YView, $1 ) -> view_yview[$1]
remap __view_get( e__VW.HView, $1 ) -> view_hview[$1]
remap __view_get( e__VW.WView, $1 ) -> view_wview[$1]
remap __view_get( e__VW.Angle, $1 ) -> view_angle[$1]
remap __view_get( e__VW.HBorder, $1 ) -> view_hborder[$1]
remap __view_get( e__VW.VBorder, $1 ) -> view_vborder[$1]
remap __view_get( e__VW.HSpeed, $1 ) -> view_hspeed[$1]
remap __view_get( e__VW.VSpeed, $1 ) -> view_vspeed[$1]
remap __view_get( e__VW.Object, $1 ) -> view_object[$1]
remap __view_get( e__VW.Visible, $1 ) -> view_object[$1]
remap __view_get( e__VW.XView, $1 ) -> view_xview[$1]
remap __view_get( e__VW.YView, $1 ) -> view_yview[$1]
remap __view_get( e__VW.HView, $1 ) -> view_hview[$1]
remap __view_get( e__VW.WView, $1 ) -> view_wview[$1]
remap __view_get( e__VW.SurfaceID, $1 ) -> view_surface_id[$1]
//
remap __view_set( e__VW.XView, $1, $2 ) -> view_xview[$1] = $2
remap __view_set( e__VW.YView, $1, $2 ) -> view_yview[$1] = $2
remap __view_set( e__VW.HView, $1, $2 ) -> view_hview[$1] = $2
remap __view_set( e__VW.WView, $1, $2 ) -> view_wview[$1] = $2
remap __view_set( e__VW.Angle, $1, $2 ) -> view_angle[$1] = $2
remap __view_set( e__VW.HBorder, $1, $2 ) -> view_hborder[$1] = $2
remap __view_set( e__VW.VBorder, $1, $2 ) -> view_vborder[$1] = $2
remap __view_set( e__VW.HSpeed, $1, $2 ) -> view_hspeed[$1] = $2
remap __view_set( e__VW.VSpeed, $1, $2 ) -> view_vspeed[$1] = $2
remap __view_set( e__VW.Object, $1, $2 ) -> view_object[$1] = $2
remap __view_set( e__VW.Visible, $1, $2 ) -> view_object[$1] = $2
remap __view_set( e__VW.XView, $1, $2 ) -> view_xview[$1] = $2
remap __view_set( e__VW.YView, $1, $2 ) -> view_yview[$1] = $2
remap __view_set( e__VW.HView, $1, $2 ) -> view_hview[$1] = $2
remap __view_set( e__VW.WView, $1, $2 ) -> view_wview[$1] = $2
remap __view_set( e__VW.SurfaceID, $1, $2 ) -> view_surface_id[$1] = $2
//}

//{ gpu
remap gpu_set_fog -> d3d_set_fog
remap gpu_set_blendmode -> draw_set_blend_mode
remap gpu_set_blendmode_ext -> draw_set_blend_mode_ext
remap gpu_set_texrepeat -> texture_set_repeat
remap gpu_set_texrepeat_ext -> texture_set_repeat_ext
remap gpu_set_blendenable -> draw_enable_alphablend
remap gpu_set_colourwriteenable -> draw_set_colour_write_enable
remap gpu_set_colorwriteenable -> draw_set_color_write_enable
remap gpu_set_alphatestenable -> draw_set_alpha_test
//}

//{ instances
remap instance_destroy($1, $2) -> instance_destroy_ext($1, $2)
//}

//{ misc
remap string_hash_to_newline($1) -> $1
//}
