local Display = false
local ZetkaPlayers = {}

RegisterNetEvent("w_hud:scoreboard:PlayerShowed", function(target, boolean)
	ZetkaPlayers[target] = boolean
end)

Citizen.CreateThread(function()
	while true do
		Wait(0)
		for _, player in ipairs(GetActivePlayers()) do
			local playerPed = GetPlayerPed(player)
			local coords1 = GetPedBoneCoords(ESX.PlayerData.ped, 31086, -0.4, 0.0, 0.0)
			local coords2 = GetPedBoneCoords(playerPed, 31086, -0.4, 0.0, 0.0)
			if #(coords1 - coords2) < 35.0 then
				local svId = GetPlayerServerId(player)
				if Display then
					if IsEntityVisible(playerPed) then
						color = (Player(svId).state.AntyTroll and '~y~' or '~w~')
						color = (NetworkIsPlayerTalking(player) and '~b~' or color)
						DrawText3D(coords2.x, coords2.y, coords2.z + 0.85, color..svId..' ~c~['..(Player(svId).state.ssn and Player(svId).state.ssn or '?')..']' .. "\n" .. (Player(svId).state.AFK and "~r~[AFK] " or " ") .. (Player(svId).state.Streamer and "~p~[Streamer]" or ""), {255, 255, 255}, 1.1)
					end
				end
				if ZetkaPlayers[svId] and GetPlayerServerId(PlayerId()) ~= svId then
					color = (NetworkIsPlayerTalking(player) and '~b~' or '~w~')
					DrawText3D(coords2.x, coords2.y, coords2.z + 1.15, '~r~!', {255, 255, 255}, 1.1)
				end
			end
		end
	end
end)

RegisterCommand("+scoreboard", function()
	if exports['w_skin']:InRoom() then return end
	Display = true
	SendNUIMessage({
		action = "toggleScoreboard",
		bool = true,
		players = GlobalState.Counter['players'] or 0,
		fractions = {
			lspd = {players = GlobalState.Counter['police'] or 0, color = '#57CDFF'},
			ems = {players = GlobalState.Counter['ambulance'] or 0, color = '#FF2525'},
			lsc = {players = GlobalState.Counter['lsc'] or 0, color = '#5AFF57'},
			furios = {players = GlobalState.Counter['furios'] or 0, color = '#EEFF25'},
			doj = {players = GlobalState.Counter['doj'] or 0, color = '#FFB800'},
		}
	})
	TriggerServerEvent("w_hud:scoreboard:PlayerShowed", true)
end)

RegisterCommand("-scoreboard", function()
	Display = false
	SendNUIMessage({
		action = "toggleScoreboard",
		bool = false
	})
	TriggerServerEvent("w_hud:scoreboard:PlayerShowed", false)
end)

RegisterKeyMapping("+scoreboard", "Scoreboard", "keyboard", "Z")

DrawText3D = function(x, y, z, text, color, _scale)
	local onScreen, _x, _y = World3dToScreen2d(x,y,z)
	local scale = (1 / #(GetGameplayCamCoords() - vec3(x, y, z))) * _scale
	local fov = (1 / GetGameplayCamFov()) * 100
	scale = scale * fov
	if onScreen then
		SetTextScale(1.0 * scale, 1.55 * scale)
		SetTextFont(0)
		SetTextColour(color[1], color[2], color[3], 255)
		SetTextProportional(1)
		SetTextDropshadow(0, 0, 0, 0, 255)
		SetTextDropShadow()
		SetTextOutline()
		SetTextCentre(1)
		SetTextEntry("STRING")
		AddTextComponentString(text)
		DrawText(_x,_y)
	end
end