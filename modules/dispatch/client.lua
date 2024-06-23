local Cache = {}

RegisterNetEvent('w_hud:dispatch:NewAlert', function(data, players)
    SendNUIMessage({
        action = 'addNotify',
        type = 'dispatch',
        maintitle = data.description,
        title = data.title,
        desc = data.code,
        lenght = 15000,
        author = data.index,
        players = players,
        importance = data.type
    })
    local _display = data.display
    if not _display then return end
    Cache[data.index] = _display.location
    if not _display.sprite or not _display.color then return end
    local blip = AddBlipForCoord(_display.location.x, _display.location.y, _display.location.z)
    SetBlipSprite(blip, _display.sprite)
    SetBlipColour(blip, _display.color)
    SetBlipAlpha(blip, 250)
    SetBlipAsShortRange(blip, 1)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString('# '..data.title)
    EndTextCommandSetBlipName(blip)
    SetTimeout(120000, function()
        RemoveBlip(blip)
        Cache[data.index] = nil
    end)
end)

RegisterNUICallback('DispatchAction', function(data)
    if not Cache[data.index] then return end
    SetNewWaypoint(Cache[data.index].x, Cache[data.index].y)
    if data.blip then
        exports['w_tokenizer']:TriggerServerEvent('w_hud:dispatch:react', data.index)
    end
end)

RegisterNetEvent('w_hud:dispatch:UpdateAlert', function(index, players)
    SendNUIMessage({
        action = 'UpdateAlert',
        data = {
            index = index,
            players = players
        }
    })
end)