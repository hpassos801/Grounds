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
	
	ui.addPopup(0,0,"",nil,-1500,-1500)
	for k in next,tfm.get.room.playerList do
		for i = 0,255 do
			for v = 0,1 do
				system.bindKeyboard(k,i,v == 0,false)
			end
		end
	end
	
	system.roomAdmins = {Bolodefchoco = true}
end
