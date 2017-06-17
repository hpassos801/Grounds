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
	end
}
system.setRoom = function()
	if system.isRoom and system.roomAttributes then
		local chars = ""
		for k in next,system.roomSettings do
			chars = chars .. k
		end

		for char,value in string.gmatch(system.roomAttributes,"(["..chars.."])([^"..chars.."]+)") do
			value = string.match(value,"[^%s]+")
			for k,v in next,system.roomSettings do
				if k == char then
					v(value)
					break
				end
			end
		end
		
		local officialModes = {
			{"vanilla","<VP>Enjoy your vanilla (: .. okno"},
			{"survivor","<R>Aw, you cannot play survivor on #grounds"},
			{"racing","<CH>Uh, racing? Good luck!"},
			{"music","<BV>Music? Nice choice! Why don't you try a rock'n'roll?"},
			{"bootcamp","<PT>Bootcamp? Ok. This is unfair and your data won't be saved out of the room."},
			{"defilante","<R>Aw, you cannot play defilante on #grounds"},
			{"village","<R>You cannot play village on #grounds. Please, change your room."},
		}
		for k,v in next,officialModes do
			if string.find(system.roomAttributes,v[1] .. "$") then
				system.officialMode = {v[1],v[2]}
				break
			end
		end
	end
end
