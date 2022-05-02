CreateThread(function()
	MySQL.query([[
    CREATE TABLE IF NOT EXISTS `friends` (
      `dbID` INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
      `identifier` VARCHAR(64) NOT NULL DEFAULT '',
      `friend` VARCHAR(64) NULL DEFAULT NULL,
      `discordId` VARCHAR(64) NULL DEFAULT NULL,
      `add_date` DATETIME NULL DEFAULT NOW(),
      `pending` INT(1) NULL DEFAULT '1'
    )
    COLLATE='utf8mb4_unicode_ci';    
  ]])
end)

function getPlayerFriends(player, typ)
	local xPlayer = false
	if type(player) == "table" then
		xPlayer = player
	else
		xPlayer = ESX.GetPlayerFromId(player)
	end

	return MySQL.query.await(
		[[
			SELECT friends.*, CONCAT(users.firstname, ' ', users.lastname) AS charName
			FROM friends, users
			WHERE friends.identifier = ? AND users.identifier=friends.friend
		]],
		{ xPlayer.identifier }
	)
end
exports("getPlayerFriends", getPlayerFriends)

ESX.RegisterServerCallback("requestPlayerFriends", function(player, cb)
	cb(getPlayerFriends(player))
end)

function getPlayerDiscordName(player)
	local ids = GetPlayerIdentifiers(player)
	local discordId = false

	for _, id in pairs(ids) do
		if id:find("discord:") then
			discordId = id:gsub("discord:", "")
			break
		end
	end

	if not discordId then
		return "Unknown"
	end

	local p = promise.new()

	PerformHttpRequest(
		"https://discord.com/api/v9/users/" .. discordId,
		function(code, result)
			if code ~= 200 then
				return p:resolve("Unknown")
			end

			result = json.decode(result)

			p:resolve(result.username .. " #" .. result.discriminator)
		end,
		"GET",
		"",
		{
			Authorization = "Bot " .. DISCORD_BOT_TOKEN,
		}
	)

	return Citizen.Await(p)
end
exports("getPlayerDiscordName", getPlayerDiscordName)

RegisterCommand(PANEL_COMMAND, function(player)
	TriggerClientEvent("openFriendsPanel", player, getPlayerFriends(player))
end)

ESX.RegisterServerCallback("newFriendRequest", function(player, cb, targetId)
	if not targetId then
		return cb(false, "Player not found!")
	end

	local xPlayer = ESX.GetPlayerFromId(player)
	if not xPlayer then
		return cb(false, "Error!")
	end

	local xTarget = ESX.GetPlayerFromId(tonumber(targetId))
	if not xTarget then
		return cb(false, "Player not found!")
	end

	local exists = MySQL.scalar.await(
		"SELECT dbID FROM friends WHERE identifier = ? AND friend = ?",
		{ xPlayer.identifier, xTarget.identifier }
	)
	if exists then
		return cb(false, "You are already friends or have a pending request.")
	end

	MySQL.insert.await(
		"INSERT INTO friends SET identifier = ?, friend = ?, pending = 0",
		{ xPlayer.identifier, xTarget.identifier }
	)
	MySQL.insert.await("INSERT INTO friends SET identifier = ?, friend = ?", { xPlayer.identifier, xTarget.identifier })

	cb(getPlayerFriends(player), "Friend request sent")
end)

ESX.RegisterServerCallback("friendInteraction", function(player, cb, method, targetPlayer)
	if not method then
		return cb(false, "Unknown error!")
	end

	if not targetPlayer or not targetPlayer.dbID then
		return cb(false, "Target player invalid!")
	end

	if method == "delete" then
		MySQL.query.await(
			"DELETE FROM friends WHERE identifier = ? AND friend = ?",
			{ targetPlayer.identifier, targetPlayer.friend }
		)
		MySQL.query.await(
			"DELETE FROM friends WHERE identifier = ? AND friend = ?",
			{ targetPlayer.friend, targetPlayer.identifier }
		)
		MySQL.query.await("DELETE FROM friends WHERE dbID = ?", { targetPlayer.dbID })
	elseif method == "accept" then
		MySQL.query.await("UPDATE friends SET pending = 0 WHERE dbID = ? ", { targetPlayer.dbID })
	end

	local xTarget = ESX.GetPlayerFromIdentifier(targetPlayer.friend)
	if xTarget then
		TriggerClientEvent("updatePlayerFriends", xTarget.source, getPlayerFriends(xTarget))
	end

	cb(getPlayerFriends(player))
end)

ESX.RegisterServerCallback("requestPlayerInfo", function(player, cb, identifier)
	if not identifier then
		return cb(false, "Player not found!")
	end

	local result = MySQL.query.await(
		"SELECT friends.*, CONCAT(firstname, ' ', lastname) AS charName, phone_number FROM friends, users WHERE friends.friend = ? AND users.identifier=friends.friend LIMIT 1",
		{ identifier }
	)

	if #result <= 0 then
		return cb(false, "Player not found!")
	end

	result = result[1]

	local xTarget = ESX.GetPlayerFromIdentifier(identifier)
	if xTarget then
		result.online = true
		result.discordName = getPlayerDiscordName(xTarget.source)
	end

	cb(result)
end)
