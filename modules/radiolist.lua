local RadioListDisplay = false
local LastPlayersToUpdate = nil

exports('RefreshRadioList', function(channel, data)
    if RadioListDisplay then
        SendNUIMessage({
            action = "updateRadioList",
            radio = channel,
            players = data
        })
    else
        LastPlayersToUpdate = data
    end
end)

RegisterCommand('radiolist', function()
    if not RadioListDisplay and not exports['w_radio']:Enabled() then
        print('cancel')
        return
    end
    RadioListDisplay = not RadioListDisplay
    RadioChannel = exports['w_radio']:GetChannel()
    SendNUIMessage({
        action = "toggleRadioList",
        bool = RadioListDisplay,
        radioChannel = RadioChannel
    })
    if LastPlayersToUpdate ~= nil then
        SendNUIMessage({
            action = "updateRadioList",
            radio = RadioChannel,
            players = LastPlayersToUpdate
        })
        LastPlayersToUpdate = nil
    end
end)

RegisterNetEvent("w_hud:SetPlayerRadioTalking", function(bool, id)
	SendNUIMessage({
		action = 'toggleRadioListTalking',
        id = id,
        bool = bool
	})
end)