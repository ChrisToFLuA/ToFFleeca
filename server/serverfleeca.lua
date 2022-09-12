ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local mincops = 0  --- nb minimum de lspd en ville
local lastrob = 0
local nextrob = 0
local cd = 3600000 --- cooldown entre 2 braquages
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
	local xPlayers = ESX.GetPlayers()
	local copsOnline = 0

	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		if xPlayer.job.name == 'police' or xPlayer.job.name == 'offpolice' then
			copsOnline = copsOnline + 1
		end
	end

    if copsOnline >= mincops then
        lastrob = GetGameTimer()
        for j=1, #xPlayers, 1 do
            local xPlayer = ESX.GetPlayerFromId(xPlayers[j])
            if xPlayer.job.name == 'police' or xPlayer.job.name == 'offpolice' then
                TriggerClientEvent('toffleeca:msgpolice', xPlayer.source, coords)
            end
        end
        TriggerEvent('toffleeca:card', xPlayer.source, coordsearch)
    else
        TriggerClientEvent('toffleeca:notnbcops', xPlayer.source)
    end    
end)

RegisterServerEvent('toffleeca:card')
AddEventHandler('toffleeca:card', function(source, coordsearch)
    local xPlayer = ESX.GetPlayerFromId(source)
    local card = exports.ox_inventory:GetItem(source, 'id_card_f', nil, false)
    if card.count > 0 then
        TriggerClientEvent('toffleeca:usecard', xPlayer.source, coordsearch)
		exports.ox_inventory:RemoveItem(xPlayer.source, 'id_card_f', 1)
		print('card ok')
    else
        TriggerClientEvent('esx:showNotification', xPlayer.source, 'Vous n\'avez pas de Carte d\'identification')      
		print('card ko')
    end
end)

RegisterServerEvent('toffleeca:thermal')
AddEventHandler('toffleeca:thermal', function(entity, coordtp, coordsearch)
    local xPlayer = ESX.GetPlayerFromId(source)
    local thermal = exports.ox_inventory:GetItem(source, 'thermalcharge', nil, false)
    if thermal.count > 1 then
        TriggerClientEvent('toffleeca:usethermal', xPlayer.source, entity, coordtp, coordsearch)
		exports.ox_inventory:RemoveItem(xPlayer.source, 'thermalcharge', 2)
		print('thermal ok')
    else
        TriggerClientEvent('esx:showNotification', xPlayer.source, 'Vous n\'avez pas assez de charges thermales')      
		print('thermal ko')
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
        local item = 'Cartes d\'identification'
        if exports.ox_inventory:CanCarryItem(xPlayer.source, 'id_card_f', count) then
            exports.ox_inventory:AddItem(xPlayer.source, 'id_card_f', count)
            TriggerClientEvent('toffleeca:loot_c', xPlayer.source, item, count)
        else
            TriggerClientEvent('toffleeca:nospace_c', xPlayer.source)
        end
    end
    if chance < 13 and chance > 7 then
        local item = 'Bijoux'
        if exports.ox_inventory:CanCarryItem(xPlayer.source, 'jewels', count) then
            exports.ox_inventory:AddItem(xPlayer.source, 'jewels', count)
            TriggerClientEvent('toffleeca:loot_c', xPlayer.source, item, count)
        else
            TriggerClientEvent('toffleeca:nospace_c', xPlayer.source)
        end
    end
    if chance < 21 and chance > 12 then
        local countMoney = math.random(10513, 11012)
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
        local item = 'Lingots Or'
        if exports.ox_inventory:CanCarryItem(xPlayer.source, 'goldingot', count) then
            exports.ox_inventory:AddItem(xPlayer.source, 'goldingot', count)
            TriggerClientEvent('toffleeca:loot_c', xPlayer.source, item, count)
        else
            TriggerClientEvent('toffleeca:nospace_c', xPlayer.source)
        end
    end
end)