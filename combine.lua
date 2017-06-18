-- Stolen from Jordynl#Pokelua
combiner = {}

repeat
	os.execute("cls")
	io.write("use version dealer? (Y/N): ")
	combiner.newVersion = io.read():upper()
until combiner.newVersion == "Y" or combiner.newVersion == "N"

combiner.newVersion = combiner.newVersion == "Y"
dump = {
	[[--Creator: Bolodefchoco
--Made in: 06/02/2017
--Last update: ]] .. os.date("%d/%m/%Y")
}
workPath = debug.getinfo(1).short_src
modulePath = string.format("%s\\",workPath:match("([^,]+)\\combine.lua"))

fileTree = {
	"src:Module",
	"src:API",
	"src:Game Mode System",
	"src:Modes",
	"src:mode:Grounds",
	"src:mode:Jokenpo",
	"src:mode:Click",
	"src:mode:Presents",
	"src:mode:Chat",
	"src:mode:Cannonup",
	"src:mode:Xmas",
	"src:mode:Signal",
	"src:mode:Bootcamp+",
	"src:mode:Map",
	"src:mode:Godmode",
	"src:Non-official Events",
	"src:Event Functions",
	"src:Room Settings",
	"src:Initialize",
}

function file_exists(file)
	local f = io.open(file,"rb")
	if f then
		f:close()
	end
	return f ~= nil
end

function lines_from(file)
	if not file_exists(file) then
		return {}
	end
	lines = {}
	for line in io.lines(file) do 
		lines[#lines + 1] = line
	end
	return table.concat(lines,"\n")
end

combiner.run = function()
	if combiner.newVersion then
		fileTree = {"src:Module","src:versionIssues:newVersion",}
	end
	for _,file in next,fileTree do
		local fullPath = string.format("%s%s.lua",modulePath,string.gsub(file,"%:","\\"))
		local toInclude = string.format("--[[ %s ]]--\n",string.reverse(string.match(string.reverse(file),"[^:]+")))
		
		if file_exists(fullPath) then
			local lines = lines_from(fullPath)
			toInclude = toInclude .. string.format("%s",lines)
		else
			print(string.format("File '%s' does not exist.",fullPath))
		end
		
		table.insert(dump,toInclude)
	end
	
	buildFile = string.format("%s\\versions\\Grounds_%s.lua",modulePath,os.date("%d_%m_%y")) 
	file = io.open(buildFile,"w")
	file:write(table.concat(dump,"\n\n"))
	file.close()
end

combiner.run()

io.write("Executed!")
os.execute("pause >nul")