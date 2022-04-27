Panel = {
	visible = false,

	init = function(self)
		RegisterNUICallback("close", function()
			self:setVisible(false)
		end)

		RegisterNetEvent("openFriendsPanel", function(friends)
			print(ESX.DumpTable(friends))
			self:setVisible(true)
			self:update(friends)
		end)

		RegisterNUICallback("sendRequest", function(data)
			if not data.requestID then
				return
			end

			ESX.TriggerServerCallback("newFriendRequest", function(result, msg)
				if msg then
					ESX.ShowNotification(msg)
				end

				self:update(result)
			end, data.requestID)
		end)

		RegisterNUICallback("friendInteraction", function(data)
			if not data.method or not data.player then
				return
			end

			ESX.TriggerServerCallback("friendInteraction", function(friends, err)
				if not friends then
					return ESX.ShowNotification(err)
				end

				self:update(friends)

				if data.method == "accept" then
					ESX.ShowNotification("Friend request accepted.")
				elseif data.method == "delete" then
					ESX.ShowNotification("Friend removed.")
				end
			end, data.method, data.player)
		end)

		RegisterNUICallback("requestPlayerInfo", function(data, cb)
			if not data.identifier then
				ESX.ShowNotification("Player not found!")
				return cb({ error = true })
			end

			ESX.TriggerServerCallback("requestPlayerInfo", function(result, err)
				if err then
					ESX.ShowNotification(err)
				end

				cb({
					error = not result and err,
					result = result,
				})
			end, data.identifier)
		end)
	end,

	setVisible = function(self, visible)
		self.visible = visible

		SendNUIMessage({ visible = visible })
		SetNuiFocus(visible, visible)
	end,

	update = function(self, friends)
		SendNUIMessage({ updatePlayers = friends })
	end,
}
Panel.__index = Panel

CreateThread(function()
	while not ESX.IsPlayerLoaded() do
		Wait(1)
	end

	Panel:init()
end)
