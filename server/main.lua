ESX = exports['es_extended']:getSharedObject()

RegisterNetEvent('apex_appearance:requestIdentifier')
AddEventHandler('apex_appearance:requestIdentifier', function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    
    if xPlayer and xPlayer.identifier then
        TriggerClientEvent('apex_appearance:receiveIdentifier', _source, xPlayer.identifier)
        print(('[Apex Appearance] Sent identifier to player %s: %s'):format(_source, xPlayer.identifier))
    else
        print(('[Apex Appearance] ERROR: Could not get identifier for player %s'):format(_source))
        TriggerClientEvent('apex_appearance:receiveIdentifier', _source, nil)
    end
end)

RegisterNetEvent('apex_appearance:log')
AddEventHandler('apex_appearance:log', function(message)
    print('[Apex Appearance] ' .. message)
end)

print('[Apex Appearance] Server started - Local KVP persistence only')