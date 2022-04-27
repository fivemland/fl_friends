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
	local xPlayer = ESX.GetPlayerFromId(player)

	local result = MySQL.query.await(
		"SELECT friends.*, CONCAT(users.firstname, ' ', users.lastname) AS charName FROM friends, users WHERE friends.identifier = ? AND users.identifier=friends.friend",
		{ xPlayer.identifier }
	)

	return result
end

RegisterCommand("friends", function(player)
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
		MySQL.query.await("DELETE FROM friends WHERE dbID = ?", { targetPlayer.dbID })
	elseif method == "accept" then
		MySQL.query.await("UPDATE friends SET pending = 0 WHERE dbID = ? ", { targetPlayer.dbID })
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
	result.online = xTarget and true or false

	print(ESX.DumpTable(result))
	cb(result)
end)
