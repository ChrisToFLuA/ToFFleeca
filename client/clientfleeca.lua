ESX = nil

local banks = {}
local bankszone2 = {}
local card = false
local thermal = false
local code = ko
local door = closed
local nextCoffre = 0

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
    Wait(500)
	while PlayerData == nil do
        PlayerData = ESX.GetPlayerData()
        Wait(10)
    end	

end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
end)

-- ** qtarget documentation : https://overextended.github.io/qtarget/model.html
-- ** ox_inventory documentation : https://overextended.github.io/docs
-- ** ox_lib documentation : https://overextended.github.io/docs

------------------------------------------------------------------------------
---------------------- launch menus depending on the job ---------------------
------------------------------------------------------------------------------

AddEventHandler('esx:onPlayerSpawn', function()
    Citizen.Wait(30000)
    Citizen.CreateThread(function()
        -- you can modify / add jobs here --
        local jobs = {
            {name = 'police'},          -- LSPD in service
            {name = 'offpolice'},       -- LSPD out of service
            {name = 'ambulance'},       -- EMS in service
            {name = 'offambulance'},    -- EMS out of service
        }
        for a = 1, #jobs, 1 do
            local jobsname = jobs[a].name
            if ESX.PlayerData.job.name ~= jobsname then     -- test on jobname
                TriggerEvent('toffleeca:menus')             -- call menu qtarget robbery
            else
                TriggerEvent('toffleeca:menuslspd')         -- call menu qtarget lspd
            end
        end
    end)
end)

------------------------------------------------------------------------------
---------------------------- menu qtarget LSPD -------------------------------
------------------------------------------------------------------------------
RegisterNetEvent('toffleeca:menuslspd')
AddEventHandler('toffleeca:menuslspd', function()

    Citizen.CreateThread(function()
        local bankslspd = {
            {zone = 'Bank1lspd', coordzone = vector3(-1210.8, -336.52, 36.78), long = 1.0, larg = 1.0, headingzone = 306.63, minz = 36.78, maxz = 39.78},    
            {zone = 'Bank2lspd', coordzone = vector3(-353.79, -55.35, 48.04), long = 1.0, larg = 1.0, headingzone = 237.18, minz = 48.04, maxz = 51.04},    
            {zone = 'Bank3lspd', coordzone = vector3(311.25, -284.45, 53.16), long = 1.0, larg = 1.0, headingzone = 246.87, minz = 53.16, maxz = 56.16},    
        }
    
        for w = 1, #bankslspd, 1 do
            local zonelspd = bankslspd[w].zone
            local coordlspd = bankslspd[w].coordzone
            local longlspd = bankslspd[w].long
            local larglspd = bankslspd[w].larg
            local minzlspd = bankslspd[w].minz
            local maxzlspd = bankslspd[w].maxz
            local headingzonelspd = bankslspd[w].headingzone
    
            exports.qtarget:AddBoxZone(zonelspd, coordlspd, longlspd, larglspd, {
                name=zonelspd,
                heading=headingzonelspd,
                debugPoly=false,
                minZ=minzlspd,  
                maxZ=maxzlspd,
                }, {
                    options = {
                        {
                            icon = "fas fa-sign-in-alt",
                            label = "Saisir Code",
                            action = function(entity)
                                TriggerServerEvent('toffleeca:opendoorlspd_s', coordlspd)
                            end,
                            job = 'police'
                        },			    
                    },
                    distance = 1
            })
        end    
    end)
end)
------------------------------------------------------------------------------
---------------------------- menu qtarget robbery ----------------------------
------------------------------------------------------------------------------

RegisterNetEvent('toffleeca:menus')
AddEventHandler('toffleeca:menus', function()

    Citizen.CreateThread(function()

    -------------------------------------------------------------------------------------------------------------------------
    -------------------------------------------- Hacking zones --------------------------------------------------------------
    -------------------------------------------------------------------------------------------------------------------------

    local banks = {
        {zone = 'Bank1', coordzone = vector3(-1210.8, -336.52, 36.78), long = 1.0, larg = 1.0, headingzone = 306.63, minz = 36.78, maxz = 39.78, coordtp = vector3(-1215.46, -337.27, 36.78)},    
        {zone = 'Bank2', coordzone = vector3(-353.79, -55.35, 48.04), long = 1.0, larg = 1.0, headingzone = 237.18, minz = 48.04, maxz = 51.04, coordtp = vector3(-357.89, -52.53, 48.04)},    
        {zone = 'Bank3', coordzone = vector3(311.25, -284.45, 53.16), long = 1.0, larg = 1.0, headingzone = 246.87, minz = 53.16, maxz = 56.16, coordtp = vector3(307.36, -281.31, 53.16)},    
    }

    for i = 1, #banks, 1 do -- start loop
        local zone = banks[i].zone
        local coord = banks[i].coordzone
        local long = banks[i].long
        local larg = banks[i].larg
        local minz = banks[i].minz
        local maxz = banks[i].maxz
        local coordtp = banks[i].coordtp
        local headingzone = banks[i].headingzone

        exports.qtarget:AddBoxZone(zone, coord, long, larg, {
	        name=zone,
	        heading=headingzone,
	        debugPoly=false,
	        minZ=minz,  
	        maxZ=maxz,
	        }, {
		        options = {
			        {
				        icon = "fas fa-sign-in-alt",
				        label = "Piratage", -- hacking (step one)
                        action = function(entity)
                            TriggerServerEvent('toffleeca:timers', coord) -- verify the cooldown
                        end,
		    	    },			    
		        },
		        distance = 1.5
        })

        exports.qtarget:AddTargetModel({2121050683}, {
	        options = {
		        {
			        icon = "fas fa-box-circle-check",
			        label = "Utiliser Thermite", -- use thermal charge on the door (step two)
                    action = function(entity)
                        local coordsearch = GetEntityCoords(PlayerPedId())
                        TriggerEvent('toffleeca:usethermalverif', entity, coordtp, coordsearch)
                    end,
		        },
	        },
	        distance = 2
        })
    
    end
    -------------------------------------------------------------------------
    ---------------------- create blips on map ------------------------------
    -------------------------------------------------------------------------
    for z = 1,#banks,1 do
      local blip = AddBlipForCoord(banks[z].coordzone)  
      SetBlipSprite(blip, 568)  -- change blip sprite ** https://docs.fivem.net/docs/game-references/blips/
      SetBlipScale(blip, 0.65)  -- change blip scale
      SetBlipColour(blip, 5)    -- change blip color
      SetBlipAsShortRange(blip, true)
  
      BeginTextCommandSetBlipName('STRING')
      AddTextComponentSubstringPlayerName('Coffre Banque') -- name of blip
      EndTextCommandSetBlipName(blip)
    end
    -------------------------------------------------------------------------------------------------------------------------
    -------------------------------------------- Room behind vault door -----------------------------------------------------
    -------------------------------------------------------------------------------------------------------------------------
    local bankszone2 = {
        {zone = 'Bank1 - zone2', coordzone = vector3(-1207.47, -333.71, 36.76), long = 2, larg = 1, headingzone = 294.27, minz = 36.76, maxz = 39.77},
        {zone = 'Bank1 - zone3', coordzone = vector3(-1209.71, -333.69, 36.76), long = 3, larg = 1, headingzone = 19.84, minz = 36.76, maxz = 39.77},
        {zone = 'Bank2 - zone2', coordzone = vector3(-349.52, -55.77, 48.01), long = 2, larg = 1, headingzone = 278.78, minz = 48.01, maxz = 51.01},
        {zone = 'Bank2 - zone3', coordzone = vector3(-351.02, -54.05, 48.01), long = 3, larg = 1, headingzone = 340.87, minz = 48.01, maxz = 51.01},
        {zone = 'Bank3 - zone2', coordzone = vector3(315.5, -284.82, 53.14), long = 2, larg = 1, headingzone = 246.94, minz = 53.14, maxz = 56.14},
        {zone = 'Bank3 - zone3', coordzone = vector3(314.2, -283.29, 53.14), long = 3, larg = 1, headingzone = 342.94, minz = 53.14, maxz = 56.14},
    }    

    for j = 1, #bankszone2, 1 do -- start loop

        exports.qtarget:AddBoxZone(bankszone2[j].zone, bankszone2[j].coordzone, bankszone2[j].long, bankszone2[j].larg, {
	        name=zone,
	        heading=bankszone2[j].headingzone,
	        debugPoly=false,
	        minZ=bankszone2[j].minz,  
	        maxZ=bankszone2[j].maxz,
	        }, {
		        options = {
			        {
				        icon = "fas fa-sign-in-alt",
				        label = "Forcer un coffre",
                        action = function(entity)
                            TriggerEvent('toffleeca:forcecoffre')
                        end,
			        },			    
		        },
		        distance = 1.5
        })        
    end -- end loop

    -------------------------------------------------------------------------------------------------------------------------
    -------------------------------------- force lock to access the second room ---------------------------------------------
    -------------------------------------------------------------------------------------------------------------------------
    
    exports.qtarget:AddTargetModel({-1591004109}, {
        options = {
            {
                icon = "fas fa-box-circle-check",
                label = "Forcer la serrure",
                action = function(entity)
                    local coordsearch2 = GetEntityCoords(PlayerPedId())
                    TriggerEvent('toffleeca:opendoor2_c', coordsearch2)
                end,
            },
        },
        distance = 2
    })

    -------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------- Second Room -----------------------------------------------------
    -------------------------------------------------------------------------------------------------------------------------

    local bankszone2 = {
        {zone = 'Bank1 - zone4', coordzone = vector3(-1205.42, -336.51, 36.76), long = 4, larg = 1, headingzone = 307.15, minz = 36.76, maxz = 39.77},
        {zone = 'Bank1 - zone5', coordzone = vector3(-1206.49, -338.84, 36.76), long = 4, larg = 1, headingzone = 195.65, minz = 36.76, maxz = 39.77},
        {zone = 'Bank2 - zone4', coordzone = vector3(-352.87, -59.84, 48.01), long = 4, larg = 1, headingzone = 154.85, minz = 48.01, maxz = 51.01},
        {zone = 'Bank2 - zone5', coordzone = vector3(-350.13, -59.18, 48.01), long = 4, larg = 1, headingzone = 250.83, minz = 48.01, maxz = 51.01},
    }

    for k = 1, #bankszone2, 1 do -- start loop

        exports.qtarget:AddBoxZone(bankszone2[k].zone, bankszone2[k].coordzone, bankszone2[k].long, bankszone2[k].larg, {
            name=zone,
            heading=bankszone2[k].headingzone,
            debugPoly=false,
            minZ=bankszone2[k].minz,  
            maxZ=bankszone2[k].maxz,
            }, {
                options = {
                    {
                        icon = "fas fa-sign-in-alt",
                        label = "Forcer coffre",
                        action = function(entity)
                            TriggerEvent('toffleeca:forcecoffre2')
                        end,
                    },			    
                },
                distance = 1.5
        })    
    end -- end loop

    end)
end)


    -------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------- anti spam loot-------------------------------------------------
    -------------------------------------------------------------------------------------------------------------------------

local function SetnextCoffre()
    nextCoffre = GetGameTimer() + 36000
end

---------------------------------------------------------------------------------------
---------------------------------- Doors Opening --------------------------------------
---------------------------------------------------------------------------------------

RegisterNetEvent("toffleeca:opendoorsearchlspd_c")
AddEventHandler("toffleeca:opendoorsearchlspd_c", function(coordsearch)
    local obj4 = GetClosestObjectOfType(coordsearch.x, coordsearch.y, coordsearch.z, 3.0, GetHashKey('v_ilev_gb_vauldr'), false, false, false)
    local obj5 = GetClosestObjectOfType(coordsearch.x, coordsearch.y, coordsearch.z, 4.0, GetHashKey('v_ilev_gb_vaubar'), false, false, false)
    FreezeEntityPosition(obj5, false)
    Citizen.Wait(5000)
    local count = 0
    repeat
        local heading = GetEntityHeading(obj4) - 0.05
        SetEntityHeading(obj4, heading)
        count = count + 10
        Citizen.Wait(100)
    until count == 14400
    Citizen.Wait(600000)
    TriggerServerEvent('toffleeca:closedoor_s', obj4)
end)

RegisterNetEvent("toffleeca:opendoorsearch_c")
AddEventHandler("toffleeca:opendoorsearch_c", function(coordsearch)
    local obj = GetClosestObjectOfType(coordsearch.x, coordsearch.y, coordsearch.z, 3.0, GetHashKey('v_ilev_gb_vauldr'), false, false, false)
    local obj2 = GetClosestObjectOfType(coordsearch.x, coordsearch.y, coordsearch.z, 4.0, GetHashKey('v_ilev_gb_vaubar'), false, false, false)
    FreezeEntityPosition(obj2, true)
    TriggerEvent('toffleeca:opendoor_c', obj)
end)

RegisterNetEvent("toffleeca:opendoor2_c")
AddEventHandler("toffleeca:opendoor2_c", function(coordsearch2)
    TaskStartScenarioInPlace(PlayerPedId(), 'WORLD_HUMAN_WELDING', 0, true)
	Wait(59000)
	ClearPedTasksImmediately(PlayerPedId())
    ------------------**notification**----------------------
    lib.showTextUI('Serrure forcée', {
        position = "top-center",
        icon = 'gun-squirt',
        style = {
            borderRadius = 0,
            backgroundColor = '#FF1300',
            color = 'white'
        }
    })
    Citizen.Wait(1500)
    lib.hideTextUI()
    ------------------**fin notification**-----------------
    TriggerServerEvent('toffleeca:opendoor2_s', coordsearch2)
end)

RegisterNetEvent("toffleeca:opendoor2all_c")
AddEventHandler("toffleeca:opendoor2all_c", function(coordsearch2)
    local obj3 = GetClosestObjectOfType(coordsearch2.x, coordsearch2.y, coordsearch2.z, 4.0, GetHashKey('v_ilev_gb_vaubar'), false, false, false)
    FreezeEntityPosition(obj3, false)
end)

RegisterNetEvent("toffleeca:opendoor_c")
AddEventHandler("toffleeca:opendoor_c", function(door)
    local count = 0
    repeat
        local heading = GetEntityHeading(door) - 0.05
        SetEntityHeading(door, heading)
        count = count + 10
        Citizen.Wait(100)
    until count == 14400
    Citizen.Wait(600000)
    TriggerServerEvent('toffleeca:closedoor_s', door)
end)

---------------------------------------------------------------------------------------
---------------------------------- Doors Closing --------------------------------------
---------------------------------------------------------------------------------------

RegisterNetEvent("toffleeca:closedoor_c")
AddEventHandler("toffleeca:closedoor_c", function(door)
        print('door '..door) 
        local count = 0
        repeat
            local heading = GetEntityHeading(door) + 0.05
            SetEntityHeading(door, heading)
            count = count + 10
            Citizen.Wait(100)
        until count == 14400
end)

-------------------- Step_1 --------------------------------------

RegisterNetEvent("toffleeca:usecard")
AddEventHandler("toffleeca:usecard", function()
    RequestModel("p_ld_id_card_01")
    while not HasModelLoaded("p_ld_id_card_01") do
        Citizen.Wait(1)
    end
    local ped = PlayerPedId()
    local pedco = GetEntityCoords(PlayerPedId())
    IdProp = CreateObject(GetHashKey("p_ld_id_card_01"), pedco, 1, 1, 0)
    local boneIndex = GetPedBoneIndex(PlayerPedId(), 28422)
    AttachEntityToEntity(IdProp, ped, boneIndex, 0.12, 0.028, 0.001, 10.0, 175.0, 0.0, true, true, false, true, 1, true)
    FreezeEntityPosition(ped, true)
    TaskStartScenarioInPlace(ped, "PROP_HUMAN_ATM", 0, true)
    Citizen.Wait(1500)
    DetachEntity(IdProp, false, false)
    DeleteEntity(IdProp)
    Citizen.Wait(45000)
    TriggerEvent("toffleeca:codechiffre")
    FreezeEntityPosition(ped, false)
    ClearPedTasks(ped)
    card = true
end)

RegisterNetEvent("toffleeca:codechiffre")
AddEventHandler("toffleeca:codechiffre", function()
    local input = lib.inputDialog('Code carte - Dernier Chiffre', {'Code Carte'})
    if input then
        local lockerNumber = tonumber(input[1])
    end
    ------------------**notification**----------------------
    lib.showTextUI('Code erronné - Utilisez les charges thermales', {
        position = "top-center",
        icon = 'gun-squirt',
        style = {
            borderRadius = 0,
            backgroundColor = '#FF1300',
            color = 'white'
        }
    })
    Citizen.Wait(5000)
    lib.hideTextUI()
    ------------------**fin notification**-----------------
end)

-------------------- Step_2 --------------------------------------

RegisterNetEvent("toffleeca:usethermalverif")
AddEventHandler("toffleeca:usethermalverif", function(entity, coordtp, coordsearch)
    if card == false then
        ------------------**notification**----------------------
        lib.showTextUI('Piratez d\'abord le terminal', {
            position = "top-center",
            icon = 'gun-squirt',
            style = {
                borderRadius = 0,
                backgroundColor = '#FF1300',
                color = 'white'
            }
        })
        Citizen.Wait(5000)
        lib.hideTextUI()
        ------------------**fin notification**-----------------
    end
    if card == true then
        TriggerServerEvent('toffleeca:thermal', entity, coordtp, coordsearch)
    end
end)


RegisterNetEvent("toffleeca:usethermal")
AddEventHandler("toffleeca:usethermal", function(entity, coordtp, coordsearch)
        thermal = true
        RequestAnimDict("anim@heists@ornate_bank@thermal_charge")
        RequestModel("hei_p_m_bag_var22_arm_s")
        RequestNamedPtfxAsset("scr_ornate_heist")
        while not HasAnimDictLoaded("anim@heists@ornate_bank@thermal_charge") and not HasModelLoaded("hei_p_m_bag_var22_arm_s") and not HasNamedPtfxAssetLoaded("scr_ornate_heist") do
            Citizen.Wait(50)
        end
        local ped = PlayerPedId()
        FreezeEntityPosition(ped, true)
        local x, y, z = table.unpack(GetEntityCoords(ped))
    ---------------------------------------- Thermal 1 -------------------------
        TaskStartScenarioInPlace(ped, "PROP_HUMAN_BUM_BIN", 0, 1)
        Citizen.Wait(7000)
        ClearPedTasks(ped)
        local bomba = CreateObject(GetHashKey("hei_prop_heist_thermite"), x, y, z + 0.2,  true,  true, true)
        SetEntityCollision(bomba, false, true)
        AttachEntityToEntity(bomba, entity, 15352, 0.9, 0.0, 0, 0.0, 90.0, 90.0, true, true, false, true, 1, true)
        FreezeEntityPosition(bomba, true)
    ---------------------------------------- Thermal 2 -------------------------
        TaskStartScenarioInPlace(ped, "PROP_HUMAN_BUM_BIN", 0, 1)
        Citizen.Wait(7000)
        ClearPedTasks(ped)
        local bomba2 = CreateObject(GetHashKey("hei_prop_heist_thermite"), x, y, z + 0.2,  true,  true, true)
        SetEntityCollision(bomba2, false, true)
        AttachEntityToEntity(bomba2, entity, 15352, 1.12, 0.0, 0.30, 0.0, 90.0, 90.0, true, true, false, true, 1, true)
        FreezeEntityPosition(bomba2, true)
        Citizen.Wait(1500)
    ---------------------------------------- TP Player -------------------------
        FreezeEntityPosition(ped, false)
        DoScreenFadeOut(2000)
        Citizen.Wait(2000)
        SetEntityCoords(ped, coordtp.x, coordtp.y, coordtp.z, true, false, false, false)
        Citizen.Wait(2000)
        DoScreenFadeIn(1000)
        Citizen.Wait(2000)
        TaskTurnPedToFaceEntity(ped, entity, -1)
        FreezeEntityPosition(ped, true)
        Citizen.Wait(1500)
    ---------------------------------------- Explosion Charges ---------------------
        local ptfx = GetEntityCoords(bomba)
        TriggerServerEvent('toffleeca:thermiteall_s', ptfx)
        TaskPlayAnim(ped, "anim@heists@ornate_bank@thermal_charge", "cover_eyes_intro", 8.0, 8.0, 20000, 36, 1, 0, 0, 0)
        TaskPlayAnim(ped, "anim@heists@ornate_bank@thermal_charge", "cover_eyes_loop", 8.0, 8.0, 20000, 49, 1, 0, 0, 0)
        Citizen.Wait(20000)
        DeleteEntity(bomba) ------ Delte charges
        DeleteEntity(bomba2) ------ Delete charges
    ---------------------------------------- Opening door -------------------------
        TriggerServerEvent("toffleeca:opendoor_s", coordsearch)
        ClearPedTasks(ped)
        FreezeEntityPosition(ped, false)
end)

RegisterNetEvent("toffleeca:thermiteall_c")
AddEventHandler("toffleeca:thermiteall_c", function(ptfx)
    SetPtfxAssetNextCall("scr_ornate_heist")
    local effect = StartParticleFxLoopedAtCoord("scr_heist_ornate_thermal_burn", ptfx.x - 0.15, ptfx.y + 4.90, ptfx.z - 0.11, 0.0, 0.0, 0.0, 5.1, false, false, false, false)
    Citizen.Wait(20000)
    StopParticleFxLooped(effect, 0) ------ stop particles
end)

-------------------------------------------------------------------------
----------------------- Loot zones --------------------------------------
-------------------------------------------------------------------------

RegisterNetEvent("toffleeca:forcecoffre")
AddEventHandler("toffleeca:forcecoffre", function(entity)
    if GetGameTimer() > nextCoffre then
    SetnextCoffre()
    TaskStartScenarioInPlace(PlayerPedId(), 'WORLD_HUMAN_WELDING', 0, true)
	Wait(25000)
	ClearPedTasksImmediately(PlayerPedId())
    ------------------**notification**----------------------
    lib.showTextUI('Coffre forcé', {
        position = "top-center",
        icon = 'gun-squirt',
        style = {
            borderRadius = 0,
            backgroundColor = '#FF1300',
            color = 'white'
        }
    })
    Citizen.Wait(1500)
    lib.hideTextUI()
    ------------------**fin notification**-----------------
    TaskStartScenarioInPlace(PlayerPedId(), "PROP_HUMAN_BUM_BIN", 0, 1)
    Citizen.Wait(10000)
    ClearPedTasksImmediately(PlayerPedId())
    local chance = math.random(1,20)
    TriggerServerEvent('toffleeca:loot_s', chance)
    else
        ------------------**notification**----------------------
        lib.showTextUI('Respire, ça n\'ira pas plus vite !', {
            position = "top-center",
            icon = 'gun-squirt',
            style = {
                borderRadius = 0,
                backgroundColor = '#FF1300',
                color = 'white'
            }
        })
        Citizen.Wait(1500)
        lib.hideTextUI()
        ------------------**fin notification**-----------------
    end
end)

--------------------------------------------------------------------------
-------------------------- msg loot --------------------------------------
--------------------------------------------------------------------------

RegisterNetEvent("toffleeca:noloot_c")
AddEventHandler("toffleeca:noloot_c", function()
    ------------------**notification**----------------------
    lib.showTextUI('Vous n\'avez rien trouvé ', {
        position = "top-center",
        icon = 'gun-squirt',
        style = {
            borderRadius = 0,
            backgroundColor = '#FF1300',
            color = 'white'
        }
    })
    Citizen.Wait(1500)
    lib.hideTextUI()
    ------------------**fin notification**-----------------
end)

RegisterNetEvent("toffleeca:nospace_c")
AddEventHandler("toffleeca:nospace_c", function()
    ------------------**notification**----------------------
    lib.showTextUI('Vous n\'avez plus de place ', {
        position = "top-center",
        icon = 'gun-squirt',
        style = {
            borderRadius = 0,
            backgroundColor = '#FF1300',
            color = 'white'
        }
    })
    Citizen.Wait(1500)
    lib.hideTextUI()
    ------------------**fin notification**-----------------
end)

RegisterNetEvent("toffleeca:loot_c")
AddEventHandler("toffleeca:loot_c", function(item, count)
    ------------------**notification**----------------------
    lib.showTextUI('Vous avez trouvé '..count..' '..item, {
        position = "top-center",
        icon = 'gun-squirt',
        style = {
            borderRadius = 0,
            backgroundColor = '#FF1300',
            color = 'white'
        }
    })
    Citizen.Wait(1500)
    lib.hideTextUI()
    ------------------**fin notification**-----------------
end)

RegisterNetEvent("toffleeca:lootmoney_c")
AddEventHandler("toffleeca:lootmoney_c", function(count)
    ------------------**notification**----------------------
    lib.showTextUI('Vous avez trouvé '..count..' $', {
        position = "top-center",
        icon = 'gun-squirt',
        style = {
            borderRadius = 0,
            backgroundColor = '#FF1300',
            color = 'white'
        }
    })
    Citizen.Wait(1500)
    lib.hideTextUI()
    ------------------**fin notification**-----------------
end)

-------------------------------------------------------------------------
------------------------ msg timer --------------------------------------
-------------------------------------------------------------------------

RegisterNetEvent("toffleeca:nottimer")
AddEventHandler("toffleeca:nottimer", function()
    ------------------**notification**----------------------
    lib.showTextUI('Braquage déjà en cours, revenez plus tard', {
        position = "top-center",
        icon = 'gun-squirt',
        style = {
            borderRadius = 0,
            backgroundColor = '#FF1300',
            color = 'white'
        }
    })
    Citizen.Wait(5000)
    lib.hideTextUI()
    ------------------**fin notification**-----------------
end)

-------------------------------------------------------------------------
----------------------- Loot zones 2 ------------------------------------
-------------------------------------------------------------------------

RegisterNetEvent("toffleeca:forcecoffre2")
AddEventHandler("toffleeca:forcecoffre2", function(entity)
    if GetGameTimer() > nextCoffre then
    SetnextCoffre()
    TaskStartScenarioInPlace(PlayerPedId(), 'WORLD_HUMAN_WELDING', 0, true)
	Wait(25000)
	ClearPedTasksImmediately(PlayerPedId())
    ------------------**notification**----------------------
    lib.showTextUI('Coffre forcé', {
        position = "top-center",
        icon = 'gun-squirt',
        style = {
            borderRadius = 0,
            backgroundColor = '#FF1300',
            color = 'white'
        }
    })
    Citizen.Wait(1500)
    lib.hideTextUI()
    ------------------**fin notification**-----------------
    TaskStartScenarioInPlace(PlayerPedId(), "PROP_HUMAN_BUM_BIN", 0, 1)
    Citizen.Wait(10000)
    ClearPedTasksImmediately(PlayerPedId())
    local chance2 = math.random(1,20)
    TriggerServerEvent('toffleeca:loot2_s', chance2)
    else
        ------------------**notification**----------------------
        lib.showTextUI('Respire, ça n\'ira pas plus vite !', {
            position = "top-center",
            icon = 'gun-squirt',
            style = {
                borderRadius = 0,
                backgroundColor = '#FF1300',
                color = 'white'
            }
        })
        Citizen.Wait(1500)
        lib.hideTextUI()
        ------------------**fin notification**-----------------
    end
end)

-------------------------------------------------------------------------
------------------------ msg nbcops -------------------------------------
-------------------------------------------------------------------------

RegisterNetEvent("toffleeca:notnbcops")
AddEventHandler("toffleeca:notnbcops", function()
    ------------------**notification**----------------------
    lib.showTextUI('Braquage compromis, revenez plus tard', {
        position = "top-center",
        icon = 'gun-squirt',
        style = {
            borderRadius = 0,
            backgroundColor = '#FF1300',
            color = 'white'
        }
    })
    Citizen.Wait(5000)
    lib.hideTextUI()
    ------------------**fin notification**-----------------
end)

-------------------------------------------------------------------------
------------------------- msg LSPD --------------------------------------
-------------------------------------------------------------------------

RegisterNetEvent("toffleeca:msgpolice")
AddEventHandler("toffleeca:msgpolice", function(coords)
    ------------------**notification**----------------------
    lib.showTextUI('Braquage en cours - Position GPS de l\'alarme dans 30s', {
        position = "top-center",
        icon = 'gun-squirt',
        style = {
            borderRadius = 0,
            backgroundColor = 'red',
            color = 'white'
        }
    })
    Citizen.Wait(30000)
    lib.hideTextUI()
    ------------------**fin notification**-----------------
    TriggerEvent('toffleeca:blipPolice', coords)
end)

-------------------------------------------------------------------------
------------------------ blip LSPD --------------------------------------
-------------------------------------------------------------------------

RegisterNetEvent("toffleeca:blipPolice")
AddEventHandler("toffleeca:blipPolice", function(coords)
    local alertblip = AddBlipForCoord(coords.x,coords.y,coords.z)
    SetBlipSprite(alertblip, 161)
    SetBlipScale(alertblip, 2.0)
    SetBlipColour(alertblip, 5)
    PulseBlip(alertblip)
    Wait(600000)
    RemoveBlip(alertblip)
end)