events = {}

events.eventLoop = function(currentTime,leftTime)
	_G.currentTime = normalizeTime(currentTime / 1e3)
	_G.leftTime = normalizeTime(leftTime / 1e3)
end

events.eventChatCommand = function(n,c)
	disableChatCommand(c)
	if not system.isRoom then
		if c == "refresh" then
			system.init()
		else
			if module._FREEACCESS[n] and os.time() > system.modeChanged and os.time() > system.newGameTimer then
				local newMode = system.getGameMode(c)
				if newMode then
					system.init()
				end
			end
		end
	end
	if string.sub(1,6) == "module" then
		c = string.upper(string.sub(8))
		if module["_" .. c] then
			tfm.exec.chatMessage(c .. " : " .. table.concat(table.turnTable(module["_" .. c]),", "),n)
		else
			tfm.exec.chatMessage(string.format("VERSION : %s\nNAME : %s\nSTATUS : %s\nAUTHOR : %s\n\nMODE : %s",module._VERSION,module._NAME,module._STATUS,module._AUTHOR,system.gameMode),n)
		end
	elseif c == "stop" and system.roomAdmins[n] then
		system.exit()
	end
end

events.eventNewPlayer = function(n)
	if system.officialMode[2] ~= "" then
		tfm.exec.chatMessage(system.officialMode[2],n)
	end
end
