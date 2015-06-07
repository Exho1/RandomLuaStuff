if SERVER then
	AddCSLuaFile()
	util.AddNetworkString( "DisguiseDestroyed" )
	util.AddNetworkString( "PD_ChatPrint" ) 
end


---- Prop Disguiser ----
-- Redone by Exho - based off Jonascone's SWEP 
-- V: 9/20/14	


SWEP.PrintName 			= "Prop Disguiser"
SWEP.Author				= "Exho and Jonascone"
SWEP.Contact			= ""
SWEP.Purpose			= ""
SWEP.Instructions		= "Left Click to disguise. \nRight click to undisguise.\nReload to choose new prop"
SWEP.Category			= "Prop Disguiser" 

SWEP.Slot				= 3
SWEP.SlotPos			= 1
SWEP.HoldType			= "normal"
SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true
SWEP.AutoSpawnable 		= false
SWEP.ViewModel          = "models/weapons/v_pistol.mdl"
SWEP.WorldModel         = "models/weapons/w_pistol.mdl"
SWEP.ViewModelFlip		= false

------ CONFIGURATION ------
SWEP.Primary.Delay 		= 2 -- Time limit after undisguising until next disguise
SWEP.Secondary.Delay	= 2 -- The exact opposite of that ^

SWEP.DisguiseProp 		= Model("models/props_c17/oildrum001.mdl") -- Default disguise model
SWEP.DisguiseTime 		= 25 -- How long, seconds, for the player to be disguised
SWEP.DisguiseHealth 	= 50 -- Health for the disguised prop to have. Works with about half the models

SWEP.MaxRadius			= 100 -- Max radius of a chosen prop. If its bigger than the player cannot use it
SWEP.MinRadius			= 5 -- Min radius of a chosen prop
------ //END CONFIGURATION//------

SWEP.Prop				= nil
SWEP.Disguised			= false
SWEP.AllowDrop			= true

-- Put the Model Names of props that pass the criteria but you dont want anyone to use. Seperate each string WITH a comma
-- Example of a model path would be "models/props_junk/wood_crate001a.mdl" 
SWEP.Blacklist = {

}

local function PD_Msg(txt, ply)
	if SERVER then
			net.Start("PD_ChatPrint")
				net.WriteString(txt)
			net.Send(ply)
	end
end

function SWEP:PrimaryAttack()
	local ply = self.Owner
	
	if not self:GetNWBool("PD_WepDisguised") then
		if IsValid(self.Prop) then self.Prop:Remove() end -- Just in case the prop already exists
		ply:SetNWBool("PD_Disguised", true)
		self:SetNextPrimaryFire(CurTime()+self.Primary.Delay)
		self:PropDisguise() -- The main attraction, disguise
	else
		PD_Msg("You are already disguised.", ply)
		return
	end
end

function SWEP:SecondaryAttack()
	if self:GetNWBool("PD_WepDisguised") then 
		self.Owner:SetNWBool("PD_Disguised", false)
		self:SetNextSecondaryFire(CurTime()+self.Secondary.Delay)
		self:PropUnDisguise() 
	end
end

function SWEP:Reload()
	if self:GetNWBool("PD_WepDisguised") then -- If you are a prop, the trace 'hits' your entity. 
		PD_Msg("You can't choose a new model while disguised, silly", ply)
		return
	else
		self:ModelHandler()
	end
end

function SWEP:PropDisguise()
	local ply = self.Owner
	if self:GetNWBool("PD_WepDisguised") then print("HOW DID YOU GET THIS FAR??") return end -- Cant be too careful!
	--self.Disguised = true
	self:SetNWBool("PD_TimeOut", false)
	if not IsValid(ply) or not ply:Alive() then print("Player aint valid, yo") return end
	
	if SERVER then
		-- Undisguise after the time limit
		timer.Create(ply:SteamID().."_DisguiseTime", self.DisguiseTime, 1, function() 
			self:SetNWBool("PD_TimeOut", true)
			self:SetNextPrimaryFire(CurTime()+self.Primary.Delay + 5) -- Small delay after timer going out
			self:PropUnDisguise() 
		end)
		self.AllowDrop = false
		ply:SetNWFloat("PD_TimeLeft", CurTime() + self.DisguiseTime) -- Clientside timer
		ply:SetNWBool("PD_Disguised", true) -- Shared - player disguised
		self:SetNWBool("PD_WepDisguised", true)
		
			self.Prop = ents.Create("prop_physics") -- Create our disguise
			local prop = self.Prop
		prop:SetModel(self.DisguiseProp)
		local ang = ply:GetAngles()
		ang.x = 0 -- The Angles should always be horizontal
		prop:SetAngles(ang)
		prop:SetPos(ply:GetPos() + Vector(0,0,20))
		prop.fakehp = self.DisguiseHealth -- Using our own health value
		prop.plyhp = ply:Health()
		prop.hp_constant = self.DisguiseHealth
		ply:SetHealth(50) -- This is the prop's health but displayed as their own
		prop.IsADisguise = true -- Identifier for our prop
		prop.TiedPly = ply -- The Master
		prop:SetName(ply:Nick().."'s Disguised Prop") -- Prevent spectator possessing if TTT
		ply.DisguisedProp = prop
		
		prop:Spawn()
	
		local phys = prop:GetPhysicsObject()
		if not IsValid(phys) then return end
		phys:SetVelocity(ply:GetVelocity())
		
		-- Spectate it
		ply:Spectate(OBS_MODE_CHASE)
		ply:SpectateEntity(self.Prop)
		ply:SelectWeapon(self:GetClass())
		ply:SetRenderMode(RENDERMODE_NONE) -- Fixes the player showing above the object
		ply:DrawViewModel(false)
		ply:DrawWorldModel(false)
		
		PD_Msg("Enabled Prop Disguise!", ply)
	end
end

function SWEP:PropUnDisguise()
	local ply = self.Owner
	local prop = self.Prop
	
	if IsValid(self.Prop) and IsValid(self.Owner) and self:GetNWBool("PD_WepDisguised") then
		prop.IsADisguise = false
		self.AllowDrop = true
		ply:SetNWFloat("PD_TimeLeft", 0)
		ply:SetNWBool("PD_Disguised", false)
		self:SetNWBool("PD_WepDisguised", false)
		
		timer.Destroy(ply:SteamID().."_DisguiseTime")
		
		ply:UnSpectate()
		ply:Spawn() -- We have to spawn before editing anything
		
		ply:SetRenderMode(RENDERMODE_NORMAL)
		ply:SetAngles(prop:GetAngles())
		ply:SetPos(prop:GetPos())
		ply:SetHealth( prop.plyhp ) -- Clamp health, explanation below
		ply:SetVelocity(prop:GetVelocity())
		ply:DrawViewModel(true)
		ply:DrawWorldModel(true)
		ply:SelectWeapon(self:GetClass())
		prop:Remove() -- Banish our prop
		prop = nil
		
		local tout = self:GetNWBool("PD_TimeOut", true)
		if tout then
			PD_Msg("Timer ran out and you were undisguised! This weapon will cooldown for 5 seconds", ply)
		else
			PD_Msg("Disabled Prop Disguise!", ply)
		end
	end
end

local seen 
function SWEP:ModelHandler()
	local ply = self.Owner -- Ply is a lot easier to type
	local tr = ply:GetEyeTrace()
	local ent = tr.Entity
	
	if seen then return end -- To prevent chat spamming of messages
	seen = true
	timer.Simple(1, function() seen = false end)
	
	if ent:IsPlayer() or ent:IsNPC() or ent:GetClass() == "prop_ragdoll" or tr.HitWorld or ent:IsWeapon() then
		PD_Msg("That entity is not a prop.", ply)
		return
	elseif IsValid(ent) then -- The PROP is valid
		if string.sub( ent:GetClass(), 1, 5 ) ~= "prop_" then -- The last check
			PD_Msg("That entity is not a valid prop", ply)
			return
		end
		-- This entity IS a prop without a shadow of a doubt.
		for CANT, EVEN in pairs(self.Blacklist) do
			if ent:GetModel() == EVEN then
				print("I LITERALLY CANT EVEN")
				PD_Msg("That model is blacklisted, sorry.", ply)
				return
			end
		end
		
		local mdl = ent:GetModel()
		local rad = ent:BoundingRadius() 
		if rad < self.MinRadius then -- All self explanatory
			PD_Msg("That model is too small!", ply)
			return
		elseif rad > self.MaxRadius then
			PD_Msg("That model is too big!", ply)
			return
		else -- If its not a bad prop, choose it.
			self.DisguiseProp = mdl
			PD_Msg("Set Disguise Model to ("..mdl..")!", ply)
		end
	end
end

function SWEP:DrawHUD()
	local ply = self.Owner
	local propped = ply:GetNWBool("PD_Disguised")
	local disguised = self:GetNWBool("PD_WepDisguised")
	
	--print(disguised, propped)
	if disguised and propped then
		local w = ScrW()
		local h = ScrH()
		local x_axis, y_axis, width, height = 800, 98, 320, 54
		draw.RoundedBox(2, x_axis, y_axis, width, height, Color(10,10,10,200))
	
		local timeleft = ply:GetNWFloat("PD_TimeLeft") - CurTime() -- Subtract (float + Cur) from Cur
		timeleft = math.Round(timeleft or 0, 1) -- Round for simplicity
		timeleft = math.Clamp(timeleft, 0, self.DisguiseTime) -- Clamp to prevent negatives
		
		local Segments = width / self.DisguiseTime -- Divide the width into the timer 
		local CountdownBar = timeleft * Segments -- Bar length 
		CountdownBar = math.Clamp(CountdownBar, 3, 320)

		draw.RoundedBox(2, x_axis, y_axis, CountdownBar, height, Color(52, 152, 219,200))
		draw.SimpleText(timeleft, "Trebuchet24", x_axis + 160, y_axis + 27, Color(255,255,255,255), 1, 1)
	end
end

local function DeathHandler(ply, inflictor, att)
	if ply:GetNWBool("PD_Disguised") then
		if IsValid(ply.DisguisedProp) then
			ply.DisguisedProp:Remove() -- If the player is disguised, remove their disguise.
		end
	end
end

local function DamageHandler( ent, dmginfo ) -- Entity Take Damage
	-- Damage method copied from my Destructible Doors and Door Locker addons
	if ent.IsADisguise and SERVER and IsValid(ent.TiedPly) then
		local ply = ent.TiedPly
		
		local dbug_mdl = ent:GetModel()
		local h = ent.fakehp 
		local dmg = dmginfo:GetDamage()
		ent.fakehp = h - (dmg) -- Artificially take damage for the prop
		ent.hp_constant = ent:Health() -- Make sure this stays updated
		if ent.fakehp <= 0 then 
			net.Start("DisguiseDestroyed")
			net.Send(ply) -- Tell the client to draw our fancy messages
			
			ply:Kill() -- Kill the player
			
				local effectdata = EffectData() -- EFFECTS!
			effectdata:SetOrigin( ent:GetPos() + ent:OBBCenter() )
			effectdata:SetMagnitude( 5 )
			effectdata:SetScale( 2 )
			effectdata:SetRadius( 5 )
			util.Effect( "Sparks", effectdata )
			ent:Remove() -- Remove the disguise
		else
			-- Sometimes the Prop's defined Health is lower than what it should be, so it gets destroyed early. 
			-- This is a fix for it
			timer.Simple(0.5, function() -- Wait a little bit
				if not IsValid(ent) and ply:GetNWBool("PD_Disguised") then 
					-- Player is disguised but the disguise doesnt exist anymore
					print("[Prop Disguise Debug]")
					print(ply:Nick().." used wonky prop ("..dbug_mdl..") and was automatically killed!")
					print("Recommended you add this prop to the blacklist")
					ply:Kill() -- Kill the player
					net.Start("DisguiseDestroyed")
					net.Send(ply)
				end
			end)
		end
	end
end
hook.Add("EntityTakeDamage","CauseGodModeIsOP", DamageHandler)
hook.Add("PlayerDeath","EntDestroyeronDeath", DeathHandler)

if CLIENT then
	local white = Color( 255, 255, 255 )
	local PropDisguiseCol = Color(52, 152, 219)
	
	net.Receive( "DisguiseDestroyed", function( len, ply ) -- Recieve the message
		chat.AddText( PropDisguiseCol, "Prop Disguiser: ", white, 
		"Your disguise was destroyed and you were ",  Color( 170, 0, 0 ), "KILLED",white,"!!")
	end)
	
	net.Receive( "PD_ChatPrint", function( len, ply ) -- Recieve the message
		local txt = net.ReadString()
		chat.AddText( PropDisguiseCol, "Prop Disguiser: ", white, txt)
	end)
end