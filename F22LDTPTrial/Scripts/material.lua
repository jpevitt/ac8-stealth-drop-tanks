-- Reuse the game's cooked shader. The payload contains textures only.
local M={cache={}}
local BASE='/Game/Base/Material/Vechicle/MP/MP_Live_Vehicle_Base_UDIM.MP_Live_Vehicle_Base_UDIM'
local function read(fn)local ok,v=pcall(fn);if ok then return v end end
local function valid(o)return read(function()return o~=nil and o:IsValid() and not o:HasAnyFlags(0x00018000)end)==true end
local function id(o)return read(function()return o:GetAddress()end)end
function M.initialize(system)
    assert(valid(system) and system:GetFullName()=="KismetSystemLibrary /Script/Engine.Default__KismetSystemLibrary",
        "Native asset-loading context unavailable; stock preserved")
    M.system=system
end
function M.invalidate()
    -- Lua userdata does not root engine assets. Never inspect dead cached wrappers
    -- while retiring a preview; live dynamic materials retain their dependencies.
    M.cache={}
end
local function load(path,log)
    local system=M.system
    assert(valid(system),'MATERIAL_PENDING native asset-loading context unavailable')
    log('MATERIAL NATIVE LOAD_BEGIN '..path)
    -- UE4SS global StaticFindObject/LoadAsset searches can walk invalid outer
    -- chains during aircraft swaps. Call the game's loader through its permanent
    -- Kismet default object; never fall back to a global search in this path.
    local ok,asset=pcall(function()
        local soft=system:MakeSoftObjectPath(path)
        return system:LoadAsset_Blocking(system:Conv_SoftObjPathToSoftObjRef(soft))
    end)
    if not ok or not valid(asset)then error('MATERIAL_PENDING native shader03 load unavailable: '..path)end
    local expected=path
    assert(asset:GetFullName():match('^[^ ]+ (.+)$')==expected,
        'Native asset identity differs; stock tank preserved: '..path)
    log('MATERIAL NATIVE LOADED '..path)
    return asset
end
function M.prepare(log,lod,allowLoad)
    assert(lod==0 or lod==1 or lod==2,'Invalid texture LOD')
    local bundle=M.cache[lod]
    if bundle and valid(bundle.base) and valid(bundle.C) and valid(bundle.MRX) and valid(bundle.NO)then return bundle end
    M.cache[lod]=nil
    if allowLoad==false then error('MATERIAL_PENDING native dependencies deferred to paced game-thread queue')end
    bundle={base=load(BASE,log)}
    assert(bundle.base.MaterialDomain==0 and bundle.base.BlendMode==0,'Game shader is not opaque Surface; stock tank preserved')
    assert(bundle.base:GetFullName():find('Material ',1,true)==1,'Expected an original base Material; stock tank preserved')
    for _,kind in ipairs({'C','MRX','NO'})do
        local name='T_F22Shader03_LOD'..lod..'_'..kind
        local texture=load('/Game/F22Shader03/Textures/'..name..'.'..name,log)
        assert(texture:GetFullName():find('Texture2D ',1,true)==1,'Unexpected texture class; stock tank preserved')
        assert(texture.VirtualTextureStreaming==true,'Shader requires virtual textures; stock tank preserved')
        assert(texture.SRGB==(kind=='C'),'Texture colour space differs; stock tank preserved')
        bundle[kind]=texture
    end
    M.cache[lod]=bundle
    return bundle
end
function M.assign(visual,source,folder,lod,config,log,bundle)
    bundle=bundle or M.prepare(log,lod)
    local mid=visual:CreateDynamicMaterialInstance(0,bundle.base,FName('F22Tank_Shader03_'..lod))
    assert(valid(mid),'Dynamic game material unavailable; stock tank preserved')
    for parameter,kind in pairs({Basecolor='C',Livemap='MRX',Normalmap='NO'})do
        local existing=mid:K2_GetTextureParameterValue(FName(parameter))
        assert(valid(existing),'Game texture parameter missing: '..parameter..'; stock tank preserved')
        mid:SetTextureParameterValue(FName(parameter),bundle[kind])
        assert(id(mid:K2_GetTextureParameterValue(FName(parameter)))==id(bundle[kind]),'Game texture assignment differs; stock tank preserved')
    end
    -- These names and defaults were read from the original game's cached expressions.
    -- Roughness stays a multiplier of one; the MRX map carries the authored finish.
    for parameter,value in pairs({Metallic=0,Roughness=1,NormalIntencity=1,AO_amoumt=1,
        DNormal_Strength=0,DamegedNormal_Intencity=0,Damage_Amount=0,Ctrl_All_Emissive=0})do
        mid:SetScalarParameterValue(FName(parameter),value)
        assert(math.abs(mid:K2_GetScalarParameterValue(FName(parameter))-value)<.0001,'Game scalar assignment differs; stock tank preserved')
    end
    local materials={}
    for slot=0,1 do
        visual:SetMaterial(slot,mid)
        assert(id(visual:GetMaterial(slot))==id(mid),'Game material slot assignment differs; stock tank preserved')
        materials[slot+1]=mid
    end
    log('MATERIAL SHADER03 game-cooked opaque vehicle shader; C/MRX/NO virtual textures; authored normal replaces stock atlas; zero metal/emissive; LOD='..lod)
    return materials,'shader03 original game shader + approved service details; manual acceptance pending'
end
return M
