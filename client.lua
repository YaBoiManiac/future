

function draw2dText(text, coords)
	SetTextFont(4)
	SetTextProportional(1)
	SetTextScale(0.6, 0.6)
	SetTextColour(255, 255, 255, 255)
	SetTextDropShadow(0, 0, 0, 0, 255)
	SetTextEdge(1, 0, 0, 0, 255)
	SetTextDropShadow()
	SetTextOutline()
	SetTextEntry('STRING')
	AddTextComponentString(text)
	DrawText(table.unpack(coords))
end

function drawRct(x,y,width,height,r,g,b,a)
	DrawRect(x + width/2, y + height/2, width, height, r, g, b, a)
end

-------- Main Script
local time_charge = 0
local landing_pos = nil
local boost_time = 0
local cooldown = 0

local effects_f = {}
local effects_r = {}

function CalculateLandingPosition()
	local pos = GetBlipInfoIdCoord(GetFirstBlipInfoId(8))
	local ukn = nil
	local z = 0.0 
	local found = false
	for i = 800, 0, - 1 do
		RequestCollisionAtCoord(pos.x, pos.y, i + 0.0)
		found, z =  GetGroundZFor_3dCoord(pos.x, pos.y, i + 0.0, 0)
		if (found) then
			break
		end
	end
	landing_pos = {x = pos.x, y = pos.y, z = z}
end

function GotoLandingPosition(veh, speed)
	cooldown = 1000
	boosting = false
	PlaySoundFrontend(-1, "SCREEN_FLASH", "CELEBRATION_SOUNDSET", true)
	SetEntityCoords(veh, landing_pos.x, landing_pos.y, landing_pos.z, 0.0, 0.0, 0.0, true)
	SetVehicleForwardSpeed(veh, speed)
	StopScreenEffect("RaceTurbo")
end

function CreateFireEffects(veh)
	Citizen.CreateThread(function()
		while boost_time > 0 do
		    for i=1, 60 do
		        Wait(20)
		        local wheelf = GetWorldPositionOfEntityBone(veh, GetEntityBoneIndexByName(veh, "wheel_rf"))
		        local wheelr = GetWorldPositionOfEntityBone(veh, GetEntityBoneIndexByName(veh, "wheel_lf"))

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
		    end
			Wait(1)
		end
	end)
end

function StartBoost(veh)
	local speed = GetEntitySpeed(veh)
	boost_time = 300
	PlaySoundFrontend(-1, "OOB_Start", "GTAO_FM_Events_Soundset", true)
	CalculateLandingPosition(veh)
	CreateFireEffects(veh)

	PlaySoundFrontend(-1, "Power_Down", "DLC_HEIST_HACKING_SNAKE_SOUNDS", true)
	while boost_time > 0 do
		speed = speed + 0.1
		boost_time = boost_time - 1
		SetVehicleForwardSpeed(veh, speed)
		SetVehicleOnGroundProperly(veh)
		StartScreenEffect("RaceTurbo", 0, true)
		Wait(1)
	end

	GotoLandingPosition(veh, GetEntitySpeed(veh))
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
    	local veh = GetVehiclePedIsIn(PlayerPedId(), false)
        if (GetEntityModel(veh) == GetHashKey("deluxo")) then

        	-- silly UI
        	drawRct(0.01, 0.4, 0.027, 0.25, 0, 0, 0, 150)
        	drawRct(0.012, 0.402, 0.01, (0.245/500)*time_charge, 0, 0, 250, 150)
        	drawRct(0.025, 0.402, 0.01, (0.245/1000)*cooldown, 150, 0, 0, 150)

        	if (not boosting and time_charge >= 500) then
            	draw2dText("~r~[PRESS ENTER]", { 0.47, 0.8 } )
            	if (IsControlJustPressed(1, 191)) then
            		boosting = true
            		StartBoost(veh)
            	end
            end

            if (GetEntitySpeed(veh)*2.23694 >= 88.0 and cooldown <= 0) then
            	if (time_charge < 500) then
                	time_charge = time_charge + 1
                end
            elseif (time_charge > 0) then
            	time_charge = time_charge - 1
            end

            if (cooldown > 0) then
            	cooldown = cooldown - 1
            end

        end
    end
end)

RegisterCommand("clearfire", function(source, args)
	for i=1, 60 do
        if effects_f[i] then
            StopParticleFxLooped(effects_f[i])
        end

        if (effects_r[i]) then
            StopParticleFxLooped(effects_r[i])
        end
	end
end)