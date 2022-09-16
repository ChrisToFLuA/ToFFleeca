local mincops = 0  --- nb minimum de lspd en ville
local lastrob = 0
local nextrob = 0
local cd = 3600000 --- cooldown

lib.versionCheck('ChrisToFLuA/ToFFleeca')

---------------------------------------------------------------------------------

-- ** qtarget documentation : https://overextended.github.io/qtarget/model.html
-- ** ox_inventory documentation : https://overextended.github.io/docs
-- ** ox_lib documentation : https://overextended.github.io/docs

---------------------------------------------------------------------------------

RegisterServerEvent('toffleeca:timers')
AddEventHandler('toffleeca:timers', function(coords, coordsearch)
    local xPlayer = ESX.GetPlayerFromId(source)
	if lastrob ~= 0 then
        nextrob = lastrob + cd
        if GetGameTimer() >= nextrob then
            TriggerEvent('toffleeca:nbcops', xPlayer.source, coords, coordsearch)
        end
        if GetGameTimer() < nextrob then
            TriggerClientEvent('toffleeca:nottimer', xPlayer.source)
        end         
    end
    if lastrob == 0 then 
        TriggerEvent('toffleeca:nbcops', xPlayer.source, coords, coordsearch)
    end
end)

RegisterServerEvent('toffleeca:nbcops')
AddEventHandler('toffleeca:nbcops', function(source, coords, coordsearch)
    local xPlayer = ESX.GetPlayerFromId(source)
	local copsOnline = ESX.GetExtendedPlayers('job', 'police')

    if #copsOnline >= mincops then
        lastrob = GetGameTimer()
        for j=1, #copsOnline, 1 do
            local xPlayerx = copsOnline[j]
            TriggerClientEvent('toffleeca:msgpolice', xPlayerx.source)
        end
        TriggerEvent('toffleeca:card', xPlayer.source, coordsearch)
    else
        TriggerClientEvent('toffleeca:notnbcops', xPlayer.source)
    end    
end)

RegisterServerEvent('toffleeca:card')
AddEventHandler('toffleeca:card', function(source, coordsearch)
    local xPlayer = ESX.GetPlayerFromId(source)
    local card = exports.ox_inventory:GetItem(source, 'id_card_f', nil, false)      -- check id_card_f count
    if card.count > 0 then
        TriggerClientEvent('toffleeca:usecard', xPlayer.source, coordsearch)
		exports.ox_inventory:RemoveItem(xPlayer.source, 'id_card_f', 1)     -- remove id_card_f from inventory player
    else
        TriggerClientEvent('esx:showNotification', xPlayer.source, 'Vous n\'avez pas de Carte d\'identification')       -- notification no card     
    end
end)

RegisterServerEvent('toffleeca:thermal')
AddEventHandler('toffleeca:thermal', function(entity, coordtp, coordsearch)
    local xPlayer = ESX.GetPlayerFromId(source)
    local thermal = exports.ox_inventory:GetItem(source, 'thermalcharge', nil, false)       -- check thermalcharge count
    if thermal.count > 1 then
        TriggerClientEvent('toffleeca:usethermal', xPlayer.source, entity, coordtp, coordsearch)
		exports.ox_inventory:RemoveItem(xPlayer.source, 'thermalcharge', 2)         -- remove thermalcharge from inventory
    else
        TriggerClientEvent('esx:showNotification', xPlayer.source, locale('no_thermal'))       -- notification no thermalcharge
    end
end)

RegisterServerEvent('toffleeca:thermiteall_s')
AddEventHandler('toffleeca:thermiteall_s', function(ptfx)
	TriggerClientEvent("toffleeca:thermiteall_c", -1, ptfx)
end)

RegisterServerEvent('toffleeca:opendoorlspd_s')
AddEventHandler('toffleeca:opendoorlspd_s', function(coordsearch)
	TriggerClientEvent("toffleeca:opendoorsearchlspd_c", -1, coordsearch)
end)

RegisterServerEvent('toffleeca:opendoor_s')
AddEventHandler('toffleeca:opendoor_s', function(coordsearch)
	TriggerClientEvent("toffleeca:opendoorsearch_c", -1, coordsearch)
end)

RegisterServerEvent('toffleeca:opendoor2_s')
AddEventHandler('toffleeca:opendoor2_s', function(coordsearch2)
	TriggerClientEvent("toffleeca:opendoor2all_c", -1, coordsearch2)
end)

RegisterServerEvent('toffleeca:closedoor_s')
AddEventHandler('toffleeca:closedoor_s', function(door)
    local xPlayer = ESX.GetPlayerFromId(source)
	TriggerClientEvent('toffleeca:closedoor_c', -1, door) 
end)

RegisterServerEvent('toffleeca:loot_s')
AddEventHandler('toffleeca:loot_s', function(chance)
    local xPlayer = ESX.GetPlayerFromId(source)
    local count = math.random(3, 6)
    if chance < 6 then
        TriggerClientEvent('toffleeca:noloot_c', xPlayer.source)
    end
    if chance < 8 and chance > 5 then
        local item = locale('id_card')     -- label item id_card_f
        if exports.ox_inventory:CanCarryItem(xPlayer.source, 'id_card_f', count) then       -- check cancarry items
            exports.ox_inventory:AddItem(xPlayer.source, 'id_card_f', count)
            TriggerClientEvent('toffleeca:loot_c', xPlayer.source, item, count)
        else
            TriggerClientEvent('toffleeca:nospace_c', xPlayer.source)
        end
    end
    if chance < 13 and chance > 7 then
        local item = locale('jewels')       -- label item jewels
        if exports.ox_inventory:CanCarryItem(xPlayer.source, 'jewels', count) then      -- check cancarry items
            exports.ox_inventory:AddItem(xPlayer.source, 'jewels', count)
            TriggerClientEvent('toffleeca:loot_c', xPlayer.source, item, count)
        else
            TriggerClientEvent('toffleeca:nospace_c', xPlayer.source)
        end
    end
    if chance < 21 and chance > 12 then
        local countMoney = math.random(10513, 11012)        -- how many black_money earn for 1 loot
        xPlayer.addAccountMoney('black_money', countMoney)
        TriggerClientEvent('toffleeca:lootmoney_c', xPlayer.source, countMoney)
    end
end)

RegisterServerEvent('toffleeca:loot2_s')
AddEventHandler('toffleeca:loot2_s', function(chance2)
    local xPlayer = ESX.GetPlayerFromId(source)
    local count = math.random(1, 2)
    if chance2 < 8 then
        TriggerClientEvent('toffleeca:noloot_c', xPlayer.source)
    end
    if chance2 > 7 then
        local item = locale('ingot')       -- label item goldingot
        if exports.ox_inventory:CanCarryItem(xPlayer.source, 'goldingot', count) then       -- check cancarry item
            exports.ox_inventory:AddItem(xPlayer.source, 'goldingot', count)
            TriggerClientEvent('toffleeca:loot_c', xPlayer.source, item, count)
        else
            TriggerClientEvent('toffleeca:nospace_c', xPlayer.source)
        end
    end
end)