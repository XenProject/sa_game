CustomPlayerResource = CustomPlayerResource or {}
CustomPlayerResource.data = CustomPlayerResource.data or {}

function CustomPlayerResource:InitPlayer(playerID)

	if not self.data[playerID] then
		self.data[playerID] = {}
		self.data[playerID].readyToRound = false
	end

end

function CDOTA_PlayerResource:ClearReadyToRound()
	for playerID,playerTable in pairs(CustomPlayerResource.data) do
		playerTable.readyToRound = false
		--CustomNetTables:SetTableValue("lia_player_table", "Player"..playerID, playerTable)
	end
end

function CDOTA_PlayerResource:SetReadyToRound(playerID,ready)
	CustomPlayerResource.data[playerID].readyToRound = ready
end

function CDOTA_PlayerResource:IsReadyToRound(playerID)
	return CustomPlayerResource.data[playerID].readyToRound
end

function CDOTA_PlayerResource:GetNumPlayersReadyToRound()
	local n = 0
	for _,v in pairs(CustomPlayerResource.data) do
		if type(v) == "table" then
			if v.readyToRound then
				n = n + 1
			end
		end
	end
	return n
end