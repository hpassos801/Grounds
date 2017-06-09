system.roomSettings = {
	["@"] = function(n)
		system.roomAdmins[string.nick(n)] = true
	end,
	["#"] = function(id)
		system.miscAttrib = tonumber(id) or 1
		system.miscAttrib = math.max(1,math.min(system.miscAttrib,99))
	end,
	["*"] = function(name)
		local game = system.getGameMode(name)
		if not game then
			system.gameMode = "grounds"
		end
	end,
	["vanilla"] = function()
		system.officialModeMessage = "<VP>Enjoy your vanilla (: .. okno"
	end,
	["survivor"] = function()
		system.officialModeMessage = "<R>Aw, you cannot play survivor on #grounds"
	end,
	["racing"] = function()
		system.officialModeMessage = "<CH>Uh, racing? Good luck!"
	end,
	["music"] = function()
		system.officialModeMessage = "<BV>Music? Nice choice! Why don't you try a rock'n'roll?"
	end,
	["bootcamp"] = function()
		system.officialModeMessage = "<PT>Bootcamp? Ok. This is unfair and your data won't be saved out of the room."
	end,
	["defilante"] = function()
		system.officialModeMessage = "<R>Aw, you cannot play defilante on #grounds"
	end,
	["village"] = function()
		system.officialModeMessage = "<R>You cannot play village on #grounds. Please, change your room."
	end,
}
system.setRoom = function()
	if system.isRoom and system.roomAttributes then
		local chars = ""
		for k in next,system.roomSettings do
			chars = chars .. k
		end

		for char,value in string.gmatch(system.roomAttributes,"(["..chars.."])([^"..chars.."]+)") do
			for k,v in next,system.roomSettings do
				if k == char then
					v(value)
					break
				end
			end
		end
	end
end
