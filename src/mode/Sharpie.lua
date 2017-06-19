mode.sharpie = {
	-- Translations
	translations = {
		en = {
			-- Init
			welcome = "Welcome to #sharpie! Fly pressing space.",

			-- Warning
			nothacker = "The mice flying are NOT hackers!",

			-- Sample words
			won = "won",
			
			-- Messages
			first = {
				"yay 2 in a row",
				"super pro",
				"oml are you playing alone or what",
				"wooow 4 in a row!",
				"getting hard? good luck pro!",
				"you noob just unlocked the title lightning",
				"woah speedmaster",
				"formula 1",
				"time traveler you sir",
				"queen of the win",
				"as pro as the developer",
				"ILLUMINATI!",
				"are you a real hacker?",
				"I hope you dont loose the chance of seeing the last message",
				"THIS IS A SHIT MESSAGE BECAUSE YOU DIDNT DESERVE IT",
			},
			hardMode = "The hard mode is activated this round!",
		},
		br = {
			welcome = "Bem-vindo ao #sharpie! Voe apertando espaço.",

			nothacker = "Os ratos voando NÃO são hackers!",

			won = "venceu",

			first = {
				"yay 2 seguidas",
				"super pro",
				"omg você tá jogando sozinho ou o que",
				"etaaa 4 seguidas!",
				"ficando difícil? boa sorte mito!",
				"vc noob acaba de desbloquear o título relâmpago",
				"vuash mestre da corrida",
				"relâmpago marquinhos",
				"viajante do tempo vc senhor",
				"rainha da vitória",
				"tão pro quanto o criador do jogo",
				"ILLUMINATI!",
				"éres um hacker de verdade?",
				"Espero que você não perca a chance de ler a última mensagem",
				"ESSA É UMA MENSAGEM DE MERDA PQ VC N MERECEU ISSO",
			},
			hardMode = "O modo difícil está ativado nessa partida!",
		},
	},
	langue = "en",
	-- New Game Settings
	firstRow = {"",0}, -- Player, amount
	podium = 0,
	totalPlayers = 0,
	hardmode = false,
	modeImages = {"15cbdb3c427","15cbdb479ca","15cbdb4a1ca","15cbdb4cae5"},
	mapInfo = {800,400},
	-- Init
	init = function()
		-- Warning
		system.newTimer(function()
			tfm.exec.chatMessage("<B>[•] " .. system.getTranslation("nothacker") .. "</B>")
		end,20000,true)

		-- Init
		tfm.exec.disableAutoShaman()
		tfm.exec.disableAutoScore()
	end,
	-- New Game
	eventNewGame = function()
		mode.sharpie.podium = 0

		local xml = tfm.get.room.xmlMapInfo
		xml = xml and xml.xml or ""
		local properties = string.match(xml,"<C><P (.-)/>.*<Z>")
		if properties then
			mode.sharpie.mapInfo[1] = string.match(properties,'L="(%d+)"') or 800
			mode.sharpie.mapInfo[2] = string.match(properties,'H="(%d+)"') or 400
		else	
			mode.sharpie.mapInfo = {800,400}
		end

		mode.sharpie.hardmode = math.random(10) == 6
		if mode.sharpie.hardmode then
			tfm.exec.chatMessage("<CH>" .. system.getTranslation("hardMode"))
		end
	end,
	-- New Player
	eventNewPlayer = function(n)
		tfm.exec.chatMessage("<CE>" .. system.getTranslation("welcome"),n)

		system.bindKeyboard(n,32,true,true)
	end,
	-- Keyboard
	eventKeyboard = function(n,k)
		if k == 32 then
			tfm.exec.movePlayer(n,0,0,true,0,-50,true)
		end
	end,
	-- Victory
	eventPlayerWon = function(n)
		mode.sharpie.podium = mode.sharpie.podium + 1
		if mode.sharpie.podium == 1 then
			if mode.sharpie.firstRow[1] == n then
				mode.sharpie.firstRow[2] = mode.sharpie.firstRow[2] + 1
				
				if mode.sharpie.totalPlayers > 3 then
					local msg = system.getTranslation("first")
					tfm.exec.chatMessage("<G># <ROSE>" .. (msg[mode.sharpie.firstRow[2] - 1] or table.random({msg[2],msg[3],msg[6],msg[13],msg[15]})),n)
				end
			else
				mode.sharpie.firstRow = {n,1}
			end

			tfm.exec.setPlayerScore(n,(mode.sharpie.firstRow[2]+1) * 5,true)

			tfm.exec.chatMessage(string.format("<J>%s %s! %s",n,system.getTranslation("won"),mode.sharpie.firstRow[2] > 1 and "("..mode.sharpie.firstRow[2]..")" or ""))
		else
			tfm.exec.setPlayerScore(n,5,true)
		end
	end,
	-- Loop
	eventLoop = function()
		if _G.currentTime % 5 == 0 then
			local alive,total = system.players()
			mode.sharpie.totalPlayers = total
		end

		if mode.sharpie.hardmode and _G.currentTime % 14 == 0 then
			system.newTimer(function()
				local x,y = math.random(0,mode.sharpie.mapInfo[1]),math.random(0,mode.sharpie.mapInfo[2])
				local id = tfm.exec.addImage(table.random(mode.sharpie.modeImages) .. ".png","&0",x - 56,y - 51) -- 112x103 img
				system.newTimer(function()
					tfm.exec.removeImage(id)

					tfm.exec.displayParticle(24,x,y)
					tfm.exec.explosion(x,y,50,100)
				end,1000,false)
			end,1000,false)
		end
	end,
}
