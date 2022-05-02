<p align="center">
<img src="https://raw.githubusercontent.com/fivemland/fl_dashboard/master/ui/src/assets/logo.png " width="100" height="100">
</p>

## FiveM Land Friends - fl_friends

### Dependencies

- [oxmysql](https://github.com/overextended/oxmysql 'oxmysql')
- [esx-legacy](https://github.com/esx-framework/esx-legacy 'esx-legacy')

### Commands

- /friends - Open friends management panel (command adjustable in shared.lua)

### Exports

#### Server

```lua
-- player: serverId or xPlayer
-- returns: table
getPlayerFriends(player)
```

```lua
-- returns: string
getPlayerDiscordName(player)
```

#### Client

```lua
-- identifier: xPlayer identifier
-- returns: boolean
isPlayerFriend(identifier)
```

### Screenshots

[![1](https://raw.githubusercontent.com/fivemland/fl_friends/main/screenshots/1.png '1')](https://raw.githubusercontent.com/fivemland/fl_friends/main/screenshots/1.png '1')

[![2](https://raw.githubusercontent.com/fivemland/fl_friends/main/screenshots/2.png '2')](https://raw.githubusercontent.com/fivemland/fl_friends/main/screenshots/2.png '2')

[![3](https://raw.githubusercontent.com/fivemland/fl_friends/main/screenshots/3.png '3')](https://raw.githubusercontent.com/fivemland/fl_friends/main/screenshots/3.png '3')
