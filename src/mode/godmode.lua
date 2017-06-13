mode.godmode = {
	-- Translations
	translations = {
		en = {
			-- Init
			welcome = "Welcome to <B>#godmode</B>. Type !info to read the help message.\n\tReport any issue to Bolodefchoco.",

			-- Guide
			shaman = "Hello shaman! Try to build without nails! Good luck.",

			-- Info
			xp = "You've saved %s mice, but %s died.",

			-- Warning
			nail = "You can use %s more nails. After that, you will die.",
			kill = "Try not to use nails in your buildings.",
			fail = "You failed!",
		},
		br = {
			welcome = "Bem-vindo ao <B>#godmode</B>. Digite !info para ler a mensagem de ajuda.\n\tReporte qualquer problema para Bolodefchoco.",

			shaman = "Olá shaman! Tente construir sem pregos! Boa sorte.",

			xp = "Você salvou %s ratos, mas %s morreram.",

			nail = "Você pode usar mais %s pregos. Depois disso, você morrerá.",
			kill = "Tente não usar pregos em suas construções.",
			fail = "Você falhou!",
		},
	},
	langue = "en",
	-- Data
	info = {},
	-- Shaman
	getShaman = function()
		local s = {}
		for k,v in next,tfm.get.room.playerList do
			if v.isShaman then
				s[#s + 1] = k
			end
		end

		return s
	end,
	-- New Game Settings
	savedMice = 0,
	deadMice = 0,
	-- Init
	init = function()
		mode.godmode.translations.pt = mode.godmode.translations.br
		mode.godmode.langue = mode.godmode.translations[tfm.get.room.community] and tfm.get.room.community or "en"

		tfm.exec.disableAutoNewGame()
		tfm.exec.newGame(table.random({"#4","#8"}))
	end,
	-- New Player
	eventNewPlayer = function(n)
		if not mode.godmode.info[n] then
			mode.godmode.info[n] = {
				usedNails = 0,
				roundSha = 0,
				deathSha = 0,
				deathMice = 0,
				cheeseMice = 0,
			}
		end

		for k,v in next,{66,67,74,78,86} do
			system.bindKeyboard(n,v,true,true)
		end

		tfm.exec.chatMessage("<ROSE>" .. system.getTranslation("welcome"),n)
	end,
	-- New Game
	eventNewGame = function()
		mode.godmode.savedMice = 0
		mode.godmode.deadMice = 0

		for k,v in next,mode.godmode.info do
			v.usedNails = 0
		end
		for k,v in next,mode.godmode.getShaman() do
			mode.godmode.info[v].roundSha = mode.godmode.info[v].roundSha + 1
			tfm.exec.chatMessage("<CH>" .. system.getTranslation("shaman"),v)
		end

	end,
	-- Keyboard
	eventKeyboard = function(n,k)
		if not tfm.get.room.playerList[n].isDead and tfm.get.room.playerList[n].isShaman then
			if table.find({66,67,74,78,86},k) then -- B;C;V;N;J
				mode.godmode.info[n].usedNails = mode.godmode.info[n].usedNails + 1
				if mode.godmode.info[n].usedNails > 4 then
					tfm.exec.killPlayer(n)
					tfm.exec.chatMessage("<R>" .. system.getTranslation("fail") .. " " .. system.getTranslation("kill"),n)
				else
					tfm.exec.chatMessage("<R>" .. string.format(system.getTranslation("nail"),5 - mode.godmode.info[n].usedNails),n)
				end
			end
		end
	end,
	-- Summoned
	eventSummoningEnd = function(n,o,x,y,a,i)
		tfm.exec.removeObject(i.id)
		
		tfm.exec.addShamanObject(o,x,y,a,i.vx,i.vy,i.ghost)
	end,
	-- Loop
	eventLoop = function()
		local alive,total = system.players()
		if _G.leftTime < 2 or (total > 1 and alive < 2) or alive == 0 then
			if _G.leftTime < 2 then
				for k,v in next,mode.godmode.getShaman() do
					mode.godmode.info[v].cheeseMice = mode.godmode.info[v].cheeseMice + mode.godmode.savedMice
					mode.godmode.info[v].deathMice = mode.godmode.info[v].deathMice + mode.godmode.deadMice
					tfm.exec.chatMessage("<CH>" .. string.format(system.getTranslation("xp"),mode.godmode.savedMice,mode.godmode.deadMice),v)
				end
			end
			tfm.exec.newGame(table.random({"#4","#8"}))
		end
	end,
	-- Player Died
	eventPlayerDied = function(n)
		if tfm.get.room.playerList[n].isShaman then
			tfm.exec.setGameTime(10,false)
	
