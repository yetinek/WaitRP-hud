local LastHelpInput = GetGameTimer()

CreateHelpInputs = function(data)
    LastHelpInput = GetGameTimer() + 200
    if not HUD.HelpInputCache.Display then
        HUD.HelpInputCache.Display = true
        SendNUIMessage({
            action = "createhelpInputs",
            bool = true,
            keys = data
        })
    end
end

RegisterNUICallback('SetHelpInputDisplay', function(data)
    HUD.HelpInputCache.Display = data.bool
end)

CreateThread(function()
    while true do
        Wait(0)
        if HUD.HelpInputCache.Display then
            if LastHelpInput <= GetGameTimer() then
                SendNUIMessage({
                    action = "createhelpInputs",
                    bool = false,
                })
                HUD.HelpInputCache = {
                    Update = GetGameTimer(),
                    Display = false
                }
            end
        else
            Wait(250)
        end
    end
end)

exports('CreateHelpInputs', CreateHelpInputs)