Friends = {}

Panel = {
	visible = false,

	init = function(self)
		RegisterNUICallback("close", function()
			self:setVisible(false)
		end)

		RegisterNetEvent("openFriendsPanel", function(friends)
			self:setVisible(not self.visible)
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
				return cb({ error = "Player not found!" })
			end

			ESX.TriggerServerCallback("requestPlayerInfo", function(result, err)
				cb({
					error = not result and err,
					result = result,
				})
			end, data.identifier)
		end)

		ESX.TriggerServerCallback("requestPlayerFriends", function(friends)
			self:update(friends)
		end)
	end,

	setVisible = function(self, visible)
		self.visible = visible

		SendNUIMessage({ visible = visible })
		SetNuiFocus(visible, visible)
	end,

	update = function(self, friends)
		SendNUIMessage({ updatePlayers = friends })

		Friends = {}
		for _, friend in pairs(friends) do
			if (friend.pending or 1) == 0 then
				Friends[friend.friend] = friend
			end
		end
	end,
}
Panel.__index = Panel

CreateThread(function()
	while not ESX.IsPlayerLoaded() do
		Wait(1)
	end

	Panel:init()
end)

exports("isPlayerFriend", function(identifier)
	return Friends[identifier]
end)
