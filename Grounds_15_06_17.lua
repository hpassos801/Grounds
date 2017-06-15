--Creator: Bolodefchoco
--Made in: 06/02/2017
--Last update: 15/06/2017

--[[ Module ]]--
local module = {
	_VERSION = "3.3",
	_NAME = "grounds",
	_STATUS = "semi-official",
	_AUTHOR = "Bolodefchoco",
	_LICENSE = [[
		MIT LICENSE
		
		Copyright (c) 2017 @Transformice + @Bolodefchoco
		
		Permission is hereby granted, free of charge, to any person obtaining
		a copy of this software and associated documentation files (the
		"Software"), to deal in the Software without restriction, including
		without limitation the rights to use, copy, modify, merge, and to
		permit persons to whom the Software is furnished to do so, subject to
		the following conditions:

		The above copyright notice and this permission notice shall be included
		in all copies or substantial portions of the Software.

		THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
		OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF FITNESS FOR
		A PARTICULAR PURPOSE AND NONINFRINGEMENT.
		IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
		CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
		TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
		SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
	]]
}

--[[ API ]]--
	-- Timers
system.newGameTimer = 0

	-- Improvements
table.concat = function(list,sep,f,i,j)
	local txt = ""
	sep = sep or ""
	i,j = i or 1,j or #list
	for k,v in next,list do
		if k >= i and k <= j then
			txt = txt .. (f and f(k,v) or v) .. sep
		end
	end
	return string.sub(txt,1,-1-#sep)
end
do
	local newGame = tfm.exec.newGame
	tfm.exec.newGame = function(code)
		if os.time() > system.newGameTimer then
			system.newGameTimer = os.time() + 6000
			newGame(code)
			return true
		end
		return false
	end
	
	local addImage = tfm.exec.addImage
	local removeImage = tfm.exec.removeImage
	tfm.exec.addImage = function(...)
		local id = addImage(...)
		if id then
			system.objects.image[id] = true
		end
		return id
	end
	tfm.exec.removeImage = function(id)
		removeImage(id)
		if system.objects.image[id] then
			system.objects.image[id] = nil
		end
	end
	
	local addTextArea = ui.addTextArea
	ui.addTextArea = function(id,...)
		addTextArea(id,...)
		if not system.objects.textarea[id] then
			system.objects.textarea[id] = true
		end
	end
end

	-- Room
system.isRoom = string.byte(tfm.get.room.name,2) ~= 3
system.roomAdmins = {Bolodefchoco = true}
system.miscAttrib = 0
system.roomNumber,system.roomAttributes = (function()
	if system.isRoom then
		local number,attribute = string.match(tfm.get.room.name,"%*?#"..module._NAME.."(%d+)(.*)")
		return tonumber(number) or "",attribute or ""
	else
		return "",""
	end
end)()

	-- Player
system.isPlayer = function(n)
	--[[
		The player must not be a souris;
		The player must have played Transformice for at least 5 days
	]]
	return tfm.get.room.playerList[n] and string.sub(n,1,1) ~= "*" and tfm.get.room.playerList[n].registrationDate and (os.time() - (tfm.get.room.playerList[n].registrationDate or 0) >= 432e6) or false
end
system.players = function(alivePlayers)
	local alive,total = 0,0
	if alivePlayers then
		alive = {}
	end
	for k,v in next,tfm.get.room.playerList do
		if system.isPlayer(k) then
			if not v.isDead and not v.isVampire then
				if alivePlayers then
					alive[#alive + 1] = k
				else
					alive = alive + 1
				end
			end
			total = total + 1
		end
	end
	if alivePlayers then
		return alive
	else
		return alive,total
	end
end

	-- System
currentTime,leftTime = 0,0
system.loadTable = function(s)
	-- "a.b.c.1" returns a[b][c][1]
	local list
	for tbl in string.gmatch(s,"[^%.]+") do
		tbl = tonumber(tbl) and tonumber(tbl) or tbl
		list = (list and list[tbl] or _G[tbl])
	end
	return list
end
system.getTranslation = function(index,n)
	local t = string.format("mode.%s.translations.%s.%s",system.gameMode,(n and mode[system.gameMode].info[n].langue or mode[system.gameMode].langue),index)
	return system.loadTable(t) or system.loadTable(string.gsub(t,"translations%..-%.",function() return "translations.en." end))
end
system.looping = function(f,tick)
	local s = 1000 / tick
	local t = {}
	for timer = 0,1000 - s,s do
		system.newTimer(function()
			t[#t+1] = system.newTimer(f,1000,true)
		end,1000 + timer,false)
	end
	return t
end

	-- Math
math.isNegative = function(x,iN,iP)
	return (x<0 and (iN or x) or (iP or x))
end
math.percent = function(x,y,v)
	v = (v or 100)
	local m = x/y * v
	return math.min(m,v)
end
math.pythag = function(x1,y1,x2,y2,range)
	return (x1-x2)^2 + (y1-y2)^2 <= (range^2)
end

	-- String
string.split = function(value,pattern,f)
	local out = {}
	for v in string.gmatch(value,pattern) do
		out[#out + 1] = (f and f(v) or v)
	end
	return out
end
string.nick = function(player)
	return string.gsub(string.lower(player),"%a",string.upper,1)
end

	-- Table
table.find = function(list,value,index,f)
	for k,v in next,list do
		local i = (type(v) == "table" and index and v[index] or v)
		if (f and f(i) or i) == value then
			return true,k
		end
	end
	return false,0
end
table.turnTable = function(x)
	return (type(x)=="table" and x or {x})
end
table.random = function(t)
	return (type(t) == "table" and t[math.random(#t)] or math.random())
end
table.shuffle = function(t)
	local randomized = {}
	for v = 1,#t do
		table.insert(randomized,math.random(#randomized),t[v])
	end
	return randomized
end

	-- Others
deactivateAccents=function(str)
	local letters = {a = {"á","â","à","å","ã","ä"},e = {"é","ê","è","ë"},i = {"í","î","ì","ï"},o = {"ó","ô","ò","õ","ö"},u = {"ú","û","ù","ü"}}
	for k,v in next,letters do
		for i = 1,#v do
			str = string.gsub(str,v[i],tostring(k))
		end
	end
	return str
end
normalizeTime = function(time)
	return math.floor(time) + ((time - math.floor(time)) >= .5 and .5 or 0)
end
disableChatCommand = function(command)
	system.disableChatCommandDisplay(command,true)
	system.disableChatCommandDisplay(string.lower(command),true)
	system.disableChatCommandDisplay(string.upper(command),true)
end	
normalizeTranslation = function()
	local t = mode[system.gameMode].translations

	for k,v in next,t.en do
		for i,j in next,t do
			if i ~= "en" then
				if not j[k] then
					j[k] = v
				end
			end
		end
	end
end

	-- XML Dealer
xml = {}
xml.parse = function(currentXml)
	currentXml = string.match(currentXml,"<P (.-)/>") or ""
	local out = {}
	for tag,_,value in string.gmatch(currentXml,"([%-%w]+)=([\"'])(.-)%2") do
		out[tag] = value
	end
	return out
end
xml.attribFunc = function(currentXml,funcs)
	local attributes = xml.parse(currentXml)
	for k,v in next,funcs do
		if attributes[v.attribute] then
			v.func(attributes[v.attribute])
		end
	end
end
xml.addAttrib = function(currentXml,out,launch)
	local parameters = string.match(currentXml,"<P (.-)/>") or ""
	for k,v in next,out do
		if not string.find(parameters,v.tag) then
			currentXml = string.gsub(currentXml,"<P (.-)/>",function(attribs)
				return string.format("<P %s=\"%s\" %s/>",v.tag,v.value,attribs)
			end)
		end
	end
	if launch then
		tfm.exec.newGame(currentXml)
	else
		return currentXml
	end
end
xml.getCoordinates = function(s)
	if string.find(s,";") then
		local x,y
		local axis,value = string.match(s,"(%a);(%d+)")
		value = tonumber(value)
		if value then
			if axis == "x" then x = value else y = value end
		end
		return x or 0,y or 0
	else
		local pos = {}
		for x,y in string.gmatch(s,"(%d+) ?, ?(%d+)") do
			pos[#pos+1] = {x = x,y = y}
		end
		return pos
	end
end

--[[ Game Mode System ]]--
system.normalizedModeName = function(name,back)
	if back then
		name = string.gsub(name,"%+","P") -- Test+ = TestP
	else
		name = string.gsub(name,"P$","+") -- TestP = Test+
	end
	return name
end

system.submodes = {}

system.gameMode = module._NAME
system.modeChanged = os.time() + 10e3

system.getGameMode = function(value)
	local found,submode = table.find(system.submodes,string.lower(value),nil,string.lower)
	if found then
		system.gameMode = system.normalizedModeName(system.submodes[submode],true)
		
		eventModeChanged()
		
		system.modeChanged = os.time() + 10e3
	end
	return found
end

--[[ Modes ]]--
mode = setmetatable({},{
	__newindex = function(list,key,value)
		rawset(list,key,value)
		system.submodes[#system.submodes+1] = system.normalizedModeName(key,false)
	end
})

--[[ Grounds ]]--
mode.grounds = {
	-- Translations
	translations = {
		en = {
			-- Data
			grounds = {
				-- Ground, Description
				[0] = {"Wood","?","?"},
				[1] = {"Ice","Increases your speed by pressing spacebar","Increases the speed in <BL>%s%%</BL>"},
				[2] = {"Trampoline","?","?"},
				[3] = {"Lava","Teleports you to the last Z indexed ground","?"},
				[4] = {"Chocolate","?","?"},
				[5] = {"Earth","?","?"},
				[6] = {"Grass","?","?"},
				[7] = {"Sand","Creates a sand storm","Decreases the storm in <BL>%s%%</BL>"},
				[8] = {"Cloud","Enables you to fly by pressing spacebar","Increases the fly in <BL>%s%%</BL>"},
				[9] = {"Water","Drowns you","Drowns you <BL>%s%%</BL> slower"},
				[10] = {"Stone","Creates a block of stone by pressing spacebar","Increases the block size in <BL>%s%%</BL>"},
				[11] = {"Snow","Shoots snowballs by pressing spacebar","Increases the snowball speed in <BL>%s%%</BL>"},
				[12] = {"Rectangle","Each color has its own function","?",{
					["C90909"] = "Kills you",
					["18C92B"] = "Revives all the enemies",
					["555D77"] = "Respawning Checkpoint",
				}},
				[13] = {"Circle","Each color has its own function","?"},
				[14] = {"Invisible","?","?"},
				[15] = {"Spiderweb","Teleports you to the spawn point","?"},
			},
			categories = {
				[1] = "Often long maps that, in most of the cases, the players must pass the same obstacles more than once.",
				[2] = "Usually long maps with dodgeable spiderwebs or lavas, sometimes using invisible waters to simule a fly.",
				[3] = "Harder maps that requires multiple skills to be completed.",
				[4] = "Maps that has as main obstacle the water drowning.",
				[5] = "Maps based mainly on lava teleports.",
				[6] = "Maps that requires a new skill, with mechanisms or something that makes you think before act.",
				[7] = "Maps based on speed and agility, built mostly with ice grounds.",
				[8] = "Maps based on snowball mechanisms/technics.",
				[9] = "Maps with different gameplays that doesn't fit any other category, also locates the <i>vanilla maps</i>.",
				[10] = "Soloable (mostly) maps, but with faster paths when the players work together.",
				[11] = "Maps with vampires.",
			},

			-- Init
			welcome = "Welcome to #%s! Can you be the fastest mouse using the ground effects? Try it!\n<PS>Press H for more info!",
			developer = "Developed by %s",
			
			-- Shop
			shop = {
				coin = "Coins",
				power = "Ground power",
				upgrade = "Upgrade",
				price = "Upgrade price",
				close = "Close",
			},
			bought = "You just spent %s coins for the ground %s!",
			cantbuy = "You haven't coins enough in order to buy this upgrade! :(",
			
			-- Profile
			profile = "Leaderboard : %s\n\n<N>Rounds : %s\n<N>Podiums : %s\n\n<N>Deaths : %s\n\n<N>Shop Coins : %s",
			
			-- Gameplay
			gotcoin = "You just got %s coins! :D",
			zombie = "Now you are a zombie!",
			countstats = {
				mice = "At least 5 mice are needed to stats count",
				tribe = "Stats do not count in tribe houses"
			},
			
			-- New map
			powersenabled = "The ground powers were enabled! Good luck!",
			
			-- Language
			language = "Current language : <J>%s",
			
			-- Settings
			password = {
				on = "New password : %s",
				off = "Password disabled!"
			},
			
			-- Commands
			commands = {
				shop = "shop",
				profile = "profile",
				help = "help",
				langue = "langue",
				leaderboard = "leaderboard",
				info = "info",
				pw = "password",
				mapinfo = "mapinfo",
			},
			
			-- Menu
			menu = {
				[1] = {"%s","\tYour aim in this minigame is to collect the cheese the faster you can, using the effects each ground offers."},
				[2] = {"Ground effects","Click in the ground's name to read more.\n\n%s"},
				[3] = {"Commands",{
					[1] = {"\t<J>» User</J>\n",{
						[1] = "<VP>!%s</VP> <PS>playerName</PS> <R>or</R> <VP>Key P</VP> - Opens the profile!",
						[2] = "<VP>!%s</VP> <R>or</R> <VP>Key O</VP> - Opens the shop!",
						[3] = "<VP>!%s</VP> - Changes the language!",
					}},
					[2] = {"\n\t<J>» Others</J>\n",{
						[1] = "<VP>!%s</VP> <R>or</R> <VP>Key H</VP> - Opens the help menu!",
						[2] = "<VP>!%s</VP> - Opens the leaderboard!",
						[3] = "<VP>!%s</VP> - Opens the help according to the ground you are on!",
						[4] = "<VP>!%s</VP> - Displays the map info if it is in the rotation!",
					}},
					[3] = {"\n\t<J>» Room admin</J>\n",{
						[1] = "<VP>!%s</VP> <PS>password</PS> - Adds or removes a password in the room!",
					}},
				}},
				[4] = {"Maps","<J>Maps : %s\n\n\tAccess %s and send your map. Do not forget to read all the rules before!"},
				[5] = {"Thanks for","<R>%s <G>- <N>Developer\n%s <G>- <N>Translators\n%s <G>- <N>Map evaluators"},
			},
			max = "15a2df47d2e",
		},
		br = {
			grounds = {
				[0] = {"Madeira","?","?"},
				[1] = {"Gelo","Aumenta sua velocidade ao pressionar a barra de espaço","Aumenta a velocidade em <BL>%s%%</BL>"},
				[2] = {"Trampolim","?","?"},
				[3] = {"Lava","Teletransporta-o para o piso de Z anterior","?"},
				[4] = {"Chocolate","?","?"},
				[5] = {"Terra","?","?"},
				[6] = {"Grama","?","?"},
				[7] = {"Areia","Cria uma tempestade de areia","Diminui a tempestade em <BL>%s%%</BL>"},
				[8] = {"Nuvem","Permite o voo ao pressionar a barra de espaço","Aumenta o voo em <BL>%s%%</BL>"},
				[9] = {"Água","Afoga-o","Afoga-o <BL>%s%%</BL> mais devagar"},
				[10] = {"Pedra","Cria um bloco de pedra ao pressionar a barra de espaço","Aumenta o tamanho do bloco em <BL>%s%%</BL>"},
				[11] = {"Neve","Atira bolas de neve ao pressionar a barra de espaço","Aumenta a velocidade da bola de neve em <BL>%s%%</BL>"},
				[12] = {"Retângulo","Cada cor tem sua própria função","?",{
					["C90909"] = "Mata-o",
					["18C92B"] = "Revive todos os inimigos",
					["555D77"] = "Checkpoint para reviver",
				}},
				[13] = {"Círculo","Cada cor tem sua própria função","?","?"},
				[14] = {"Invisível","?","?"},
				[15] = {"Teia de aranha","Teletransporta-o para o ponto de spawn","?"},
			},
			categories = {
				[1] = "Geralmente mapas longos que, na maioria dos casos, os jogadores devem passar pelo mesmo obstáculo mais de uma vez.",
				[2] = "Geralmente mapas grandes com teias de aranha ou lavas desviáveis, às vezes usando águas invisíveis para simular voo.",
				[3] = "Mapas mais difíceis que requem múltiplas habilidades para serem completados.",
				[4] = "Mapas que tem como obstáculo principal o afogamento na água.",
				[5] = "Mapas baseados principalmente em teleportes de lava.",
				[6] = "Mapas que requerem novas habilidades, com mecanismos ou algo que o faça pensar antes de agir.",
				[7] = "Mapas baseados em velocidade e agilidade, construídos em sua maioria por pisos de gelo.",
				[8] = "Mapas baseados em mecanismos/técnicas com bolas de neve.",
				[9] = "Mapas com gameplays diferentes que não se encaixam em nenhuma outra categoria, também dá espaço aos <i>mapas vanilla</i>.",
				[10] = "Mapas em que você pode completar sozinho (em maioria), mas com caminhos mais rápidos quando há trabalho em equipe entre os jogadores.",
				[11] = "Mapas com vampiros.",
			},
			
			welcome = "Bem-vindo ao #%s! Você pode ser o rato mais rápido usando os efeitos dos pisos? Prove!\n<PS>Pressione H para mais informações!",
			developer = "Desenvolvido por %s",
			
			shop = {
				coin = "Moedas",
				power = "Poder do piso",
				upgrade = "Melhorar",
				price = "Preço de aprimoramento",
				close = "Fechar",
			},
			bought = "Você acaba de gastar %s moedas pelo piso %s!",
			cantbuy = "Você não tem moedas suficientes para comprar esta atualização! :(",
			
			profile = "Rank : %s\n\n<N>Partidas : %s\n<N>Pódios : %s\n\n<N>Mortes : %s\n\n<N>Moedas na loja : %s",
			
			gotcoin = "Você acaba de conseguir %s moedas! :D",
			zombie = "Agora você é um zumbi!",
			countstats = {
				mice = "Ao menos 5 ratos são necessários para as estatísticas serem contabilizadas",
				tribe = "Estatísticas não são contabilizadas em cafofos de tribo"
			},
			
			powersenabled = "Os poderes dos pisos foram ativados! Boa sorte!",
			
			language = "Idioma atual : <J>%s",
			
			password = {
				on = "Nova senha : %s",
				off = "Senha desativada!"
			},

			commands = {
				shop = "loja",
				profile = "perfil",
				help = "ajuda",
				langue = "idioma",
				leaderboard = "rank",
				info = "info",
				pw = "senha",
			},
			
			menu = {
				[1] = {"%s","\tSeu objetivo neste mini-game é coletar o queijo o mais rápido possível, utilizando os efeitos que cada piso oferecer."},
				[2] = {"Efeitos dos pisos","Clique no nome do piso para ler mais.\n\n%s"},
				[3] = {"Comandos",{
					[1] = {"\t<J>» Usuário</J>\n",{
						[1] = "<VP>!%s</VP> <PS>nomeDoJogador</PS> <R>ou</R> <VP>Tecla P</VP> - Abre o perfil!",
						[2] = "<VP>!%s</VP> <R>ou</R> <VP>Tecla O</VP> - Abre a loja!",
						[3] = "<VP>!%s</VP> - Altera o idioma!",
					}},
					[2] = {"\n\t<J>» Outros</J>\n",{
						[1] = "<VP>!%s</VP> <R>ou</R> <VP>Tecla H</VP> - Abre o menu de ajuda!",
						[2] = "<VP>!%s</VP> - Abre o ranking!",
						[3] = "<VP>!%s</VP> - Abre a ajuda de acordo com o piso que você está pisando!",
						[4] = "<VP>!%s</VP> - Mostra as informações do mapa se estiver na rotação!",
					}},
					[3] = {"\n\t<J>» Administrador da sala</J>\n",{
						[1] = "<VP>!%s</VP> <PS>senha</PS> - Adiciona ou remove uma senha na sala!",
					}},
				}},
				[4] = {"Mapas","<J>Mapas : %s\n\n\tAcesse %s e envie seu mapa. Não se esqueça de ler todas as regras antes!"},
				[5] = {"Agradecimentos","<R>%s <G>- <N>Desenvolvedor\n%s <G>- <N>Tradutores\n%s <G>- <N>Avaliadores de mapa"},
			},
			max = "15a2df3e699",
		},
		es = {
			grounds = {
				[0] = {"Madera","?","?"},
				[1] = {"Hielo","Incrementa tu velocidad apretando espacio","Aumenta la velocidad en <BL>%s%%</BL>"},
				[2] = {"Trampolín","?","?"},
				[3] = {"Lava","Te teletransporta al suelo que tenga el último Z index","?"},
				[4] = {"Chocolate","?","?"},
				[5] = {"Tierra","?","?"},
				[6] = {"Hierba","?","?"},
				[7] = {"Arena","Crea una tormenta de arena","Disminuye la tormenta en <BL>%s%%</BL>"},
				[8] = {"Nube","Te permite volar presionando espacio","Aumenta el vuelo en <BL>%s%%</BL>"},
				[9] = {"Agua","Te ahogas","Te ahogas <BL>%s%%</BL> más lento"},
				[10] = {"Piedra","Crea un bloque de piedra presionando espacio","Aumenta el tamaño del bloque en <BL>%s%%</BL>"},
				[11] = {"Nieve","Dispara bolas de nieve presionando espacio","Aumenta la velocidad de la bola de nieve en <BL>%s%%</BL>"},
				[12] = {"Rectángulo","Cada color tiene su propia función","?",{
					["C90909"] = "Te mata",
					["18C92B"] = "Revive todos los enemigos",
					["555D77"] = "Respawning Checkpoint", -- *
				}},
				[13] = {"Círculo","Cada color tiene su propia función","?"},
				[14] = {"Invisible","?","?"},
				[15] = {"Tela de araña","Te teletransporta al punto de aparición","?"},
			},
			categories = {
				[1] = "Mapas que, en la mayoría de los casos, los jugadores deben pasar obstaculos más de una vez.",
				[2] = "Usualmente mapas largos con telas de araña y lavas esquivables, algunas veces usando agua invisible para simular un vuelo.",
				[3] = "Mapas difíciles que necesitan una gran habilidad para completarlos.",
				[4] = "Mapas que tienen un obstáculo principal: el agua. ¡Te puedes ahogar!.",
				[5] = "Mapas basados principalmente en teletransportes de lava.",
				[6] = "Mapas que necesitan una nueva habilidad, con mecanismos o algo que te haga pensar antes de actuar.",
				[7] = "Mapas basados en la velocidad del jugador, construidos mayoritariamente con suelos de hielo.",
				[8] = "Mapas basados en mecanismos/técnicas con nieve.",
				[9] = "Mapas con un gameplay diferente que no entran en otra categoría, también localizados en los <i>mapas vanilla</i>.",
				[10] = "Mapas que (mayoritariamente) pueden ser completados solo, pero con patrones rápidos donde los jugadores necesitan trabajar juntos.",
				[11] = "Mapas con vampiros.",
			},
			
			welcome = "Bienvenido a #%s! Podrás ser el más rápido usando los efectos de los suelos? Inténtalo!\n<PS>Presiona H para más información!",
			developer = "Programado por %s",
			
			shop = {
				coin = "Monedas",
				power = "Potencia del suelo",
				upgrade = "Mejorar",
				price = "Precio de la mejora",
				close = "Cerrar",
			},
			bought = "Has gastado %s monedas para el suelo %s!",
			cantbuy = "No tienes las suficientes monedas para comprar esta mejora! :(",

			profile = "Tabla de líderes : %s\n\n<N>Rondas : %s\n<N>Podios : %s\n\n<N>Muertes : %s\n\n<N>Monedas : %s",

			gotcoin = "Has obtenido %s monedas! :D",
			zombie = "Ahora eres un Zombi!",
			countstats = {
				mice = "Por lo menos 5 ratones son necesarios para contar estadísticas",
				tribe = "Las estadísticas no cuentan en casas de tribu"
			},
			
			powersenabled = "Los poderes de los suelos han sido activados! Buena suerte!",
			
			language = "Idioma actual : <J>%s",
			
			password = {
				on = "Nueva contraseña : %s",
				off = "Contraseña desactivada!"
			},
			
			commands = {
				shop = "tienda",
				profile = "perfil",
				help = "ayuda",
				langue = "idioma",
				leaderboard = "ranking",
				info = "info",
				pw = "contraseña",
			},
			
			menu = {
				[1] = {"%s","\tTu objetivo en este juego es agarrar el queso lo más rápido que puedas, usando los efectos que cada suelo ofrece."},
				[2] = {"Efectos de suelo","Clickea en el nombre del suelo para leer más.\n\n%s"},
				[3] = {"Comandos",{
					[1] = {"\t<J>» Usuario</J>\n",{
						[1] = "<VP>!%s</VP> <PS>nombreDeUsuario</PS> <R>o</R> <VP>Tecla P</VP> - Abre el perfil!",
						[2] = "<VP>!%s</VP> <R>o</R> <VP>Tecla O</VP> - Abre la tienda!",
						[3] = "<VP>!%s</VP> - Cambia el idioma!\n",
					}},
					[2] = {"\t<J>» Otros</J>\n",{
						[1] = "<VP>!%s</VP> <R>o</R> <VP>Tecla H</VP> - Abre el menu de ayuda!",
						[2] = "<VP>!%s</VP> - Abre el ranking!",
						[3] = "<VP>!%s</VP> - Abre la guía del suelo en el que estás!",
						[4] = "<VP>!%s</VP> - Muestra la información del mapa si está en la rotación!",
					}},
					[3] = {"\n\t<J>» Admin de la sala</J>\n",{
						[1] = "<VP>!%s</VP> <PS>contraseña</PS> - Activa o desactiva la contraseña en la sala.",
					}},
				}},
				[4] = {"Mapas","<J>Mapas : %s\n\n\tEntra a %s y envía tu mapa. No olvides leer las reglas antes!"},
				[5] = {"Agradecimientos","<R>%s <G>- <N>Programador\n%s <G>- <N>Traductores\n%s <G>- <N>Evaluadores de mapas"},
			},
			max = "15a2df3e699",
		},
		fr = {
			grounds = {
				[0] = {"Bois","?","?"},
				[1] = {"Glace","Augmente votre vitesse en appuyant sur Espace","Augmente la vitesse de <BL>%s%%</BL>"},
				[2] = {"Trampoline","?","?"},
				[3] = {"Lave","Vous téléporte au sol avec le dernier indice Z","?"},
				[4] = {"Chocolat","?","?"},
				[5] = {"Terre","?","?"},
				[6] = {"Herbe","?","?"},
				[7] = {"Sable","Crée une tempête de sable","Diminue la tempête de <BL>%s%%</BL>"},
				[8] = {"Nuage","Vous donne la possibilité de voler en appuyant sur Espace","Augmente le vol de <BL>%s%%</BL>"},
				[9] = {"Eau","Vous noie","Vous noie <BL>%s%%</BL> plus lentement"},
				[10] = {"Pierre","Crée un bloc de pierre en appuyant sur Espace","Augmente la taille du bloc de <BL>%s%%</BL>"},
				[11] = {"Neige","Tire des boules de neige en appuyant sur Espace","Augmente la vitesse de la boule de neige de <BL>%s%%</BL>"},
				[12] = {"Rectangle","Chaque couleur a sa propre fonction","?",{
					["C90909"] = "Te tue",
					["18C92B"] = "Ressuscite tous les ennemis",
					["555D77"] = "Respawning Checkpoint", -- *
				}},
				[13] = {"Cercle","Chaque couleur a sa propre fonction","?"},
				[14] = {"Invisible","?","?"},
				[15] = {"Toile d'araignée","Vous téléporte au point de spawn","?"},
			},
			-- *
			
			welcome = "Bienvenue à #%s! Pouvez vous être la souris la plus rapide grâce aux effets des sols? Essayez!\n<PS>Appuyez sur H pour plus d'informations!",
			developer = "Développé par %s",

			shop = {
				coin = "Pièces",
				power = "Force du sol",
				upgrade = "Améliorer",
				price = "Coût d'amélioration",
				close = "Fermer",
			},
			bought = "Vous venez de dépenser %s pièces pour le sol %s!",
			cantbuy = "Vous n'avez pas assez de pièces pour acheter cette amélioration! :(",
			
			profile = "Leaderboard : %s\n\n<N>Parties : %s\n<N>Podiums : %s\n\n<N>Morts : %s\n\n<N>Shop Pièces : %s",
			
			gotcoin = "Vous venez de recevoir %s pièces! :D",
			countstats = {
				mice = "Au moins 5 souris sont nécessaires pour que les statistiques comptent",
				tribe = "Les statistiques ne comptent pas en maison de tribu"
			},
			zombie = "Vous êtes maintenant un zombie!",
			
			powersenabled = "Les pouvoirs des sols ont été activés! Bonne chance!",
			
			language = "Langage actuel : <J>%s",
			
			password = {
				on = "Nouveau mot de passe : %s",
				off = "Mot de passe désactivé!"
			},
			
			commands = {
				shop = "magasin",
				profile = "profil",
				help = "aide",
				langue = "langue",
				leaderboard = "leaderboard",
				info = "info",
				pw = "password",
			},
			
			menu = {
				[1] = {"%s","\tVotre but dans ce minijeu est de collecter le fromage aussi vite que possible, en utilisant les effets des différents sols."},
				[2] = {"Effets du sol","Clique sur le nom du salon pour en lire plus.\n\n%s"},
				[3] = {"Commandes",{
					[1] = {"\t<J>» Joueur</J>\n",{
						[1] = "<VP>!%s</VP> <PS>playerName</PS> <R>ou</R> <VP>Touche P</VP> - Ouvre le profil !",
						[2] = "<VP>!%s</VP> <R>ou</R> <VP>Touche O</VP> - Ouvre le magasin !",
						[3] = "<VP>!%s</VP> - Change la langue !\n",
					}},
					[2] = {"\t<J>» Autres</J>\n",{
						[1] = "<VP>!%s</VP> <R>ou</R> <VP>Touche H</VP> - Ouvre le menu d'aide !",
						[2] = "<VP>!%s</VP> - Ouvre le leaderboard!",
						[3] = "<VP>!%s</VP> - Ouvre l'aide en fonction du sol sur lequel vous vous trouvez!",
						[4] = "<VP>!%s</VP> - Affiche les informations de la carte si elle est dans la rotation!"
					}},
					[3] = {"\n\t<J>» Place admin</J>\n",{
						[1] = "<VP>!%s</VP> <PS>mot de passe</PS> - Ajoute ou supprime un mot de passe dans la chambre.",
					}},
				}},
				[4] = {"Cartes","<J>Cartes : %s\n\n\tAccédez à %s et envoyez votre carte. N'oubliez pas de lire toutes les règles avant!"},
				[5] = {"Merci à","<R>%s <G>- <N>Développeur\n%s <G>- <N>Traducteurs\n%s <G>- <N>Evaluateurs de maps"},
			},
			-- *
		},
		pl = {
			grounds = {
				[0] = {"Drewno","?","?"},
				[1] = {"Lód","Zwiększa twoją szybkość, gdy klikasz spację","Zwiększa prędkość w <BL>%s%%</BL>"},
				[2] = {"Trampolina","?","?"},
				[3] = {"Lawa","Przenosi ciebie do ostatniego indexu Z","?"},
				[4] = {"Czekolada","?","?"},
				[5] = {"Ziemia","?","?"},
				[6] = {"Trawa","?","?"},
				[7] = {"Piasek","Tworzy burzę piaskową","Zmniejsza storm w <BL>%s%%</BL>"},
				[8] = {"Chmura","Pozwala tobie latać, gdy klikasz spację","Zwiększa latanie w <BL>%s%%</BL>"},
				[9] = {"Woda","Topi ciebie","Topi <BL>%s%%</BL> wolniej"},
				[10] = {"Kamień","Powoduje, że możesz stworzyć blok kamienia, wciskając spację","Zwiększa wielkość bloku w <BL>%s%%</BL>"},
				[11] = {"Śnieg","Powoduje, że możesz strzelić śnieżką, wciskając spację","Zwiększa prędkość śnieżki w <BL>%s%%</BL>"},
				[12] = {"Trójkąt","Każdy kolor ma swoją funkcję","?",{
					["C90909"] = "Zabija ciebie",
					["18C92B"] = "Ożywia wszystkich przeciwników",
					["555D77"] = "Ponowne spawnowanie Checkpointów",
				}},
				[13] = {"Koło","Każdy kolor ma swoją funkcję","?"},
				[14] = {"Niewidzialność","?","?"},
				[15] = {"Pajęcza sieć","Przenosi ciebie do miejsca spawnu","?"},
			},
			categories = {
				[1] = "Często długie mapy, w większości przypadków, gracze muszą przejść takie same przeszkody.",
				[2] = "Zwyczajnie długie mapy z lawami i pajęczynami, czasami używana woda aby zasymulować latanie.",
				[3] = "Trudniejsze mapy, które wymagają większej ilości zdolności, aby zostały ukończone.",
				[4] = "Mapy, które jako główną mapę mają wodę, w której myszki się topią.",
				[5] = "Mapy bazowane głównie na teleportacji z lawy.",
				[6] = "Mapy, które wymagają nowej zdolności, z mechanizmem albo czymś co powoduje, że musisz myśleć zanim coś zrobisz.",
				[7] = "Mapy bazowane na szybkości i zwinności, budowane najczęsciej z gruntów lodu.",
				[8] = "Mapy bazowane na technikach/mechanikach śnieżnych kulek.",
				[9] = "Mapy z zupełnie inną rozgrywką niż inne kategorie, również znaduje się w <I>mapach vanilliowych</I>.",
				[10] = "Mapy (w większości) zdolne do przejścia samemu, ale szybciej się ją przechodzi gdy gracze pracują wspólnie.",
				[11] = "Mapy z wampirami.",
			},
			
			welcome = "Witaj w #%s! Możesz zostać najszybszą myszką, używając moce gruntów? Spróbuj!\n<PS>Wciśnij H, aby otrzymać więcej informacji!",
			developer = "Stworzone przez %s",
			
			shop = {
				coin = "Kredyty",
				power = "Moc gruntu",
				upgrade = "Ulepsz",
				price = "Cena ulepszenia",
				close = "Zamknij",
			},
			bought = "Wydałeś %s monet na %s!",
			cantbuy = "Nie masz wystarczającej ilości monet, żeby zakupić to ulepszenie! :(",
			
			profile = "Ranking : %s\n\n<N>Rund : %s\n<N>Podia : %s\n\n<N>Zgony : %s\n\n<N>Monety : %s",

			gotcoin = "Masz %s monet! :D",
			zombie = "Zostałeś/-aś zombie!",
			countstats = {
				mice = "Przynajmniej 5 myszek jest potrzebnych aby statystyki były naliczane",
				tribe = "Statystyki nie są naliczane w chatkach plemiennych"
			},

			powersenabled = "Moce gruntów są włączone! Powodzenia!",

			language = "Bieżący język : <J>%s",
			
			password = {
				on = "Nowe hasło : %s",
				off = "Hasło wyłączone!"
			},
			
			commands = {
				shop = "sklep",
				profile = "profil",
				help = "pomoc",
				langue = "język",
				leaderboard = "ranking",
				info = "informacje",
				pw = "hasło",
			},
			
			menu = {
				[1] = {"%s","\tTwoim zadaniem w tej minigrze jest zbieranie serka najszybciej jak potrafisz, wykorzystując moce gruntów."},
				[2] = {"Moce gruntu","Kliknij w nazwę gruntu, żeby uzyskać więcej informacji.\n\n%s"},
				[3] = {"Komendy",{
					[1] = {"\t<J>» Użytkowe</J>\n",{
						[1] = "<VP>!%s</VP> <PS>nazwaGracza</PS> <R>albo</R> <VP>Klawisz P</VP> - Otwiera profil!",
						[2] = "<VP>!%s</VP> <R>albo</R> <VP>Klawisz O</VP> - Otwiera Sklep!",
						[3] = "<VP>!%s</VP> - Zmienia język!",
					}},
					[2] = {"\t<J>» Inne</J>\n",{
						[1] = "<VP>!%s</VP> <R>albo</R> <VP>Klawisz H</VP> - Otwiera pomoc!",
						[2] = "<VP>!%s</VP> - Otwiera ranking!",
						[3] = "<VP>!%s</VP> - Otwiera pomoc zależnie, na którym gruncie jesteś!",
						[4] = "<VP>!%s</VP> - Pokazuje informacje o mapie jeżeli jest w rotacji!",
					}},
					[3] = {"\n\t<J>» Pokój z adminem</J>\n",{
						[1] = "<VP>!%s</VP> <PS>hasło</PS> - Dodaje lub usuwa hasło w pokoju.",
					}},
				}},
				[4] = {"Mapy","<J>Mapy : %s\n\n\tStwórz %s i prześlij swoją mapę. Nie zapomnij, aby najpierw przeczytać zasady!"},
				[5] = {"Podziękowania","<R>%s <G>- <N>Twórca\n%s <G>- <N>Tłumacze\n%s <G>- <N>Testerzy map"},
			},
			max = "15a2df4de75",
		},
		hu = {
			grounds = {
				[0] = {"Fa","?","?"},
				[1] = {"Jég","Növeli a sebességedet, ha megnyomod a Szóközt","Növeli a sebességet <BL>%s%%</BL>-kal"},
				[2] = {"Trambulin","?","?"},
				[3] = {"Láva","Elteleportál téged a legutóbbi Z index talajhoz","?"},
				[4] = {"Csoki","?","?"},
				[5] = {"Föld","?","?"},
				[6] = {"Füves talaj","?","?"},
				[7] = {"Homok","Homokvihart hoz létre","Csökkenti a sebességet <BL>%s%%</BL>-kal"},
				[8] = {"Felhő","Lehetővé teszi számodra a repülést, ha megnyomod a Szóközt","Növeli a repülést <BL>%s%%</BL>-kal"},
				[9] = {"Víz","Megfullaszt téged","Megfullaszt <BL>%s%%</BL>-kal lassabban"},
				[10] = {"Kő","Egy kőtömböt hoz létre, ha megnyomod a Szóközt","Növeli a blokk méretét <BL>%s%%</BL>-kal"},
				[11] = {"Hó","Hógolyót lő, ha megnyomod a Szóközt","Növeli a hógolyó sebességét <BL>%s%%</BL>-kal"},
				[12] = {"Téglalap","Mindegyik színnek megvan a saját szerepe","?",{
					["C90909"] = "Megöl téged",
					["18C92B"] = "Újraéleszti az összes ellenséget",
					["555D77"] = "Újraéledő Ellenőrzőpont",
				}},
				[13] = {"Kör","Mindegyik színnek megvan a saját szerepe","?"},
				[14] = {"Láthatatlan","?","?"},
				[15] = {"Pókháló","Elteleportál téged a kezdőpontra","?"},
			},
			-- *
			
			welcome = "Üdvözöllek a #%s! Sikerül neked a leggyorsabb egérré válni a talajhatások használatával? Próbáld ki!\n<PS>Nyomd meg a H betűt több információért!",
			developer = "Fejlesztve %s által",
			
			shop = {
				coin = "Pénzérmék",
				power = "Talaj ereje",
				upgrade = "Frissítés",
				price = "Ár frissítése",
				close = "Bezárás",
			},
			bought = "Te most költöttél el %s pénzt a talajra %s!",
			cantbuy = "Nincs elég pénzed ahhoz, hogy megvedd ezt a frissítést! :(",
			
			profile = "Ranglista : %s\n\n<N>Körök : %s\n<N>Dobogók : %s\n\n<N>Halálozások : %s\n\n<N>Bolti pénz : %s",
			
			gotcoin = "Te most szereztél %s pénzt! :D",
			zombie = "Most egy zombi vagy!",
			countstats = {
				mice = "Legalább 5 egérnek kell lennie, hogy statisztikát lehessen számolni",
				tribe = "A statisztika nem számít a törzsházakban"
			},
			
			powersenabled = "A talajhatások engedélyezve lettek! Sok szerencsét!",
			
			language = "Jelenlegi nyelv : <J>%s",
			
			password = {
				on = "Új jelszó : %s",
				off = "Jelszó letiltva!"
			},
			
			commands = {
				shop = "bolt",
				profile = "profil",
				help = "súgó",
				langue = "nyelv",
				leaderboard = "ranglistát",
				info = "infó",
				pw = "jelszó",
			},
			
			menu = {
				[1] = {"%s","\tA te feladatod ebben a minijátékban az, hogy a lehető leggyorsabban összegyűjtsd a sajtot a talajhatások használatával."},
				[2] = {"Talajhatások","Kattints a talaj nevére, hogy több mindent megtudhass.\n\n%s"},
				[3] = {"Parancsok",{
					[1] = {"\t<J>» Felhasználó</J>\n",{
						[1] = "<VP>!%s</VP> <PS>játékosNeve</PS> <R>vagy</R> <VP>P billenytű</VP> - Megnyitja a profilt!",
						[2] = "<VP>!%s</VP> <R>vagy</R> <VP>O billentyű</VP> - Megnyitja a boltot!",
						[3] = "<VP>!%s</VP> - Megváltoztatja a nyelvet!\n",
					}},
					[2] = {"\t<J>» Egyebek</J>\n",{
						[1] = "<VP>!%s</VP> <R>vagy</R> <VP>H billentyű</VP> - Megnyitja a Súgó menüpontot!",
						[2] = "<VP>!%s</VP> - Megnyitja a ranglistát!",
						[3] = "<VP>!%s</VP> - Megnyitja a Súgót aszerint, amelyik talajon állsz!",
						[4] = "<VP>!%s</VP> - Displays the map info if it is in the rotation!",
					}},
					[3] = {"\n\t<J>» Szoba admin</J>\n",{
						[1] = "<VP>!%s</VP> <PS>jelszó</PS> - Bekapcsolja vagy kikapcsolja a jelszót a szobában!",
					}},
				}},
				[4] = {"Pályák","<J>Pályák : %s\n\n\tEngedélyezd a %s és küldd be a pályádat. Előtte ne felejtsd el elolvasni az összes szabály!"},
				[5] = {"Köszönet","<R>%s - Nak <G>- <N>Fejlesztő\n%s <G>- <N>Fordítók\n%s <G>- <N>Pálya értékelők"},
			},
			-- *
		},
		ar = {
			grounds = {
				[0] = {"خشب","?","?"},
				[1] = {"جليد","تزيد من سرعتك عند الضغط على زر المسطرة","يزيد من السرعة ب <BL>%s%%</BL>"},
				[2] = {"الترامبولين","?","?"},
				[3] = {"الحمم","تنقلك إلى الأرضية التي لديها اَخر رقم في الـ Z","?"},
				[4] = {"الشوكولاته","?","?"},
				[5] = {"الأرض","?","?"},
				[6] = {"العشب","?","?"},
				[7] = {"الرمل","تصنع عاصفة رملية","يقلل من العاصفة ب <BL>%s%%</BL>"},
				[8] = {"غيمة","تجعلك تطير عن طريق الضغط على زر المسطرة","يزيد من الطيران ب <BL>%s%%</BL>"},
				[9] = {"المياه","تغرقك","يغرقك <BL>%s%%</BL> ببطئ"},
				[10] = {"الحجارة","تصنع حاجو من الحجارة عن طريق الضغط على زر المسطرة","يزيد من حجم الارضية ب <BL>%s%%</BL>"},
				[11] = {"الثلج","تطلق كرات ثلجية عن طريق الضغط على زر المسطرة","يزيد من سرعة كرة الثلج ب <BL>%s%%</BL>"},
				[12] = {"مستطيل","كل لون له قوته الخاصة","?",{
					["C90909"] = "يقتلك",
					["18C92B"] = "إعادة الحياة إلى جميع أعدائك",
					["555D77"] = "نقطة العودة للحياة",
				}},
				[13] = {"الدائرة","كل لون له قوته الخاصة","?"},
				[14] = {"الإختفاء","?","?"},
				[15] = {"شبكة العنكبوت","تنقلك إلى نقطة البداية","?"},
			},
			-- *
			
			welcome = "مرحبا إلى #%s! هل يمكنك أن تكون أسرع فأر يستعمل قوى الأرض؟ قم بتجربتها!\n<PS>اضغط على الزر H لمعرفة المزيد!",
			developer = "مبرمجة من قبل %s",
			
			shop = {
				coin = "النقود",
				power = "طاقة الارضية",
				upgrade = "ترقية",
				price = "ترقبة السعر",
				close = "اغلاق",
			},
			bought = "لقد قمت بإستعمال %s من النقود من أجل الأرضية %s!",
			cantbuy = "لا تملك النقود الكافية لشراء هذا! :(",
			
			profile = "لائحة المتقدمين : %s\n\n<N>الجولات : %s\n<N>المناصب : %s\n\n<N>الموت : %s\n\n<N>نقود المتجر : %s",
			
			gotcoin = "لقد حصلت على %s نقود! :D",
			zombie = "أصبحت الأن ميت حي!",
			countstats = {
				mice = "تحتاج الاقل ل 5 فئران لاحصائيات الاعتماد",
				tribe = "الاحصائيات لا تحسب بمنزل القبيلة"
			},
			
			powersenabled = "تم تفعيل قوى الأرض! حظا موفقا!",
			
			language = "اللغة الحالية : <J>%s",
			
			password = {
				on = "جديدة سر كلمة : %s",
				off = "السر كلمة تعطيل!"
			},
			
			commands = {
				shop = "المتجر",
				profile = "لاعب",
				help = "المساعدة",
				langue = "اللغة",
				leaderboard = "مراكز",
				info = "معلومة",
				pw = "password",
			},
			
			menu = {
				[1] = {"%s","\tما عليك فعله في هذه اللعبة هو جمع الجبن بأسرع ما يمكن يمكنك إستخدام القوى التي  توفرها لك الأرضيات."},
				[2] = {"تأثيرات الأراضي","أنقر على إسم الأرضية لمعرفة المزيد عنها\n\n%s"},
				[3] = {"الأوامر",{
					[1] = {"\t<J>» اللاعب</J>\n",{
						[1] = "<VP>!%s</VP> <PS>إسم اللاعب</PS> <R>أو</R> <VP>زر P</VP> - لفتح الملف الشخصي!",
						[2] = "<VP>!%s</VP> <R>أو</R> <VP>الزر O</VP> - لفتح المتجر!",
						[3] = "<VP>!%s</VP> - لتغيير اللغة!\n",
					}},
					[2] = {"\t<J>» البقية</J>\n",{
						[1] = "<VP>!%s</VP> <R>أو</R> <VP>الزر H</VP> - لقتح لائحة المساعدة!",
						[2] = "<VP>!%s</VP> - فتح قائمة المراكز!",
						[3] = "<VP>!%s</VP> - فتح المساعدة وفقا للمكان الذي انت عليه!",
						[4] = "<VP>!%s</VP> - يعرض معلومات الخريطة إذا كانت في دوران",
					}},
					[3] = {"\n\t<J>» مشرف غرفة</J>\n",{
						[1] = "<VP>!%s</VP> <PS>سر كلمة</PS> - إضافة أو إزالة كلمة مرور في الغرفة!",
					}},
				}},
				[4] = {"الخرائط","<J>الخرائط : %s\n\n\tتفعيل %s وأرسل الخارطة. لا تنسى قراءة القوانين!"},
				[5] = {"شكرا لـ","<R>%s <G>- <N>المبرمج\n%s <G>- <N>مترجمون\n%s <G>- <N>مقيموا الخرائط"},
			},
			-- *
		},
		nl = {
			grounds = {
				[0] = {"Hout","?","?"},
				[1] = {"Ijs","Verhoogt je snelheid door op de spatiebalk te drukken","Verhoogd de snelheid met <BL>%s%%</BL>"},
				[2] = {"Trampoline","?","?"},
				[3] = {"Lava","Teleport jou naar de laatst Z index grond","?"},
				[4] = {"Chocolade","?","?"},
				[5] = {"Aarde","?","?"},
				[6] = {"Gras","?","?"},
				[7] = {"Zand","Maakt een zandstorm","Vemindert de storm met <BL>%s%%</BL>"},
				[8] = {"Wolk","Hiermee kun je vliegen door op de spatiebalk te drukken","Verhoogd de vlucht met <BL>%s%%</BL>"},
				[9] = {"Water","Laat je verdrinken","Maakt je <BL>%s%%</BL> langzamer"},
				[10] = {"Steen","Hiermee maak je een blok steen door op de spatiebalk te drukken","Vergroot de grootte van het blok met <BL>%s%%</BL>"},
				[11] = {"Sneeuw","Schiet sneeuwballen door op de spatiebalk te drukken","Verhoogd de snelheid van de sneeuwbal met <BL>%s%%</BL>"},
				[12] = {"Rechthoek","Elke kleur heeft zijn eigen functie","?",{
					["C90909"] = "Vermoordt jou",
					["18C92B"] = "Brengt alle tegenstanders weer tot leven",
					["555D77"] = "Respawning Checkpoint", -- *
				}},
				[13] = {"Cirkel","Elke kleur heeft zijn eigen functie","?"},
				[14] = {"Onzichtbaar","?","?"},
				[15] = {"Spinnenweb","Teleport je naar het beginpunt","?"},
			},
			-- *
			
			
			welcome = "Welkom bij #%s! Ben jij de snelste muis door grond effecten te gebruiken? Probeer het!",
			developer = "Gemaakt door %s",
			
			shop = {
				coin = "Munten",
				power = "Grondkracht",
				upgrade = "Upgraden",
				price = "Upgrade kosten",
				close = "Sluit",
			},
			bought = "Je gaf net %s munten uit voor de grond %s!",
			cantbuy = "Je hebt niet genoeg munten om deze upgrade uit te voeren! :(",

			profile = "Ranglijst : %s\n\n<N>Rondes : %s\n<N>Podiums : %s\n\n<N>Sterfgevallen : %s\n\n<N>Winkel Munten : %s",

			gotcoin = "Je kreeg zojuist %s munten! :D",
			zombie = "Nu ben je een zombie!",
			countstats = {
				mice = "Er zijn minstens 5 muizen nodig voordat de stats tellen",
				tribe = "Stats tellen niet in stamhuizen"
			},

			powersenabled = "De grondkrachten zijn ingeschakeld! Succes!",

			language = "Huidige taal : <J>%s",

			password = {
				on = "Nieuwe wachtwoord : %s",
				off = "Wachtwoord uitgezet!"
			},

			commands = {
				shop = "winkel",
				profile = "profiel",
				help = "help",
				langue = "taal",
				leaderboard = "leaderboard",
				info = "info",
				pw = "wachtwoord",
			},
			
			menu = {
				[1] = {"%s","\tJouw doel is om zoveel mogelijk kaas te verzamelen, met gebruik van verschillende grond-effecten."},
				[2] = {"Grond effecten","Klik op de grond om meer info te lezen.\n\n%s"},
				[3] = {"Commands",{
					[1] = {"\t<J>» User</J>\n",{
						[1] = "<VP>!%s</VP> <PS>playerName</PS> <R>or</R> <VP>Key P</VP> - Opent het profiel!",
						[2] = "<VP>!%s</VP> <R>or</R> <VP>Key O</VP> - Opent de winkel!",
						[3] = "<VP>!%s</VP> - Wijzigt de taal!\n",
					}},
					[2] = {"\t<J>» Others</J>\n",{
						[1] = "<VP>!%s</VP> <R>or</R> <VP>Key H</VP> - Opent de Help menu!",
						[2] = "<VP>!%s</VP> - Opent de leaderboard!",
						[3] = "<VP>!%s</VP> - Opent help op basis van de grond waarop je staat!",
						[4] = "<VP>!%s</VP> - Displays the map info if it is in the rotation!", -- *
					}},
					[3] = {"\n\t<J>» Kamer admin</J>\n",{
						[1] = "<VP>!%s</VP> <PS>wachtwoord</PS> - Voegt of haalt een wachtwoord weg van een kamer!",
					}},
				}},
				[4] = {"Maps","<J>Maps : %s\n\n\tBereik %s en verzend jouw map. Vergeet niet om alle regels te lezen voordat je begint!"},
				[5] = {"Dank aan","<R>%s <G>- <N>Developer\n%s <G>- <N>Translators\n%s <G>- <N>Mapbeoordelaars"},
			},
			-- *
		},
		de = {
			grounds = {
				[0] = {"Holz","?","?"},
				[1] = {"Eis","Beschleunigt dich indem du die Leertaste drückst","Erhoht die geschwindigkeit in <BL>%s%%</BL>"},
				[2] = {"Trampoline","?","?"},
				[3] = {"Lava","Teleportiert dich zum letzen Z Index Boden","?"},
				[4] = {"Schokolade","?","?"},
				[5] = {"Erde","?","?"},
				[6] = {"Gras","?","?"},
				[7] = {"Sand","Kreiert einen Sandsturm","Verringert die sturm in <BL>%s%%</BL>"},
				[8] = {"Wolke","Du kannst fliegen indem du die Leertaste drückst","Erhoht die fliege in <BL>%s%%</BL>"},
				[9] = {"Wasser","Ertränkt dich","Ertrinkt dich <BL>%s%%</BL> langsamer"},
				[10] = {"Stein","Erschaffe einen Stein indem du die Leertaste drückst","Erhoht die blockgrosse in <BL>%s%%</BL>"},
				[11] = {"Schnee","Wirf Schneebälle indem du die Leertaste drückst","Erhoht die schneeball geschwindigkeit in <BL>%s%%</BL>"},
				[12] = {"Rechteck","Jede Farbe hat seine eigene Funktion","?",{
					["C90909"] = "Tötet du",
					["18C92B"] = "Aufleben alle Feinde",
					["555D77"] = "Respawning Checkpoint", -- *
				}},
				[13] = {"Kreis","Jede Farbe hat seine eigene Funktion","?"},
				[14] = {"Unsichtbar","?","?"},
				[15] = {"Spinnweben","Teleportiert dich zum Startpunkt","?"},
			},
			-- *
			
			welcome = "Willkommen zu #%s! Kannst du die schnellste Maus mit den Bodeneffekten sein? Versuch es!\n<PS>Drück H für mehr informationen!",
			developer = "Entwickelt von %s",
			
			shop = {
				coin = "Munzen",
				power = "Bodenleistung",
				upgrade = "Aktualisierung",
				price = "Upgrade Preis",
				close = "Schliessen",
			},
			bought = "Du hast %s Münzen für den Boden %s ausgegeben!",
			cantbuy = "Du hast nicht genügend Münzen um dieses Upgrade zu kaufen! :(",
			
			profile = "Bestenliste : %s\n\n<N>Runden: %s\n<N>Podiums: %s\n\n<N>Tode : %s\n\n<N>Shop Münzen: %s",
			
			gotcoin = "Du hast soeben %s Münzen erhalten! :D",
			zombie = "Du bist nun ein Zombie!",
			countstats = {
				mice = "Es müssen mindestens 5 Mäuse im Raum sein damit die Stats zählen",
				tribe = "Stats zählen in Stammeshäusern nicht"
			},
			
			powersenabled = "Der Effekt des Bodens wurde aktiviert! Viel Glück!",
			
			language = "Aktuelle Sprache : <J>%s",
			
			password = {
				on = "Neu passwort: : %s",
				off = "Passwort deaktiviert!"
			},
			
			commands = {
				shop = "shop",
				profile = "profil",
				help = "hilfe",
				langue = "sprache",
				leaderboard = "bestenliste",
				info = "info",
				pw = "passwort",
			},
			
			menu = {
				[1] = {"%s","\tDein Ziel in diesem Minigame ist es den Käse so schnell wie möglich zu sammeln, indem du die verschiedenen Effekte der Böden ausnutzt."},
				[2] = {"Bodeneffekte","Klicken in den bodens namen um mehr zu lesen.\n\n%s"},
				[3] = {"Kommandos",{
					[1] = {"\t<J>» Benutzer</J>\n",{
						[1] = "<VP>!%s</VP> <PS>Spielername</PS> <R>oder</R> <VP>Taste P</VP> - Öffnet das Profil!",
						[2] = "<VP>!%s</VP> <R>oder</R> <VP>Taste O</VP> - Öffnet den Shop!",
						[3] = "<VP>!%s</VP> - Ändert die Sprache!\n",
					}},
					[2] = {"\t<J>» Anderes</J>\n",{
						[1] = "<VP>!%s</VP> <R>oder</R> <VP>Taste H</VP> - Öffnet das Hilfsmenu!",
						[2] = "<VP>!%s</VP> - Öffnet die Bestenliste!",
						[3] = "<VP>!%s</VP> - Öffnet die hilfe nach dem boden auf dem du bist auf!",
						[4] = "<VP>!%s</VP> - Displays the map info if it is in the rotation!", -- *
					}},
					[3] = {"\n\t<J>» Zimmer admin</J>\n",{
						[1] = "<VP>!%s</VP> <PS>passwort</PS> - Hinzufugen oder entfernen eines passwortes im raum!",
					}},
				}},
				[4] = {"Maps","<J>Maps : %s\n\n\tBesuche das Thema %s und reiche deine Map ein. Vergiss nicht zuvor alle Regeln zu lesen!"},
				[5] = {"Danke an ","<R>%s <G>- <N>Entwickler\n%s <G>- <N>Übersetzer\n%s <G>- <N>Landkarte bewerter"},
			},
			-- *
		},
	},
	langue = "en",
	-- Info
	staff = {
		translators = {
			-- Name, Languages
			{"Bolodefchoco",{"EN","BR"}},
			{"Distances","NL"},
			{"Tocutoeltuco","ES"},
			{"Sebafrancuz","PL"},
			{"Doriiarvai","HU"},
			{"Error_404","AR"},
			{"Cheeselicious","NL"},
			{"Archaeron","DE"},
			{"Aewing","FR"},
			{"Fashionkid","DE"},
			{"Yuir","ES"},
			{"Mquk","FR"}
		},
		mapEvaluators = {
			-- Name, Joined
			{"Bolodefchoco","14/02/2017"},
			{"Error_404","11/03/2017"}
		},
	},
	-- Data
	bindKeys = {0,1,2,3,string.byte("OPHK",1,4)},
	info = {},
	stormIntensities = {
		--[[ Opaque images
			[1] = "15a6d6fcd18",
			[2] = "15a6d6ff82f",
			[4] = "15a6d7015bc",
			[8] = "15a6d703149"
		]]
		[1] = .75,
		[2] = .65,
		[4] = .5,
		[8] = .25
	},
	-- Maps (G Categories)
	maps = {},
	G = {
		--[[
			name = catName,
			queue{maps},
			id = 1,
			icon = {iconImage,x axis (from 360),y axis (from 123)}
			color = catColor,
			before = function executed before the map,
			after = function executed after the map
		]]--
		[1] = {
			name = "Circuit",
			queue = {3099763,4612510,7078090,4493715,7102175,5921816,7127261,7102187},
			id = 1,
			icon = {"15c60371706",0,-1},
			color = "9A9ACE",
		},
		[2] = {
			name = "Flap Bird",
			queue = {7069835,2265250,6300148,5921754,2874090,2310427},
			id = 1,
			icon = {"15c603730a6",0,0},
			color = "E084D4",
		},
		[3] = {
			name = "Bootcamp",
			queue = {4592612,7079708,5921867,7087840,6391815,7090909,7011800,7069314,6333026,6000012,6990787},
			id = 1,
			icon = {"15c60382627",-5,-5},
			color = "A4CF9E",
		},
		[4] = {
			name = "Aquatic",
			queue = {6133469,3324284,6578479,7095393,5772226,2310447},
			id = 1,
			icon = {"15c603788c1",0,0},
			color = "2194D9",
		},
		[5] = {
			name = "Teleport",
			queue = {5168440,6987992,7069343,6945850,7090907,3326655,7069816,5921744,7071075,7071400,4509060,7118888},
			id = 1,
			icon = {"15c60376d57",2,-1},
			color = "E29E71",
		},
		[6] = {
			name = "Puzzle",
			queue = {5993927,7057010,5507021,6994066,6332986,7074686,3448597,2887357,6576282,4514386,7079827,7079880},
			id = 1,
			icon = {"15c6037edb7",0,-1},
			color = "CB56D8",
		},
		[7] = {
			name = "Racing",
			queue = {4140491,3324180,6564380,6600268,6987993,6726599,2283901,6568120,4055924,4361785,3851416,7079644,6347093,6620004,7086768,6797243,2030030,5198518,6230212,6340023,7069304,4362362,5981054,4364504,7086737,6623930},
			id = 1,
			icon = {"15c6037ccd7",-5,-5},
			color = "9DBCF2",
		},
		[8] = {
			name = "Snow",
			queue = {4396371,5632126,7079092,4531989,4509584},
			id = 1,
			icon = {"15c6037b089",5,1},
			color = "C4F4F6",
			after = function()
				if os.date("%m") == "12" then
					tfm.exec.chatMessage("<PS>Merry christmas :)")
					tfm.exec.snow(60)
				end
			end,
		},
		[9] = {
			name = "Miscellaneous",
			queue = {6226386,5425815,7047955,6558179,6961916,6968299,6935117,4802574,7087798,6335452,7093647,7145064},
			id = 1,
			icon = {"15c6036fb66",-10,-2},
			color = "DED963",
		},
		[10] = {
			name = "Cooperation",
			queue = {3326675,4184558,5198607,6988672},
			id = 1,
			icon = {"15c60374f1f",-3,-1},
			color = "2EBA7E",
		},
		[11] = {
			name = "Vampire",
			queue = {5043429,4361619,4633670},
			id = 1,
			icon = {"15c60380b12",-10,-5},
			color = "CB546B",
			after = function()
				if os.date("%m") == "10" then
					tfm.exec.chatMessage("<R>Happy Halloween :>")
				end
			end,
		},
	},
	rotation = {1,{9,7,4,1,5,7,10,8,6,11,2,1,3,5}},
	newMap = coroutine.wrap(function()
		while true do
			local map
			if os.time() > system.newGameTimer then
				if mode.grounds.rotation[1] > #mode.grounds.rotation[2] then
					mode.grounds.rotation[1] = 1
				end
				
				local category = mode.grounds.rotation[2][mode.grounds.rotation[1]]
				mode.grounds.mapInfo[2] = category
				category = mode.grounds.G[category]
				mode.grounds.mapInfo[5] = category.color
				map = category.queue[category.id]
				mode.grounds.mapInfo[1] = map
				
				category.id = category.id + 1
				
				mode.grounds.afterFunction = category.after or (function() end)
				if category.before then
					category.before()
				end
				
				if category.id > #category.queue then
					category.queue = table.shuffle(category.queue)
					category.id = 1
				end
				
				mode.grounds.rotation[1] = mode.grounds.rotation[1] + 1
			end
			coroutine.yield(map)
		end
	end),
	-- New Map Settings
	review = false,
	afterFunction = (function() end),
	mapInfo = {0,0,0,0,"CAA4CF"}, -- Code, Category, Width, Height, Color
	respawn = 0,
	hasWater = false,
	podium = 0,
	availableRoom = false,
	alivePlayers = 0,
	totalPlayers = 0,
	spawnPoint = {0,0},
	-- Loop Settings
	despawnGrounds = {},
	announceTimer = 0,
	-- Misc Settings
	welcomeMessage = (function()
		if system.roomNumber == 666 then
			return "<R>[•] %s\n\n<G>[^_^] <R>%s"
		else
			return "<PT>[•] <BV>%s\n\n<G>[^_^] <VP>%s"
		end
	end)(),
	-- Leaderboard Settings
	leaderboard = {update = 0,data = {}},
	-- Shop
	shop = {
		images = {
			[1] = {'15a2a340dd5','15a2a342b88','15a2a3449a9','15a2a3459e1','15a2a346953','15a2a3479a3','15a2a348ad3','15a2a349a89','15a2a34aa0d'},
			[3] = {'15a2a35fef7','15a2a36114b','15a2a36240d','15a2a36332f','15a2a3645f3'},
			[7] = {'15a2a3721bc','15a2a3731bb','15a2a3742b6','15a2a375439','15a2a376339'},
			[8] = {'15a2a31b8dc','15a2a31d292','15a2a323150','15a2a32815c','15a2a32af10','15a2a32ce03','15a2a32dc09','15a2a32ecde','15a2a32fc20'},
			[9] = {'15a2a3b475f','15a2a3b5996','15a2a3b6ab9','15a2a3b8250','15a2a3b924f'},
			[10] = {'15a2a3a0156','15a2a3a1229','15a2a3a2460','15a2a3a3702','15a2a3a4c70'},
			[11] = {'15a2a381307','15a2a3824c8','15a2a383682','15a2a384dc1','15a2a3865c5','15a2a38820d','15a2a38a3a8','15a2a38bbd6','15a2a38d0ec'},
			[15] = {'15a2a3c4442','15a2a3c54f3','15a2a3c69b7','15a2a3c78e7','15a2a3c873b'},	
		},
		unpackImages = function(id,e)
			local t = {}
			for k,v in next,mode.grounds.shop.images[id] do
				if #t < e then
					t[#t+1] = v
				end
			end
			return t
		end,
	},
	-- System functions
	concat = function(k,v)
		if type(v) == "table" then
			return table.concat(v,"\n",function(i,j) return mode.grounds.concat(i,j) end)
		else
			return v
		end
	end,
	listener = function(t,st,from)
		from = (from and from.."." or "")
		for k,v in next,t do
			if type(v) == "table" then
				mode.grounds.listener(v,st,from .. tostring(k))
			else
				st[#st + 1] = from .. k
			end
		end
		return st
	end,
	-- Bar
	uibar = function(id,player,value,color,size,height)
		size = size or 100
		height = height or 20

		if value > size then
			value = size
		elseif value < 0 then
			value = 0
		end

		ui.addTextArea(id,"",player,5,(height+8) * id,size + 4,height,0xC7CED2,1,1,true)
		if value ~= 0 then
			ui.addTextArea(id+1,"",player,6,(height+8) * id + 2,value + 2,height - 4,color,color,1,true)
		end
		ui.addTextArea(id+2,"<p align='center'><B><font color='#0'>"..value.."%",player,5,(height+8) * id,size + 4,height,1,1,0,true)
	end,
	-- Shop
	uishop = function(n)
		if mode.grounds.info[n].groundsDataLoaded then
			for k,v in next,mode.grounds.info[n].shop.image do
				tfm.exec.removeImage(v)
			end
			if not mode.grounds.info[n].shop.accessing then
				local get,index = table.find(mode.grounds.shop.grounds,mode.grounds.info[n].powersOP.GTYPE,1)
				if get then
					mode.grounds.info[n].shop.page = index
				else
					mode.grounds.info[n].shop.page = 1
				end
				mode.grounds.info[n].shop.accessing = true
			end
			if mode.grounds.info[n].shop.page < 1 then
				mode.grounds.info[n].shop.page = #mode.grounds.shop.grounds
			elseif mode.grounds.info[n].shop.page > #mode.grounds.shop.grounds then
				mode.grounds.info[n].shop.page = 1
			end
			
			local shopTxt = system.getTranslation("shop",n)
			local debuggedGround = mode.grounds.shop.grounds[mode.grounds.info[n].shop.page]
			local ground = system.getTranslation("grounds."..debuggedGround[1],n)
			local G = string.lower(mode.grounds.translations.en.grounds[debuggedGround[1]][1])
			local groundLevel = mode.grounds.info[n].stats.powers[G]
			groundLevel = groundLevel[#groundLevel]
			
			ui.addTextArea(4,"",n,160,50,480,320,0x1a2433,1,1,true)

			ui.addTextArea(5,"",n,171,56,240,15,0x1d5a78,0x1d5a78,1,true)
			ui.addTextArea(6,"<p align='center'><font size='13'>"..string.nick(mode.grounds.cmds.shop),n,170,53,240,25,1,1,0,true)

			ui.addTextArea(7,"<p align='center'><font size='12'><B><a href='event:shop.left'><BV>«</BV></a>  <font size='14'><a href='event:info.grounds."..string.gsub(ground[1],"'","#").."."..ground[2].."'>"..ground[1].."</a></font>  <a href='event:shop.right'><BV>»</BV></a>",n,170,87,240,25,0x073247,0x073247,1,true)
			
			mode.grounds.info[n].shop.image[1] = tfm.exec.addImage(debuggedGround[2][1]..".png","&0",435,70,n)

			local playerData = string.format("<font size='12'><N>%s <G>: <J>$%s\n<N>%s\n<N>%s <G>: <BL>%s",shopTxt.coin,mode.grounds.info[n].stats.groundsCoins,"%s",shopTxt.power,math.floor(math.percent(groundLevel,#debuggedGround[2])).."%%")
			local groundData = ""
			local upgradeData = "<p align='center'><font size='15'><B>%s" .. shopTxt.upgrade

			if (groundLevel + 1) <= #debuggedGround[2] then
				local price = (groundLevel + 1) * (120 * debuggedGround[3])
				playerData = string.format(playerData,shopTxt.price .. " <G>: <R>$" .. price)
				local iniPerc = math.floor(math.percent(1,#mode.grounds.shop.grounds[mode.grounds.info[n].shop.page][2]))
				groundData = string.format(ground[3],iniPerc)
				upgradeData = string.format(upgradeData,"<a href='event:shop.buy."..price.."."..G.."'><PT>")
				
				local gId = mode.grounds.info[n].stats.powers[G][#mode.grounds.info[n].stats.powers[G]]
				mode.grounds.info[n].shop.image[2] = tfm.exec.addImage(debuggedGround[2][gId]..".png","&1",540,70,n)
				mode.grounds.info[n].shop.image[3] = tfm.exec.addImage("15a2df6ab69.png","&2",440,205,n)
				mode.grounds.info[n].shop.image[4] = tfm.exec.addImage(debuggedGround[2][gId+1]..".png","&3",540,210,n)
			else
				playerData = string.format(playerData,"<R>-")
				upgradeData = string.format(upgradeData,"<V>")
				
				mode.grounds.info[n].shop.image[2] = tfm.exec.addImage(system.getTranslation("max",n)..".png","&2",175,215,n)
			end
			
			ui.addTextArea(8,playerData,n,170,130,240,52,0x073247,0x073247,1,true)
			ui.addTextArea(9,groundData,n,170,200,240,80,0x073247,0x073247,1,true)

			ui.addTextArea(10,upgradeData,n,170,298,240,24,0x073247,0x073247,1,true)
			ui.addTextArea(11,"<p align='center'><font size='15'><R><B><a href='event:shop.close'>"..shopTxt.close.."</a></B>",n,170,339,240,24,0x073247,0x073247,1,true)

			ui.addTextArea(12,"",n,430,62,200,300,0x073247,0x073247,1,true)
			ui.addTextArea(13,"",n,426,58,90,90,0x1a2433,0x1a2433,1,true)
		end
	end,
	-- Profile
	uiprofile = function(n,p)
		if mode.grounds.info[p].groundsDataLoaded then
			local nickSize = #p > 12 and 10 or 15
			ui.addTextArea(14,"<p align='center'><B><R><a href='event:profile.close'>X",n,513,115,20,20,1,1,1,true)
			ui.addTextArea(15,"<p align='center'><B><PS><a href='event:profile.open'>•",n,513,145,20,20,1,1,1,true)
			ui.addTextArea(16,"<p align='center'><font size='16'><B><V>"..p.."</V></B> "..(mode.grounds.info[p].isOnline and "<VP>" or "<R>").."•</font></p><p align='left'><font size='12'>\n<N>" .. string.format(system.getTranslation("profile",n),"<V>#"..mode.grounds.info[p].ranking,"<V>"..mode.grounds.info[p].stats.rounds,"<V>"..mode.grounds.info[p].stats.podiums,"<V>"..mode.grounds.info[p].stats.deaths,"<J>$"..mode.grounds.info[p].stats.groundsCoins),n,290,115,220,160,0x073247,1,1,true)
		end
	end,
	-- Menu
	uimenu = function(n)
		if not mode.grounds.info[n].menu.accessing then
			mode.grounds.info[n].menu.page = 1
			mode.grounds.info[n].menu.accessing = true
		end

		local langue = system.getTranslation("menu",n)

		if mode.grounds.info[n].menu.page < 1 then
			mode.grounds.info[n].menu.page = #langue
		elseif mode.grounds.info[n].menu.page > #langue then
			mode.grounds.info[n].menu.page = 1
		end

		local popupFormat = "<%s><a href='event:menu.page.%d'>#%s</a>"
		local popups = {}
		for k,v in next,langue do
			popups[#popups+1] = string.format(popupFormat,(k == mode.grounds.info[n].menu.page and "VP" or "J"),k,string.format(v[1],string.nick(module._NAME)))
		end

		local popup = {
			x = {663,546},
			d = "«",
			txt = "<font size='11'><J>"..table.concat(popups,"\n\n")
		}
		if not mode.grounds.info[n].menu.showPopup then
			popup = {
				x = {552,435},
				d = "»",
				txt = "",
			}
		end
		
		local displayText = {table.unpack(langue[mode.grounds.info[n].menu.page])}

		if mode.grounds.info[n].menu.page == 1 then
			displayText[1] = string.format(displayText[1],string.nick(module._NAME))
			
			local gameModes = "<PT>"
			for k,v in next,{"powers",table.unpack(system.submodes,2)} do
				local room
				if k > 1 then
					room = string.format("/room #%s%s@%s*%s",module._NAME,math.random(0,999),n,system.normalizedModeName(v,false))
				else
					room = string.format("/room #%s%s%s",v,math.random(0,999),n)
				end
				gameModes = gameModes .. string.format("<a href='event:print.&lt;ROSE>%s'>%s</a>\n",room,room)
			end
			
			displayText[2] = displayText[2] .. "\n\n" .. gameModes
		else
			local textFormat = nil
			if mode.grounds.info[n].menu.page == 2 then
				textFormat = {{},system.getTranslation("grounds",n)}
				for k,v in next,textFormat[2] do
					if v[2] ~= "?" then
						table.insert(textFormat[1],string.format("<a href='event:info.grounds.%s.%s'><B>%s</B></a>",string.gsub(v[1],"'","#"),string.gsub(v[2],"%.","@"),string.upper(v[1])))
					end
				end
				displayText[2] = string.format(displayText[2],"• "..table.concat(textFormat[1],"\n• "))
			elseif mode.grounds.info[n].menu.page == 3 then
				displayText[2] = table.concat(displayText[2],"\n",function(k,v)
					return mode.grounds.concat(k,v)
				end)
				displayText[2] = "<font size='10'>" .. string.format(displayText[2],mode.grounds.cmds.profile,mode.grounds.cmds.shop,mode.grounds.cmds.langue,mode.grounds.cmds.help,mode.grounds.cmds.leaderboard,mode.grounds.cmds.info,mode.grounds.cmds.mapinfo,mode.grounds.cmds.pw)
			elseif mode.grounds.info[n].menu.page == 4 then
				displayText[2] = string.format(displayText[2] .. "\n\n%s",#mode.grounds.maps.."<N>","<BV><a href='event:print.atelier801¬com/topic?f=6&t=845005'>#"..string.upper(module._NAME).." MAP SUBMISSIONS</a></BV>",table.concat(mode.grounds.G,"\n",function(k,v)
					return string.format("<font color='#%s'><a href='event:info.mapCategory.%s'>G%s</a> : %s</font>",v.color,k,k,#v.queue)
				end))
			elseif mode.grounds.info[n].menu.page == 5 then
				local concat = {}
				for i,j in next,{{"translators","<CEP>"},{"mapEvaluators","<BV>"}} do
					concat[#concat+1] = j[2] .. table.concat(mode.grounds.staff[j[1]],"<G>, " .. j[2],function(k,v)
						return string.format("<a href='event:info.%s.%s'>%s</a>",j[1],k,v[1])
					end)
				end
				displayText[2] = string.format(displayText[2],"Bolodefchoco",concat[1],concat[2])
			end
		end

		ui.addTextArea(17,"<font size='1'>\n</font><p align='center'><J><B><a href='event:menu.right'>»</a>",n,543,352,40,20,1,1,1,true)
		ui.addTextArea(18,"<font size='1'>\n</font><p align='center'><J><B><a href='event:menu.left'>«</a>",n,217,352,40,20,1,1,1,true)

		ui.addTextArea(19,"<font size='1'>\n</font><p align='center'><PT><B><a href='event:menu.popup'>"..popup.d.."</a>",n,popup.x[1],137,20,20,1,1,1,true)
		ui.addTextArea(20,popup.txt,n,popup.x[2],137,115,125,0x123e54,1,1,true)

		ui.addTextArea(21,"<p align='center'><B><R><a href='event:menu.close'>X",n,543,42,20,20,1,1,1,true)
		ui.addTextArea(22,"<p align='center'><font size='20'><V><B>"..string.upper(displayText[1]).."</B></V><font size='15'>\n<R>_____________\n\n<font size='11'><N><p align='left'>"..displayText[2],n,260,42,280,330,0x073247,1,1,true)
	end,
	-- Info
	uidisplayInfo = function(n,data)
		local what = data[2]
		local title,text,color = "","",""
		if what == "grounds" then
			color = "<N>"
			title = string.gsub(data[3],"#","'")
			local info = string.gsub(data[4],"@",".")
			local groundTxt = system.getTranslation("grounds.12",n)
			if info == groundTxt[2] then
				local colors = {}
				for k,v in next,groundTxt[4] do
					colors[#colors+1] = string.format("<PT>[•] <N2><font color='#%s'>(#%s)</a> <BL>- <PS>%s",k,k,v)
				end
				text = table.concat(colors,"\n")
			else
				text = string.format("<PT>[•] <PS>%s",info)
			end
		elseif what == "mapCategory" then
			data[3] = tonumber(data[3])
			color = "<S>"
			title = "G"..data[3]
			text = string.format("%s\n# %s\n@ %s",mode.grounds.G[data[3]].name,#mode.grounds.G[data[3]].queue,system.getTranslation("categories." .. data[3],n))
			if mode.grounds.info[n].infoImage[#mode.grounds.info[n].infoImage] then
				tfm.exec.removeImage(mode.grounds.info[n].infoImage[#mode.grounds.info[n].infoImage])
			end
			mode.grounds.info[n].infoImage[#mode.grounds.info[n].infoImage + 1] = tfm.exec.addImage(mode.grounds.G[data[3]].icon[1] .. ".png","&4",360 + mode.grounds.G[data[3]].icon[2],125 + mode.grounds.G[data[3]].icon[3],n)
		elseif mode.grounds.staff[what] then
			local comp = data[3]
			local info = mode.grounds.staff[what][tonumber(comp)]
			title = info[1]
			if what == "translators" then
				color = "<CEP>"
				text = string.format("[•] !%s %s",mode.grounds.cmds.langue,table.concat(table.turnTable(info[2]),", "))
			elseif what == "mapEvaluators" then
				color = "<BV>"
				text = string.format("[•] %s",info[2])
			end
		end
		ui.addTextArea(37,"<p align='center'><B><R><a href='event:info.close'>X",n,528,115,20,20,1,1,1,true)
		ui.addTextArea(38,"<p align='center'><font size='20'><V><B>" .. title .. "</B>" .. color .. (mode.grounds.staff[what] and " •" or "") .. "\n\n<p align='left'><font size='13'>" .. text,n,275,115,250,160,0x073247,1,1,true)
	end,
	-- Leaderboard
	uileaderboard = function(n)
		if os.time() > mode.grounds.leaderboard.update or not n then
			mode.grounds.leaderboard = {update = os.time() + 180e3,data = {}}
			
			local players = {}
			for k,v in next,mode.grounds.info do
				if string.sub(k,1,1) ~= "*" then
					players[#players + 1] = {k,math.floor((v.stats.rounds - v.stats.deaths)/10) * (v.stats.podiums + 1)}
				end
			end
			table.sort(players,function(p1,p2) return p1[2] > p2[2] end)

			for k,v in next,players do
				mode.grounds.info[v[1]].ranking = k
				if k < 11 then
					table.insert(mode.grounds.leaderboard.data,"<J>"..k..". " .. (({"<BV>","<PS>","<CE>"})[k] or "<V>") .. "<a href='event:profile.open."..v[1].."'>".. v[1] .. "</a> <BL>- <VP>" .. v[2] .. "G")
				end
			end
			if #mode.grounds.leaderboard.data == 0 then
				mode.grounds.leaderboard.update = 0
			end
		end

		if n then
			mode.grounds.info[n].leaderboardAccessing = true
			local id,y = 25,100
			ui.addTextArea(23,"<p align='center'><B><R><a href='event:ranking.close'>X",n,603,35,20,20,1,1,1,true)
			ui.addTextArea(24,"<p align='center'><font size='45'>" .. string.nick(mode.grounds.cmds.leaderboard),n,200,35,400,350,0x073247,1,1,true)

			for i = 1,10 do
				local v = mode.grounds.leaderboard.data[i] or ""
				local color = id % 2 == 0 and 0x123e54 or 0x042636
				if string.find(v,n) then
					v = string.gsub(v,"'>(.-)</a>",function(name)
						return "'><a:active>"..name.."</a:active></a>"
					end)
				end
				ui.addTextArea(id,v,n,245,y,315,20,color,color,1,true)
				id = id + 1
				y = y + 28
			end

			ui.addTextArea(id,"",n,230,90,10,285,0x073247,0x073247,1,true)
			ui.addTextArea(id + 1,"",n,565,90,10,285,0x073247,0x073247,1,true)
		end
	end,
	-- Grounds system
	gsys = {
		-- Ground system
		grounds = {},
		disabledGrounds = {},
		collisionArea = {34,40,50,50,40,34,34,35,0,0,40,35,35,23,0,0},
		getTpPos = function(g,center)
			if center then
				return {g.X,g.Y}
			else
				local ang = string.split(g.P,"[^,]+",tonumber)
				ang = ang[5]
				local hTP = {g.X,g.Y}
				if ang == 90 or ang == -270 then
					hTP[1] = hTP[1] + g.L/2
				elseif ang == -90 or ang == 270 then
					hTP[1] = hTP[1] - g.L/2
				elseif math.abs(ang) == 180 then
					hTP[2] = hTP[2] + g.H/2
				else
					hTP[2] = hTP[2] - g.H/2
				end
				
				return hTP
			end
		end,
		onGround = function(t,px,py)
			local prop = string.split(t.P,"[^,]+",tonumber)

			px,py = px or 0,py or 0
			local offset = {}
			local isOn = false

			local w = tonumber(t.L)
			local h = tonumber(t.H)
			local x = tonumber(t.X)
			local y = tonumber(t.Y)
			local gtype = tonumber(t.T)
			gtype = math.min(15,math.max(0,gtype))

			if not table.find({8,9,15},gtype) then
				local area = mode.grounds.gsys.collisionArea[gtype + 1]
				w = w + area
				h = h + area
			end

			if gtype == 13 then
				isOn = math.pythag(x,y,px,py,w)
			else
				local ang = math.rad(prop[5])

				local range = {w = w/2,h = h/2}

				local cosA = math.cos(ang)
				local sinA = math.sin(ang)
				
				local vxA = {x = ((-range.w * cosA - (-range.h) * sinA) + x),y = ((-range.w * sinA + (-range.h) * cosA) + y)}
				local vxB = {x = ((range.w * cosA - (-range.h) * sinA) + x),y = ((range.w * sinA + (-range.h) * cosA) + y)}
				local vxC = {x = ((range.w * cosA - range.h * sinA) + x),y = ((range.w * sinA + range.h * cosA) + y)}
				local vxD = {x = ((-range.w * cosA - range.h * sinA) + x),y = ((-range.w * sinA + range.h * cosA) + y)}
				offset = {vxA,vxB,vxC,vxD}

				local p = 4
				for i = 1,4 do
					if (offset[i].y < py and offset[p].y >= py) or (offset[p].y < py and offset[i].y >= py) then
						if offset[i].x + (py - offset[i].y) / (offset[p].y - offset[i].y) * (offset[p].x - offset[i].x) < px then
							isOn = not isOn
						end
					end
					p = i
				end
			end

			return isOn
		end,
		getGroundProperties = function(xml)
			mode.grounds.gsys.grounds = {}
			string.gsub(xml,"<S (.-)/>", function(parameters)
				local attributes = {}
				string.gsub(parameters,"([%-%w]+)=([\"'])(.-)%2",function(tag,_,value)
					attributes[tag] = tonumber(value) or value
				end)
				mode.grounds.gsys.grounds[#mode.grounds.gsys.grounds + 1] = attributes
			end)
		end,
		groundEffects = function()
			for n,p in next,tfm.get.room.playerList do
				if not p.isDead then
					local affected = false
					for id = 1,#mode.grounds.gsys.grounds do
						local ground = mode.grounds.gsys.grounds[id]
						local newId = id - 1
						if (ground.disablepower or string.sub(ground.P,1,1) == "1" or (ground.v and (_G.currentTime - 3) == (tonumber(ground.v)/1000))) and not mode.grounds.gsys.disabledGrounds[newId] then
							-- If the ground has the disablepower attribute, or is dynamic, or the v despawner attribute exists (after it disappear)
							mode.grounds.gsys.disabledGrounds[newId] = true
						end
						if not mode.grounds.gsys.disabledGrounds[newId] and _G.currentTime >= 3 then
							if mode.grounds.gsys.onGround(ground,p.x,p.y) then
								affected = true
								local gtype = ground.T
								local color = string.upper(tostring(ground.o or ""))
								mode.grounds.info[n].powersOP.GTYPE = gtype
								if gtype == 1 or color == "89A7F5" then -- ice
									system.bindKeyboard(n,32,true,true)
									if color ~= "" then
										mode.grounds.info[n].powersOP.GTYPE = 1
									end
								elseif gtype == 2 or color == "6D4E94" then -- trampoline
									if color ~= "" then
										mode.grounds.info[n].powersOP.GTYPE = 2
									end
								elseif gtype == 3 or color == "D84801" then -- lava
									if color ~= "" then
										mode.grounds.info[n].powersOP.GTYPE = 3
									end
									id = (id > 1 and id - 1 or #mode.grounds.gsys.grounds)
									local g = mode.grounds.gsys.grounds[id]
									local hTP = mode.grounds.gsys.getTpPos(g)
									tfm.exec.displayParticle(36,p.x,p.y,0,0,0,0,n)
									tfm.get.room.playerList[n].x = 0
									tfm.get.room.playerList[n].y = 0
									tfm.exec.movePlayer(n,hTP[1],hTP[2])
									tfm.exec.displayParticle(36,hTP[1],hTP[2],0,0,0,0,n)
								elseif gtype == 8 or color == "9BAABC" then -- cloud
									system.bindKeyboard(n,32,true,true)
								elseif gtype == 7 then -- sand
									ui.addTextArea(-1,"",n,-1500,-1500,3e3,3e3,0xE5CC5D,0xE5CC5D,mode.grounds.stormIntensities[mode.grounds.info[n].stats.powers.sand[1]],false)
									for i = 1,2 do
										tfm.exec.displayParticle(26,math.random(800),math.random(350),0,0,0,0,n)
										tfm.exec.displayParticle(27,math.random(800),math.random(350),0,0,0,0,n)
									end
								elseif gtype == 9 then -- water
									if mode.grounds.hasWater then
										mode.grounds.info[n].drown = mode.grounds.info[n].drown + math.random(1,math.floor(mode.grounds.info[n].stats.powers.water[1]))
										mode.grounds.uibar(1,n,mode.grounds.info[n].drown,0x519DDA,100,20)
										if mode.grounds.info[n].drown > 99 then
											tfm.exec.killPlayer(n)
											mode.grounds.uibar(1,n,mode.grounds.info[n].drown,0xDA516D,100,20)
											mode.grounds.info[n].drown = 0
											for i = 1,8 do
												tfm.exec.displayParticle(14,p.x+math.random(-50,50),p.y+math.random(-20,20),0,-1,0,0,n)
											end
										end
										for i = 1,math.random(2,4) do
											tfm.exec.displayParticle(14,p.x+math.random(-50,50),p.y+math.random(-20,20),0,-1,0,0,n)
										end
									end
								elseif gtype == 10 then -- stone
									system.bindKeyboard(n,32,true,true)
								elseif gtype == 11 or color == "E7F0F2" then -- snow
									system.bindKeyboard(n,32,true,true)
								elseif gtype == 12 or gtype == 13 then -- retangle or circle
									if color == "C90909" then
										tfm.exec.killPlayer(n)
									elseif color == "18C92B" then
										if os.time() > mode.grounds.respawn then
											mode.grounds.respawn = os.time() + 7e3
											for k,v in next,tfm.get.room.playerList do
												if v.isVampire then
													tfm.exec.killPlayer(k)
												elseif v.isDead and mode.grounds.info[k].canRev then
													tfm.exec.respawnPlayer(k)
												end
											end
										end
									elseif color == "555D77" then
										mode.grounds.info[n].checkpoint = id
									end
								elseif gtype == 15 then -- web
									tfm.exec.movePlayer(n,mode.grounds.spawnPoint[1],mode.grounds.spawnPoint[2])
									tfm.get.room.playerList[n].x = 0
									tfm.get.room.playerList[n].y = 0
								end
							end
						end
					end
					if not affected then
						mode.grounds.info[n].powersOP.GTYPE = -1
					end
				end
			end
		end,
	},
	-- Init
	init = function()
		mode.grounds.translations.pt = mode.grounds.translations.br
	
		-- Sets the main language according to the community
		if mode.grounds.translations[tfm.get.room.community] then
			mode.grounds.langue = tfm.get.room.community
		end
		
		-- Shuffle the map rotation
		for k,v in next,mode.grounds.G do
			v.queue = table.shuffle(v.queue)
		end
		
		-- Map list
		for k,v in next,mode.grounds.G do
			for i,j in next,v.queue do
				mode.grounds.maps[#mode.grounds.maps + 1] = {j,k}
			end
		end
	
		-- Organizates the staff table
		for k,v in next,mode.grounds.staff do
			table.sort(v,function(t1,t2) return t2[1] > t1[1] end)
		end
		
		-- Organizes the languages
		mode.grounds.langues = (function()
			local l = {}
			for id in next,mode.grounds.translations do
				l[#l + 1] = string.upper(id)
			end
			table.sort(l)
			return l
		end)()
		
		-- Translation indexes
		mode.grounds.translationIndexes = mode.grounds.listener(mode.grounds.translations.en,{})
		
		-- Sets the shop prices, upgrades, etc
		mode.grounds.shop.grounds = {
			-- Ground ID, #Possible upgrades (Imgs), Price average, Upgrade average
			[1] = {1,mode.grounds.shop.unpackImages(1,3),1.05,1.5},
			[2] = {7,mode.grounds.shop.unpackImages(7,4),.4,2},
			[3] = {8,mode.grounds.shop.unpackImages(8,3),1.15,1.47},
			[4] = {9,mode.grounds.shop.unpackImages(9,3),1.6,.6},
			[5] = {10,mode.grounds.shop.unpackImages(10,3),1.1,1.65},
			[6] = {11,mode.grounds.shop.unpackImages(11,5),.5,1.42},
		}
		
		-- Sets the commands
		mode.grounds.cmds = system.getTranslation("commands")
		
		-- Disable commands
		for k,v in next,mode.grounds.cmds do
			disableChatCommand(v)
		end
		for k,v in next,{"o","p","h","k","?","pw","time","np","is","check","review","next","again"} do
			disableChatCommand(v)
		end
		
		-- Init
		mode.grounds.alivePlayers,mode.grounds.totalPlayers = system.players()
		for _,f in next,{"AutoShaman","AutoScore","AutoNewGame","AutoTimeLeft","MinimalistMode","PhysicalConsumables"} do
			tfm.exec["disable"..f]()
		end
		tfm.exec.setAutoMapFlipMode(false)
		tfm.exec.newGame(mode.grounds.newMap())
		tfm.exec.setRoomMaxPlayers(16)
		mode.grounds.uileaderboard()
	end,
	-- Callbacks
	eventTextAreaCallback = function(i,n,c)
		local p = string.split(c,"[^%.]+")
		if p[1] == "shop" and os.time() > mode.grounds.info[n].shop.timer then
			mode.grounds.info[n].shop.timer = os.time() + 1000
			if p[2] == "left" then
				mode.grounds.info[n].shop.page = mode.grounds.info[n].shop.page - 1
				mode.grounds.uishop(n)
			elseif p[2] == "right" then
				mode.grounds.info[n].shop.page = mode.grounds.info[n].shop.page + 1
				mode.grounds.uishop(n)
			elseif p[2] == "buy" and mode.grounds.info[n].groundsDataLoaded then
				p[3] = tonumber(p[3]) or 0
				if mode.grounds.info[n].stats.groundsCoins >= p[3] then
					mode.grounds.info[n].stats.groundsCoins = mode.grounds.info[n].stats.groundsCoins - p[3]
					local loc = mode.grounds.info[n].stats.powers[p[4]]
					mode.grounds.info[n].stats.powers[p[4]][#loc] = mode.grounds.info[n].stats.powers[p[4]][#loc] + 1
					mode.grounds.info[n].stats.powers[p[4]][1] = mode.grounds.info[n].stats.powers[p[4]][1] * mode.grounds.shop.grounds[mode.grounds.info[n].shop.page][4]
					tfm.exec.chatMessage(string.format("<PT>[•] <BV>%s",string.format(system.getTranslation("bought",n),"<J>$"..p[3].."</J>","<ROSE>"..system.getTranslation("grounds."..mode.grounds.shop.grounds[mode.grounds.info[n].shop.page][1],n)[1].."</ROSE>",n)),n)
					mode.grounds.uishop(n)
				else
					tfm.exec.chatMessage(string.format("<PT>[•] <R>%s",system.getTranslation("cantbuy",n)),n)
				end
			elseif p[2] == "close" then
				for i = 4,13 do
					ui.removeTextArea(i,n)
				end
				mode.grounds.info[n].shop.accessing = false
				for k,v in next,mode.grounds.info[n].shop.image do
					tfm.exec.removeImage(v)
				end
			end
		elseif p[1] == "profile" then
			if p[2] == "close" then
				for i = 14,16 do
					ui.removeTextArea(i,n)
				end
				mode.grounds.info[n].profileAccessing = false
			elseif p[2] == "open" then
				if p[3] then
					mode.grounds.uiprofile(n,p[3])
				else
					mode.grounds.uiprofile(n,n)
				end
			end
		elseif p[1] == "menu" and os.time() > mode.grounds.info[n].menu.timer then
			mode.grounds.info[n].menu.timer = os.time() + 1e3
			if p[2] == "page" and p[3] then
				mode.grounds.info[n].menu.page = tonumber(p[3])
				mode.grounds.uimenu(n)
			elseif p[2] == "right" then
				mode.grounds.info[n].menu.page = mode.grounds.info[n].menu.page + 1
				mode.grounds.uimenu(n)
			elseif p[2] == "left" then
				mode.grounds.info[n].menu.page = mode.grounds.info[n].menu.page - 1
				mode.grounds.uimenu(n)
			elseif p[2] == "popup" then
				mode.grounds.info[n].menu.showPopup = not mode.grounds.info[n].menu.showPopup
				mode.grounds.uimenu(n)
			elseif p[2] == "close" then
				for i = 22,17,-1 do
					ui.removeTextArea(i,n)
				end
				mode.grounds.info[n].menu.accessing = false
				if mode.grounds.info[n].showHelp then
					mode.grounds.info[n].showHelp = false
					ui.removeTextArea(0,n)
				end
			end
		elseif p[1] == "print" then
			p[2] = string.gsub(p[2],"¬",".")
			tfm.exec.chatMessage(string.format("<PT>[•] <BV>%s",p[2]),n)
		elseif p[1] == "ranking" then
			if p[2] == "close" then
				mode.grounds.info[n].leaderboardAccessing = false
				for i = 23,36 do
					ui.removeTextArea(i,n)
				end
			end
		elseif p[1] == "info" then
			if p[2] == "close" then
				for i = 37,38 do
					ui.removeTextArea(i,n)
				end
				for k,v in next,mode.grounds.info[n].infoImage do
					tfm.exec.removeImage(v)
				end
				mode.grounds.info[n].infoImage = {}
			else
				mode.grounds.uidisplayInfo(n,p)
			end
		end
	end,
	-- New Player
	eventNewPlayer = function(n)
		tfm.exec.chatMessage(string.format(mode.grounds.welcomeMessage,string.format(system.getTranslation("welcome"),"<ROSE>"..module._NAME.."<BV>"),string.format(system.getTranslation("developer"),"Bolodefchoco")),n)
		if math.random(10) < 3 then
			tfm.exec.chatMessage("<ROSE>[•] Play #powers at /room #powers",n)
		end
		
		if system.isPlayer(n) then
			tfm.exec.lowerSyncDelay(n)
			for _,key in next,mode.grounds.bindKeys do
				if key < 4 then
					system.bindKeyboard(n,key,false,true)
				end
				system.bindKeyboard(n,key,true,true)
			end
		else
			tfm.exec.chatMessage("<R>Souris! :(",n)
		end
		if not mode.grounds.info[n] then
			mode.grounds.info[n] = {
				groundsDataLoaded = true,
				showHelp = true,
				right = true,
				langue = mode.grounds.langue,
				isWalking = false,
				drown = 0,
				ranking = -1,
				canRev = false,
				checkpoint = -1,
				shop = {
					accessing = false,
					page = 0,
					timer = 0,
					image = {},
				},
				menu = {
					accessing = false,
					page = 0,
					timer = 0,
					showPopup = true,
				},
				profileAccessing = false,
				leaderboardAccessing = false,
				profileTimer = 0,
				leaderboardTimer = 0,
				isOnline = true,
				stats = {
					groundsCoins = 1000,
					rounds = 0,
					podiums = 0,
					deaths = 0,
					powers = {
						ice = {25,100,1}, -- power, timer, level
						lava = {0,1}, -- power, level
						sand = {1,1}, -- Txtarea opacity, level
						cloud = {35,100,1}, -- power, timer, level
						water = {5,1}, -- power, level
						stone = {15,2500,700,1}, -- size, despawn timer, timer, level
						snow = {5,100,1}, -- power, timer, level
						spiderweb = {0,1}, -- power, level
					},
				},
				powersOP = {
					TIMER = 0,
					GTYPE = -1,
				},
				infoImage = {},
			}
			ui.addTextArea(0,"",n,-1500,-1500,3e3,3e3,1,1,.8,true)
			mode.grounds.uimenu(n)
		end
	
		mode.grounds.info[n].isOnline = true
		mode.grounds.info[n].canRev = false
	end,
	-- New Game
	eventNewGame = function()
		local mapName = {}
		if table.find(mode.grounds.maps,tfm.get.room.xmlMapInfo.mapCode,1) then
			mapName[#mapName + 1] = "<font color='#".. mode.grounds.mapInfo[5] .."'>G" .. mode.grounds.mapInfo[2] .. "</font>"
		else
			mode.grounds.mapInfo = {0,0,0,0,"CAA4CF"}
			mode.grounds.afterFunction = (function() end)
		end

		tfm.exec.setGameTime(3 * 60)

		mode.grounds.podium = 0
		mode.grounds.availableRoom = mode.grounds.totalPlayers > 2 and system.isRoom
		if not mode.grounds.availableRoom then
			if math.random(30) < 16 then
				if not system.isRoom then
					tfm.exec.chatMessage(string.format("<PT>[•] <BV>%s",system.getTranslation("countstats.tribe")))
				else
					tfm.exec.chatMessage(string.format("<PT>[•] <BV>%s",system.getTranslation("countstats.mice")))
				end
			end
		end

		for k,v in next,mode.grounds.info do
			if not system.isPlayer(k) then
				tfm.exec.killPlayer(k)
			end
			if v.groundsDataLoaded and mode.grounds.availableRoom then
				v.stats.rounds = v.stats.rounds + 1
			end
			v.canRev = true
			v.right = true
			v.checkpoint = -1
		end

		mode.grounds.afterFunction()
		
		mode.grounds.hasWater = false
		local deactivateWater = false

		mode.grounds.despawnGrounds = {}
		mode.grounds.gsys.disabledGrounds = {}
		local currentXml = tfm.get.room.xmlMapInfo

		local xmlPowers = {}
			-- Info
		xmlPowers[1] = { -- Soulmate system
			attribute = "A", -- Soulmate not allowed for rooms with odd amount of players
			func = function()
				if mode.grounds.totalPlayers % 2 ~= 0 then
					table.foreach(mode.grounds.info,tfm.exec.killPlayer)
				end
			end
		}
		xmlPowers[2] = { -- Map Width
			attribute = "L",
			func = function(size)
				if size then
					mode.grounds.mapInfo[3] = tonumber(size)
				end
			end
		}
		xmlPowers[3] = { -- Map Height
			attribute = "H",
			func = function(size)
				if size then
					mode.grounds.mapInfo[4] = tonumber(size)
				end
			end
		}
		
		mode.grounds.mapInfo[3] = math.max(800,mode.grounds.mapInfo[3])
		mode.grounds.mapInfo[4] = math.max(400,mode.grounds.mapInfo[4])
			-- Powers
		xmlPowers[4] = { -- mapname
			attribute = "mapname",
			func = function(t)
				if t ~= "" then
					mapName[#mapName + 1] = t
				end
			end
		}
		xmlPowers[5] = { -- disablepower
			attribute = "disablepower",
			func = function(g)
				for ground in string.gmatch(g,"[^,]+") do
					ground = tonumber(ground)
					if ground and not mode.grounds.gsys.disabledGrounds[ground] then
						mode.grounds.gsys.disabledGrounds[ground] = true
					end
				end
			end
		}
		xmlPowers[6] = { -- cheese
			attribute = "cheese",
			func = function()
				table.foreach(mode.grounds.info,tfm.exec.giveCheese)
			end
		}
		xmlPowers[7] = { -- meep
			attribute = "meep",
			func = function()
				table.foreach(mode.grounds.info,tfm.exec.giveMeep)
			end
		}
		xmlPowers[8] = { -- addtime
			attribute = "addtime",
			func = function(minutes)
				tfm.exec.setGameTime((3 + (tonumber(minutes) or 0)) * 60)
			end
		}
		xmlPowers[9] = { -- notwater
			attribute = "notwater",
			func = function()
				deactivateWater = true
			end
		}
		xmlPowers[10] = { -- setvampire
			attribute = "setvampire",
			func = function(coordinates)
				if mode.grounds.totalPlayers > 2 then
					local coord,axY = xml.getCoordinates(coordinates)

					local vampires,p = {},{}
					for k,v in next,mode.grounds.info do
						if v.isOnline then
							p[#p + 1] = k
						end
					end
					local randomVamp = ""
					for i = 1,math.floor(mode.grounds.totalPlayers/3) do
						repeat
							randomVamp = table.random(p)
						until not table.find(vampires,randomVamp)
						vampires[#vampires + 1] = randomVamp
					end
					for k,v in next,vampires do
						if type(coord) == "table" then
							local c = table.random(coord)
							tfm.exec.movePlayer(v,c.x,c.y)
						else
							if axY == 0 then
								tfm.exec.movePlayer(v,coord,math.random(10,mode.grounds.mapInfo[4] - 10))
							else
								tfm.exec.movePlayer(v,math.random(10,mode.grounds.mapInfo[4] - 10),axY)
							end
						end
						tfm.exec.setVampirePlayer(v)
					end
				else
					table.foreach(mode.grounds.info,tfm.exec.setVampirePlayer)
				end
			end
		}
		xmlPowers[11] = { -- shaman
			attribute = "shaman",
			func = function(t)
				if t ~= "" then
					ui.setShamanName(t)
				end
			end
		}	

		xml.attribFunc(currentXml.xml or "",xmlPowers)

		mode.grounds.gsys.getGroundProperties(currentXml.xml)

		if not deactivateWater then
			for k,v in next,mode.grounds.gsys.grounds do
				if v.T == 9 then
					mode.grounds.hasWater = true
					for k,v in next,mode.grounds.info do
						v.drown = 0
						mode.grounds.uibar(1,k,v.drown,0x519DDA,100,20)
					end
					break
				end
			end
		end
		if not mode.grounds.hasWater then
			for i = 1,3 do
				ui.removeTextArea(i)
			end
		end
		
		local ini = ""
		local D = string.match(tfm.get.room.xmlMapInfo.xml,"<D>(.-)</D>") or ""
		for k,v in next,{"DS","T"} do
			ini = string.match(D,"<"..v.." (.-)/>")
			if ini then
				break
			end
		end
		ini = ini or ""
		local sX = string.match(ini,"X=\"(.-)\"")
		local sY = string.match(ini,"Y=\"(.-)\"")
		mode.grounds.spawnPoint = {tonumber(sX) or 0,tonumber(sY) or 0}
		
		ui.setMapName(table.concat(mapName,"   <G>|<J>   ") .. (#mapName > 0 and "   <G>|<J>   " or "") .. currentXml.author .. " <BL>- " .. tfm.get.room.currentMap)
	end,
	-- Loop
	eventLoop = function()
		mode.grounds.gsys.groundEffects()
		
		if _G.currentTime % 5 == 0 then
			mode.grounds.alivePlayers,mode.grounds.totalPlayers = system.players()
		end
		
		if _G.currentTime == 3 and math.random(50) < 16 and os.time() > mode.grounds.announceTimer then
			mode.grounds.announceTimer = os.time() + 5000
			tfm.exec.chatMessage(string.format("<PT>[•] <BV>%s",system.getTranslation("powersenabled")))
		end

		if _G.currentTime%2 == 0 and not mode.grounds.review then
			if mode.grounds.alivePlayers < 1 or _G.leftTime <= 2 then
				tfm.exec.newGame(mode.grounds.newMap())
			elseif mode.grounds.alivePlayers == 1 and _G.leftTime > 50 and mode.grounds.totalPlayers > 1 then
				tfm.exec.setGameTime(30)
			elseif mode.grounds.podium > 5 and mode.grounds.alivePlayers > 3 then
				tfm.exec.setGameTime(20,false)
			end
		end

		local grounds = {}
		for k,v in next,mode.grounds.despawnGrounds do
			grounds[k] = v
		end
		for k,v in next,grounds do
			if os.time() > v[2] then
				tfm.exec.removePhysicObject(v[1])
				table.remove(mode.grounds.despawnGrounds,k)
			end
		end
		for n,v in next,mode.grounds.info do
			v.isWalking = (tfm.get.room.playerList[n] and (tfm.get.room.playerList[n].movingRight or tfm.get.room.playerList[n].movingLeft) or false)
			v.right = (tfm.get.room.playerList[n] and (tfm.get.room.playerList[n].isFacingRight) or false)
			if v.powersOP.GTYPE ~= 7 then -- Sand
				ui.removeTextArea(-1,n)
			end
			if mode.grounds.hasWater then
				if _G.currentTime%2 == 0 then
					if tfm.get.room.playerList[n] then
						if not tfm.get.room.playerList[n].isDead and v.powersOP.GTYPE ~= 9 then -- Water
							if v.drown > 0 then
								v.drown = v.drown - math.random(1,math.floor(v.stats.powers.water[1]))
								mode.grounds.uibar(1,n,v.drown,0x519DDA,100,20)
							end
						end
					end
				end
			end
		end
	end,
	-- Keyboard
	eventKeyboard = function(n,k,d,x,y)
		tfm.get.room.playerList[n].x = x
		tfm.get.room.playerList[n].x = y
		if table.find(mode.grounds.bindKeys,k) then
			if k < 4 then
				if k == 0 then
					mode.grounds.info[n].right = false
				elseif k == 2 then
					mode.grounds.info[n].right = true
				end
			elseif k == string.byte("O") then
				mode.grounds.eventChatCommand(n,"o")
			elseif k == string.byte("P") then
				if mode.grounds.info[n].profileAccessing then
					mode.grounds.eventTextAreaCallback(nil,n,"profile.close")
				else
					if os.time() > mode.grounds.info[n].profileTimer then
						mode.grounds.info[n].profileTimer = os.time() + 1e3
						mode.grounds.eventChatCommand(n,"p")
					end
				end
			elseif k == string.byte("H") then
				mode.grounds.eventChatCommand(n,"h")
			elseif k == string.byte("K") then
				mode.grounds.eventChatCommand(n,"k")
			end
		else
			if k == 32 and os.time() > mode.grounds.info[n].powersOP.TIMER then
				local ms = 0
				local power = {0,0}
				if mode.grounds.info[n].powersOP.GTYPE == 8 then -- Cloud
					power = mode.grounds.info[n].stats.powers.cloud
					ms = power[2]
					tfm.exec.movePlayer(n,0,0,true,0,-power[1],true)
				elseif mode.grounds.info[n].powersOP.GTYPE == 1 and mode.grounds.info[n].isWalking then -- Ice
					power = mode.grounds.info[n].stats.powers.ice
					ms = power[2]
					tfm.exec.movePlayer(n,0,0,false,(mode.grounds.info[n].right and power[1] or -power[1]),0,true)
				elseif mode.grounds.info[n].powersOP.GTYPE == 11 and not mode.grounds.info[n].isWalking then -- Snow
					power = mode.grounds.info[n].stats.powers.snow
					ms = power[2]
					tfm.exec.addShamanObject(34,x + (mode.grounds.info[n].right and 20 or -20),y - 5,0,(mode.grounds.info[n].right and power[1] or -power[1]))
					tfm.exec.playEmote(n,26)
				elseif mode.grounds.info[n].powersOP.GTYPE == 10 and not mode.grounds.info[n].isWalking then -- Stone
					power = mode.grounds.info[n].stats.powers.stone
					local id = tfm.get.room.playerList[n].id
					if not table.find(mode.grounds.despawnGrounds,id,1) then
						ms = power[3]
						local halfSize = (power[1]/2) + 15
						tfm.exec.addPhysicObject(id,x + (mode.grounds.info[n].right and halfSize or -halfSize),y + 32 - halfSize,{
							type = 10,
							miceCollision = true,
							groundCollision = false,
							width = power[1],
							height = power[1],
							friction = .3,
							restitution = 0
						})
						table.insert(mode.grounds.despawnGrounds,{id,os.time() + power[2]})
					end
				end
				mode.grounds.info[n].powersOP.TIMER = os.time() + ms
				system.bindKeyboard(n,32,true,false)
			end
			mode.grounds.info[n].powersOP.GTYPE = -1
		end
	end,
	-- Commands
	eventChatCommand = function(n,c)
		if system.isPlayer(n) then
			c = deactivateAccents(c)
			system.disableChatCommandDisplay(c,true)
			local p = string.split(c,"[^%s]+",string.lower)
			disableChatCommand(p[1])
			if p[1] == mode.grounds.cmds.shop or p[1] == "o" then
				if mode.grounds.info[n].shop.accessing then
					mode.grounds.eventTextAreaCallback(nil,n,"shop.close")
				else
					if os.time() > mode.grounds.info[n].shop.timer then
						mode.grounds.info[n].shop.timer = os.time() + 1200
						mode.grounds.uishop(n)
					end
				end
			elseif p[1] == mode.grounds.cmds.profile or p[1] == "p" then
				if p[2] then
					p[2] = string.nick(p[2])
					if mode.grounds.info[p[2]] then
						mode.grounds.uiprofile(n,p[2])
					end
				else
					mode.grounds.uiprofile(n,n)
				end
				mode.grounds.info[n].profileAccessing = true
			elseif p[1] == mode.grounds.cmds.help or p[1] == "h" then
				if mode.grounds.info[n].menu.accessing then
					mode.grounds.eventTextAreaCallback(nil,n,"menu.close")
				else
					if os.time() > mode.grounds.info[n].menu.timer then
						mode.grounds.info[n].menu.timer = os.time() + 1e3
						mode.grounds.uimenu(n)
					end
				end
			elseif p[1] == mode.grounds.cmds.langue then
				p[2] = p[2] and string.lower(p[2]) or nil
				if p[2] and (p[2] == "default" or mode.grounds.translations[p[2]]) then
					if p[2] == "default" then
						mode.grounds.info[n].langue = (mode.grounds.translations[tfm.get.room.playerList[n].community] and tfm.get.room.playerList[n].community or mode.grounds.langue)
					else
						mode.grounds.info[n].langue = string.lower(p[2])
					end
					tfm.exec.chatMessage(string.format("<PT>[•] <BV>%s",string.format(system.getTranslation("language",n),string.upper(mode.grounds.info[n].langue))),n)
				else
					tfm.exec.chatMessage(string.format("<PT>[•] <J>!%s <PS>%s",p[1],table.concat(mode.grounds.langues," <G>-</G> ")),n)
				end
			elseif p[1] == mode.grounds.cmds.leaderboard or p[1] == "k" then
				if mode.grounds.info[n].leaderboardAccessing then
					mode.grounds.eventTextAreaCallback(nil,n,"ranking.close")
				else
					if os.time() > mode.grounds.info[n].leaderboardTimer then
						mode.grounds.info[n].leaderboardTimer = os.time() + 1e3
						mode.grounds.uileaderboard(n)
					end
				end
			elseif p[1] == mode.grounds.cmds.info or p[1] == "?" then
				local grounds = system.getTranslation("grounds",n)
				local ground = grounds[mode.grounds.info[n].powersOP.GTYPE]
				if ground then
					mode.grounds.uidisplayInfo(n,{"info","grounds",string.gsub(ground[1],"'","#"),ground[2]})
				end
			elseif p[1] == "mapinfo" and mode.grounds.mapInfo[2] > 0 then
				tfm.exec.chatMessage(string.format("<PT>[•] <BV>G%s (%s) - %s - @%s",mode.grounds.mapInfo[2],mode.grounds.G[mode.grounds.mapInfo[2]].name,tfm.get.room.xmlMapInfo.author,mode.grounds.mapInfo[1]),n)
			else
				local isAdmin,isMapEv,isTranslator = system.roomAdmins[n],table.find(mode.grounds.staff.mapEvaluators,n,1),table.find(mode.grounds.staff.translators,n,1)
				if p[1] == mode.grounds.cmds.pw or p[1] == "pw" then
					if isAdmin then
						local newPassword = p[2] and table.concat(p," ",nil,2) or ""
						local pwMsg = system.getTranslation("password")
						if newPassword == "" then
							tfm.exec.chatMessage(string.format("<R>[•] %s",pwMsg.off))
						else
							local xxx = string.rep("*",#newPassword)
							for k in next,mode.grounds.info do
								if system.roomAdmins[k] and system.isPlayer(k) then
									tfm.exec.chatMessage(string.format("<R>[•] %s",string.format(pwMsg.on,newPassword)),k)
								else
									tfm.exec.chatMessage(string.format("<R>[•] %s",string.format(pwMsg.on,xxx)),k)
								end
							end
						end
						tfm.exec.setRoomPassword(newPassword)
					else
						tfm.exec.chatMessage("<ROSE>[•] /room #" .. module._NAME .. math.random(0,999) .. "@" .. n,n)
					end
				end
				if not system.isRoom then
					if p[1] == "time" and isMapEv then
						tfm.exec.setGameTime(p[2] or 1e7)
					elseif p[1] == "np" and p[2] and isMapEv then
						mode.grounds.mapInfo = {0,0,0,0,"CAA4CF"}
						tfm.exec.newGame(p[2])
					elseif p[1] == "review" and isMapEv then
						mode.grounds.review = not mode.grounds.review
						tfm.exec.chatMessage("<BV>[•] REVIEW MODE : " .. string.upper(tostring(mode.grounds.review)),n)
						tfm.exec.disableAfkDeath(mode.grounds.review)
						if mode.grounds.review then
							table.foreach(mode.grounds.info,tfm.exec.respawnPlayer)
						end
					elseif p[1] == "next" and _G.currentTime > 10 and isMapEv then
						tfm.exec.newGame(mode.grounds.newMap())
					elseif p[1] == "again" and _G.currentTime > 10 and isMapEv then
						if tfm.get.room.currentMap then
							tfm.exec.newGame(tfm.get.room.currentMap)
						end
					end
				end
				if p[1] == "is" and isMapEv then
					p[2] = p[2] or tfm.get.room.currentMap
					p[2] = tonumber(string.match(p[2],"@?(%d+)")) or 0
					
					local exist,index = table.find(mode.grounds.maps,p[2],1)
					local cat = exist and mode.grounds.maps[index][2] or 0
					tfm.exec.chatMessage(string.format("<BV>[•] @%s : %s",p[2],string.upper(tostring(exist)) .. (exist and " (G"..cat..")" or "")),n)
				end	
				if p[1] == "check" and isTranslator then
					p[2] = p[2] and string.lower(p[2]) or nil
					if p[2] and mode.grounds.translations[p[2]] then
						local newP3 = p[3] and system.loadTable("mode.grounds.translations."..p[2].."."..p[3]) or {}
						if newP3 and type(newP3) == "string" then
							tfm.exec.chatMessage("<CEP>[•] [" .. p[3] .. "] : <N><VI>\"</VI>" .. newP3 .. "<VI>\"</VI>",n)
						else
							tfm.exec.chatMessage("<CEP>[•] " .. (p[3] and "Invalid! Try one of these indexes:" or "!" .. p[1] .. " " .. p[2] .. " <VI>id"),n)
							for k,v in next,mode.grounds.translationIndexes do
								tfm.exec.chatMessage("<N>\t\t" .. v,n)
							end
						end
					else
						tfm.exec.chatMessage("<CEP>[•] !" .. p[1] .. " " .. table.concat(mode.grounds.langues," <G>-</G> "),n)
					end
				end
			end
		end
	end,
	-- Victory
	eventPlayerWon = function(n)
		if mode.grounds.availableRoom and mode.grounds.info[n].groundsDataLoaded and system.isPlayer(n) then
			mode.grounds.podium = mode.grounds.podium + 1
			if mode.grounds.podium < 4 then
				mode.grounds.info[n].stats.podiums = mode.grounds.info[n].stats.podiums + 1
				local addedCoins = 20 - mode.grounds.podium * 5
				mode.grounds.info[n].stats.groundsCoins = mode.grounds.info[n].stats.groundsCoins + addedCoins
				tfm.exec.setPlayerScore(n,4-podium,true)
				tfm.exec.chatMessage(string.format("<PT>[•] <BV>%s",string.format(system.getTranslation("gotcoin",n),"<J>+$"..addedCoins.."</J>")),n)
				if mode.grounds.podium == 1 then
					tfm.exec.setGameTime(60,false)
				end
			else
				if mode.grounds.podium == 4 then
					tfm.exec.setGameTime(30,false)
				end
				mode.grounds.info[n].stats.groundsCoins = mode.grounds.info[n].stats.groundsCoins + 1
				tfm.exec.setPlayerScore(n,1,true)
			end
			if mode.grounds.hasWater then
				mode.grounds.uibar(1,n,mode.grounds.info[n].drown,0x6FDA51,100,20)
			end
			if system.miscAttrib ~= 0 then
				if mode.grounds.podium == system.miscAttrib then
					tfm.exec.setGameTime(0)
				end
			end
		end
		if mode.grounds.review then
			tfm.exec.respawnPlayer(n)
		end
		mode.grounds.info[n].canRev = false
	end,
	-- Died
	eventPlayerDied = function(n)
		if mode.grounds.info[n].groundsDataLoaded and mode.grounds.availableRoom then
			mode.grounds.info[n].stats.deaths = mode.grounds.info[n].stats.deaths + 1
		end
		if mode.grounds.hasWater then
			if mode.grounds.info[n].drown > 0 then
				mode.grounds.uibar(1,n,mode.grounds.info[n].drown,0xDA516D,100,20)
			end
		end
		system.bindKeyboard(n,32,true,false)
		ui.removeTextArea(-1,n)
		if mode.grounds.review then
			tfm.exec.respawnPlayer(n)
		end
	end,
	-- Left
	eventPlayerLeft = function(n)
		if mode.grounds.info[n] then
			mode.grounds.info[n].isOnline = false
		end
	end,
	-- Respawn
	eventPlayerRespawn = function(n)
		if mode.grounds.info[n].checkpoint ~= -1 then
			local g = mode.grounds.gsys.grounds[mode.grounds.info[n].checkpoint]
			local hTP = mode.grounds.gsys.getTpPos(g,true)
			tfm.exec.movePlayer(n,hTP[1],hTP[2])
		end
		if mode.grounds.info[n].groundsDataLoaded and mode.grounds.availableRoom then
			mode.grounds.info[n].stats.rounds = mode.grounds.info[n].stats.rounds + 1
		end
		if mode.grounds.hasWater then
			mode.grounds.uibar(1,n,mode.grounds.info[n].drown,0x519DDA,100,20)
		end
		tfm.exec.chatMessage(string.format("<R>[•] %s",system.getTranslation("zombie",n)),n)
	end,
}

--[[ Jokenpo ]]--
mode.jokenpo = {
	-- Translations
	translations = {
		en = {
			-- Init
			welcome = "Welcome to <ROSE>#Jokenpo<CE>! Choose a chair, press space and start playing!\n\tReport any issue to Bolodefchoco",
			
			-- Simple words
			round = "Round",
			players = "Players",
			won = "won the round!",
			tie = "Tie!",
			victory = "won the game!",
			
			-- Info
			guide = "Press\n\t<PS>»</PS> %s<PT> - Rock</PT>\n\t<PS>»</PS> %s<PT> - Paper</PT>\n\t<PS>»</PS> %s<PT> - Scissor (Pufferfish)</PT>",
			
			-- Game
			items = {"Rock","Paper","Scissor"},
			selected = "You've selected the item %s!",
		},
		br = {
			welcome = "Bem-vindo ao <ROSE>#Jokenpo<CE>! Escolha uma cadeira, aperte espaço e comece a jogar!\n\tReporte qualquer problema para Bolodefchoco",
		
			round = "Partida",
			players = "Jogadores",
			won = "venceu a partida!",
			tie = "Empate!",
			victory = "ganhou!",
			
			guide = "Pressione\n\t<PS>»</PS> %s<PT> - Pedra</PT>\n\t<PS>»</PS> %s<PT> - Papel</PT>\n\t<PS>»</PS> %s<PT> - Tesoura (Baiacu)</PT>",
			
			items = {"Pedra","Papel","Tesoura"},
			selected = "Você selecionou o item %s!",
		},
	},
	langue = "en",
	-- Maps
	maps = {5198315,4093087},
	buildSquares = function(c)
		tfm.exec.removePhysicObject(1)
		for k,v in next,{{346,224},{454,224},{400,105}} do
			for i = 1,4 do
				local x = i == 1 and v[1] + 28 or i == 2 and v[1] - 28 or v[1]
				local y = i == 3 and v[2] + 28 or i == 4 and v[2] - 28 or v[2]
				
				local w = x == v[1] and 46 or 10
				local h = w == 10 and 66 or 10
				
				tfm.exec.addPhysicObject(i..k,x,y,{
					type = 12,
					color = c[k],
					width = w,
					height = h,
				})
			end
		end
	end,
	-- New Round Settings
	playing = false,
	players = {},
	colors = {0xE3454D,0x4577E3,0x45E374},
	timer = 9.5,
	partialTimer = 0,
	tie = 0,
	round = 0,
	roundsPerGame = 5,
	-- Game settings
	objects = {
		85,
		95,
		65,
	},
	-- Emotes
	emote = {
		sit = 8,
		victory = 24,
		fail = 5,
		tie = 4,
		no = 2
	},
	-- Battle
	decision = function()
		for i = 1,2 do
			mode.jokenpo.players[i].obj = mode.jokenpo.players[i].obj ~= 0 and mode.jokenpo.players[i].obj or false
			if mode.jokenpo.players[i].obj then
				mode.jokenpo.players[i].remId = tfm.exec.addShamanObject(mode.jokenpo.objects[mode.jokenpo.players[i].obj],({350,455})[i],200)
			end
		end

		local winner = ((mode.jokenpo.players[1].obj and mode.jokenpo.players[2].obj) and ((3 + mode.jokenpo.players[1].obj - mode.jokenpo.players[2].obj) % 3) or mode.jokenpo.players[1].obj and 1 or mode.jokenpo.players[2].obj and 2 or 0)
		
		if winner == 0 then
			mode.jokenpo.tie = mode.jokenpo.tie + 1
			tfm.exec.chatMessage("<CE>[•] <J>" .. system.getTranslation("tie"))
			
			for k,v in next,mode.jokenpo.players do
				tfm.exec.playEmote(v.name,mode.jokenpo.emote.tie)
			end
		else
			mode.jokenpo.players[winner].score = mode.jokenpo.players[winner].score + 1
			tfm.exec.playEmote(mode.jokenpo.players[winner].name,mode.jokenpo.emote.victory)
			
			local looser = (winner == 1 and 2 or 1)
			local looserEmote = mode.jokenpo.emote.fail
			if not mode.jokenpo.players[looser].obj then
				looserEmote = mode.jokenpo.emote.no
			end
			tfm.exec.playEmote(mode.jokenpo.players[looser].name,looserEmote)

			tfm.exec.chatMessage("<CE>[•] " .. mode.jokenpo.players[winner].color .. mode.jokenpo.players[winner].name .. " " .. system.getTranslation("won"))
		end
		
		ui.addTextArea(5,string.format("<font size='50'><p align='center'>%s%d <PT>| <J>%d <PT>| %s%s",mode.jokenpo.players[1].color,mode.jokenpo.players[1].score,mode.jokenpo.tie,mode.jokenpo.players[2].color,mode.jokenpo.players[2].score),nil,5,270,795,nil,1,1,0,true)
	end,
	-- Partial Next Round
	pNextRound = function()
		mode.jokenpo.playing = false
		mode.jokenpo.timer = 9.5
		mode.jokenpo.partialTimer = 3.5
		mode.jokenpo.decision()
		if mode.jokenpo.round == mode.jokenpo.roundsPerGame then
			table.sort(mode.jokenpo.players,function(p1,p2) return p1.score > p2.score end)
			if mode.jokenpo.tie > mode.jokenpo.players[1].score then
				tfm.exec.chatMessage("<CE>[•] " .. system.getTranslation("tie"))
			else
				tfm.exec.chatMessage("<CE>[•] " .. mode.jokenpo.players[1].color .. mode.jokenpo.players[1].name .. " " .. system.getTranslation("victory"))
			end
		end
	end,
	-- Next Round
	nextRound = function()
		for i = 1,2 do
			if mode.jokenpo.players[i].remId then
				tfm.exec.removeObject(mode.jokenpo.players[i].remId)
			end
			mode.jokenpo.players[i].remId = nil
			mode.jokenpo.players[i].obj = 0
		end
		ui.removeTextArea(5,nil)
		mode.jokenpo.partialTimer = 0
		if mode.jokenpo.roundsPerGame > mode.jokenpo.round then
			mode.jokenpo.playing = true
			mode.jokenpo.round = mode.jokenpo.round + 1
		else
			mode.jokenpo.playing = false
			mode.jokenpo.round = 0
			mode.jokenpo.tie = 0
			mode.jokenpo.timer = 9.5
			mode.jokenpo.partialTimer = 0
			mode.jokenpo.players = {}
			tfm.exec.newGame(table.random(mode.jokenpo.maps))
			for i = 2,3 do
				ui.removeTextArea(i,nil)
			end
		end
		mode.jokenpo.uiinfo()
	end,
	-- Display names
	displayNames = function()
		if #mode.jokenpo.players == 0 then
			return ""
		else
			return "   <G>|   <N>" .. system.getTranslation("players") .. " : " .. table.concat(mode.jokenpo.players," <V>- ",function(k,v)
				tfm.exec.setNameColor(v.name,mode.jokenpo.colors[v.id])
				return v.color .. v.name
			end)
		end
	end,
	-- Info textareas
	uiinfo = function()
		ui.addTextArea(0,"<p align='center'><font size='35'><J>"..math.floor(mode.jokenpo.timer),nil,380,85,40,40,1,1,0,true)
		ui.addTextArea(1,"<p align='center'><font size='25'><J><B>X</B><font size='13'>\n"..string.format("%02d",mode.jokenpo.tie),nil,380,207,40,nil,1,1,0,true)
		
		for k,v in next,mode.jokenpo.players do
			ui.addTextArea(v.id + 1,"<p align='center'>"..v.name.."\n"..string.format("%02d",v.score),nil,v.x,165,105,nil,1,1,0,true)
		end
		
		ui.setMapName("<PT>#Jokenpo   <G>|   <N>" .. system.getTranslation("round") .. " : <V>" .. mode.jokenpo.round .. mode.jokenpo.displayNames() .. "<")
	end,
	-- Init
	init = function()
		mode.jokenpo.translations.pt = mode.jokenpo.translations.br
	
		-- Sets the main language according to the community
		if mode.jokenpo.translations[tfm.get.room.community] then
			mode.jokenpo.langue = tfm.get.room.community
		end
		
		-- Sets the rounds per game
		mode.jokenpo.roundsPerGame = math.max(5,system.miscAttrib)
		
		-- Init
		for _,f in next,{"AutoShaman","AutoNewGame","PhysicalConsumables","AfkDeath"} do
			tfm.exec["disable"..f]()
		end
		tfm.exec.setAutoMapFlipMode(false)
		tfm.exec.setRoomMaxPlayers(20)

		tfm.exec.newGame(table.random(mode.jokenpo.maps))
	end,
	-- New Player
	eventNewPlayer = function(n)
		tfm.exec.chatMessage("<CE>[•] " .. system.getTranslation("welcome"),n)
	
		for k,v in next,{32,string.byte("BNM",1,3)} do
			system.bindKeyboard(n,v,true,true)
		end
		
		if mode.jokenpo.playing then
			mode.jokenpo.round = mode.jokenpo.round + 1
		else
			tfm.exec.respawnPlayer(n)
		end
		
		mode.jokenpo.buildSquares(mode.jokenpo.colors)
		mode.jokenpo.uiinfo()
	end,
	-- New Game
	eventNewGame = function()
		if mode.jokenpo.playing then
			for k,v in next,tfm.get.room.playerList do
				if not table.find(mode.jokenpo.players,k,"name") then
					tfm.exec.killPlayer(k)
				end
			end
		end
	
		mode.jokenpo.colors = {0xE3454D,0x4577E3,0x45E374}	
		xml.attribFunc(tfm.get.room.xmlMapInfo.xml or "",{
			[1] = {
				attribute = "o",
				func = function(color)
					local c = string.split(color,"[^,]+",function(o)
						return string.match(o,"#?(.+)")
					end)
					
					for i = 1,#c do
						mode.jokenpo.colors[i] = tonumber(c[i],16)
					end
				end
			}
		})
		
		mode.jokenpo.buildSquares(mode.jokenpo.colors)
		mode.jokenpo.uiinfo()
	end,
	-- Keyboard
	eventKeyboard = function(n,k,d,x,y)
		if k == 32 and #mode.jokenpo.players < 2 then
			for k,v in next,{{285,330,270},{515,330,425}} do
				if math.pythag(v[1],v[2],x,y,30) then
					if not table.find(mode.jokenpo.players,n,"name") then
						if not table.find(mode.jokenpo.players,k,"id") then
							mode.jokenpo.players[#mode.jokenpo.players + 1] = {
								name = n,
								x = v[3],
								score = 0,
								color = string.format("<font color='#%s'>",string.format("%x",mode.jokenpo.colors[k])),
								id = k,
								obj = 0,
								remId = nil,
							}
							
							tfm.exec.chatMessage("<CE>[•] " .. mode.jokenpo.players[#mode.jokenpo.players].color .. string.format(system.getTranslation("guide"),"B","N","M"),n)
							
							mode.jokenpo.uiinfo()
							tfm.exec.playEmote(n,mode.jokenpo.emote.sit)
						end
					end
				end
			end
			
			if #mode.jokenpo.players == 2 then
				table.sort(mode.jokenpo.players,function(p1,p2) return p1.id < p2.id end)
				mode.jokenpo.playing = true
			end
		else
			if mode.jokenpo.playing then
				local foundObject,objectIndex = table.find({string.byte("BNM",1,3)},k)
				if foundObject then	
					local found,i = table.find(mode.jokenpo.players,n,"name")
					if found then
						i = mode.jokenpo.players[i]
						if i.obj == 0 then
							i.obj = objectIndex

							tfm.exec.chatMessage("<CE>[•] " .. i.color .. string.format(system.getTranslation("selected"),system.getTranslation("items")[objectIndex]),n)
						end
					end
				end
			end
		end
	end,
	-- Loop
	eventLoop = function()
		if mode.jokenpo.playing then
			if mode.jokenpo.timer > 0 then
				mode.jokenpo.timer = mode.jokenpo.timer - .5
				ui.addTextArea(0,"<p align='center'><font size='35'><J>"..math.floor(mode.jokenpo.timer),nil,380,85,40,40,1,1,0,true)
				for i = 1,2 do
					tfm.exec.movePlayer(mode.jokenpo.players[i].name,({285,515})[i],330)
					tfm.exec.playEmote(mode.jokenpo.players[i].name,26)
				end
			else
				mode.jokenpo.pNextRound()
			end
		else
			if mode.jokenpo.partialTimer > 0 then
				mode.jokenpo.partialTimer = mode.jokenpo.partialTimer - .5
				ui.addTextArea(0,"<p align='center'><font size='35'><PT>"..math.floor(mode.jokenpo.partialTimer),nil,380,85,40,40,1,1,0,true)
				
				if mode.jokenpo.partialTimer <= 0 then
					mode.jokenpo.nextRound()
				end
			end
		end
	end,
	-- Player Left
	eventPlayerLeft = function(n)
		if table.find(mode.jokenpo.players,n,"name") then
			mode.jokenpo.round = mode.jokenpo.roundsPerGame
			mode.jokenpo.nextRound()
		end
	end,
}

--[[ Click ]]--
mode.click = {
	-- Translations
	translations = {
		en = {
			-- Init
			welcome = "<BV>Welcome to <CH><B>#click</B><BV>!\n\t» Type <B>!p Playername</B> to open the profile of the player\n\t» Report any issue to <B>Bolodefchoco</B>",
		
			-- Info
			newGame = "New game in %s seconds!",
			clickfast = "Click several times in the circle before %s seconds!",
			
			-- Simple words
			click = "CLICK!",
			won = "won!",
			
			-- Profile
			profile = "Total clicks <BL>: <V>%s\n<J>High Score <BL>: <V>%s\n\n<J>Victories <BL>: <V>%s",
		},
		br = {
			welcome = "<BV>Bem-vindo ao <CH><B>#click</B><BV>!\n\t\n\t» Digite <B>!p Jogador</B> para abrir o perfil do jogador\n\t» Reporte qualquer problema para <B>Bolodefchoco</B>",
			
			newGame = "Novo jogo em %s segundos!",
			clickfast = "Clique várias vezes no círculo antes de %s segundos!",
			
			click = "CLIQUE!",
			won = "venceu!",
			
			profile = "Cliques totais <BL>: <V>%s\n<J>Maior pontuação <BL>: <V>%s\n\n<J>Vitórias <BL>: <V>%s",
		},
	},
	langue = "en",
	-- Data
	info = {},
	-- System
	circle = {
		id = 0,
		status = false
	},
	spawnCircle = function(on)
		if mode.click.circle.id > 0 then
			tfm.exec.removeJoint(mode.click.circle)
		end
		
		mode.click.circle = {id = 1,status = on}
		
		local color = on and 0x53D08B or 0x555D77
		
		tfm.exec.addJoint(1,0,0,{
			type = 0,
			alpha = .9,
			color = color,
			foreground = false,
			line = 300,
			point1 = "400,200",
			point2 = "400,201"
		})
	end,
	-- Timers
	partialTimer = 1,
	counter = 0,
	-- Ranking
	uileaderboard = function()
		local data = {}
		for k,v in next,mode.click.info do
			if v.canPlay and v.roundClick > 0 then
				data[#data + 1] = {k,v.roundClick}
			end
			
			if v.highScore < v.roundClick then
				v.highScore = v.roundClick
			end
			v.totalClick = v.totalClick + v.roundClick
			v.roundClick = 0
		end
		
		table.sort(data,function(p1,p2) return p1[2] > p2[2] end)
		
		local str = ""
		for k,v in next,data do
			if k < 51 then
				if k == 1 then
					mode.click.info[v[1]].victories = mode.click.info[v[1]].victories + 1
					tfm.exec.chatMessage("<J>" .. v[1] .. " <G>" .. system.getTranslation("won"))
					tfm.exec.setPlayerScore(v[1],1,true)
				end
				
				str = str .. string.format("<J>%s. <V>%s <BL>- <PT>%sP\n",k,v[1],v[2])
			end
		end
		
		ui.addTextArea(1,str,nil,5,30,250,330,1,1,.9,true)
	end,
	-- Init
	init = function()
		mode.click.translations.pt = mode.click.translations.br

		-- Sets the main language according to the community
		if mode.click.translations[tfm.get.room.community] then
			mode.click.langue = tfm.get.room.community
		end
		
		-- Init
		for _,f in next,{"AutoShaman","AutoScore","AutoNewGame","AfkDeath"} do
			tfm.exec["disable"..f]()
		end

		tfm.exec.newGame(5993911)
	end,
	-- New Player
	eventNewPlayer = function(n)
		system.bindMouse(n,true)
		if not mode.click.info[n] then
			mode.click.info[n] = {
				canPlay = false,
				totalClick = 0,
				roundClick = 0,
				highScore = 0,
				victories = 0,
			}
		end
		if not mode.click.circle.status then
			tfm.exec.respawnPlayer(n)
			mode.click.info[n].canPlay = true
		end
		tfm.exec.chatMessage(system.getTranslation("welcome"),n)
	end,
	-- New Game
	eventNewGame = function()
		mode.click.spawnCircle(false)
		mode.click.partialTimer = 10.5
	end,
	-- Loop
	eventLoop = function()
		if mode.click.partialTimer > 0 then
			mode.click.partialTimer = mode.click.partialTimer - .5
			ui.setMapName(string.format(system.getTranslation("newGame"),"<ROSE>"..math.floor(mode.click.partialTimer).."<J>") .. "<")
			if mode.click.partialTimer <= 0 then
				mode.click.spawnCircle(true)
				
				mode.click.counter = math.max(20,system.miscAttrib)
				
				for k,v in next,mode.click.info do
					v.canPlay = true
					tfm.exec.respawnPlayer(k)
				end
				
				ui.removeTextArea(1,nil)
				ui.setMapName(system.getTranslation("click") .. "<")
			end
		else
			if mode.click.counter > 0 then
				mode.click.counter = mode.click.counter - .5
				ui.addTextArea(0,"<p align='center'><font size='28'>" .. string.format(system.getTranslation("clickfast"),math.floor(mode.click.counter)),nil,0,30,800,50,1,1,0,true)
				if mode.click.counter <= 0 then
					mode.click.spawnCircle(false)

					mode.click.partialTimer = 10.5

					ui.removeTextArea(0,nil)
					mode.click.uileaderboard()
				end
			end
		end
	end,
	-- Mouse
	eventMouse = function(n,x,y)
		if mode.click.circle.status then
			if mode.click.info[n].canPlay then
				if math.pythag(400,200,x,y,150) then
					mode.click.info[n].roundClick = mode.click.info[n].roundClick + 1
					tfm.exec.displayParticle(15,math.random(150,650),math.random(100,300),0,0,0,0,n)
				end
			end
		end
	end,
	-- Commands
	eventChatCommand = function(n,c)
		local p = string.split(c,"[^%s]+",string.lower)
		if p[1] == "p" then
			p[2] = p[2] and string.nick(p[2]) or n
			if mode.click.info[p[2]] then
				ui.addTextArea(2,"<p align='center'><font size='18'><a:active><a href='event:close'>"..p[2].."</a><p align='left'><font size='13'>\n<J>" .. string.format(system.getTranslation("profile"),mode.click.info[p[2]].totalClick,mode.click.info[p[2]].highScore,mode.click.info[p[2]].victories),n,620,295,175,100,1,1,1,true)
			end
		end
	end,
	-- Callbacks
	eventTextAreaCallback = function(i,n,c)
		if c == "close" then
			ui.removeTextArea(2,n)
		end
	end,
	-- Respawn
	eventPlayerDied = function(n)
		tfm.exec.respawnPlayer(n)
	end,
	-- Player Left
	eventPlayerLeft = function(n)
		mode.click.info[n].canPlay = false
	end,
}

--[[ Presents ]]--
mode.presents = {
	-- Translations
	translations = {
		en = {
			-- Init
			welcome = "<J>Welcome to <VP><B>#presents</B><J>! Choose a gap according to the gift represented and good luck! You will win if your three-gifts-sequence is correct!\nType !p PlayerName to open the profile of the specified player\n\n<CE>Developed by Bolodefchoco and projected by Ruamorangos",
		
			-- Info
			choose = "Choose a gift before <PT>%s seconds!",
			kill = "Those who are out of the correct gift will be dead!",
			newGame = "New game in <PT>%s seconds!",
			nowinner = "No one won!",
			appear = "You will appear in the next game!",
			
			-- Simple words
			rival = "Rivals",
			won = "won!",
			
			-- Profile
			profile = "Rounds <BL>: <V>%s\n<J>Gifts <BL>: <V>%s\n\n<J>Victories <BL>: <V>%s",
		},
		br = {
			welcome = "<J>Bem-vindo ao <VP><B>#presents</B><J>! Escolha um buraco de acordo com o presente representado e boa sorte! Você ganhará se sua sequência nos três presentes estiver correta!\nDigite !p Jogador para abrir o perfil o jogador especificado\n\n<CE>Desenvolvido por Bolodefchoco, pedido por Ruamorangos",
		
			choose = "Escolha um presente antes de <PT>%s segundos!",
			kill = "Aqueles que estão fora do presente correto serão mortos!",
			newGame = "Novo jogo em <PT>%s segundos!",
			nowinner = "Ninguém ganhou!",
			appear = "Você irá aparecer no próximo jogo!",
			
			rival = "Rivais",
			won = "venceu!",

			profile = "Partidas <BL>: <V>%s\n<J>Presents <BL>: <V>%s\n\n<J>Vitórias <BL>: <V>%s",
		},
	},
	langue = "en",
	-- Data
	info = {},
	-- System
	isRunning = false,
	gifts = {},
	-- Timers
	chooseTimer = 15,
	blockTimer = 0,
	newMapTimer = 0,
	currentGift = 1,
	-- Map
	generateMap = function()
		mode.presents.isRunning = true
		mode.presents.gifts = {
			[1] = table.random({2104,2102,2100,2101,2103,2100,2104,2102,2103,2101,2104,2102,2100,2101,2103,2100,2104,2102,2103,2101,2104,2102,2100,2101,2103,2100,2104,2102,2103,2101}),
			[2] = table.random({2102,2100,2101,2103,2100,2104,2102,2103,2101,2104,2102,2100,2101,2103,2100,2104,2102,2103,2101,2104,2102,2100,2101,2103,2100,2104,2102,2103,2101,2104}),
			[3] = table.random({2100,2101,2103,2100,2104,2102,2103,2101,2104,2102,2100,2101,2103,2100,2104,2102,2103,2101,2104,2102,2100,2101,2103,2100,2104,2102,2103,2101,2104,2102})
		}
		
		tfm.exec.newGame('<C><P DS="m;250,120,400,120,550,120" D="x_transformice/x_inventaire/'..mode.presents.gifts[1]..'.jpg,230,60;x_transformice/x_inventaire/'..mode.presents.gifts[2]..'.jpg,380,60;x_transformice/x_inventaire/'..mode.presents.gifts[3]..'.jpg,530,60;x_transformice/x_inventaire/2100.jpg,140,320;x_transformice/x_inventaire/2101.jpg,260,320;x_transformice/x_inventaire/2102.jpg,380,320;x_transformice/x_inventaire/2103.jpg,500,320;x_transformice/x_inventaire/2104.jpg,620,320" /><Z><S><S P="1,0.0001,20,0.2,90,1,0,0" H="700" L="15" X="400" c="3" Y="161" T="4" /><S X="100" P="0,0,20,0.2,0,0,0,0" L="40" H="135" c="3" Y="335" T="4" /><S H="135" P="0,0,20,0.2,0,0,0,0" L="40" X="220" c="3" Y="335" T="4" /><S X="340" P="0,0,20,0.2,0,0,0,0" L="40" H="135" c="3" Y="335" T="4" /><S H="135" P="0,0,20,0.2,0,0,0,0" L="40" X="460" c="3" Y="335" T="4" /><S X="580" P="0,0,20,0.2,0,0,0,0" L="40" H="135" c="3" Y="335" T="4" /><S H="40" P="0,0,0.3,0.2,0,0,0,0" L="40" X="100" c="3" Y="160" T="0" /><S X="700" P="0,0,0.3,0.2,0,0,0,0" L="40" H="40" c="3" Y="160" T="0" /><S X="550" P="0,0,0.3,0.2,0,0,0,0" L="40" H="40" c="3" Y="160" T="0" /><S X="400" P="0,0,0.3,0.2,0,0,0,0" L="40" H="40" c="3" Y="160" T="0" /><S X="250" P="0,0,0.3,0.2,0,0,0,0" L="40" H="40" c="3" Y="160" T="0" /><S H="20" P="0,0,0.3,0.2,0,0,0,0" L="800" X="400" Y="10" T="0" /><S H="135" P="0,0,20,0.2,0,0,0,0" L="40" X="700" c="3" Y="335" T="4" /><S X="400" P="0,0,0.3,0.2,0,0,0,0" L="800" H="100" c="3" Y="415" T="0" /><S P="0,0,0.3,0.2,0,0,0,0" H="10" L="50" o="324650" X="745" c="3" Y="138" T="13" /><S X="55" P="0,0,0.3,0.2,0,0,0,0" L="50" o="324650" H="10" c="3" Y="138" T="13" /><S P="0,0,0.3,0.2,0,0,0,0" H="140" L="100" o="324650" X="55" c="3" Y="72" T="12" /><S X="745" P="0,0,0.3,0.2,0,0,0,0" L="100" o="324650" H="140" c="3" Y="72" T="12" /><S P="0,0,0,0,0,0,0,0" H="102" L="581" o="6a7495" X="401" c="4" v="3001" Y="78" T="12" /></S><D /><O /><L><JR M2="10" M1="0" /></L></Z></C>')
	end,
	-- Kill wrong gaps
	killOutOfRange = function()
		local gift = mode.presents.gifts[mode.presents.currentGift] - 2099
		for k,v in next,tfm.get.room.playerList do
			if not v.isDead then
				if v.x >= (gift * 120) and v.x <= (gift * 120 + 80) and v.y > 267 then
					mode.presents.info[k].gifts = mode.presents.info[k].gifts + 1
					tfm.exec.setPlayerScore(k,1,true)
				else
					tfm.exec.killPlayer(k)
				end
			end
		end
	end,
	-- Victory
	victory = function(noone)
		if noone then
			tfm.exec.chatMessage("<J>" .. system.getTranslation("nowinner"))
			mode.presents.chooseTimer = 0
			mode.presents.blockTimer = 0
		else
			tfm.exec.chatMessage("<S>" .. table.concat(system.players(true),"<J>, <S>",function(k,v)
				mode.presents.info[v].victories = mode.presents.info[v].victories + 1
				return v
			end) .. " <J>" .. system.getTranslation("won"))
		end
		mode.presents.newMapTimer = 10.5
	end,
	-- Init
	init = function()
		mode.presents.translations.pt = mode.presents.translations.br

		-- Sets the main language according to the community
		if mode.presents.translations[tfm.get.room.community] then
			mode.presents.langue = tfm.get.room.community
		end
		
		-- Init
		for _,f in next,{"AutoShaman","AutoNewGame","AutoScore","AfkDeath","MortCommand","DebugCommand","PhysicalConsumables"} do
			tfm.exec["disable"..f]()
		end	
		tfm.exec.setRoomMaxPlayers(30)

		mode.presents.generateMap()
	end,
	-- New Player
	eventNewPlayer = function(n)
		if not mode.presents.info[n] then
			mode.presents.info[n] = {
				rounds = 0,
				gifts = 0,
				victories = 0,
			}
		end
		
		tfm.exec.chatMessage(system.getTranslation("welcome"),n)
		
		if mode.presents.isRunning then
			local m = "<PT>" .. system.getTranslation("appear")
			ui.addTextArea(0,"<p align='center'><font size='20'><VP>" .. m,n,216,65,365,35,1,1,1,true)
			tfm.exec.chatMessage(m,n)
		else
			tfm.exec.respawnPlayer(n)
		end
	end,
	-- New Game
	eventNewGame = function()
		if mode.presents.isRunning then
			for i,x in next,{250,400,550} do
				tfm.exec.addPhysicObject(i,x,75,{
					type = 12,
					height = 90,
					width = 90,
					miceCollision = false,
					groundCollision = false,
					color = 0x6A7495
				})
			end
			for i = 0,1 do
				ui.removeTextArea(i)
			end
			mode.presents.chooseTimer = 15
			mode.presents.blockTimer = 0
			mode.presents.newMapTimer = 0
			mode.presents.currentGift = 1
			for k,v in next,mode.presents.info do
				v.rounds = v.rounds + 1
			end
		end
	end,
	-- Loop
	eventLoop = function()
		local mapName = "<N>" .. system.getTranslation("rival") .." : <V>" .. math.isNegative(system.players()-1,0)
		if _G.currentTime > 4 and mode.presents.isRunning then
			if mode.presents.chooseTimer > 0 then
				mode.presents.chooseTimer = mode.presents.chooseTimer - .5
				
				if mode.presents.chooseTimer <= 0 then
					mode.presents.blockTimer = 5
					tfm.exec.addPhysicObject(4,400,270,{
						type = 4,
						height = 10,
						width = 640,
						miceCollision = true,
						groundCollision = false
					})
					tfm.exec.removePhysicObject(mode.presents.currentGift)
				else
					mapName = mapName .. "   <G>|   <J>" .. string.format(system.getTranslation("choose"),math.floor(mode.presents.chooseTimer).."<J>")
				end
				
				if system.players() == 0 then
					mode.presents.victory(true)
				end
			end
			
			if mode.presents.blockTimer > 0 then
				mode.presents.blockTimer = mode.presents.blockTimer - .5
				
				if mode.presents.blockTimer == 2 then
					mode.presents.killOutOfRange()
				end
				
				if mode.presents.blockTimer <= 0 then
					mode.presents.currentGift = mode.presents.currentGift + 1
					if mode.presents.currentGift > 3 then
						mode.presents.victory()
					else
						tfm.exec.removePhysicObject(4)
						mode.presents.chooseTimer = 15
					end
				else
					mapName = mapName .. "   <G>|   <R>" .. system.getTranslation("kill")
				end
			end
			
			if mode.presents.newMapTimer > 0 then
				mode.presents.newMapTimer = mode.presents.newMapTimer - .5
				
				mapName = "<PS>" .. string.format(system.getTranslation("newGame"),math.floor(mode.presents.newMapTimer) .. "<PS>")
				if mode.presents.newMapTimer <= 0 then
					mode.presents.generateMap()
				end
			end
		end
		ui.setMapName(mapName .. "<")
	end,
	-- Commands
	eventChatCommand = function(n,c)
		local p = string.split(c,"[^%s]+",string.lower)
		if p[1] == "p" then
			p[2] = p[2] and string.nick(p[2]) or n
			if mode.presents.info[p[2]] then
				ui.addTextArea(1,"<p align='center'><font size='18'><a:active><a href='event:close'>"..p[2].."</a><p align='left'><font size='13'>\n<J>" .. string.format(system.getTranslation("profile"),mode.presents.info[p[2]].rounds,mode.presents.info[p[2]].gifts,mode.presents.info[p[2]].victories),n,5,30,790,100,1,1,.8,true)
			end
		end
	end,
	-- Callbacks
	eventTextAreaCallback = function(i,n,c)
		if c == "close" then
			ui.removeTextArea(1,n)
		end
	end,
}

--[[ Chat ]]--
mode.chat = {
	-- Translations
	translations = {
		en = {
			-- Init
			welcome = "<J>Welcome to #chat. Enjoy while you are muted ?! Report any issue to Bolodefchoco.",
		
			-- Info
			loadmap = "loaded by",
			enabled = "enabled",
			disabled = "disabled",
			
			-- Cats
			shaman = "shaman",
			newGame = "Auto New Game",
			
			-- Misc
			title = "%s has just unlocked the «%s» title.\n<ROSE>Type /title to choose a title",
		},
		br = {
			welcome = "<J>Bem-vindo ao #chat. Aproveite enquanto você está mutado ?! Reporte qualquer problema para Bolodefchoco.",
		
			loadmap = "carregado por",
			enabled = "ativado",
			disabled = "desativado",
			
			shaman = "shaman",
			newGame = "Novo Jogo Automático",
			
			title = "%s Desbloqueou o título «%s»\n<ROSE>Digite /title para escolher um título.",
		},
		ar = {
			welcome = "<J>مرحبًا بك في #chat. استمتع بينما أنت مكتوم ?! بلغ عن أي مشكلة إلى Bolodefchoco.",
		
			loadmap = "شُغل بواسطة",
			enabled = "فُعل",
			disabled = "أُلغي",
			
			shaman = "الشامان",
			newGame = "جولة جديدة تلقائية",
			
			title = "%s has just unlocked the «%s» title.\n<ROSE>Type /title to choose a title",
		},
	},
	langue = "en",
	-- Data
	info = {},
	data = {},
	displayData = {},
	messageId = 0,
	-- New Game Settings
	hasShaman = false,
	autoNeWGame = false,
	-- Chat settings
	chatTitle = "Chat",
	-- Chat
	chat = function(n,message,update)
		if not update then
			ui.addPopup(0,2,"",n,107,325,565,true)
		end
		ui.addTextArea(0,"",n,108,73,564,253,0x212E35,0x212E35,1,true)
		ui.addTextArea(1,message,n,110,75,560,250,0x324650,0x324650,1,true)
		ui.addTextArea(2,"<p align='center'><B><V>" .. mode.chat.chatTitle,n,108,53,564,20,0x212E35,0x212E35,1,true)
		ui.addTextArea(3,"<p align='right'><B><R><a href='event:close'>X",n,110,54,560,20,1,1,0,true)
	end,
	getTextLength = function(line)
		return string.len(string.gsub(line,"<.*>",""))
	end,
	loadData = function()
		local message = "<font size='7'>\n</font>"
		for i = 18,1,-1 do
			if #message < 1900 then
				local line = mode.chat.displayData[i] or ""
				message = message .. line
			end
		end
		return message
	end,
	updateToRead = function(n)
		ui.addTextArea(4,"<p align='center'><V><a href='event:open'><B>" .. string.sub(string.lower(mode.chat.chatTitle),1,8) .. "</B> <J>" .. mode.chat.info[n].toRead,n,712,378,80,nil,0x324650,0x212E35,1,true)
	end,
	displayChat = function(n,update)
		local loadedM = mode.chat.loadData()
		if not update then
			mode.chat.chat(n,loadedM)
		else
			for k,v in next,mode.chat.info do
				if v.open then
					mode.chat.chat(k,loadedM,k ~= n)
				else
					v.toRead = v.toRead + 1
					mode.chat.updateToRead(k)
				end
			end
		end
	end,
	newMessage = function(message,n)
		mode.chat.messageId = mode.chat.messageId + 1
		table.insert(mode.chat.data,{mode.chat.messageId,n,string.gsub(string.gsub(message,"@%((.*)%)",function(text) return text end),"{.-:(.-)}",function(text) return text end)})
	
		if mode.chat.getTextLength(message) > 50 then
			message = string.sub(message,1,47) .. "..."
		end
		message = string.gsub(message,"<","&lt;") -- < to <
		message = string.gsub(message,"https?","") -- https to ""
		message = string.gsub(message,"://","") -- :// to ""
		message = string.gsub(message,"@%((.*)%)",function(text) -- @(link:text)
			return string.format("<a href='event:display.%s'>%s</a>",mode.chat.messageId,text)
		end)
		
		if #message > 0 then
			if string.sub(message,1,1) == "/" then
				mode.chat.eventChatCommand(n,string.sub(message,2))
			else
				message = string.gsub(message,"{(.-):(.-)}",function(color,text) -- {colorTag:Text}
					color = string.upper(color)
					if table.find({"BV","R","BL","J","N","N2","PT","CE","CEP","CS","S","PS","G","V","VP","VI","ROSE","CH","T"},color) then
						return string.format("<%s>%s</%s>",color,text,color)
					else
						return text
					end
				end)
				table.insert(mode.chat.displayData,1,string.format("<V>[%s] <N>%s\n",n,message))
			end
		end
	end,
	-- Init
	init = function()
		mode.chat.translations.pt = mode.chat.translations.br
		mode.chat.langue = mode.chat.translations[tfm.get.room.community] and tfm.get.room.community or "en"
		tfm.exec.setRoomMaxPlayers(30)
		system.disableChatCommandDisplay("title",true)
		mode.chat.displayChat()
	end,
	-- New Player
	eventNewPlayer = function(n)
		mode.chat.info[n] = {
			open = true,
			toRead = 0,
		}
		mode.chat.displayChat(n)
		tfm.exec.chatMessage(system.getTranslation("welcome"),n)
	end,
	-- Answer bar
	eventPopupAnswer = function(i,n,a)
		if #string.gsub(a," ","") > 0 then
			mode.chat.newMessage(a,n)
			mode.chat.displayChat(n,true)
		else
			mode.chat.displayChat(n)
		end
	end,
	-- Callbacks
	eventTextAreaCallback = function(i,n,c)
		local p = string.split(c,"[^%.]+")
		if p[1] == "close" then
			ui.addPopup(0,2,"",n,1e7,1e7)
			for i = 0,3 do
				ui.removeTextArea(i,n)
			end
			mode.chat.info[n].open = false
			mode.chat.updateToRead(n)
		elseif p[1] == "open" then
			mode.chat.info[n].open = true
			mode.chat.info[n].toRead = 0
			mode.chat.displayChat(n)
			ui.removeTextArea(4,n)
		elseif p[1] == "display" then
			local msg = mode.chat.data[tonumber(p[2])]		
			tfm.exec.chatMessage(string.format("<N>> <V>[%s] <N>%s",msg[2],msg[3]),n)
		end
	end,
	-- Commands
	eventChatCommand = function(n,c)
		local p = string.split(c,"[^%s]+",string.lower)
		if p[1] == "title" and p[2] and system.roomAdmins[n] then
			mode.chat.chatTitle = string.sub(table.concat(p," ",nil,2),1,40)
			mode.chat.displayChat()
		elseif p[1] == "np" and p[2] then
			tfm.exec.chatMessage(string.format("<S>%s %s %s",string.sub(p[2],1,1) == "@" and p[2] or "@" .. p[2],system.getTranslation("loadmap"),n))
			tfm.exec.newGame(p[2])
		elseif p[1] == "sha" then
			mode.chat.hasShaman = not mode.chat.hasShaman
			
			tfm.exec.chatMessage("<S>• " .. system.getTranslation("shaman") .. " " .. system.getTranslation((mode.chat.hasShaman and "disabled" or "enabled")),n)
			tfm.exec.disableAutoShaman(mode.chat.hasShaman)
		elseif p[1] == "new" then
			mode.chat.autoNeWGame = not mode.chat.autoNeWGame
		
			tfm.exec.chatMessage("<S>• " .. system.getTranslation("newGame") .. " " .. system.getTranslation((mode.chat.autoNeWGame and "disabled" or "enabled")),n)
			tfm.exec.disableAutoNewGame(mode.chat.autoNeWGame)
			tfm.exec.disableAutoTimeLeft(mode.chat.autoNeWGame)
		elseif p[1] == "adm" and system.roomAdmins[n] then
			system.roomAdmins[string.nick(p[2])] = true
		elseif string.sub(c,1,6) == "unlock" then
			tfm.exec.chatMessage("<J>" .. string.format(system.getTranslation("title"),n,string.sub(c,8)),n)
		end
	end,	
}

--[[ Cannonup ]]--
mode.cannonup = {
	-- Translations
	translations = {
		en = {
			-- Init
			welcome = "Welcome to #cannonup. Your aim is to be the survivor! <VP>Take care, watermelons are dangerous!\n\t<J>Report any issue to Bolodefchoco.",

			-- Info
			nowinner = "No one won!",
			
			-- Simple words
			won = "won!",
			
			-- Profile
			profile = "Rounds : <V>%d</V>\nCheeses : <V>%d</V>\n\nDeaths : <V>%d</V>",
		},
		br = {
			welcome = "Bem-vindo ao #cannonup. Seu objetivo é ser o sobrevivente! <VP>Tome cuidado, melancias são perigosas!\n\t<J>Reporte qualquer problema para Bolodefchoco.",
		
			nowinner = "Ninguém ganhou!",
		
			won = "venceu!",
			
			profile = "Rodadas : <V>%d</V>\nQueijos : <V>%d</V>\n\nMortes : <V>%d</V>",
		},
	},
	langue = "en",
	-- Data
	info = {},
	-- Maps
	maps = {3746497,6001536,3666224,4591929,"#10","#10","#10","#10","#10","#10","#10","#10","#10"},
	-- Settings
	isRunning = false,
	totalPlayers = 0,
	-- New Map Settings
	cannon = {
		x = 0,
		y = 0,
		time = 3,
		amount = 1,
		speed = 20,
	},
	canMessage = false,
	currentXml = -1,
	toDespawn = {},
	alivePlayers = {},
	-- Cannon ID
	getCannon = function()
		-- 1705 maçã
		-- 1706 melancia
		local currentMonth = tonumber(os.date("%m"))
		
		if currentMonth == 12 then
			return 1703 -- Christmas [Ornament]
		elseif currentMonth == 10 then
			return table.random({17,1701,1702}) -- Halloween [Normal, Glass, Lollipop]
		elseif currentMonth == 5 and tonumber(os.date("%d")) < 11 then
			return 1704 -- Transformice's Birthday [Shaman]
		elseif currentMonth == 7 then
			return table.random({17,1705,1706}) -- Vacations [Normal, Apple, Watermellon]
		else
			return table.random({17,17,17,1706}) -- Standard
		end
	end,
	-- Spawn Cannon
	newCannon = function()
		local alive = system.players(true)
		if #alive > 0 then
			local player
			repeat
				player = tfm.get.room.playerList[table.random(alive)]
			until not player.isDead
			
			local coordinates = {
				{player.x,math.random() * 700},
				{player.y,math.random() * 300},
				{false,false}
			}
			
			if mode.cannonup.cannon.x ~= 0 then
				coordinates[1][2] = mode.cannonup.cannon.x
				coordinates[3][1] = true
			end
			if mode.cannonup.cannon.y ~= 0 then
				coordinates[2][2] = mode.cannonup.cannon.y
				coordinates[3][2] = true
			end
			
			if not coordinates[3][2] and coordinates[2][2] > coordinates[2][1] then
				coordinates[2][2] = coordinates[2][1] - math.random(100) - 35
			end
			if not coordinates[3][1] and math.abs(coordinates[1][2] - coordinates[1][1]) > 350 then
				coordinates[1][2] = coordinates[1][1] + math.random(-100,100)
			end
			
			local ang = math.deg(math.atan2(coordinates[2][2] - coordinates[2][1],coordinates[1][2] - coordinates[1][1]))
			tfm.exec.addShamanObject(0,coordinates[1][2] - (coordinates[3][1] and 0 or 10),coordinates[2][2] - (coordinates[3][2] and 0 or 10),ang + 90)
			
			--system.newTimer(function()
				mode.cannonup.toDespawn[#mode.cannonup.toDespawn + 1] = {tfm.exec.addShamanObject(mode.cannonup.getCannon(),coordinates[1][2],coordinates[2][2],ang - 90,mode.cannonup.cannon.speed),os.time() + 5000}
			--end,math.isNegative((mode.cannonup.cannon.speed - 1) * 500,0),false)
		end
	end,
	-- Profile
	uiprofile = function(p,n)
		ui.addTextArea(1,"\n\n<font size='13'>\n" .. string.format(system.getTranslation("profile"),mode.cannonup.info[p].round,mode.cannonup.info[p].victory,mode.cannonup.info[p].death),n,300,100,200,150,0x0B282E,0x1B282E,1,true)
		ui.addTextArea(2,"<p align='center'><font size='20'><VP><B><a href='event:close'>"..p.."</a>",n,305,105,190,30,0x244452,0x1B282E,.4,true)
	end,
	-- Update data
	updatePlayers = function()
		local alive,total = system.players()
		mode.cannonup.alivePlayers = system.players(true)
		mode.cannonup.totalPlayers = total
	end,
	-- Init
	init = function(map)
		if not map then
			mode.cannonup.translations.pt = mode.cannonup.translations.br

			-- Sets the main language according to the community
			if mode.cannonup.translations[tfm.get.room.community] then
				mode.cannonup.langue = tfm.get.room.community
			end
			
			-- Init
			for _,f in next,{"AutoShaman","AutoScore","AutoNewGame","AutoTimeLeft","PhysicalConsumables"} do
				tfm.exec["disable"..f]()
			end
			tfm.exec.setRoomMaxPlayers(25)
		end
		tfm.exec.newGame('<C><P /><Z><S><S L="800" o="324650" H="100" X="400" Y="400" T="12" P="0,0,0.3,0.2,0,0,0,0" /></S><D /><O /></Z></C>')
	end,
	-- New Player
	eventNewPlayer = function(n)
		if not mode.cannonup.info[n] then
			mode.cannonup.info[n] = {
				round = 0,
				victory = 0,
				death = 0
			}
		end
		
		tfm.exec.chatMessage("<J>" .. system.getTranslation("welcome"),n)
	end,
	-- New Game
	eventNewGame = function()
		ui.setMapName("#CannonUp")
		
		mode.cannonup.cannon = {
			x = 0,
			y = 0,
			time = 3,
			amount = ((mode.cannonup.totalPlayers - (mode.cannonup.totalPlayers % 10)) / 10) + math.min(5,math.max(1,system.miscAttrib+1)),
			speed = 20,
		}

		mode.cannonup.toDespawn = {}
		
		if mode.cannonup.currentXml == -1 then
			mode.cannonup.currentXml = 0
		elseif mode.cannonup.currentXml == -2 then
			mode.cannonup.currentXml = -1
		end
		
		ui.removeTextArea(0,nil)
		if mode.cannonup.isRunning then
			if mode.cannonup.currentXml == 0 then
				tfm.exec.setGameTime(5)
				
				mode.cannonup.currentXml = xml.addAttrib(tfm.get.room.xmlMapInfo.xml or "",{
					[1] = {
						tag = "BH",
						value = "",
					}
				},false)
				ui.addTextArea(0,"",nil,-1500,-1500,3e3,3e3,0x6A7495,0x6A7495,1,true)
				
				mode.cannonup.canMessage = false
			else
				tfm.exec.setGameTime(125)
				mode.cannonup.canMessage = true
				
				if mode.cannonup.totalPlayers > 3 then
					for k,v in next,mode.cannonup.info do
						v.round = v.round + 1
					end
				end
				
				xml.attribFunc(mode.cannonup.currentXml or "",{
					[1] = {
						attribute = "cn",
						func = function(value)
							local coord,axY = xml.getCoordinates(value)
							if type(coord) == "table" then
								mode.cannonup.cannon.x = coord[1].x
								mode.cannonup.cannon.y = coord[1].y
							else
								if axY == 0 then
									mode.cannonup.cannon.x = coord
								else
									mode.cannonup.cannon.y = coord
								end
							end
						end
					},
					[2] = {
						attribute = "cheese",
						func = function()
							table.foreach(tfm.get.room.playerList,tfm.exec.giveCheese)
						end,
					},
					[3] = {
						attribute = "meep",
						func = function()
							table.foreach(tfm.get.room.playerList,tfm.exec.giveMeep)
						end,
					},
				})
			
				mode.cannonup.currentXml = 0
				mode.cannonup.canMessage = true
			end
		else
			tfm.exec.setGameTime(1e7)
			mode.cannonup.currentXml = -1
			mode.cannonup.canMessage = false
		end
	end,
	-- Loop
	eventLoop = function()
		mode.cannonup.updatePlayers()

		if mode.cannonup.isRunning then
			if mode.cannonup.totalPlayers < 2 then
				mode.cannonup.isRunning = false
				mode.cannonup.canMessage = false
				mode.cannonup.currentXml = -2
			else
				if mode.cannonup.currentXml == -1 then
					tfm.exec.newGame(table.random(mode.cannonup.maps))
				elseif mode.cannonup.currentXml ~= 0 then
					tfm.exec.newGame(mode.cannonup.currentXml)
				else		
					if _G.leftTime < 4 or #mode.cannonup.alivePlayers < 2 then
						if mode.cannonup.canMessage and mode.cannonup.totalPlayers > 1  then
							mode.cannonup.canMessage = false
							if #mode.cannonup.alivePlayers > 0 then
								for k,v in next,mode.cannonup.alivePlayers do
									tfm.exec.giveCheese(v)
									tfm.exec.playerVictory(v)
									if mode.cannonup.totalPlayers > 3 then
										mode.cannonup.info[v].victory = mode.cannonup.info[v].victory + 1
									end
									tfm.exec.setPlayerScore(v,5,true)
								end
								
								tfm.exec.chatMessage("<J>" .. table.concat(mode.cannonup.alivePlayers,"<G>, <J>") .. " <J>" .. system.getTranslation("won"))
							else
								tfm.exec.chatMessage("<J>" .. system.getTranslation("nowinner"))
							end
						end
						tfm.exec.newGame(table.random(mode.cannonup.maps))
					else
						if _G.currentTime > 5 and mode.cannonup.currentXml == 0 then
							if _G.currentTime % mode.cannonup.cannon.time == 0 then
								for i = 1,mode.cannonup.cannon.amount do
									mode.cannonup.newCannon()
								end
							end
							
							if #mode.cannonup.toDespawn > 0 then
								for i = 1,#mode.cannonup.toDespawn do
									if os.time() > mode.cannonup.toDespawn[i][2] then
										tfm.exec.removeObject(mode.cannonup.toDespawn[i][1])
									end
								end
							end
							
							if _G.currentTime % 20 == 0 then
								mode.cannonup.cannon.amount = ((mode.cannonup.totalPlayers - (mode.cannonup.totalPlayers % 10)) / 10) + math.min(5,math.max(1,system.miscAttrib+1))
								mode.cannonup.cannon.speed = mode.cannonup.cannon.speed + 20
								mode.cannonup.cannon.time = math.max(.5,mode.cannonup.cannon.time-.5)
							end
						end
					end
				end
			end
		else
			if mode.cannonup.currentXml == -2 then
				tfm.exec.newGame('<C><P /><Z><S><S L="800" o="324650" H="100" X="400" Y="400" T="12" P="0,0,0.3,0.2,0,0,0,0" /></S><D /><O /></Z></C>')
			end
		
			if mode.cannonup.totalPlayers > 1 then
				mode.cannonup.isRunning = true
			end
		end
	end,
	-- Commands
	eventChatCommand = function(n,c)
		local p = string.split(c,"[^%s]+",string.lower)
		if p[1] == "p" or p[1] == "profile" then
			if p[2] then
				p[2] = string.nick(p[2])
				if tfm.get.room.playerList[p[2]] then
					mode.cannonup.uiprofile(p[2],n)
				end
			else
				mode.cannonup.uiprofile(n,n)
			end
		end
	end,
	-- Callbacks
	eventTextAreaCallback = function(i,n,c)
		if c == "close" then
			for i = 1,2 do
				ui.removeTextArea(i,n)
			end
		end
	end,
	-- Player Left
	eventPlayerLeft = function()
		mode.cannonup.updatePlayers()
	end,
	-- Player Died
	eventPlayerDied = function(n)
		mode.cannonup.info[n].death = mode.cannonup.info[n].death + 1
	end,
}

--[[ Xmas ]]--
mode.xmas = {
	-- Translations
	translations = {
		en = {"Merry Christmas & Happy New Year!","Christmas is approaching and S4nt4 has a lot to do on his <I>paws</I>. He wants to give all the gifts on time, but he must be fast! Since our dear S4nt4 is clumsy, some gifts will fall and you will have to <CE>collect</CE> them by pressing the <I>space bar</I>! Give the gifts back to S4nt4 when he feels <CE>dizzy</CE> by pressing the <I>space bar</I>!"},
		fr = {"Joyeux Noël et Bonne Année!","Noël approche et S4nt4 en a plein les <I>pattes</I>. Il veut donner tous les cadeaux à temps, mais il doit être rapide ! Puisque notre cher S4nt4 est maladroix, certains cadeaux tombent et vous devrez les, <CE>collecter</CE> en appuyant sur la <I>barre d'espace</I>! Donnez les cadeaux à S4nt4 quand il se sent <CE>étourdi</CE> en appuyant sur la <I>barre d'espace</I>!"},
		br = {"Feliz Natal & Feliz Ano Novo!","O Natal está chegando e S4nt4 tem em suas <I>patas</I> muito o que fazer. Ele quer entregar todos os presentes a tempo, mas ele deve ser rápido! Uma vez que nosso querido S4NT4 é desajeitado, alguns presentes cairão e você terá que <CE>coletá-los</CE> pressionando a <I>barra de espaço</I>! Devolva os presentes ao S4nt4, pressionando a <I>barra de espaço</I>, quando ele se sentir <CE>tonto</CE>!"},
		es = {"¡Feliz Navidad y Próspero Año Nuevo!","La Navidad se está acercando y S4nt4 tiene muchas cosas que hacer con sus <I>patas</I>. Él quiere dar todos los regalos a tiempo, pero debe ser rápido! Puesto que nuestro querido S4nt4 es torpe, algunos regalos caerán y tendrás que <CE>recogerlos</CE> pulsando la <I>barra espaciadora</I>! Regrese los regalos a S4nt4 cuando se sienta <CE>mareado</CE> presionando la <I>barra de espacio</I>!"},
		tr = {"Mutlu Noeller & Mutlu Yıllar!","Noel geliyor ve S4nt4'nın <I>patilerinde</I> yapacağı çok işi var. Bütün hediyeleri zamanında vermek istiyor ama hızlı olması gerek! Sevgili S4nt4'mız sakar olduğu için, bazı hediyeler düşecek ve <I>boşluk tuşuna</I> basarak onları <CE>toplamanız</CE> gerekecek! S4nt4'nın <CE>başı döndüğünde</CE> <I>boşluk tuşuna</I> basarak hediyeleri ona geri verin!"},
		pl = {"Wesołych Świąt i Wesołego Nowego Roku!","Święta nadchodzą, a S4nt4 ma <I>łapki</I> pełne roboty. On chce dać wszystkim prezenty na czas, ale musi się pośpieszyć! Od kiedy nasz S4nt4 jest niezdarny, gubi prezenty, które musicie <CE>pozbierać</CE> wciskając <I>spację</I>! Oddajcie prezenty S4nt4 kiedy jest <CE>oszołomiony</CE> wciskając <I>spację</I>!"},
		ar = {"عيد ميلاد مجيدا و كل عام و أنتم بخير","عيد الميلاد اقترب و<I> يدى </I> سانتا مليئة. يريد سانتا تسليم جميع الهدايا على الوقت, ولكن يجب ان يكون سريعا! ولكن صديقنا العزيز سانتا غير بارع في تسليم الهدايا, بعض الهدايا ستسقط وعليك ان تقوم <CE> بجمع</CE>  الهدايا التي سقطت عن طريق الضغط على المسطرة ! وارجاع الهدايا الى صديقنا العزيز سانتا عندما يشعر <CE> بالدوار</CE> عن طريق الضغط على زر المسطرة!"},
		hu = {"Boldog Karácsonyt & Boldog Új Évet!","A Karácsony közeleg, és a Mikulásra pedig <I>rengeteg munka vár<I>. Oda akarja adni az összes ajándékot időben, de muszáj gyorsnak lennie! Mivel a mi Mikulásunk kétbalkezes, néhány ajándék lepottyan és Neked kell <CE>összegyűjteni</CE> azokat, a <I>Szóköz</I> megnyomásával! Vidd vissza a Mikulásnak az ajándékot a <I>Szóköz</I> megnyomásával, amikor Mikulás <CE>megszédül</CE>!"},
		ru = {"С новым годом и Рождеством!","Рождество приближается и S4nt4 направляется к вам! Он очень спешит, чтобы раздать все подарки вовремя! Но так как наш дорогой S4nt4 неуклюж, то некоторые подарки будут падать. Вы должны <CE>собрать</CE> их, нажимая клавишу <I>пробел</I>! Помогите S4nta. <CE>Верните</CE> ему подарки обратно с помощью <I>пробела</I>!"},
	},
	langue = "en",
	-- Data
	info = {},
	gifts = {
		[1] = {
			[1] = "158bb1db61b",
			[2] = 20000,
		};
		[2] = {
			[1] = "158bb1c95e0",
			[2] = 15000,
		};
		[3] = {
			[1] = "158bb1cc6ec",
			[2] = 10000,
		};
		[4] = {
			[1] = "158bb1ce1aa",
			[2] = 8000,
		};
		[5] = {
			[1] = "1591c9b3123",
			[2] = 6000,
		};
	},
	-- Maps
	xml = '<C><P DS="y;310" /><Z><S><S H="10" L="50" X="275" c="2" Y="165" T="12" P="0,0,0.3,0.2,0,0,0,0" /><S L="200" X="100" H="80" Y="360" T="12" P="0,0,0.3,0.2,0,0,0,0" /><S L="200" X="109" H="80" Y="379" T="12" P="0,0,0.3,0.2,-10,0,0,0" /><S X="391" L="230" H="80" c="3" Y="354" T="12" P="0,0,0.3,0.2,-2,0,0,0" /><S H="100" L="230" X="430" c="3" Y="411" T="12" P="0,0,0.3,0.2,-30,0,0,0" /><S H="80" L="180" X="705" c="3" Y="397" T="12" P="0,0,0.3,0.2,-2,0,0,0" /><S P="0,0,0.3,0.2,0,0,0,0" L="44" H="10" c="3" Y="361" T="13" X="237" /><S X="-5" L="10" H="3000" c="3" Y="100" T="12" P="0,0,0,0,0,0,0,0" /><S H="3000" L="10" X="805" c="3" Y="101" T="12" P="0,0,0,0,0,0,0,0" /><S L="10" X="400" H="3000" Y="-5" T="12" P="0,0,0,0,90,0,0,0" /><S L="80" H="10" X="96" Y="158" T="12" P="0,0,0.3,0.2,0,0,0,0" /><S P="0,0,0.3,.9,0,0,0,0" L="50" X="275" c="3" Y="165" T="12" H="10" /><S L="130" X="527" H="10" Y="128" T="12" P="0,0,0.3,0.2,10,0,0,0" /><S L="90" H="10" X="632" Y="131" T="12" P="0,0,0.3,0.2,-10,0,0,0" /><S H="3000" L="10" o="23E9E9" X="805" c="2" Y="100" T="12" m="" P="0,0,0,2,0,0,0,0" /><S X="-5" L="10" o="23E9E9" H="3000" c="2" Y="100" T="12" m="" P="0,0,0,2,0,0,0,0" /><S P="0,0,0.3,0.2,-35,0,0,0" L="230" X="549" c="3" Y="467" T="12" H="100" /><S P="0,0,0.3,0.2,-55,0,0,0" L="230" H="100" c="3" Y="441" T="12" X="250" /><S L="230" X="125" H="100" Y="422" T="12" P="0,0,0.3,0.2,-30,0,0,0" /><S X="510" L="230" H="100" c="3" Y="477" T="12" P="0,0,0.3,0.2,-65,0,0,0" /><S L="50" X="91" H="50" Y="339" T="12" P="0,0,0.3,0.2,-45,0,0,0" /><S P="0,0,0.3,0.2,0,0,0,0" L="30" X="164" c="2" Y="325" T="12" H="50" /><S P="0,0,0.3,1.1,0,0,0,0" L="30" H="50" c="3" Y="325" T="12" X="164" /><S L="50" X="240" H="10" Y="158" T="12" P="0,0,0.3,0.2,0,0,0,0" /><S L="50" H="10" X="443" Y="125" T="12" P="0,0,0.3,0.2,-20,0,0,0" /><S H="80" L="220" o="23E9E9" X="393" c="1" Y="359" T="12" m="" P="0,0,0.3,0.2,-2,0,0,0" /><S L="230" o="23E9E9" X="427" H="100" Y="416" T="12" m="" P="0,0,0.3,0.2,-30,0,0,0" /><S P="0,0,0.3,0.2,-65,0,0,0" L="230" o="23E9E9" H="100" Y="481" T="12" m="" X="501" /><S P="0,0,0.3,0.2,-35,0,0,0" L="230" o="23E9E9" H="100" Y="474" T="12" m="" X="550" /><S P="0,0,0.3,0.2,-2,0,0,0" L="180" o="23E9E9" X="706" Y="404" T="12" m="" H="80" /><S P="0,0,0.3,0.2,1,0,0,0" L="230" o="23E9E9" X="314" c="2" Y="373" T="12" m="" H="100" /></S><D><P X="241" Y="507" T="51" P="0,1" /><P X="566" Y="449" T="46" P="0,0" /></D><O /></Z></C>',
	initx = 240,
	inity = 140,
	-- New Game Settings
	aim = 8,
	start = true,
	amountPlayers = 20,
	despawnObjects = {},
	currentGifts = {},
	currentTime = 0,
	leftTime = 150,
	-- Player Settings
	setPlayerTools = function(k)
		mode.xmas.info[k] = {
			db = {
				eventNoelGifts = {0,0},
			},
			catch = 0,
			lastColor = 0xB73535,
		}
		if not tfm.get.room.playerList[k].isDead then
			system.bindKeyboard(k,32,true,true)
		end
		mode.xmas.updateBar(k)
	end,
	-- Noel's AI
	noel = {
		x = 240,
		y = 140,
		id = -1,
		isEscaping = false,
		isDizzy = {0,false},
		timers = {
			teleport = 0,
			prize = 0
		},
		img = {
			dizzy = {"158bb1dccb6","158bb1cf9a8","158bb1d6489","158bb1e2518"},
			right = "158bb1d8069",
			left = "158bb1e0daf",
			jumping = "158bb1d470a",
			stop = "158bb1d9b67",
		},
		updateImage = function(img)
			tfm.exec.removeImage(mode.xmas.noel.imgId)
			mode.xmas.noel.imgId = tfm.exec.addImage(img..".png","#"..mode.xmas.noel.id,-23,-32)
		end,
		particles = function(id)
			for i = 1,5 do
				tfm.exec.displayParticle(id,mode.xmas.noel.x + math.random(-50,50),mode.xmas.noel.y + math.random(-50,50),table.random({-.2,.2}),table.random({-.2,.2}))
			end
		end,
		move = function(x,y)
			tfm.exec.moveObject(mode.xmas.noel.id,0,0,false,x,y,false)
		end,
		nearMouse = function(range)
			local player = {"",{dist=math.random(800),x=0,y=0}}
			for k,v in next,tfm.get.room.playerList do
				if not v.isDead then
					if math.pythag(v.x,v.y,mode.xmas.noel.x,mode.xmas.noel.y,range) then
						local m = v.x-mode.xmas.noel.x
						if math.abs(m) < player[2].dist then
							player = {k,{dist=m,x=v.x,y=v.y}}
						end
					end
				end
			end
			mode.xmas.noel.isEscaping = player[1] ~= ""
			return player
		end,
		escape = function(id)
			local player = mode.xmas.noel.nearMouse(math.random(80,100))
			local mul = (player[1] ~= "" and math.isNegative(player[2].dist,1,-1) or table.random({-1,1}))
			local img = math.isNegative(mul,"left","right")
			local rand = 9 - math.random(0,9)
			if id == 0 or (rand < 6) then
				mode.xmas.noel.move(mul * math.random(50,80),-math.random(1,10))
				mode.xmas.noel.updateImage(mode.xmas.noel.img[img])
			elseif id == 1 or (rand < 9) then
				mode.xmas.noel.move(mul * math.random(60,70),-80)
				mode.xmas.noel.updateImage(table.random({mode.xmas.noel.img[img],mode.xmas.noel.img.jumping}))
			elseif id == 2 or rand == 9 then
				mode.xmas.noel.move(mul * math.random(10,20),-math.random(70,100))
				mode.xmas.noel.updateImage(mode.xmas.noel.img.jumping)
			end
		end,
		meep = function()
			tfm.exec.displayParticle(20,mode.xmas.noel.x,mode.xmas.noel.y)
			tfm.exec.explosion(mode.xmas.noel.x,mode.xmas.noel.y,20,50)
		end,
		cannon = function()
			local player = mode.xmas.noel.nearMouse(100)
			if player[1] ~= "" then
				local x = mode.xmas.noel.x + (mode.xmas.noel.x > player[2].x and -40 or 40)
				local y = mode.xmas.noel.y + (mode.xmas.noel.y > player[2].y and -40 or 40)
				local angle = math.deg(math.atan2(player[2].y-mode.xmas.noel.y,player[2].x-mode.xmas.noel.x)) + 90
				table.insert(mode.xmas.despawnObjects,{
					[1] = tfm.exec.addShamanObject(1703,x,y,angle),
					[2] = os.time() + 2500
				})
				local effect = function(id,sx,sy,xs,ys,e)
					for i = 1,2 do
						tfm.exec.displayParticle(id[i] and id[i] or id[1],x + sx * e,y - sy * e,xs/1.5,ys/1.5)
					end
				end
				for i = 1,20 do
					effect({9,11},math.cos(i),math.sin(i),math.cos(i),-math.sin(i),22)
					effect({13},math.cos(i),math.sin(i),math.sin(i),math.cos(i),19)
				end
			end
		end,
		teleport = function()
			if os.time() > mode.xmas.noel.timers.teleport then
				mode.xmas.noel.timers.teleport = os.time() + 8000
				tfm.exec.displayParticle(37,mode.xmas.noel.x,mode.xmas.noel.y)
				local x,y = math.random(20,780),math.random(50,300)
				tfm.exec.moveObject(mode.xmas.noel.id,x,y)
				tfm.exec.displayParticle(37,x,y)
			else
				mode.xmas.noel.escape(2)
			end
		end,
		gift = function()
			if os.time() > mode.xmas.noel.timers.prize then
				mode.xmas.noel.timers.prize = os.time() + 5000
				mode.xmas.noel.updateImage(mode.xmas.noel.img.stop)
				local giftsAmount = mode.xmas.amountPlayers < 10 and 1 or math.floor(mode.xmas.amountPlayers/10)
				for i = 1,giftsAmount do
					local gift = table.random({2,4,3,1,1,2,3,5,2,4})
					for k,v in next,mode.xmas.gifts do
						if gift == k then
							gift = k
							break
						end
					end
					local gen = {}
					gen[1] = tfm.exec.addShamanObject(6300,mode.xmas.noel.x,mode.xmas.noel.y,0,table.random({-13,-10,-5,5,10,13}))
					gen[2] = os.time() + mode.xmas.gifts[gift][2]
					gen[3] = tfm.exec.addImage(mode.xmas.gifts[gift][1]..".png","#"..gen[1],-15,-15)
					gen[4] = gift
					table.insert(mode.xmas.currentGifts,gen)
				end
			else
				mode.xmas.noel.escape(0)
			end
		end,
		dizzy = function(timer)
			if os.time() > mode.xmas.noel.timers.prize then
				mode.xmas.noel.isDizzy[1] = os.time() + 9500
			else
				mode.xmas.noel.escape(2)
			end
		end,
	},
	resetNoel = function()
		mode.xmas.initx = 240
		mode.xmas.inity = 140
		mode.xmas.noel.x = mode.xmas.initx
		mode.xmas.noel.y = mode.xmas.inity
		mode.xmas.noel.id = -1
		mode.xmas.noel.isEscaping = false
		mode.xmas.noel.isDizzy = {0,false}
		mode.xmas.noel.timers = {
			teleport = 0,
			prize = 0
		}
	end,
	-- Bar
	displayBar = function(id,player,value,nvalue,color,sig,size,height)
		sig = sig or ""
		size = size or 100
		height = height or 20

		ui.addTextArea(id,"",player,5,(height+8) * id,size + 4,height,0xC7CED2,1,1,true)
		if value ~= 0 then
			ui.addTextArea(id.."0","",player,6,(height+8) * id + 2,nvalue + 2,height - 4,color,color,1,true)
		end
		ui.addTextArea(id + 2,"<B><font color='#0'>"..value..sig,player,(size-30)/2,(height+8) * id + 1,50,height,1,1,0,true)
	end,
	updateBar = function(n,giftColor)
		giftColor = giftColor or mode.xmas.info[n].lastColor
		mode.xmas.displayBar(1,n,math.floor(mode.xmas.info[n].db.eventNoelGifts[2]) .. " / "..mode.xmas.aim,(mode.xmas.info[n].db.eventNoelGifts[2] > mode.xmas.aim and 100 or math.percent(mode.xmas.info[n].db.eventNoelGifts[2],mode.xmas.aim,100)),0xFF0000)
		mode.xmas.displayBar(2,n,mode.xmas.info[n].db.eventNoelGifts[1],(mode.xmas.info[n].db.eventNoelGifts[1] > 50 and 50 or math.percent(mode.xmas.info[n].db.eventNoelGifts[1],50,50)),giftColor,"G",50,20)
	end,
	-- Init
	init = function()
		mode.xmas.translations.pt = mode.xmas.translations.br
		mode.xmas.langue = mode.xmas.translations[tfm.get.room.community] and tfm.get.room.community or "en"
		for i,f in next,{"AutoShaman","AfkDeath","MortCommand","AutoTimeLeft","PhysicalConsumables","AutoNewGame","DebugCommand"} do
			tfm.exec["disable"..f]()
		end
		tfm.exec.setRoomMaxPlayers(25)
		tfm.exec.newGame(mode.xmas.xml)
		mode.xmas.aim = system.miscAttrib > 0 and system.miscAttrib or 8
	end,
	-- New Game
	eventNewGame = function()
		mode.xmas.resetNoel()

		mode.xmas.start = true
		
		local _,aP = system.players()
		mode.xmas.amountPlayers = aP
		
		tfm.exec.setGameTime(150)
		tfm.exec.snow(150)
		mode.xmas.currentTime = 0
		mode.xmas.leftTime = 150
		
		tfm.exec.addImage("158c1feaf90.png","?0",0,0)
		
		ui.setMapName("<J>"..table.random({"Nöel","Christmas","Bolodefchoco","Lua event","#xmas","Bogkitty"}).." <G>- @"..table.random({666,404,801,os.date("%Y"),0,1}))
		ui.setShamanName("<R>S4NT4 M4U5")
		
		for k,v in next,tfm.get.room.playerList do
			mode.xmas.setPlayerTools(k)
		end
		tfm.exec.chatMessage(string.format("<V><B>[^_^]</B></V> <BV>%s</BV>\n<V><B>[S4NT4 M4U5]</B></V> <R>%s</R>",mode.xmas.translations[mode.xmas.langue][2],string.upper(mode.xmas.translations[mode.xmas.langue][1])))
	end,
	-- New Player
	eventNewPlayer = function(n)
		tfm.exec.addImage("158c1feaf90.png","?0",0,0,n)
		mode.xmas.setPlayerTools(n)
		tfm.exec.respawnPlayer(n)
	end,
	-- Loop
	eventLoop = function()
		mode.xmas.currentTime = mode.xmas.currentTime + .5
		mode.xmas.leftTime = mode.xmas.leftTime - .5
		if mode.xmas.start then
			if mode.xmas.currentTime > 4 then
				if mode.xmas.noel.id == -1 then
					mode.xmas.noel.id = tfm.exec.addShamanObject(6300,mode.xmas.noel.x,mode.xmas.noel.y)
					mode.xmas.noel.updateImage(mode.xmas.noel.img.stop)
				end

				local ox,oy
				if tfm.get.room.objectList[mode.xmas.noel.id] then
					ox,oy = tfm.get.room.objectList[mode.xmas.noel.id].x,tfm.get.room.objectList[mode.xmas.noel.id].y
				else
					ox,oy = mode.xmas.noel.x,mode.xmas.noel.y
				end

				if (ox < -10 or ox > 810) or (oy > 400 or oy < -50) then
					tfm.exec.removeObject(mode.xmas.noel.id)
					mode.xmas.noel.x,mode.xmas.noel.y = mode.xmas.initx,mode.xmas.inity
					mode.xmas.noel.id = nil
				end

				if mode.xmas.noel.id then
					mode.xmas.noel.x = ox
					mode.xmas.noel.y = oy
				end

				for k,v in ipairs(mode.xmas.despawnObjects) do
					if os.time() > v[2] then
						tfm.exec.removeObject(v[1])
					end
				end
				for k,v in ipairs(mode.xmas.currentGifts) do
					if os.time() > v[2] then
						tfm.exec.removeObject(v[1])
						tfm.exec.removeImage(v[3])
					end
				end

				if os.time() > mode.xmas.noel.isDizzy[1] and mode.xmas.currentTime > 5 then
					mode.xmas.noel.particles(13)
					if mode.xmas.currentTime % 60 == 0 then
						mode.xmas.noel.dizzy()
					elseif mode.xmas.currentTime % 5 == 0 then
						mode.xmas.noel.gift()
						mode.xmas.noel.escape(1)
					elseif math.floor(mode.xmas.currentTime) % 2 == 0 then
						local option = math.random((mode.xmas.noel.isEscaping and 15 or 12))
						if option > 3 then
							mode.xmas.noel.escape()
						else
							mode.xmas.noel.updateImage(mode.xmas.noel.img.stop)
							if mode.xmas.currentTime > 7 and math.random(1,2) == 1 then
								if option == 3 then
									mode.xmas.noel.cannon()
								elseif option == 2 then
									mode.xmas.noel.teleport()
								elseif option == 1 then
									mode.xmas.noel.meep()
								end
							end
						end
					else
						mode.xmas.noel.updateImage(mode.xmas.noel.img.stop)
					end
				else
					mode.xmas.noel.particles(1)
					if not mode.xmas.noel.isDizzy[2] then
						mode.xmas.noel.isDizzy[2] = true
						mode.xmas.noel.timers.prize = os.time() + 5000
						local imgId = #mode.xmas.noel.img.dizzy
						local animation = {}
						local numb = 1
						animation = system.looping(function()
							mode.xmas.noel.updateImage(mode.xmas.noel.img.dizzy[imgId])

							if imgId == #mode.xmas.noel.img.dizzy or imgId == 1 then
								numb = -numb
							end

							imgId = imgId + numb

							if (os.time()+250) > mode.xmas.noel.isDizzy[1] then
								for k,v in next,animation do
									system.removeTimer(v)
								end
								mode.xmas.noel.isDizzy = {0,false}
							end
						end,10)
					end
				end
			end
			if mode.xmas.leftTime < 2 then
				mode.xmas.start = false
				tfm.exec.newGame(mode.xmas.xml)
			end
		end
	end,
	-- Keyboard
	eventKeyboard = function(n,k,d,x,y)
		if mode.xmas.start then
			if os.time() > mode.xmas.info[n].catch and k == 32 then
				if os.time() < mode.xmas.noel.isDizzy[1] then
					if math.pythag(x,y,mode.xmas.noel.x,mode.xmas.noel.y,32) then
						mode.xmas.info[n].db.eventNoelGifts[2] = (mode.xmas.info[n].db.eventNoelGifts[1]/10) + mode.xmas.info[n].db.eventNoelGifts[2]
						mode.xmas.info[n].db.eventNoelGifts[1] = 0

						mode.xmas.updateBar(n)
					end
				else
					for k,v in next,mode.xmas.currentGifts do
						local o = tfm.get.room.objectList[v[1]]
						if o and math.pythag(x,y,o.x,o.y,25) then
							if (mode.xmas.info[n].db.eventNoelGifts[1]+v[4]) <= 50 then
								tfm.exec.removeObject(v[1])
								tfm.exec.removeImage(v[3])

								mode.xmas.currentGifts[k][2] = 0
								mode.xmas.info[n].db.eventNoelGifts[1] = mode.xmas.info[n].db.eventNoelGifts[1] + v[4]

								mode.xmas.updateBar(n,({0xB73535,0x358CB7,0x35B765,0xB7B735,0xB73487})[v[4]])
								break
							end
						end
					end
				end
				mode.xmas.info[n].catch = os.time() + 1000
			end
		end
	end,
	-- Player Died
	eventPlayerDied = function(n)
		if mode.xmas.start then
			system.bindKeyboard(n,32,true,false)
		end
	end,
}

--[[ Signal ]]--
mode.signal = {
	-- Translations
	translations = {
		en = {
			-- Init
			welcome = "<S>Welcome to <PS>#Signal<S>! Follow the signs and join the hole! Use !help to read more informations.\n\tReport any issue to Bolodefchoco",
			
			-- Info
			info = {
				[1] = {"Run","Run the faster you can. Do not stop!"},
				[2] = {"Attention","Pay attention! You can die in a few seconds!"},
				[3] = {"Stop","Stop or die!"},
			},
			skip = "<PS>[•] <S>Impossible map? Type !skip",
			skipped = "Your vote to skip the map has been recorded.",
			
			-- Simple words
			close = "Close",
		},
		br = {
			welcome = "<S>Bem-vindo ao <PS>#Signal<S>! Siga os sinais e entre na toca!  Use !help para ler mais informações.\n\tReporte qualquer problema para Bolodefchoco",

			info = {
				[1] = {"Corra","Corra o mais rápido que puder. Não pare!"},
				[2] = {"Atenção","Preste atenção! Você poderá morrer a qualquer momento!"},
				[3] = {"Pare","Pare ou morra!"},
			},
			skip = "<PS>[•] <S>Mapa impossível? Digite !skip",
			skipped = "Seu voto para passar o mapa foi registrado.",

			close = "Fechar",
		},
		pl = {
			welcome = "<S>Witaj w <PS>#Signal<S>! Patrz na tabliczke i wejdź do norki! Użyj komendy !help, aby przeczytać więcej informacji.\n\tZgłoś wszystkie błędy jakie znajdziesz do Bolodefchoco",
			
			info = {
				[1] = {"Biegnij","Biegnij jak najszybciej do norki. Nie zatrzymuj się!"},
				[2] = {"Uważaj","Uważaj! Możesz zginąć za kilka sekund!"},
				[3] = {"Stój","Stój albo zgiń!"},
			},
			skip = "<PS>[•] <S>Niemożliwa mapa? Wpisz komendę !skip",
			skipped = "Twój głos na ominięcie mapy został policzony.",
			
			close = "Zamknij",
		},
	},
	langue = "en",
	-- Data
	info = {},
	-- Maps
	generateMap = function()
		local groundProperties = {[0] = {.3,.2},[4] = {20,.2},[5] = {.3,.2},[6] = {.3,.2},[7] = {.1,.2},[10] = {.3,0},[11] = {.05,.1},[3] = {5,20}}
		local groundDecorations = {[0] = {0,4,5},[4] = {1,42,51},[5] = {1,2,4,12,18,20,32,42,46},[6] = {0,1,2,3,4,5,11,42},[7] = {7,8,9,10},[10] = {42,103,118},[11] = {51,106},[3] = {}}
		local newGround = "<S L=\"%s\" H=\"%s\" X=\"%s\" Y=\"%s\" T=\"%s\" P=\"0,0,%s,%s,0,0,0,0\" />"
		local newDecoration = "<P P=\"%s,0\" X=\"%d\" Y=\"%d\" T=\"%d\" />"
		local object = "<%s X=\"%s\" Y=\"%s\"/>"
		local objects = {hole="T",mice="DS",cheese="F"}

		local mapHeight = math.random(1500,3000)

		local grounds = {}
		local decorations = {}
		for i = 1,math.ceil(mapHeight/180) do
			local T = table.random({0,4,5,6,7,10,11,table.random({4,5,6,10,3})})

			local H = T==3 and math.random(10,20) or math.random(40,100)

			local Y = (#grounds > 1 and grounds[#grounds].Y < 320 and math.random(230,310) or math.random(300,350)) or math.random(290,350)

			local X,L
			repeat
				X = (#grounds > 1 and (grounds[#grounds].X + ((math.random(-1,1) * 30) + 200)) or math.random(50,300))
				X = X < 60 and 100 or X > mapHeight - 100 and mapHeight - 300 or X
				L = T==3 and H or math.random(40,math.ceil(mapHeight/18))
			until (X - (L/2)) > 50 and (X + (L/2)) < mapHeight - 50

			local properties = groundProperties[T]
			grounds[#grounds + 1] = {X=X,Y=Y,L=L,H=H,string.format(newGround,L,H,X,Y,T,properties[1],properties[2])}

			if T ~= 3 and math.random(20) < 10 then
				local decoList = groundDecorations[T]
				decorations[#decorations + 1] = string.format(newDecoration,table.random({0,0,0,math.random(0,1),1}),X - math.random(-((L/4)+1),((L/4)+1)),Y - (H/2),table.random(decoList))
			end
		end
		
		local cheeseX
		repeat
			cheeseX = math.random(200,mapHeight - 500)
		until (function()
			for k,v in next,grounds do
				if (cheeseX + 10) > (v.X - v.L/2) and (cheeseX - 10) < (v.X + v.L/2) then
					return false
				end
			end
			return true
		end)()

		grounds[#grounds + 1] = {X=0,Y=0,L=0,H=0,string.format(newGround,200,40,100,380,2,.3,.9)}
		grounds[#grounds + 1] = {X=0,Y=0,L=0,H=0,string.format(newGround,300,40,mapHeight - 150,380,6,.3,.2)}

		tfm.exec.newGame(string.format("<C><P G=\"0,%s\" F=\"%s\" L=\"%s\" /><Z><S>%s</S><D>%s%s%s%s</D><O /></Z></C>",table.random({math.random(7,12),10,11,9}),table.random({0,1,2,3,4,5,7,8}),mapHeight,table.concat(grounds,"",function(k,v) return v[1] end),string.format(object,objects.hole,mapHeight - 30,360),string.format(object,objects.mice,10,365),string.format(object,objects.cheese,cheeseX,math.random(280,340)),table.concat(decorations)))
	end,
	-- Settings
	sys = {0,1},
	discrepancy = 0,
	lights = {"15b52f8717d","15b52f8583a","15b52f88765"},
	lightId = -1,
	skip = 0,
	rounds = 0,
	possible = false,
	-- Settings
	update = function(id)
		tfm.exec.removeImage(mode.signal.lightId)
		mode.signal.lightId = tfm.exec.addImage(mode.signal.lights[mode.signal.sys[2]] .. ".png","&0",375,30)
		local color = ({0x1CB70C,0xF4D400,0xEC0000})[mode.signal.sys[2]]
		for k,v in next,mode.signal.info do
			if id == 1 then
				if not v.afk and v.canRev then
					tfm.exec.respawnPlayer(k)
				end
			end
			tfm.exec.setNameColor(k,color)
		end
	end,
	-- Help
	displayInfo = function(n,id)
		local color = ({"<VP>","<J>","<R>"})[id]
		ui.addTextArea(1,"<p align='center'><font size='25'>" .. color .. mode.signal.translations[mode.signal.langue].info[id][1] .. "\n</font></p><p align='left'><font size='14'>" .. mode.signal.translations[mode.signal.langue].info[id][2],n,250,110,300,181,0x324650,0x27343A,1,true)
		ui.addTextArea(2,"<font size='2'>\n</font><p align='center'><font size='16'><a href='event:close'>" .. mode.signal.translations[mode.signal.langue].close,n,250,300,300,30,0x27343A,0x27343A,1,true)
		ui.addTextArea(3,"<p align='center'><font size='20'><a href='event:info.1'><VP>•</a> <a href='event:info.2'><J>•</a> <a href='event:info.3'><R>•</a>",n,250,145,300,30,1,1,0,true)
		tfm.exec.removeImage(mode.signal.info[n].imageId)
		mode.signal.info[n].imageId = tfm.exec.addImage(mode.signal.lights[id] .. ".png","&1",375,200,n)
	end,
	-- Init
	init = function()
		mode.signal.translations.pt = mode.signal.translations.br
		mode.signal.langue = mode.signal.translations[tfm.get.room.community] and tfm.get.room.community or "en"

		for _,f in next,{"AutoShaman","AutoNewGame","AutoTimeLeft","PhysicalConsumables"} do
			tfm.exec["disable"..f]()
		end

		mode.signal.generateMap()
	end,
	-- New Player
	eventNewPlayer = function(n)
		if not mode.signal.info[n] then
			mode.signal.info[n] = {
				isMoving = {false,false,false,false},
				imageId = -1,
				afk = true,
				skipped = false,
				canRev = true,
			}
		end
		for i = 0,3 do
			system.bindKeyboard(n,i,true,true)
			system.bindKeyboard(n,i,false,true)
		end
		tfm.exec.chatMessage(mode.signal.translations[mode.signal.langue].welcome,n)
	end,
	-- New Game
	eventNewGame = function()
		mode.signal.skip = 0
		mode.signal.possible = false
		mode.signal.rounds = mode.signal.rounds + 1
		
		if mode.signal.rounds % 3 == 0 then
			tfm.exec.chatMessage(mode.signal.translations[mode.signal.langue].skip)
		end
		
		ui.setMapName("<BL>@" .. math.random(999) .. "   <G>|   <N>Round : <V>" .. mode.signal.rounds)
		
		for k,v in next,mode.signal.info do
			v.isMoving = {false,false,false,false}
			v.afk = true
			v.skipped = false
			v.canRev = true
		end
		
		mode.signal.sys = {0,1}
		mode.signal.update(mode.signal.sys[2])
	end,
	-- Keyboard
	eventKeyboard = function(n,k,d)
		if mode.signal.sys[2] == 3 and d and os.time() > mode.signal.discrepancy then
			tfm.exec.killPlayer(n)
		else
			mode.signal.info[n].isMoving[k + 1] = d
		end
		mode.signal.info[n].afk = false
	end,
	-- Loop
	eventLoop = function(currentTime,leftTime)
		if _G.currentTime > 8 then
			if os.time() > mode.signal.sys[1] then
				mode.signal.sys[2] = (mode.signal.sys[2] % 3) + 1
				mode.signal.sys[1] = os.time() + ({math.random(7,13),math.random(2,3),math.random(3,5)})[mode.signal.sys[2]] * 1000
				mode.signal.update(mode.signal.sys[2])
				mode.signal.discrepancy = os.time() + 520
			end
		end

		if _G.leftTime > 2 and system.players() > 0 then
			if mode.signal.sys[2] == 3 and os.time() > mode.signal.discrepancy then
				for k,v in next,mode.signal.info do
					for i,j in next,v.isMoving do
						if j then
							tfm.exec.killPlayer(k)
							break
						end
					end
				end
			end
		else
			mode.signal.generateMap()
		end
	end,
	-- Callbacks
	eventTextAreaCallback = function(i,n,c)
		local p = string.split(c,"[^%.]+")
		if p[1] == "info" then
			mode.signal.displayInfo(n,tonumber(p[2]))
		elseif p[1] == "close" then
			tfm.exec.removeImage(mode.signal.info[n].imageId)
			for i = 1,3 do
				ui.removeTextArea(i,n)
			end
		end
	end,
	-- Commands
	eventChatCommand = function(n,c)
		if c == "info" or c == "help" or c == "?" then
			eventTextAreaCallback(nil,n,"info." .. mode.signal.sys[2])
		elseif c == "skip" and _G.currentTime > 8 and not mode.signal.possible and not mode.signal.info[n].skipped then
			mode.signal.skip = mode.signal.skip + 1
			tfm.exec.chatMessage(mode.signal.translations[mode.signal.langue].skipped,n)
			
			local alive,total = system.players()
			if mode.signal.skip == math.ceil(.5 * total) then
				tfm.exec.chatMessage("o/")
				mode.signal.generateMap()
			end
		end
	end,
	-- Victory
	eventPlayerWon = function(n)
		mode.signal.possible = true
		mode.signal.info[n].canRev = false
		tfm.exec.setGameTime(40,false)
	end,
}

--[[ Bootcamp+ ]]--
mode.bootcampP = {
	-- Translations
	translations = {
		en = {
			-- Init
			welcome = "Welcome to <B>#Bootcamp+</B>! Type !info to check the commands\n\tReport any issue to Bolodefchoco!",
			
			-- Info
			info = "Checkpoint:\n\tIf the checkpoint system is enabled, press <B>E</B> to put a checkpoint and <B>Shift+E</B> to remove it.\nAdmin\n\tIf you are a room admin, there are some commands that you can execute:\n\tMaps\n\t\t!next <V>--> Pass the map</V>\n\t\t!again <V>--> Resets the current map</V>\n\t\t!np @Code <VP>or</VP> !map @Code <V>--> Loads a map</V>\n\t\t!queue clear <V>--> Clear the map queue</V>\n\t\t!queue add @Code <V>--> Adds a map in the map queue</V>\n\t\t!queue P3 <VP>or</VP> P13 <VP>or</VP> P23 <V>--> Adds the whole official rotation of P3 or P13 or P23 in the map queue</V>\n\tTime\n\t\t!time TimeInMinutes <V>--> Set the time of the current round in TimeInMinutes</V>\n\t\t!standtime TimeInMinutes <V>--> Set the time of all the rounds in TimeInMinutes</V>\n\tOthers\n\t\t<B>Shift+Click</B> in a ground to read its properties\n\t\t!checkpoint [[not] cheese] <V>--> Enables/Disables the checkpoint system</V>\n\t\tKey Delete <V>--> Kills you</V>",
			skip = "<VP>%s</VP> just skipped the map!",
			restart = "<VP>%s</VP> just restarted the current map!",
			loadmap = "<VP>%s</VP> just loaded the map %s!",
			settime = "The time has been set to %s minutes!",
			setstandtime = "The standard time of all the rounds has been set to %s minutes!",
			enabled = "enabled! Press <B>E</B> to put a checkpoint and <B>Shift+E</B> to remove it.",
			queuecleared = "%s just cleared the map queue",
			queuemapadded = "%s just added the map %s to the map queue",
			queueperm = "%s just added the category %s to the map queue",
			queuereset = "%s just reseted the queue to the main maps",
			
			-- Simple words
			disabled = "disabled!",
		},
		br = {
			welcome = "Bem-vindo ao <B>#Bootcamp+</B>! Digite !info para checar os comandos\n\tReporte quaisquer problemas para Bolodefchoco!",
			
			info = "Checkpoint:\n\tSe o sistema de checkpoint está ativado, pressione <B>E</B> para marcar um checkpoint e <B>Shift+E</B> para remove-lo.\nAdmin\n\tSe você é um administrador da sala, há alguns comandos que você pode executar:\n\tMapas\n\t\t!next <V>--> Passa o mapa</V>\n\t\t!again <V>--> Reinicia o mapa atual</V>\n\t\t!np @Código <VP>ou</VP> !map @Código <V>--> Carrega um mapa</V>\n\t\t!queue clear <V>--> Limpa a lista de mapas</V>\n\t\t!queue add @Código <V>--> Adiciona um mapa na lista de mapas</V>\n\t\t!queue P3 <VP>ou</VP> P13 <VP>ou</VP> P23 <V>--> Adiciona a rotação inteira de P3 ou P13 ou P23 na lista de mapas</V>\n\tTempo\n\t\t!time TempoEmMinutos <V>--> Define o tempo do mapa atual em TempoEmMinutos</V>\n\t\t!standtime TempoEmMinutos <V>--> Define o tempo de todas as partidas em TempoEmMinutos</V>\n\tOutros\n\t\t<B>Shift+Click</B> sobre um piso para ler suas propriedades\n\t\t!checkpoint [[not] cheese] <V>--> Ativa/Desativa o sistema de checkpoint</V>\n\t\tTecla Delete <V>--> Mata-o</V>",
			skip = "<VP>%s</VP> acabou de passar o mapa!",
			restart = "<VP>%s</VP> acabou de reiniciar o mapa atual!",
			loadmap = "<VP>%s</VP> acabou de carregar o mapa %s!",
			settime = "O tempo foi definido para %s minutos!",
			setstandtime = "O tempo padrão para todas as partidas foram definidas para %s minutos!",
			enabled = "ativado! Pressione <B>E</B> para marcar um checkpoint e <B>Shift+E</B> para remove-lo.",
			queuecleared = "%s acabou de limpar a rotação de mapas",
			queuemapadded = "%s acabou de adicionar o mapa %s na rotação de mapas",
			queueperm = "%s acabou de adicionar a categoria %s na rotação de mapas",
			queuereset = "%s acabou de resetar a rotação de mapas para os mapas principais",
			
			disabled = "desativado!",
		},
		pl = {
			welcome = "Witaj w <B>#Bootcamp+</B>! Wpisz !info na czacie aby sprawdzić jakie są komendy\n\tZgłaszaj wszelkie błędy do Bolodefchoco!",
	
			info = "Checkpoint:\n\tJeżeli system checkpointów jest włączony, kliknij <B>E</B>, aby ustawić checkpoint i <B>Shift+E</B>, aby go usunąć.\nAdmin\n\tJeżeli jesteś administratorem pokoju, jest kilka komend, które możesz użyć:\n\tMapy\n\t\t!next <V>--> Przełącza mapę</V>\n\t\t!again <V>--> Restartuje mapę</V>\n\t\t!np @Code <VP>albo</VP> !map @Code <V>--> Ładuje mapę</V>\n\t\t!queue clear <V>--> Czyści kolejkę map</V>\n\t\t!queue add @Code <V>--> Dodaję mapę do kolejki</V>\n\t\t!queue P3 <VP>albo</VP> P13 <VP>albo</VP> P23 <V>--> Dodaje wszystkie oficjalne rotacje z permów P3 albo P13 albo P23 do kolejki map</V>\n\tCzas\n\t\t!time CzasWMinutach <V>--> Ustawia czas obecnej mapy na CzasWMinutach</V>\n\t\t!standtime CzasWMinutach <V>--> Ustawia czas dla wszystkich rund na CzasWMinutach</V>\n\tInne\n\t\t<B>Shift+Click</B> na gruncie aby przeczytać jego właściwości\n\t\t!checkpoint [[not] cheese] <V>--> Włącza/Wyłącza system checkpointów</V>\n\t\tKey Delete <V>--> Kills you</V>",
			skip = "<VP>%s</VP> pominął/-ęła mapę!",
			restart = "<VP>%s</VP> zrestartował/-a mapę!",
			loadmap = "<VP>%s</VP> załadował/-a mapę %s!",
			settime = "Czas został ustawiony na %s minut!",
			setstandtime = "Standardowy czas dla wszystkich map został ustawiony na %s minut!",
			enabled = "włączony! Kliknij <B>E</B>, aby ustawić checkpoint i <B>Shift+E</B>, aby go usunąć.",
			queuecleared = "%s just cleared the map queue",
			queuemapadded = "%s just added the map %s to the map queue",
			queueperm = "%s just added the category %s to the map queue",
			queuereset = "%s just reseted the queue to the main maps",
			
			disabled = "wyłączony!",
		},
	},
	langue = "en",
	-- Data
	info = {},
	-- Maps
	maps = {},
	map = function()
		mode.bootcampP.maps = {6501305,6118143,2604997,2836937,6921682,3339586,5776126,5678468,5731571,6531399,6794559,5847160,5745650,7091808,7000003,6999993,4559999,4784241,3883780,4976520,4854044,6374076,3636206,3883883,6793803,4499335,4694197,5485847,6258690,3938895,1719709,4209243,6550335,5994088,3866650,3999455,4095418,4523127,1964971,1554670,4423047,764650,6079942,5562230,4883346,2978216,1947288,7025830,6822222,7096798,7108857,4766627,5888889,6782978,7035277,7151255,5699275,6422459,2634659,4808290,3620953,2973289,2604643,6591698,7134487,7054821,6928736,6930231,6900009,7159725,3737744,6933187,6864581,6807369,4701337,5277821,263226,6631702,6761156,4212122,7035055,6654599,4160675,4623227,5191670,7163009,6377984,1132272,2781845,7162779,3460976,2250757,7130399,7167027}
	end,
	-- New Game Settings
	groundsData = {},
	mapData = {},
	standardTime = 6,
	checkpoint = false,
	-- Settings
	respawnCheese = false,
	-- Leaderboard
	rank = function(players,fromValue,showPos,showPoints,pointsName,lim)
		local p,rank = {},""
		fromValue,lim = fromValue or {tfm.get.room.playerList,"score"},tonumber(lim) or 100
		for n in next,players do
			p[#p+1] = {name=n,v=fromValue[1][n][fromValue[2]]}
		end
		table.sort(p,function(f,s) return f.v>s.v end)
		for o,n in next,p do
			if o <= lim then
				rank = rank .. (showPos and "<J>"..o..". " or "") .. "<V>" .. n.name .. (showPoints and " <BL>- <VP>" .. n.v .. " "..(pointsName or "points") .."\n" or "\n")
			end
		end
		return rank
	end,
	-- Init
	init = function()
		-- Translations
		mode.bootcampP.translations.pt = mode.bootcampP.translations.br
		mode.bootcampP.langue = mode.bootcampP.translations[tfm.get.room.community] and tfm.get.room.community or "en"
		
		-- Settings
		mode.bootcampP.respawnCheese = system.miscAttrib == 1
		
		-- Init
		for _,f in next,{"AutoShaman","AutoScore","AutoTimeLeft","AutoNewGame","PhysicalConsumables","AfkDeath"} do
			tfm.exec["disable"..f]()
		end
		tfm.exec.setAutoMapFlipMode(false)

		mode.bootcampP.map()
		tfm.exec.newGame(table.random(mode.bootcampP.maps))
	end,
	-- New Game
	eventNewGame = function()
		tfm.exec.setGameTime(mode.bootcampP.standardTime * 60)
		mode.bootcampP.groundsData = {}
		mode.bootcampP.mapData = {}
		for k,v in next,mode.bootcampP.info do
			v.cheese = false
			v.checkpoint = {false,0,0,false}
			ui.removeTextArea(1,n)
		end
		
		local xml = tfm.get.room.xmlMapInfo.xml
		if xml then
			local grounds = string.match(xml,"<S>(.-)</S>")
			local properties = string.match(xml,"<C><P (.-)/>.*<Z>")
			if properties then
				mode.bootcampP.mapData = {
					width = string.match(properties,'L="(%d+)"') or 800,
					heigth = string.match(properties,'H="(%d+)"') or 400,
				}
			else
				mode.bootcampP.mapData = {
					width = 800,
					heigth = 400,
				}
			end

			local data = {}
			string.gsub(grounds,"<S (.-)/>",function(attributes)
				data[#data + 1] = attributes
			end)
			for i = 1,#data do
				mode.bootcampP.groundsData[i] = {}
				
				local type = string.match(data[i],'T="(%d+)"')
				mode.bootcampP.groundsData[i].type = type and tonumber(type) or -1

				local x = string.match(data[i],'X="(%d+)"')
				mode.bootcampP.groundsData[i].x = x and tonumber(x) or 0

				local y = string.match(data[i],'Y="(%d+)"')
				mode.bootcampP.groundsData[i].y = y and tonumber(y) or 0

				local width = string.match(data[i],'L="(%d+)"')
				mode.bootcampP.groundsData[i].width = width and tonumber(width) or 0

				local heigth = string.match(data[i],'H="(%d+)"')
				mode.bootcampP.groundsData[i].heigth = heigth and tonumber(heigth) or 0

				local info = string.match(data[i],'P="(.*)"')
				info = string.split(info,"[^,]+")

				mode.bootcampP.groundsData[i].friction = info[3] and tonumber(info[3]) or .3
				mode.bootcampP.groundsData[i].restitution = info[3] and tonumber(info[4]) or .2
				mode.bootcampP.groundsData[i].angle = info[3] and tonumber(info[5]) or 0
			end
		end
	end,
	-- New Player
	eventNewPlayer = function(n)
		if not mode.bootcampP.info[n] then
			mode.bootcampP.info[n] = {
				shift = false,
				checkpoint = {false,0,0,false},
				cheese = false,
			}
		end
		
		system.bindMouse(n,true)
		for i = 1,2 do
			system.bindKeyboard(n,16,i==1,true)
			system.bindKeyboard(n,string.byte("K"),i==1,true)
		end
		
		system.bindKeyboard(n,string.byte("E"),true,true)
		system.bindKeyboard(n,46,true,true) -- Delete key
		tfm.exec.chatMessage("<T>" .. system.getTranslation("welcome") .. "\n\t<CEP>/w Mquk #bootcamp+ @mapCode",n)
		
		local id = tfm.exec.addImage("15c6ee6324d.png","&0",120,100,n)
		system.newTimer(function()
			tfm.exec.removeImage(id)
		end,5000,false)
	end,
	-- Mouse
	eventMouse = function(n,x,y)
		if mode.bootcampP.info[n].shift then
			for i = #mode.bootcampP.groundsData,1,-1 do
				local g = mode.bootcampP.groundsData[i]
				local rad = math.rad(g.angle)
				local ax = {math.cos(rad),math.sin(rad)}

				local gX = g.x + ax[1] * (x - g.x) - ax[2] * (y - g.y)
				local gY = g.y + ax[2] * (x - g.x) + ax[1] * (y - g.y)

				if (g.type == 13 and math.pythag(x,y,g.x,g.y,g.width/2) or (math.abs(gX - g.x) < g.width/2 and math.abs(gY - g.y) < g.heigth/2)) then
					local properties = {"Type","ID","X","Y","Heigth","Width","Friction","Restitution","Angle"}
					local info = ""

					for k,v in next,properties do
						info = info .. string.format("<N>%s : <V>%s\n",v,(v == "ID" and i or v == "Type" and (({[0] = "Unknown","Wood","Ice","Trampoline","Lava","Chocolate","Earth","Grass","Sand","Cloud","Water","Stone","Snow","Rectangle","Circle","Spiderweb"})[g.type + 1]) or tostring(g[string.lower(v)])))
					end

					local mapW = tonumber(mode.bootcampP.mapData.width)
					local mapH = tonumber(mode.bootcampP.mapData.heigth)
					ui.addTextArea(0,info,n,(x + 150 <= mapW and x) or (x < 0 and 0) or (mapW - 150),(y + 180 <= mapH and y > 20 and y) or (y < 20 and 25) or (mapH - 180),nil,nil,nil,nil,.8,false)
				end
			end
		else
			ui.removeTextArea(0,n)
		end
	end,
	-- Keyboard
	eventKeyboard = function(n,k,d,x,y)
		if k == 16 then
			mode.bootcampP.info[n].shift = d
		elseif k == string.byte("E") and mode.bootcampP.checkpoint then
			if mode.bootcampP.info[n].shift then
				mode.bootcampP.info[n].checkpoint = {false,0,0,mode.bootcampP.info[n].checkpoint[4]}
				ui.removeTextArea(1,n)
			else
				mode.bootcampP.info[n].checkpoint = {true,x,y,true}
				ui.addTextArea(1,"",n,x-5,y-5,10,10,0x56A75A,0x56A75A,.5,true)
			end
		elseif k == string.byte("K") then
			if d then
				ui.addTextArea(2,mode.bootcampP.rank(tfm.get.room.playerList,{tfm.get.room.playerList,"score"},true,true,"points",20),n,5,30,nil,200,nil,nil,.8,true)
			else
				ui.removeTextArea(2,n)
			end
		elseif k == 46 then
			tfm.exec.killPlayer(n)
		end
	end,
	-- Commands
	eventChatCommand = function(n,c)
		local p = string.split(c,"[^%s]+",string.lower)
		if p[1] == "info" then
			tfm.exec.chatMessage("<T>" .. system.getTranslation("info"),n)
		else
			if system.roomAdmins[n] then
				if p[1] == "next" and os.time() > system.newGameTimer then
					tfm.exec.newGame(table.random(mode.bootcampP.maps))
					tfm.exec.chatMessage("<T>• " .. string.format(system.getTranslation("skip"),n))
				elseif p[1] == "again" and os.time() > system.newGameTimer then
					tfm.exec.newGame(tfm.get.room.currentMap)
					tfm.exec.chatMessage("<T>• " .. string.format(system.getTranslation("restart"),n))
				elseif (p[1] == "np" or p[1] == "map") and os.time() > system.newGameTimer then
					tfm.exec.newGame(p[2])
					tfm.exec.chatMessage("<T>• " .. string.format(system.getTranslation("loadmap"),n,string.find(p[2],"@") and p[2] or "@"..p[2]))
				elseif p[1] == "time" then
					tfm.exec.setGameTime(p[2] * 60)
					tfm.exec.chatMessage(string.format(system.getTranslation("settime"),p[2]))
				elseif p[1] == "standtime" then
					p[2] = p[2] and tonumber(p[2]) or 6
					if p[2] > 0 and p[2] < 10 then
						mode.bootcampP.standardTime = p[2]
						tfm.exec.chatMessage(string.format(system.getTranslation("setstandtime",p[2])))
					end
				elseif p[1] == "checkpoint" then
					local attribute = false
					if p[2] then
						attribute = true
						if p[2] == "not" and p[3] and p[3] == "cheese" then
							mode.bootcampP.respawnCheese = false
						elseif p[2] == "cheese" then
							mode.bootcampP.respawnCheese = true
						else
							attribute = false
						end
					end
					
					if not (mode.bootcampP.checkpoint and attribute) then
						mode.bootcampP.checkpoint = not mode.bootcampP.checkpoint
						tfm.exec.chatMessage("<T>Checkpoint " .. system.getTranslation(mode.bootcampP.checkpoint and "enabled" or "disabled"))
					
						if not mode.bootcampP.checkpoint then
							ui.removeTextArea(1,nil)
							for k,v in next,mode.bootcampP.info do
								v.checkpoint = {false,0,0,v.checkpoint[4]}
							end
							if system.miscAttrib ~= 1 then
								mode.bootcampP.respawnCheese = false
							end
							for k,v in next,mode.bootcampP.info do
								v.cheese = false
							end
						end
					end
				elseif p[1] == "queue" then
					if p[2] == "clear" then
						mode.bootcampP.maps = {}
						tfm.exec.chatMessage("• " .. string.format(system.getTranslation("queuecleared"),n))
					elseif p[2] == "add" then
						mode.bootcampP.maps[#mode.bootcampP.maps + 1] = p[3]
						tfm.exec.chatMessage("• " .. string.format(system.getTranslation("queuemapadded"),n,string.find(p[3],"@") and p[3] or "@"..p[3]))
					elseif p[2] and string.sub(p[2],1,1) == "p" then
						if p[2] == "p3" or p[2] == "p13" or p[2] == "p23" then
							mode.bootcampP.maps[#mode.bootcampP.maps + 1] = "#" .. string.sub(p[2],2)
							tfm.exec.chatMessage("• " .. string.format(system.getTranslation("queueperm"),n,string.upper(p[2])))
						end
					else
						mode.bootcampP.map()
						tfm.exec.chatMessage("• " .. string.format(system.getTranslation("queuereset"),n))
					end
				end
			end
		end
	end,
	-- Loop
	eventLoop = function()
		if _G.leftTime < 1 then
			tfm.exec.newGame(table.random(mode.bootcampP.maps))
		end
	end,
	-- Player Died
	eventPlayerDied = function(n)
		tfm.exec.respawnPlayer(n)
		if mode.bootcampP.checkpoint and mode.bootcampP.info[n].checkpoint[1] then
			tfm.exec.movePlayer(n,mode.bootcampP.info[n].checkpoint[2],mode.bootcampP.info[n].checkpoint[3])
		end
		if mode.bootcampP.checkpoint and mode.bootcampP.info[n].cheese and mode.bootcampP.respawnCheese then
			tfm.exec.giveCheese(n)
		end
	end,
	-- Victory
	eventPlayerWon = function(n,t,time)
		mode.bootcampP.info[n].cheese = false
		mode.bootcampP.info[n].checkpoint = {false,0,0,mode.bootcampP.info[n].checkpoint[4]}
		ui.removeTextArea(1,n)

		mode.bootcampP.eventPlayerDied(n)
		tfm.exec.setPlayerScore(n,1,true)
		tfm.exec.chatMessage(string.format("<ROSE>%s (%ss <PT>(%scheckpoint)</PT>)",n,time/100,mode.bootcampP.info[n].checkpoint[4] and "" or "no "),n)
	end,
	-- Got Cheese
	eventPlayerGetCheese = function(n)
		if mode.bootcampP.checkpoint and mode.bootcampP.respawnCheese then
			mode.bootcampP.info[n].cheese = true
		end
	end,
}

--[[ Map ]]--
mode.map = {
	-- Translations
	translations = {
		en = {
			-- Init
			welcome = "Welcome to #map! Here you can test your maps in different categories and check its approvation in the community!\n\tAdd a map to the queue with the command <B>!maptest @Code PCategory</B> and check the map info using the command <B>!mapinfo</B>.\n\n\tReport any problem to Bolodefchoco.",

			-- Info
			savenewmap = "Your map %s is in the position %s",
			newmaptime = "Less than %s minutes",
			vote = "Your vote has been recorded.",
			dovote = "Hold P and vote according to your opinion about this map!",

			-- Map Info
			mapby = "Map %s loaded by %s as %s.",

			-- Security
			cantvote = "You cannot vote.",
			
			-- Simple words
			grounds = "Grounds",
			status = "Status",
			author = "Author",
		},
		br = {
			welcome = "Bem-vindo ao #map! Aqui você pode testar seus mapas em diferentes categorias e checar sua aprovação na comunidade!\n\tAdicione um mapa na lista de espera com o comando <B>!maptest @Código PCategoria</B> e cheque as informações do mapa usando o comando <B>!mapinfo</B>.\n\n\tReporte qualquer problema para Bolodefchoco.",

			savenewmap = "Seu mapa %s está na posição %s",
			newmaptime = "Menos de %s minutos",
			vote = "Seu voto foi registrado.",
			dovote = "Segure P e vote de acordo com sua opinião sobre este mapa!",

			mapby = "Mapa %s carregado por %s como %s.",

			cantvote = "Vote não pode votar.",
			
			grounds = "Pisos",
			status = "Estado",
			author = "Autor",
		}
	},
	langue = "en",
	-- Data
	info = {},
	-- Maps
	queue = {},
	-- Map Settings
	autoRespawn = false,
	category = -1,
	mapInfo = {},
	canInfo = false,
	totalPlayers = 0,
	skip = false,
	images = {},
	-- Next Map
	nextMap = function()
		if os.time() > system.newGameTimer and #mode.map.queue > 0 then
			local mapData = mode.map.queue[1]

			mode.map.mapInfo = {mapData[1],mapData[2],0,0}
			mode.map.category = mapData[3]

			mode.map.before()		
			tfm.exec.newGame(mapData[1])
		end
	end,
	-- Category rules
	before = function()
		if mode.map.category >= 0 then
			if table.find({0,1,4,5,6,8,9},mode.map.category) then
				tfm.exec.disableAutoShaman(false)
				tfm.exec.disableAfkDeath(false)
				mode.map.autoRespawn = false
			elseif table.find({3,7,17},mode.map.category) then
				tfm.exec.disableAutoShaman()
				if mode.map.category == 3 then
					mode.map.autoRespawn = true
					tfm.exec.disableAfkDeath()
				end
			end
		end
	end,
	after = function()
		if mode.map.category >= 0 then
			if table.find({0,1,4,5,6,8,9},mode.map.category) then
				tfm.exec.setGameTime(135)
				if mode.map.category == 8 and mode.map.totalPlayers > 1 then
					local newShaman
					repeat
						newShaman = table.random(system.players(true))
					until not tfm.get.room.playerList[newShaman].isShaman

					ui.setShamanName((function()
						for k,v in next,tfm.get.room.playerList do
							if v.isShaman then
								return k
							end
						end
						return "?"
					end)() .. " - <PS>" .. newShaman)
					tfm.exec.setShaman(newShaman)

					local xml = tfm.get.room.xmlMapInfo.xml
					local attribute = string.match(xml,"<DC2 (.-)/>")
					if attribute then
						local x = string.match(attribute,"X=\"(%d+)\"")
						local y = string.match(attribute,"Y=\"(%d+)\"")
						if x and y then
							tfm.exec.movePlayer(newShaman,x,y)
						end
					end

					tfm.exec.setNameColor(newShaman,0xF1C4F6)
				end
			elseif mode.map.category == 3 then
				tfm.exec.setGameTime(360)
			elseif mode.map.category == 7 then
				tfm.exec.setGameTime(120)
			elseif mode.map.category == 17 then
				tfm.exec.setGameTime(63)
			end
		end
	end,
	-- Init
	init = function()
		mode.map.translations.pt = mode.map.translations.br
		mode.map.langue = mode.map.translations[tfm.get.room.community] and tfm.get.room.community or "en"

		tfm.exec.disableAutoNewGame()
		tfm.exec.setGameTime(10,false)
		
		local alive
		alive,mode.map.totalPlayers = system.players()
	end,
	-- New Player
	eventNewPlayer = function(n)
		if not mode.map.info[n] then
			mode.map.info[n] = {
				hasVoted = false
			}
		end

		for i = 1,2 do
			system.bindKeyboard(n,string.byte("P"),i == 1,true)
		end

		tfm.exec.chatMessage("<J>" .. system.getTranslation("welcome"),n)
	end,
	-- New Game
	eventNewGame = function()
		ui.removeTextArea(2,nil)
		mode.map.skip = false
		if mode.map.mapInfo[1] then
			mode.map.canInfo = true
			
			mode.map.after()
			table.remove(mode.map.queue,1)

			for k,v in next,mode.map.info do
				v.hasVoted = false
			end
			
			for k,v in next,mode.map.images do
				tfm.exec.removeImage(v)
			end
			
			xml.attribFunc(tfm.get.room.xmlMapInfo.xml,{
				[1] = {
					attribute = "img",
					func = function(value)
						local images = string.split(value,"[^;]+")
						for k,v in next,images do
							local info = string.split(v,"[^,]+")
							
							-- "img.png,x or 0,y or 0,0/1 (foreground)"
							info[4] = tonumber(info[4]) or 0
							if table.find({0,1},info[4]) then
								mode.map.images[#mode.map.images + 1] = tfm.exec.addImage(info[1],(info[4] == 0 and "?" or info[4] == 1 and "&") .. k,tonumber(info[2]) or 5,tonumber(info[3]) or 30)
							end
						end
					end
				}
			})

			tfm.exec.chatMessage("<J>" .. string.format(system.getTranslation("mapby"),"@" .. mode.map.mapInfo[1],mode.map.mapInfo[2],"P" .. mode.map.category))
			tfm.exec.chatMessage("<J>" .. system.getTranslation("dovote"))
		end
	end,
	-- Commands
	eventChatCommand = function(n,c)
		local p = string.split(c,"[^%s]+",string.lower)
		if system.isPlayer(n) and p[1] == "maptest" and p[2] then
			p[2] = tonumber(string.sub(p[2],(string.find(p[2],"@") and 2 or 1),8))
			if p[2] and #tostring(p[2]) > 3 then
				local pos = #mode.map.queue + 1
				local category = (p[3] and tonumber(string.sub(p[3],(string.find(p[3],"p") and 2 or 1))) or 0)
				if table.find({0,1,3,4,5,6,7,8,9,17,18},category) then
					if category == 18 then
						category = 1
					end
				else
					category = 0
				end

				mode.map.queue[pos] = {p[2],n,category}
				tfm.exec.chatMessage("<J><B>" .. string.format(system.getTranslation("savenewmap"),string.format("@%s (P%s)",p[2],category),"#" .. pos) .. "</B>. <ROSE>" .. string.format("(%s)",string.format(system.getTranslation("newmaptime"),pos * 2.5)),n)
			end
		elseif mode.map.mapInfo[1] and p[1] == "mapinfo" then
			local xml = tfm.get.room.xmlMapInfo
			xml = xml and xml.xml or "?"
			
			local attributes = string.match(xml,"<P (.-)/>") or "?"
			
			local totalGrounds = (function()
				local g = string.match(xml,"<S>(.-)</S>") or "?"

				local total = 0
				string.gsub(g,"<S ",function()
					total = total + 1		
				end)

				return total
			end)()
			
			local info = {attributes,system.getTranslation("grounds") .. ": " .. totalGrounds,system.getTranslation("author") .. ": " .. (tfm.get.room.xmlMapInfo.author or "?"),system.getTranslation("status") .. ": " .. ("P" .. tfm.get.room.xmlMapInfo.permCode or "?")}
			ui.addTextArea(2,"\t<J>" .. table.concat(info,"   <G>|<J>   "),n,5,380,790,20,1,1,.7,true)
		elseif n == mode.map.mapInfo[2] and p[1] == "time" then
			tfm.exec.setGameTime(tonumber(string.sub(p[2],1,3)) or 60,false)
		elseif n == mode.map.mapInfo[2] and p[1] == "skip" then
			if os.time() > system.newGameTimer and #mode.map.queue > 0 then
				mode.map.skip = true
			end
		end
	end,
	eventKeyboard = function(n,k,d)
		if _G.currentTime > 5 then
			if d and not mode.map.info[n].hasVoted then
				if n == mode.map.mapInfo[2] or not system.isPlayer(n) then
					tfm.exec.chatMessage("<R>" .. system.getTranslation("cantvote"),n)
				else
					local ic = {{"+","VP"},{"-","R"}}
					for i = 0,1 do
						ui.addTextArea(i,"<p align='center'><font size='6'>\n<font size='17'><" .. ic[i+1][2] .. "><a href='event:" .. ic[i+1][1] .. "'><B>" .. ic[i+1][1] .. "1",n,5 + i * 50,30,40,40,1,1,.7,true)
					end
				end
			else
				for i = 0,1 do
					ui.removeTextArea(i,n)
				end
			end
		end
	end,
	-- Callbacks
	eventTextAreaCallback = function(i,n,c)
		mode.map.info[n].hasVoted = true
		if c == "+" then
			mode.map.mapInfo[3] = mode.map.mapInfo[3] + 1
		elseif c == "-" then
			mode.map.mapInfo[4] = mode.map.mapInfo[4] + 1
		end
		mode.map.eventKeyboard(n,string.byte("P"),false)

		tfm.exec.chatMessage("• " .. system.getTranslation("vote"),n)
	end,
	-- Loop
	eventLoop = function()
		local alive = 100
		if _G.currentTime % 5 == 0 then
			alive,mode.map.totalPlayers = system.players()
		end
		if _G.leftTime < 1 or alive < 1 or mode.map.skip then
			if mode.map.mapInfo[1] and mode.map.canInfo then
				mode.map.canInfo = false
				
				local totalVotes = mode.map.mapInfo[3] + mode.map.mapInfo[4]
				if totalVotes > 0 then
					tfm.exec.chatMessage(string.format("• [@%s] %s%% (%s)",mode.map.mapInfo[1],math.percent(mode.map.mapInfo[3],totalVotes),totalVotes),mode.map.mapInfo[2])
				end
			end
			mode.map.nextMap()
		end
	end,
	-- Player Died
	eventPlayerDied = function(n)
		if mode.map.autoRespawn then
			tfm.exec.respawnPlayer(n)
		end
	end,
	-- Player Won
	eventPlayerWon = function(n)
		mode.map.eventPlayerDied(n)
	end,
}

--[[ Godmode ]]--
mode.godmode = {
	-- Translations
	translations = {
		en = {
			-- Init
			welcome = "Welcome to <B>#godmode</B>. Type !info to read the help message.\n\tReport any issue to Bolodefchoco.",

			-- Guide
			shaman = "Hello shaman! Try to build without nails! Good luck.",

			-- Info
			info = "Use your creativity and build WITHOUT nails in shaman maps! The more mice you save, the higher your score will be. Do not let the mice die.\nPress P or type !p [playername] to open a profile.",
			xp = "You've saved %s mice and %s died.",

			-- Warning
			nail = "You can use %s more nails. After that, you will die.",
			kill = "Try not to use nails in your buildings.",
			fail = "You failed!",
			
			-- Profile
			profile = "Rounds : %s\n<N>Data : %s <G>/ %s\n\n<N>Deaths : %s",
		},
		br = {
			welcome = "Bem-vindo ao <B>#godmode</B>. Digite !info para ler a mensagem de ajuda.\n\tReporte qualquer problema para Bolodefchoco.",

			shaman = "Olá shaman! Tente construir sem pregos! Boa sorte.",

			info = "Utilize sua criatividade e construa em mapas shaman SEM pregos! Quanto mais ratos você salvar, maior será sua pontuação. Não deixe nenhum rato morrer.\nPressione P ou digite !p [nome] para abrir um perfil.",
			xp = "Você salvou %s ratos e %s morreram.",

			nail = "Você pode usar mais %s pregos. Depois disso, você morrerá.",
			kill = "Tente não usar pregos em suas construções.",
			fail = "Você falhou!",

			profile = "Partidas : %s\n<N>Dados : %s <G>/ %s\n\n<N>Mortes : %s",
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
	-- Profile
	profile = function(n,p)
		ui.addTextArea(0,"<p align='center'><B><R><a href='event:profile.close'>X",n,513,115,20,20,1,1,1,true)
		ui.addTextArea(1,"<p align='center'><font size='16'><B><V>"..p.."</V></B></font></p><p align='left'><font size='12'>\n<N>" .. string.format(system.getTranslation("profile"),"<V>"..mode.godmode.info[p].roundSha,"<J>"..mode.godmode.info[p].cheeseMice,"<R>"..mode.godmode.info[p].deathMice,"<V>"..mode.godmode.info[p].deathSha),n,290,115,220,160,1,1,1,true)
	end,
	-- Init
	init = function()
		mode.godmode.translations.pt = mode.godmode.translations.br
		mode.godmode.langue = mode.godmode.translations[tfm.get.room.community] and tfm.get.room.community or "en"

		tfm.exec.disableAutoNewGame()
		tfm.exec.disableAllShamanSkills()
		tfm.exec.newGame("#4")
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

		for k,v in next,{66,67,74,78,80,86} do
			system.bindKeyboard(n,v,true,true)
		end

		tfm.exec.chatMessage("<ROSE>" .. system.getTranslation("welcome"),n)
		
		local id = tfm.exec.addImage("15ca3f4a200.png","&0",5,150,n)
		system.newTimer(function()
			tfm.exec.removeImage(id)
		end,10000,false)
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
		
		tfm.exec.setGameTime(183)
	end,
	-- Keyboard
	eventKeyboard = function(n,k)
		if k == 80 then
			mode.godmode.profile(n,n)
		elseif not tfm.get.room.playerList[n].isDead and tfm.get.room.playerList[n].isShaman then
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
			tfm.exec.newGame("#4")
		end
	end,
	-- Player Died
	eventPlayerDied = function(n)
		if tfm.get.room.playerList[n].isShaman then
			tfm.exec.setGameTime(10,false)
			mode.godmode.info[n].deathSha = mode.godmode.info[n].deathSha + 1
			tfm.exec.chatMessage("<R>" .. system.getTranslation("fail"),n)
		else
			mode.godmode.deadMice = mode.godmode.deadMice + 1
		end
	end,
	-- Player Won
	eventPlayerWon = function(n)
		if not tfm.get.room.playerList[n].isShaman then
			mode.godmode.savedMice = mode.godmode.savedMice + 1
		end
	end,
	-- Commands
	eventChatCommand = function(n,c)
		local p = string.split(c,"[^%s]+",string.lower)
		if p[1] == "info" then
			tfm.exec.chatMessage("<J>" .. system.getTranslation("info"),n)
		elseif p[1] == "p" then
			if p[2] then
				p[2] = string.nick(p[2])
				if mode.godmode.info[p[2]] then
					mode.godmode.profile(n,p[2])
				end
			else
				mode.godmode.profile(n,n)
			end
		end
	end,
	-- Callback
	eventTextAreaCallback = function(i,n,c)
		local p = string.split(c,"[^%.]+")
		if p[1] == "profile" then
			if p[2] == "close" then
				for i = 0,1 do
					ui.removeTextArea(i,n)
				end
			end
		end
	end,
}

--[[ Non-official Events ]]--
system.objects = {
	image = {},
	textarea = {}
}
eventModeChanged = function()
	for k in next,system.objects.image do
		tfm.exec.removeImage(k)
	end
	
	for k in next,system.objects.textarea do
		ui.removeTextArea(k,nil)
	end
	
	system.objects = {
		image = {},
		textarea = {}
	}
end

system.officialModeMessage = ""

--[[ Event Functions ]]--
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
			if os.time() > system.modeChanged and os.time() > system.newGameTimer then
				local newMode = system.getGameMode(c)
				if newMode then
					system.init()
				end
			end
		end
	end
	if c == "module" then
		tfm.exec.chatMessage(string.format("VERSION : %s\nNAME : %s\nSTATUS : %s\nAUTHOR : %s\n\nMODE : %s",module._VERSION,module._NAME,module._STATUS,module._AUTHOR,system.gameMode),n)
	elseif c == "stop" and system.roomAdmins[n] then
		system.exit()
	end
end

events.eventNewPlayer = function(n)
	if system.officialModeMessage ~= "" then
		tfm.exec.chatMessage(system.officialModeMessage,n)
	end
end

--[[ Room Settings ]]--
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
				system.officialModeMessage = v[2]
				break
			end
		end
	end
end

--[[ Initialize ]]--
execute = {}
system.setRoom()

system.init = function()
	for i,event in next,{"Loop","NewGame","PlayerDied","PlayerGetCheese","PlayerVampire","PlayerWon","PlayerLeft","EmotePlayed","Keyboard","Mouse","PopupAnswer","TextAreaCallback","ChatCommand","ChatMessage","SummoningStart","SummoningEnd","SummoningCancel","NewPlayer","PlayerRespawn","ColorPicked"} do
		local e = "event" .. event
		
		local found = false
		for k,v in next,mode[system.gameMode] do
			if k == e then
				execute[e] = v
				found = true
				break
			end
		end
		if not found then
			execute[e] = function() end
		end

		_G[e] = function(...)
			if events[e] then
				events[e](...)
			end
			execute[e](...)
		end
	end

	if _G["eventNewPlayer"] then
		table.foreach(tfm.get.room.playerList,eventNewPlayer)
	end
	
	normalizeTranslation()
	mode[system.gameMode].init()
end
system.init()