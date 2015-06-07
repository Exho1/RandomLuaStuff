---- Killed Screen? ----
-- Author: Exho
-- V: 9/7/14	

-- TODO: Animations

--[[
local KS_Config = {}
KS_Config.Enabled = "1" -- Remove this, its silly

KS_Config.DefaultPosition = "top" -- Your choice of top, center, or bottom
KS_Config.DefaultShowTime = 4 -- Seconds the panel shows

KS_Config.OtherDeathImg = "vgui/ttt/icon_rock" -- Icon for strange deaths like world
KS_Config.ShowFriendStatus = true -- Friend icon
KS_Config.ShowAdminStatus = true -- Admin/Superadmin icon
KS_Config.AvatarHighlight = true -- Avatar highlight

KS_Config.Color_Background = Color(52, 73, 94, 255) -- BG color
KS_Config.Color_RandomInfo = Color(44, 62, 80, 255) -- Random info BG color
KS_Config.Color_AvatarHighlight = Color(42, 53, 74, 255) -- Avatar Highlight BG Color


local config = KS_Config

if SERVER then
	AddCSLuaFile()
	util.AddNetworkString( "SendDeathData" )
	local KS_NONE = 10 -- Made-up "role" to be used when the Killer doesnt actually have one.
	
	local function AliveTime(ply) -- ALIVE TIME
		ply:SetNWInt("KS_LiveTime", CurTime())
	end
	local function DamageCounter(ply, dmginfo) -- DAMAGE DEALT
		if ply:IsPlayer() or ply:IsNPC() and IsValid(ply) then
			local dmg = dmginfo:GetDamage()
			local att = dmginfo:GetAttacker()
			local cur = att:GetNWInt("KS_DamageDealt",0)
			att:SetNWInt("KS_DamageDealt", math.Round(cur + dmg))
		end
	end
	local function GunPickups(wep) -- WEAPON PICKUPS
		timer.Simple(1.5, function()
			if not IsValid(wep:GetOwner()) then return end
			
			local ply = wep:GetOwner()
			if not IsValid(ply) then return end
			
			local cur = ply:GetNWInt("KS_PickedUpGuns")
			ply:SetNWInt("KS_PickedUpGuns", cur + 1)
		end)
	end
	local function KillCounter( vic, inflictor, killer) -- KILL COUNTER
		if vic == killer then return end
		
		if vic:IsPlayer() and IsValid(vic) then
			if vic:GetRole() == ROLE_TRAITOR then
				local cur = killer:GetNWInt("KS_TraitorKilled",0)
				killer:SetNWInt("KS_TraitorKilled", 1 + cur)
			elseif vic:GetRole() == ROLE_INNOCENT then
				local cur = killer:GetNWInt("KS_InnoKilled",0)
				killer:SetNWInt("KS_InnoKilled", 1 + cur)
			end
		end
	end
	local function GiveToTheDead(ply, inflictor, killer) -- SHOWING THE ACTUAL KILL SCREEN
		if GetRoundState() ~= ROUND_ACTIVE then return end
		if ply:Team() ~= TEAM_TERROR then print("Deathmatcher") end -- SpecDM fix?
		
		if IsValid(ply) and ply:IsPlayer() then
			local DD = {} -- Create a table, Death Data
			if killer:IsPlayer() and not killer == ply then
				DD.killer = killer
				DD.role = killer:GetRole()
				DD.ply = true
			elseif killer == ply then
				DD.avatar = ply
				DD.killer = "Yourself"
				DD.ply = false
				DD.role = KS_NONE
			else
				DD.avatar = ""
				DD.killer = "The World"
				DD.role = KS_NONE -- No role, set it to a number that is unused
				DD.ply = false -- Not a player so avoid player related stuff
			end
			DD.selfrole = ply:GetRole()
			
			net.Start("SendDeathData")
				net.WriteTable(DD)
			net.Send(ply)
		end
	end
	local function Resetter()
		for k, v in pairs(player.GetAll()) do
			v:SetNWInt("KS_DamageDealt", 0)
			v:SetNWInt("KS_LiveTime", CurTime())
			v:SetNWInt("KS_PickedUpGuns", 0)
			v:SetNWInt("KS_TraitorKilled", 0)
			v:SetNWInt("KS_InnoKilled", 0)
		end
	end
	-- Hooks
	hook.Add( "PlayerSpawn", "RecordTheirLivetime", AliveTime )
	hook.Add( "PlayerDeath", "SendPhoto", GiveToTheDead )
	hook.Add( "PlayerDeath", "CountDeadTraitors", KillCounter )
	hook.Add( "EntityTakeDamage", "CountingLikeTheCount", DamageCounter )
	hook.Add( "WeaponEquip", "PickupSticks", GunPickups)
	hook.Add( "TTTBeginRound", "Resetting", Resetter )
end



if CLIENT then
	local ks_toggle = CreateClientConVar("ks_enabled", "1", true, true)
	local ks_timer = CreateClientConVar("ks_timer", config.DefaultShowTime, true, true)
	local ks_pos = CreateClientConVar("ks_position", config.DefaultPosition, true, true)
	local ply = LocalPlayer() 
	
	concommand.Add( "ks_test", function() -- test function, remove later or set to superadmin
		if not LocalPlayer():IsSuperAdmin() then print("You are not a super admin") end 
		DisplayKilledFrame("[Clan] TestPlayer", ROLE_TRAITOR, false)
	end )

	net.Receive( "SendDeathData", function( len, ply )
		-- Recieve the server data that this guy died
		if not ks_toggle:GetBool() then return end -- Enabled checker
		
		local tab = net.ReadTable()
		-- (Person who killed the local player, their role, *boolean* IsPlayer, custom avatar for suicide)
		DisplayKilledFrame(tab.killer, tab.role, tab.selfrole, tab.ply, tab.avatar)
	end)
	-- Create our fonts 
	surface.CreateFont( "KS_KilledBy", {
	font = "Arial",
	size = 30,
	italic = true, 
	shadow = true,
	weight = 1000,
	antialias = true,
} )
	surface.CreateFont( "KS_Name", {
	font = "Arial",
	size = 40,
	weight = 1500,
	antialias = true,
} )
	surface.CreateFont( "KS_TimeAlive", {
	font = "Arial",
	size = 20,
	weight = 400,
	antialias = true,
} )

	local PANEL = {} -- Create our custom panel, this is the background + avatar
	function PANEL:Init()
		local w = 500
		local h = 100
		self:SetSize( w, h )
		self:Center()
	end
	function PANEL:Avatar(ply, bool)
		if bool or ply == LocalPlayer() then
			-- NOTE: After the new Gmod update fixes AvatarImage, set the resolution higher
			self.Avatar = vgui.Create( "AvatarImage", self )
			self.Avatar:SetPos( 7, 7 )
			self.Avatar:SetSize(84, 84)
			self.Avatar:SetPlayer(ply, 64) 
		else
			self.Avatar = vgui.Create("DImage", self)
			self.Avatar:SetImage( config.OtherDeathImg )
			self.Avatar:SetPos( 7, 7 )
			self.Avatar:SetSize(84,84)
		end
	end
	function PANEL:Friend(ply, bool)
		if not bool then return end
		if not config.ShowFriendStatus then return end
		
		local fr = ply:GetFriendStatus()
		if fr == "friend" then
			local Friend = vgui.Create( "DImage", self )
			Friend:SetPos( 105, 55 )
			Friend:SetImage( "icon16/group.png" ) 
			Friend:SizeToContents()  
		elseif fr == "blocked" then
			local Friend = vgui.Create( "DImage", self )
			Friend:SetPos( 105, 55 )
			Friend:SetImage( "icon16/delete.png" ) 
			Friend:SizeToContents()  
		elseif fr == "requested" then
			local Friend = vgui.Create( "DImage", self )
			Friend:SetPos( 105, 55 )
			Friend:SetImage( "icon16/group_add.png" )
			Friend:SizeToContents()  
		else
			return
		end
	end
	function PANEL:IsAdmin(ply, bool)
		if not bool then return end
		if not config.ShowAdminStatus then return end
		
		if ply:IsSuperAdmin() then 
			local Admin = vgui.Create( "DImage", self )
			Admin:SetPos( 105, 75 )
			Admin:SetImage( "icon16/star.png" )
			Admin:SizeToContents()  
		elseif ply:IsAdmin() then
			local Admin = vgui.Create( "DImage", self )
			Admin:SetPos( 105, 75 )
			Admin:SetImage( "icon16/shield.png" )
			Admin:SizeToContents() 
		else
			return
		end
	end
	function PANEL:Paint( w, h )
		draw.RoundedBox( 0, 0, 0, w, h, config.Color_Background ) -- Panel BG
		if config.AvatarHighlight then
			draw.RoundedBox( 0, 5, 5, 87, 87, config.Color_AvatarHighlight ) -- Avatar highlight]
		end
	end
	
	local RANDINFO = {} -- Create the alive timer section
	function RANDINFO:Init()
		local w = 500 
		local h = 20
		
		self:SetSize( w, h ) 
		self:Center()
	end
	function RANDINFO:Paint( w, h )
		draw.RoundedBox( 0, 0, 0, w, h, config.Color_RandomInfo )
	end
	
	
	local KILLNAME = {} -- Create the name of the killer
	function KILLNAME:SetFont(font)
		self.Font = font
	end
	function KILLNAME:SetText(text)
		self.Text = text
	end
	function KILLNAME:SetColor(role)
		-- Role based coloring
		if role == ROLE_TRAITOR then
			self.Color = Color(230,50,50)
		elseif role == ROLE_DETECTIVE then
			self.Color = Color(52, 152, 219)
		elseif role == ROLE_INNOCENT then
			self.Color = Color(50, 210, 50)
		else
			self.Color = Color(200, 200, 50)
		end
	end
	function KILLNAME:Paint()
		surface.SetTextColor(self.Color)
		surface.SetFont(self.Font)
		surface.SetTextPos(0, 0)
		surface.DrawText(self.Text)
	end
	
	-- Register all this as Vgui elements
	vgui.Register( "KS_Panel", PANEL )
	vgui.Register( "KS_Namer", KILLNAME )
	vgui.Register( "KS_Info", RANDINFO )

	
	function DisplayKilledFrame(killer, role, selfrole, isply, ava) 
		if not ks_toggle:GetBool() then return end
		
		local Frame = vgui.Create("KS_Panel") -- Create our panel
			-- Frame position related math
			local x = (ScrW() / 2) - (Frame:GetWide() / 2)
			local y
			local c = string.lower(GetConVarString("ks_position"))
			if c == "top" then
				y = 50
			elseif c == "bottom" then
				y = (ScrH() - Frame:GetTall()) - 50
			elseif c == "center" then
				y = (ScrH() / 2) - (Frame:GetTall() / 2)
			else
				y = 50 -- Not valid? Revert to the Top position
			end
		Frame:SetPos(x, y)
		Frame:Avatar(ava or killer, isply)
		Frame:Friend(killer, isply)
		Frame:IsAdmin(killer, isply)
		
		local Info = vgui.Create("KS_Info")
		local fX, fY = Frame:GetPos()
		Info:SetPos( fX, fY + Frame:GetTall()) 
		
		local label1 = vgui.Create("DLabel", Frame)
		label1:SetPos(100,15) 
		label1:SetColor(Color(255,255,255)) 
		label1:SetFont("KS_KilledBy")
		label1:SetText("You were killed by ") 
		label1:SizeToContents()
		
		local name = vgui.Create("KS_Namer", Frame)
		name:SetPos(130,50)
		name:SetSize(345,50)
		name:SetColor(role) 
		name:SetFont("KS_Name") 
		name:SetText(killer) 
		name:SizeToContents()
		
		-- Grab integer from first spawn, subtract by current time, convert to minutes:seconds format
		local t = string.ToMinutesSeconds(  CurTime() - ply:GetNWInt("KS_LiveTime")  )
		minsec = string.Explode( ":", t ) -- Create a table with 1 being Minutes and 2 being Seconds
		local min, sec = math.Round(minsec[1]), minsec[2] -- Convert these into variables
		-- And then send them on their way! 
		
		local wepinfo = vgui.Create("DLabel", Info)
		wepinfo:SetPos(10,0) 
		wepinfo:SetColor(Color(255,255,255)) 
		wepinfo:SetFont("KS_TimeAlive")
		local types = { -- Random info to spout when the player dies
		"You dealt "..ply:GetNWInt("KS_DamageDealt").." damage during the round!",
		"You survived for "..min.." minute(s) and "..sec.." seconds!",
		"You picked up weapons "..ply:GetNWInt("KS_PickedUpGuns").." time(s) this round!",
		}
		
		-- Role based death messages
		if selfrole == ROLE_TRAITOR then
			table.insert(types, "You murdered "..ply:GetNWInt("KS_InnoKilled",0).." Innocent(s)!")
		else
			table.insert(types, "You ended the lives of "..ply:GetNWInt("KS_TraitorKilled",0).." Traitor(s) during the round!")
		end

		wepinfo:SetText(types[math.random(#types)])
		wepinfo:SizeToContents()
		
		-- Disappear like Houdini
		timer.Simple(ks_timer:GetFloat(), function()
			-- Animations here
			Frame:SetVisible(false)
			Info:SetVisible(false)
		end)
	end
end
]]


