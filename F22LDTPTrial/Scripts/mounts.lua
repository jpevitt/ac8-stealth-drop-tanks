-- Native crown coordinates measured with the existing CUE4Parse/FModel tooling.
-- The shared source model/UVs/normals are unchanged. Unreal centimetres, +X nose.
local M={}
local profiles={
    fa36={X=67.0482955,Y=0,Z=103.94396},
    ea36={X=67.0482955,Y=0,Z=103.94396},
}
local authoredCrown={X=-176.8,Y=0,Z=67.0}
function M.resolve(code,lo,hi,config)
    if code=="f22a" then return config,"f22a-accepted-center" end
    local anchor=profiles[code]
    assert(anchor,"Unsupported aircraft mount")
    assert(config.uniform_scale==1 and config.yaw_degrees==0 and config.align_stock_center==true,
        "Native crown profile requires the reviewed fixed-scale frame")
    -- Reject a different native asset/frame rather than applying a guessed fit.
    assert(math.abs((lo.X+hi.X)/2-215.18254)<1 and math.abs(hi.Z-102.94396)<1,
        "Native crown calibration differs; stock tank preserved")
    local fit={};for key,value in pairs(config) do fit[key]=value end
    local center={X=(lo.X+hi.X)/2,Y=(lo.Y+hi.Y)/2,Z=(lo.Z+hi.Z)/2}
    fit.offset_cm={}
    for _,axis in ipairs({"X","Y","Z"}) do
        fit.offset_cm[axis]=config.offset_cm[axis]+anchor[axis]-authoredCrown[axis]-center[axis]
    end
    return fit,code.."-native-crown-seat-1cm"
end
return M
