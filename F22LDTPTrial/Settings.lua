-- Integration prototype 0.4.6, approved art asset 0.5.1.
-- Source art is fixed scale; offsets are centimetres in the stock tank frame.
return {
    lod=0, uniform_scale=1.0, yaw_degrees=0,
    offset_cm={X=0,Y=0,Z=0},
    -- Initial calibration assumes stock local +X points forward and +Z up.
    -- Unexpected bounds are rejected, never used to stretch or rotate the art.
    expected_long_axis="X", align_stock_center=true,
    material={colors_srgb={{124,131,136},{88,95,100}}},
}
