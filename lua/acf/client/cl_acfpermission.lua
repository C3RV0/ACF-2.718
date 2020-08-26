--[[ 
	Code modified from the NADMOD client permissions menu, by Nebual
	http://www.facepunch.com/showthread.php?t=1221183
	
	This is the Damage Permissions menu in the Utilities tab
	It will be moved to the ACF tab when I get around to making it
]]--


-- Finds ACF table, or creates one if it does not exist
ACF = ACF or {}

-- Gets Permissions data from the ACF table, or creates it if it does not exist
ACF.Permissions = ACF.Permissions or {}
local this = ACF.Permissions

local getPanelChecks = function() return {} end



-- Net message for updating the list of people on your Damage Buddies list
net.Receive("ACF_refreshfriends", function(len)
	--Msg("\ncl refreshfriends\n")
	local perms = net.ReadTable()
	local checks = getPanelChecks()
	
	for k, check in pairs(checks) do
		if perms[check.steamid] then
			check:SetChecked(true)
		else
			check:SetChecked(false)
		end
	end
	
end)


-- Net message to check whether your Damage Permissions were successfully updated or not
net.Receive("ACF_refreshfeedback", function(len)
	local success = net.ReadBit()
	local str, notify
	
	if success then
		str = "Successfully updated your ACF damage permissions!"
		notify = "NOTIFY_GENERIC"
	else
		str = "Failed to update your ACF damage permissions."
		notify = "NOTIFY_ERROR"
	end
	
	GAMEMODE:AddNotify(str, notify, 7)
	
end)


-- Net message that sends the buddies list to the server
function this.ApplyPermissions(checks)
	perms = {}
	
	for k, check in pairs(checks) do
		-- Error thrown if a player is invalid
		if not check.steamid then
			Error("Encountered player checkbox without an attached SteamID!")
		end
		perms[check.steamid] = check:GetChecked()
	end
	
	net.Start("ACF_dmgfriends")
		net.WriteTable(perms)
	net.SendToServer()
end


-- Function for making the actual panel
function this.ClientPanel(Panel)
	Panel:ClearControls()
	if !this.ClientCPanel then this.ClientCPanel = Panel end
	Panel:SetName("ACF Damage Permissions")
	
	local txt = Panel:Help("ACF Damage Permission Panel")
	txt:SetContentAlignment( TEXT_ALIGN_CENTER )
	txt:SetFont("DermaDefaultBold")
	--txt:SetAutoStretchVertical(false)
	--txt:SetHeight

	local txt = Panel:Help("Allow or deny ACF damage to your props using this panel.\n\nThese preferences only work during the Build and Strict Build modes.")
	txt:SetContentAlignment( TEXT_ALIGN_CENTER )
	--txt:SetAutoStretchVertical(false)
	
	Panel.playerChecks = {}
	local checks = Panel.playerChecks
	
	getPanelChecks = function() return checks end
	
	local Players = player.GetAll()
	for _, tar in pairs(Players) do
		if(IsValid(tar)) then
			local check = Panel:CheckBox(tar:Nick())
			check.steamid = tar:SteamID()
			--if tar == LocalPlayer() then check:SetChecked(true) end
			checks[#checks+1] = check
		end
	end
	local button = Panel:Button("Give Damage Permission")
	button.DoClick = function() this.ApplyPermissions(Panel.playerChecks) end
	
	net.Start("ACF_refreshfriends")
		net.WriteBit(true)
	net.SendToServer(ply)
end


-- Function for creating the panel when the spawn menu is opened
function this.SpawnMenuOpen()
	if this.ClientCPanel then
		this.ClientPanel(this.ClientCPanel)
	end
end
hook.Add("SpawnMenuOpen", "ACFPermissionsSpawnMenuOpen", this.SpawnMenuOpen)


-- Function for creating the options in the Utilities menu
function this.PopulateToolMenu()
	spawnmenu.AddToolMenuOption("Utilities", "ACF", "Damage Permission", "Damage Permission", "", "", this.ClientPanel)
end
hook.Add("PopulateToolMenu", "ACFPermissionsPopulateToolMenu", this.PopulateToolMenu)
