local timer = 0
local tpcoords = {x=1219.06, y = 1834.19, z = 78.96, h = 313.59, cam = 0.49}
local backtothefuture = false
local effects_f = {}
local effects_r = {}

function SetDeloreanCoords(veh, speed)
    SetEntityCoords(veh, tpcoords.x, tpcoords.y, tpcoords.z, 0.0, 0.0, 0.0, false)
    SetEntityHeading(veh, tpcoords.h)
    SetGameplayCamRelativeHeading(tpcoords.cam)
    SetVehicleForwardSpeed(veh, speed)
end

Citizen.CreateThread(function()
    if not HasNamedPtfxAssetLoaded("core") then
        RequestNamedPtfxAsset("core")
        while not HasNamedPtfxAssetLoaded("core") do
            Wait(10)
        end
    end
    while true do
        Wait(1)
        if (IsPedInAnyVehicle(PlayerPedId(), false)) then
            if (GetEntityModel(GetVehiclePedIsIn(PlayerPedId(), false)) == GetHashKey("deluxo")) then
                for i=1, 60 do
                    Wait(20)
                    local veh = GetVehiclePedIsIn(PlayerPedId(), true)
                    local wheelf = GetWorldPositionOfEntityBone(veh, GetEntityBoneIndexByName(veh, "wheel_rf"))
                    local wheelr = GetWorldPositionOfEntityBone(veh, GetEntityBoneIndexByName(veh, "wheel_lf"))

                    if (GetEntitySpeed(veh)*2.23694 >= 88.0 and not backtothefuture) then
                        timer = timer + 1
                        if effects_f[i] then
                            StopParticleFxLooped(effects_f[i])
                        end

                        if (effects_r[i]) then
                            StopParticleFxLooped(effects_r[i])
                        end

                        UseParticleFxAssetNextCall("core")
                        effects_f[i] = StartParticleFxLoopedAtCoord("fire_object", wheelf.x, wheelf.y, wheelf.z-0.4, 0.0, 0.0, 0.0, 1.5, false, false, false, false)
                        UseParticleFxAssetNextCall("core")
                        effects_r[i] = StartParticleFxLoopedAtCoord("fire_object", wheelr.x, wheelr.y, wheelr.z-0.4, 0.0, 0.0, 0.0, 1.5, false, false, false, false)
                        
                        if (timer > 100) then
                            StartScreenEffect("RaceTurbo", 0, true)
                            if (timer > 250) then
                                backtothefuture = true
                                SetDeloreanCoords(veh, GetEntitySpeed(veh))
                                timer = 0
                            end
                        else
                            StopScreenEffect("RaceTurbo")
                        end
                    else 
                        timer = 0
                        StopScreenEffect("RaceTurbo")
                    end
                end
            end
        end
    end
end)