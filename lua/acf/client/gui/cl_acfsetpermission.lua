--[[
	This is the menu gui for damage permission.
	It is currently found in the Utilities tooltab, but I plan on moving it to its own separate tab.
	The variable names are pretty self-explanatory, but I added a few extra comments just in case. Planning on adding a few more later on.
]]--

local Menu = {}

-- The category the menu goes under
Menu.Category = "ACF"


-- The name of the item 
Menu.Name = "Set Permission Mode"

-- The convar to execute when the player clicks on the tab
Menu.Command = ""



local Permissions = {}

-- Empty table for all existing Damage Permission Modes
local PermissionModes = {}

local CurrentPermission = "default"
local DefaultPermission = "none"	-- Sets the default DP mode to 'none'
local ModeDescTxt
local ModeDescDefault = "Can't find any info for this mode!"	-- String to display if no mode description is found
local currentMode	-- Empty variable for the current DP mode
local currentModeTxt = "\nThe current damage permission mode is %s."
local introTxt = "Damage Permission Modes change the way that ACF damage works.\n\nYou can change the DP mode if you are an admin."
local list 


function Permissions:Update()

	if list then	
		for id,line in pairs(list:GetLines()) do
			if line:GetValue(1) == CurrentPermission then
				list:GetLine(id):SetValue(2,"Yes")
			else
				list:GetLine(id):SetValue(2,"")
			end
			if line:GetValue(1) == DefaultPermission then
				list:GetLine(id):SetValue(3,"Yes")
			else
				list:GetLine(id):SetValue(3,"")
			end
		end
	end
	
	if currentMode then
		currentMode:SetText(string.format(currentModeTxt, CurrentPermission))
		currentMode:SizeToContents()
	end
	
end

function Permissions:RequestUpdate()
	net.Start("ACF_refreshpermissions")
		net.WriteBit(true)	
	net.SendToServer()
end


net.Receive("ACF_refreshpermissions", function(len)
	
	PermissionModes = net.ReadTable()
	CurrentPermission = net.ReadString() 
	DefaultPermission = net.ReadString()
	
	Permissions:Update()
	
end)



function Menu.MakePanel(Panel)

	Permissions:RequestUpdate()

	Panel:ClearControls()
	
	if not PermissionModes then return end
	
	Panel:SetName("Permission Modes")
	
	
	local txt = Panel:Help(introTxt)
	txt:SetContentAlignment( TEXT_ALIGN_CENTER )
	--txt:SetAutoStretchVertical(false)
	txt:SizeToContents()
	
	Panel:AddItem(txt)
	
	currentMode = Panel:Help(string.format(currentModeTxt, CurrentPermission))
	currentMode:SetContentAlignment( TEXT_ALIGN_CENTER )
	--currentMode:SetAutoStretchVertical(false)
	currentMode:SetFont("DermaDefaultBold")
	currentMode:SizeToContents()
	
	Panel:AddItem(currentMode)
	
	
	if LocalPlayer():IsAdmin() then
	
		--[[
		local pmhelp = Panel:Help("Change Permission Mode")
		pmhelp:SetContentAlignment( TEXT_ALIGN_CENTER )
		pmhelp:SetAutoStretchVertical(false)
		pmhelp:SetFont("DermaDefaultBold")
		pmhelp:SizeToContents()
		]]--

		list = vgui.Create("DListView")
		list:AddColumn("Mode")
		list:AddColumn("Active")
		list:AddColumn("Map Default")
		list:SetMultiSelect(false)
		list:SetSize(30,100)

		for permission,desc in pairs(PermissionModes) do
			list:AddLine(permission, "", "")
		end
		
		for id,line in pairs(list:GetLines()) do
			if line:GetValue(1) == CurrentPermission then
				list:GetLine(id):SetValue(2,"Yes")
			end
			if line:GetValue(1) == DefaultPermission then
				list:GetLine(id):SetValue(3,"Yes")
			end
		end

		list.OnRowSelected = function(panel, line)
			if ModeDescTxt then
				ModeDescTxt:SetText(PermissionModes[panel:GetLine(line):GetValue(1)] or ModeDescDefault)
				ModeDescTxt:SizeToContents()
			end
		end
		
		Panel:AddItem(list)
		
		
		local txt = Panel:Help("What this mode does:")
		txt:SetContentAlignment( TEXT_ALIGN_CENTER )
		--txt:SetAutoStretchVertical(false)
		txt:SetFont("DermaDefaultBold")
		txt:SizeToContents()
		--txt:SetHeight(20)
		
		Panel:AddItem(txt)
		
		
		ModeDescTxt = Panel:Help(PermissionModes[CurrentPermission] or ModeDescDefault)
		ModeDescTxt:SetContentAlignment( TEXT_ALIGN_CENTER )
		--txt:SetAutoStretchVertical(false)
		ModeDescTxt:SizeToContents()
		
		Panel:AddItem(ModeDescTxt)
		

		local button = Panel:Button("Set Permission Mode")
		button.DoClick = function()  	
			local line = list:GetLine(list:GetSelectedLine())
			if not line then
				Permissions:RequestUpdate()
				return
			end
			
			local mode = line and line:GetValue(1)
			RunConsoleCommand("ACF_setpermissionmode",mode) 
		end
		
		Panel:AddItem(button)
		
		
		local button2 = Panel:Button("Set Default Permission Mode")
		button2.DoClick = function()  
			local line = list:GetLine(list:GetSelectedLine())
			if not line then
				Permissions:RequestUpdate()
				return
			end
			
			local mode = line and line:GetValue(1)
			RunConsoleCommand("ACF_setdefaultpermissionmode",mode) 
		end
		
		Panel:AddItem(button2)
	
	end
end


function Menu.OnSpawnmenuOpen()
	Permissions:RequestUpdate()
end 



local cat = Menu.Category
local item = Menu.Name
local var  =  Menu.Command
local open = Menu.OnSpawnmenuOpen
local panel = Menu.MakePanel
local hookname = string.Replace(item," ","_")


hook.Add("SpawnMenuOpen", "ACF.SpawnMenuOpen."..hookname, open)


hook.Add("PopulateToolMenu", "ACF.PopulateToolMenu."..hookname, function()
	spawnmenu.AddToolMenuOption("Utilities", cat, item, item, var, "", panel)
end)
