if SERVER then 
	AddCSLuaFile()
	resource.AddFile( "materials/effects/vampiresplatter.vtf" )
	resource.AddFile( "materials/effects/vampiresplatter.vmt" )
end

-- Todo: Add a convar to this and TTT to enable/disable sucking health while at the cap

SWEP.PrintName 			= "Vampire"
SWEP.Author				= "Exho"
SWEP.Contact			= ""
SWEP.Purpose			= ""
SWEP.Instructions		= "Left click to steal health\nRight click to give"
SWEP.Category			 = "The Vampire" 

SWEP.Slot				 = 3
SWEP.SlotPos			 = 1
SWEP.DrawAmmo 		   	 = false
SWEP.DrawCrosshair 		 = true
SWEP.HoldType			 = "knife"
SWEP.Spawnable			 = true
SWEP.AdminSpawnable		 = true

SWEP.UseHands			= true
SWEP.ViewModelFlip		= false
SWEP.ViewModelFOV		= 54
SWEP.ViewModel          = "models/weapons/cstrike/c_knife_t.mdl"
SWEP.WorldModel         = "models/weapons/w_knife_t.mdl"

SWEP.DrawCrosshair     	    = false
SWEP.Primary.Damage         = 0
SWEP.Primary.ClipSize       = -1
SWEP.Primary.DefaultClip    = -1
SWEP.Primary.Automatic      = true
SWEP.Primary.Ammo           = "none"
SWEP.Secondary.ClipSize     = -1
SWEP.Secondary.DefaultClip  = -1
SWEP.Secondary.Automatic    = true
SWEP.Secondary.Ammo         = "none"
SWEP.DeploySpeed            = 2


-- These are used for the delay times in between healing and giving
SWEP.Primary.Delay = 0.4
SWEP.Secondary.Delay = 0.4
SWEP.Draining = false -- Dont touch this

-- * Config * --
SWEP.VampRange = 100 -- How many units from the player's eyes that you can do the vampirism thingy
SWEP.MaxHealth = 125 -- Limit on health
SWEP.HealthRate = 5 -- How much health is taken per cycle

local function CanVamp( ent )
	if not IsValid(ent) then return false end
	if ent:IsPlayer() or ent:IsNPC() then
		return true
	else
		return false end
end

function SWEP:PrimaryAttack()
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )
	
	-- Traces a line from the players shoot position to 100 units
	local pos = self.Owner:GetShootPos()
	local ang = self.Owner:GetAimVector()
	local tracedata = {}
	tracedata.start = pos
	tracedata.endpos = pos+( ang * self.VampRange)
	tracedata.filter = self.Owner
	local trace = util.TraceLine(tracedata)

	local target = trace.Entity
	if (not trace.HitWorld and CanVamp(target)) then
		self.Draining = true
		local selfH = self.Owner:Health()
		local targetH = target:Health()
		
		if selfH ~= self.MaxHealth then
			local rate = self.HealthRate
			local amount = math.random(rate - 2, rate + 2) -- A random value just cause
			
			-- In order to show up in dmg logs, this actually hurts the player
			if SERVER then
				local dmginfo = DamageInfo()
				dmginfo:SetDamage( amount )
				dmginfo:SetDamageType( DMG_SLASH ) 
				dmginfo:SetAttacker(self.Owner ) 
				dmginfo:SetInflictor(self)
				dmginfo:SetDamagePosition(self:GetPos())
		
				target:TakeDamageInfo(dmginfo)
			end
		
		-- Gives health to the player who held the Vampire up to the max limit
			self.Owner:SetHealth(math.Clamp(self.Owner:Health() + amount, 0,self.MaxHealth ) )
		else
			self.Owner:ChatPrint("You have reached the max amount of health!")
		end
	
	else
		self.Draining = false
	end
end

-- Does the same thing as the Primary attack except this time it allows you to give health
function SWEP:SecondaryAttack()
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )
	
	-- Traces a line from the players shoot position to 100 units
	local pos = self.Owner:GetShootPos()
	local ang = self.Owner:GetAimVector()
	local tracedata = {}
	tracedata.start = pos
	tracedata.endpos = pos+( ang * self.VampRange)
	tracedata.filter = self.Owner
	local trace = util.TraceLine(tracedata)

	local target = trace.Entity
	if (not trace.HitWorld and CanVamp(target)) then
		self.Draining = true
		local selfH = self.Owner:Health()
		local targetH = target:Health()
			
		if targetH ~= self.MaxHealth then
			local rate = self.HealthRate
			local amount = math.random(rate - 2, rate + 2)	
		-- Slightly modified from the Primary attack to give health 
			target:SetHealth(math.Clamp(target:Health() + amount, 0, self.MaxHealth ))
			self.Owner:SetHealth(selfH - amount)
		else
			self.Owner:ChatPrint("Your friend has reached the max amount of health!")
		end
	else
		self.Draining = false
	end
end

function SWEP:DrawHUD()
	if self.Draining == true then
		-- Yet another trace because the health needs to be accurate and up to date
		-- Its probably inefficient to trace this much, oh well
		local pos = self.Owner:GetShootPos()
		local ang = self.Owner:GetAimVector()
		local tracedata = {}
		tracedata.start = pos
		tracedata.endpos = pos+( ang * self.VampRange)
		tracedata.filter = self.Owner
		local trace = util.TraceLine(tracedata)
		local target = trace.Entity
	
		if (not trace.HitWorld and CanVamp(target)) then
			local selfH = self.Owner:Health()
			local targetH = target:Health()
			-- Making sure the health box doesn't go out of the bounds of the regular box
			if targetH > 100 then
				targetH = 100
			end

			-- Health bar
			local w = ScrW()
			local h = ScrH()
			local x_axis, y_axis, width, height = w/2-w/21, h/2.8, w/11, h/20
			draw.RoundedBox(2, x_axis, y_axis, width, height, Color(10,10,10,200))
			draw.RoundedBox(2, x_axis, y_axis, width * (targetH / 100), height, Color(192,57,43,200))
			draw.SimpleText(target:Health(), "Trebuchet24", w/2, h/2.8 + height/2, Color(255,255,255,255), 1, 1)
			
			-- Blood splatter stuff
			local splatter = surface.GetTextureID( "effects/vampiresplatter" );
 
			local BoxSize = 128
			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.SetTexture( splatter )
			surface.DrawTexturedRect( x_axis - 60, y_axis - 50, BoxSize, BoxSize )
			
		else
			self.Draining = false
		end
	end
end


function SWEP:Equip()
   self.Weapon:SetNextPrimaryFire( CurTime() + (self.Primary.Delay * 1.5) )
   self.Weapon:SetNextSecondaryFire( CurTime() + (self.Secondary.Delay * 1.5) )
end

function SWEP:OnRemove()
   if CLIENT and IsValid(self.Owner) and self.Owner == LocalPlayer() and self.Owner:Alive() then
      RunConsoleCommand("lastinv")
   end
end


