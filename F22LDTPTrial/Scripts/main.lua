-- F22LDTPTrial 0.4.6: native mount calibration and aircraft-switch safety, offline only.
-- Stock tanks retain visibility flags, collision, attachment and jettison logic.
local folder=debug.getinfo(1,"S").source:match("^@?(.*)[\\/][Ss]cripts[\\/]") or "."
local Geometry=dofile(folder.."/Scripts/geometry.lua")
local Config=dofile(folder.."/Settings.lua")
local Materials=dofile(folder.."/Scripts/material.lua")
local Mounts=dofile(folder.."/Scripts/mounts.lua")
local M={records={},pending={},ticks=0,failed=false}
local Classes={}
local MAX_PENDING,MAX_RECORDS,MAX_ATTEMPTS=64,32,12
local function valid(o)
    local ok,v=pcall(function()
        return o~=nil and o:IsValid() and not o:HasAnyFlags(0x00018000)
    end)
    return ok and v==true
end
local function read(fn) local ok,v=pcall(fn);if ok then return v end end
local function name(o) return read(function() return o:GetFullName() end) or "" end
local function address(o) return read(function() return o:GetAddress() end) end
local function log(text)
    print("[F22LDTPTrial] "..text.."\n")
    local f=io.open(folder.."/trial.log","a");if f then f:write(os.date("%H:%M:%S ")..text.."\n");f:close() end
end
-- Resolve permanent engine objects once at startup. Do not walk the global object
-- array for classes or assets during aircraft preview destruction/recreation.
function M.initialize()
    if Classes.ready then return true end
    Classes.proc=StaticFindObject("/Script/ProceduralMeshComponent.ProceduralMeshComponent")
    Classes.system=StaticFindObject("/Script/Engine.Default__KismetSystemLibrary")
    assert(valid(Classes.proc) and valid(Classes.system),"Permanent engine dependencies unavailable; stock tanks preserved")
    assert(name(Classes.proc)=="Class /Script/ProceduralMeshComponent.ProceduralMeshComponent",
        "Procedural class identity differs; stock tanks preserved")
    Materials.initialize(Classes.system)
    Classes.ready=true
    return true
end
local function liveOwner(source)
    local owner=valid(source) and read(function() return source:GetOwner() end)
    if not valid(owner) then return nil end
    local ok,dying=pcall(function() return owner:IsActorBeingDestroyed() end)
    if not ok or dying~=false then return nil end
    return owner
end
local function offline(source)
    local owner=liveOwner(source)
    local world=valid(owner) and read(function() return owner:GetWorld() end)
    if not valid(world) then return false end
    -- A failure reading the network state is not permission to modify the world.
    local ok,driver=pcall(function() return world.NetDriver end)
    return ok and not valid(driver)
end
-- Explicit native asset identities, inspected with the existing community tools.
-- Keep the package/folder identity for compatibility with existing launcher choices.
local aircraft={
    {code="f22a",mesh="sm_pp0005_f22a_dptk1"},
    {code="fa36",mesh="sm_pp0018_fa36_dptk1"},
    {code="ea36",mesh="sm_pp0019_ea36_dptk1"},
}
local function target(source)
    if not valid(source) then return false end
    local full=name(source):lower()
    if full:find("default__",1,true) or full:find("archetype",1,true) then return false end
    for _,entry in ipairs(aircraft) do
        if full:find("_"..entry.code.."_",1,true) then return entry end
    end
    return false
end
local function candidate(source)
    local entry=target(source)
    if not entry then return false end
    local mesh=read(function() return source.StaticMesh end)
    if not valid(mesh) then return false end
    local model=name(mesh):lower():match("([^%./]+)$")
    -- Excludes the aircraft, weapon pods, missiles and the combined stock pylon mesh.
    return model==entry.mesh
end
local renderFlags={"bRenderInMainPass","bRenderInDepthPass","CastShadow","bVisibleInRayTracing","bVisibleInReflectionCaptures","bVisibleInRealTimeSkyCaptures"}
local function snapshot(source)
    local flags={};for _,key in ipairs(renderFlags) do local value=read(function() return source[key] end);if type(value)=="boolean" then flags[key]=value end end
    assert(flags.bRenderInMainPass~=nil,"Render flag unavailable; stock tank preserved")
    return flags
end
local function ownsSource(record)
    local owner=liveOwner(record.source)
    return owner and address(owner)==record.owner_id and name(owner)==record.owner_name and
        name(record.source)==record.source_name and
        name(read(function() return record.source.StaticMesh end))==record.mesh_name
end
local function restore(record)
    if ownsSource(record) then
        -- Set the main-pass flag through its native setter AFTER the other flags.
        -- Writing it directly first makes the setter skip render-state invalidation.
        local changed=false
        for key,value in pairs(record.flags) do if key~="bRenderInMainPass" then
            pcall(function() if record.source[key]~=value then record.source[key]=value;changed=true end end)
        end end
        if changed and read(function() return record.source.bRenderInMainPass end)==record.flags.bRenderInMainPass then
            pcall(function() record.source:SetRenderInMainPass(not record.flags.bRenderInMainPass) end)
        end
        pcall(function() record.source:SetRenderInMainPass(record.flags.bRenderInMainPass) end)
    end
    -- An actor already in native teardown owns destruction of its components.
    if valid(record.visual) and valid(record.owner) and
        read(function() return record.owner:IsActorBeingDestroyed() end)==false then
        pcall(function() record.visual:K2_DestroyComponent(record.visual) end)
    end
end
local function suppressStock(record)
    local source=record.source;local drift=false
    for key in pairs(record.flags) do if source[key]~=false then drift=true;break end end
    if drift then
        assert(ownsSource(record),"Stock component identity changed; replacement retired")
        local mainWasHidden=source.bRenderInMainPass==false
        for key in pairs(record.flags) do if key~="bRenderInMainPass" then source[key]=false end end
        -- A restart can restore native render flags after our original setup.
        -- Reuse the proven native setter only when flags drift. If only a secondary
        -- flag changed, toggle within this game-thread callback to dirty the proxy;
        -- the final main-pass state is false before the callback returns.
        if mainWasHidden then source:SetRenderInMainPass(true) end
        source:SetRenderInMainPass(false)
        for key in pairs(record.flags) do assert(source[key]==false,"Could not suppress stock render flag: "..key) end
        if record.suppressed then
            record.rehide_count=(record.rehide_count or 0)+1
            if record.rehide_count<=2 then log("STOCK_REHIDDEN after native render reset "..record.source_name) end
        end
    end
    record.suppressed=true
end
local function bounds(component)
    local lo,hi={},{};component:GetLocalBounds(lo,hi)
    assert(type(lo.X)=="number" and type(hi.X)=="number","Local bounds unavailable")
    return lo,hi
end
local function sync(record)
    local source,visual=record.source,record.visual
    if not valid(source) or not valid(visual) then return false end
    if not ownsSource(record) then return false end
    if not offline(source) then return false end
    suppressStock(record)
    local show=source:IsVisible()==true and source.bHiddenInGame~=true
    local owner=source:GetOwner()
    if valid(owner) and read(function() return owner.bHidden end)==true then show=false end
    if record.show~=show then visual:SetVisibility(show,false);visual:SetHiddenInGame(not show,false);record.show=show end
    return true
end
local function syncAll()
    local retired=false
    for id,record in pairs(M.records) do
        local ok,yes=pcall(sync,record)
        if not ok or not yes then restore(record);M.records[id]=nil;retired=true end
    end
    -- Drop Lua wrappers without probing dead material/texture objects after the
    -- last native owner disappears. New aircraft resolve dependencies natively.
    if retired and next(M.records)==nil then Materials.invalidate() end
end
local function released(source)
    local entry=target(source)
    return entry and name(source):lower():find(".bp_"..entry.code.."_dptk_01_c_",1,true)~=nil or false
end
function M.apply(source,allowLoad)
    if not candidate(source) or not offline(source) then return false end
    local id=address(source);if not id or M.records[id] then return false end
    local count=0;for _ in pairs(M.records) do count=count+1 end;if count>=MAX_RECORDS then return false end
    -- Resolve a cold/unloaded dependency BEFORE allocating or uploading mesh.
    local started=os.clock()
    assert(Classes.ready and valid(Classes.proc) and valid(Classes.system),"Permanent engine dependencies unavailable; stock tank preserved")
    local owner=liveOwner(source);if not owner then return false end
    local ownerId,ownerName=address(owner),name(owner)
    local sourceName,meshName=name(source),name(source.StaticMesh)
    local surface=Materials.prepare(log,Config.lod,allowLoad~=false)
    local prepared=os.clock()
    -- A blocking native dependency load can pump engine work. Recheck identities
    -- before touching a source that may have disappeared while it was loading.
    if not candidate(source) or not offline(source) or address(liveOwner(source))~=ownerId or
        name(liveOwner(source))~=ownerName or name(source)~=sourceName or name(source.StaticMesh)~=meshName then return false end
    local lo,hi=bounds(source)
    local fit,profile=Mounts.resolve(target(source).code,lo,hi,Config)
    local data=Geometry.build(lo,hi,fit)
    local built=os.clock()
    log(string.format("CALIBRATION mesh=%s localBounds=(%.3f,%.3f,%.3f)-(%.3f,%.3f,%.3f) LOD=%d scale=%.4f yaw=%d; local +X nose/+Z up, fixed asset size",name(source.StaticMesh),lo.X,lo.Y,lo.Z,hi.X,hi.Y,hi.Z,Config.lod,Config.uniform_scale,Config.yaw_degrees))
    log(string.format("MOUNT profile=%s offset_cm=(%.3f,%.3f,%.3f)",profile,fit.offset_cm.X,fit.offset_cm.Y,fit.offset_cm.Z))
    pcall(function()
        local p,r,s=source.RelativeLocation,source.RelativeRotation,source.RelativeScale3D
        log(string.format("ATTACHMENT location=(%.3f,%.3f,%.3f) rotation=(%.3f,%.3f,%.3f) scale=(%.4f,%.4f,%.4f) parent=%s",p.X,p.Y,p.Z,r.Pitch,r.Yaw,r.Roll,s.X,s.Y,s.Z,name(source:GetAttachParent())))
    end)
    local record={source=source,source_name=sourceName,mesh_name=meshName,owner=owner,owner_id=ownerId,owner_name=ownerName,flags=snapshot(source)}
    local ok,err=pcall(function()
        local identity={Rotation={X=0,Y=0,Z=0,W=1},Translation={X=0,Y=0,Z=0},Scale3D={X=1,Y=1,Z=1}}
        local visual=owner:AddComponentByClass(Classes.proc,true,identity,false);record.visual=visual
        assert(valid(visual),"Could not create procedural component")
        visual:SetVisibility(false,false);visual:SetHiddenInGame(true,false)
        assert(visual:K2_AttachToComponent(source,FName("None"),2,2,2,false)~=false,"Could not attach replacement")
        visual:SetCollisionEnabled(0);visual:SetCastShadow(record.flags.CastShadow==true)
        -- Reflected UE5 signature includes UV1/UV2/UV3 and sRGB conversion.
        local made,why=pcall(function()
            for index,part in ipairs(data.sections)do
                visual:CreateMeshSection_LinearColor(index-1,part.vertices,part.triangles,part.normals,part.uv,{},{},{},{},part.tangents,false,false)
            end
        end)
        if not made then error("Procedural mesh upload failed: "..tostring(why)) end
        assert(visual:GetNumSections()>0,"No mesh section created")
        local system=Classes.system
        assert(valid(system),"Bounds verification library unavailable")
        local origin,extent,radius={},{},{}
        system:GetComponentBounds(visual,origin,extent,radius)
        assert(type(extent.X)=="number" and type(extent.Y)=="number" and type(extent.Z)=="number" and
            math.max(extent.X,extent.Y,extent.Z)>25,"Mesh upload produced empty geometry")
        record.material,record.material_status=Materials.assign(visual,source,folder,Config.lod,Config.material,log,surface)
        -- Only change rendering after replacement geometry and material are ready.
        assert(sync(record),"World changed during replacement")
    end)
    if not ok then restore(record);error(err) end
    M.records[id]=record
    local triangleCount=0;for _,part in ipairs(data.sections)do triangleCount=triangleCount+#part.triangles/3 end
    log("APPLIED art=0.5.1 runtime=0.4.6 "..name(source).."; "..triangleCount .." triangles in two paint sections, one tank/pylon assembly; stock hardpoint retained pending wing fit; "..record.material_status)
    log(string.format("TIMING released=%s material_clock_ms=%.2f geometry_clock_ms=%.2f component_clock_ms=%.2f total_clock_ms=%.2f",tostring(released(source)),(prepared-started)*1000,(built-prepared)*1000,(os.clock()-built)*1000,(os.clock()-started)*1000))
    return true
end
function M.enqueue(source)
    if not target(source) then return end
    local id=address(source);if not id or M.pending[id] or M.records[id] then return end
    local n=0;for _ in pairs(M.pending) do n=n+1 end
    if n<MAX_PENDING then M.pending[id]={source=source,tries=0} end
end
function M.frame()
    if M.failed then return true end
    -- Native visibility can change on the jettison frame, not on our slow queue.
    syncAll()
    -- Released actors have their own physics component. Replace one ready actor
    -- per frame instead of exposing its stock mesh for 250-500ms. A failed fast
    -- attempt returns to the slow bounded retry queue; never retry loads/frame.
    for id,item in pairs(M.pending) do
        if not item.fastAttempted and released(item.source) and candidate(item.source) then
            item.fastAttempted=true
            local ok,applied=pcall(M.apply,item.source,false)
            if ok and applied then M.pending[id]=nil
            elseif not ok then log("RELEASE DEFERRED "..name(item.source)..": "..tostring(applied)) end
            break
        end
    end
end
function M.tick()
    if M.failed then return true end
    M.ticks=M.ticks+1
    -- Cached objects only. At most one tank component (two sections) per 250ms callback.
    syncAll()
    local uploads=0
    for id,item in pairs(M.pending) do
        if not valid(item.source) then M.pending[id]=nil
        elseif uploads<1 then
            item.tries=item.tries+1
            local isTank=candidate(item.source)
            if isTank then uploads=uploads+1 end
            local ok,applied=pcall(M.apply,item.source)
            if not ok then
                if tostring(applied):find("MATERIAL_PENDING",1,true) and item.tries<MAX_ATTEMPTS then
                    if item.tries==1 then log("WAITING "..name(item.source)..": game shader/texture load; stock retained during bounded retry")end
                else log("SKIPPED "..name(item.source)..": "..tostring(applied));M.pending[id]=nil end
            elseif applied then M.pending[id]=nil
            elseif item.tries>=MAX_ATTEMPTS then M.pending[id]=nil end
        end
    end
end
function M.shutdown()
    for id,record in pairs(M.records) do restore(record);M.records[id]=nil end
    M.pending={};M.failed=true
    Materials.invalidate()
end
if not _G.F22_LDTP_TEST then
    log("Loaded runtime 0.4.6, approved art 0.5.1. F-22 placement preserved; FA-36/EA-36 native crown calibration. Native material loading; F-35 deferred. Inspect wing clearance and repeated aircraft changes.")
    -- A single spawn notification plus one bootstrap. No recurring FindAllOf scans.
    NotifyOnNewObject("/Script/Engine.StaticMeshComponent",function(source)
        ExecuteInGameThread(function() if not M.failed then M.enqueue(source) end end)
    end)
    ExecuteInGameThread(function()
        local ok,err=pcall(M.initialize)
        if not ok then log("Stopped startup; stock preserved: "..tostring(err));M.shutdown();return end
        for _,source in ipairs(FindAllOf("StaticMeshComponent") or {}) do M.enqueue(source) end
    end)
    LoopInGameThreadWithDelay(250,function()
        local ok,err=pcall(M.tick)
        if not ok then log("Stopped; reverting modified visuals: "..tostring(err));M.shutdown();return true end
    end)
    LoopInGameThreadAfterFrames(1,function()
        local ok,err=pcall(M.frame)
        if not ok then log("Stopped frame handoff; reverting modified visuals: "..tostring(err));M.shutdown();return true end
        return M.failed
    end)
end
M.candidate=candidate
return M
