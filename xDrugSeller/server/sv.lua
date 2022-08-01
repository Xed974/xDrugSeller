ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local function getCops()
    local xPlayers = ESX.GetPlayers()
    local copsConnected = 0

    for i = 1, #xPlayers, 1 do
        local xPlayer = ESX.GetPlayerFromId(xPlayers[i])

        for _,v in pairs(xDrugSeller.JobPolice) do
            if (xPlayer.getJob().name) == v then
                copsConnected = copsConnected + 1
            end
        end
    end
    return copsConnected
end

ESX.RegisterServerCallback('xDrugSeller:checkcops', function(source, cb)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local copsCount = getCops()

    if (not xPlayer) then return end
    if copsCount >= xDrugSeller.PoliceRequis then
        cb(true)
    else
        cb(false)
    end
end)

ESX.RegisterServerCallback("xDrugSeller:getDrug", function(source, cb, drug, druglabel, gain, selling)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)

    if (not xPlayer) then return end
    if (xPlayer.getInventoryItem(drug).count) >= selling then
        cb(true)
        xPlayer.removeInventoryItem(drug, selling)
        xPlayer.addAccountMoney('black_money', (selling * gain))
        TriggerClientEvent('esx:showAdvancedNotification', source, "Citoyen", "Discussion", "Ca à intérêt d'être de la bonne !", "CHAR_ARTHUR", 1)
    else
        cb(false)
        TriggerClientEvent('esx:showNotification', source, ('Vous avez pas assez de ~r~%s~s~ sur vous.'):format(druglabel))
    end
end)

RegisterNetEvent('xDrugSeller:Call')
AddEventHandler('xDrugSeller:Call', function(pPos)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
	local xPlayers = ESX.GetPlayers()

    if (not xPlayer) then return end
    for i = 1, #xPlayers, 1 do
        local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
        local job = xPlayer.getJob()

        for _,v in pairs(xDrugSeller.JobPolice) do
            if (xPlayer.getJob().name) == v then
                TriggerClientEvent('esx:showAdvancedNotification', xPlayers[i], 'LSPD CENTRALE', '~g~Appel d\'un citoyen', '~g~Citoyen:~s~ Une personne a tenté de me vendre de la drogue !', 'CHAR_CHAT_CALL', 1)
                TriggerClientEvent('xDrugSeller:blips', xPlayers[i], pPos)
            end
        end
    end
end)

--- Xed#1188
