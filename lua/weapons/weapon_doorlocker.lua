if SERVER then
	AddCSLuaFile()
end

-- The Sandbox version of my TTT Door Locker. 

SWEP.PrintName 			= "Door Locker"
SWEP.Author				= "Exho"
SWEP.Contact			= ""
SWEP.Purpose			= ""
SWEP.Instructions		= "Left click to lock door, right click to unlock door!\n\nShoot the doors down to destroy them"
SWEP.Category			 = "Door Locker" 

SWEP.Slot				= 3
SWEP.SlotPos			 = 1
SWEP.DrawAmmo 			= true
SWEP.DrawCrosshair 		= true
SWEP.HoldType			 = "normal"
SWEP.Spawnable			 = true
SWEP.AdminSpawnable		 = true

SWEP.Primary.Ammo        = "none"
SWEP.Primary.Delay       = 2 
SWEP.Secondary.Delay     = 2
SWEP.Primary.ClipSize    = 5
SWEP.Primary.ClipMax     = 5
SWEP.Primary.DefaultClip = 5
SWEP.Primary.Automatic	 = false

SWEP.ViewModel           = "models/weapons/v_pistol.mdl"
SWEP.WorldModel          = "models/weapons/w_pistol.mdl"
SWEP.ViewModelFlip		 = false


SWEP.DoorHealth = 300 
SWEP.LockRange = 80 -- In Source Units
SWEP.LockTime = 30
SWEP.CooldownTime = 10
local DoorLock 			= true -- Do the doors automatically unlock?
local DoorBreak 			= true -- Do the doors break?

function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end
	self:SetNextPrimaryFire(CurTime()+self.Primary.Delay)
	self:SetNextSecondaryFire(CurTime()+self.Secondary.Delay)
	
	local pos = self.Owner:GetShootPos()
	local ang = self.Owner:GetAimVector()
	local tracedata = {}
	tracedata.start = pos
	tracedata.endpos = pos+(ang*self.LockRange)
	tracedata.filter = self.Owner
	local trace = util.TraceLine(tracedata)
	
	local door = trace.Entity
	if DCheck( door, self.Owner ) then
		
		if SERVER then -- I decided to do this instead of using SWEP delays. 
			if door:GetNWBool("DoorCooldown") then
				local timel = timer.TimeLeft(door:EntIndex() .. "_CoolDown")
				local timel = math.Round( math.Clamp(timel, 0, self.CooldownTime))
				self.Owner:ChatPrint("This door is cooling down for " .. timel .. " more seconds!")
				return false
			end 
		end
		
		if not door:GetNWBool("SBLocked") then
			self:TakePrimaryAmmo(1)
			
			if SERVER then
				door:SetNWString("SBDoorOwner", self.Owner) -- Sets the locker of that specific door
				door:EmitSound( "doors/door_metal_medium_close1.wav" )
				door:Fire("lock", "", 0)
				door:SetNWBool("SBLocked", true) 
				local prehealth = self.DoorHealth 
				door:SetNWInt(door:EntIndex() .. "_health", prehealth)
				math.Clamp(door:GetNWInt(door:EntIndex() .. "_health"), 0, self.DoorHealth)
				self.Owner:ChatPrint("Door locked!") 
				
				if DoorLock == true then
					timer.Create(door:EntIndex() .. "DoorLockedTime", self.LockTime, 1, function()
						door:Fire( "unlock", "", 0 )
						door:EmitSound( "doors/door1_move.wav" )
						door:SetNWBool("SBLocked", false)
						door:GetNWString("SBDoorOwner"):ChatPrint("One of your doors has unlocked due to time!")					
						door:SetNWString("SBDoorOwner", nil)
						timer.Destroy(door:EntIndex() .. "DoorLockedTime")
					end)
					door:SetNWFloat("LockedUntil", CurTime() + self.LockTime) -- Used for the DrawHUD timer
				end
			end
		elseif door:GetNWBool("SBLocked") then
			if SERVER then
				self.Owner:ChatPrint("This door is already locked!")
			end
		end
	end
end

function SWEP:SecondaryAttack()
	-- Allows the player to unlock their door
	if not self:CanSecondaryAttack() then return end
	self:SetNextPrimaryFire(CurTime()+self.Primary.Delay)
	
	local pos = self.Owner:GetShootPos()
	local ang = self.Owner:GetAimVector()
	local tracedata = {}
	tracedata.start = pos
	tracedata.endpos = pos+(ang* (self.LockRange * 1.5))
	tracedata.filter = self.Owner
	local trace = util.TraceLine(tracedata)
	
	local door = trace.Entity
	
	if (door:GetNWBool("SBLocked") == true and DCheck( door, self.Owner ) ) then
		local locker = door:GetNWString("SBDoorOwner")
		local wannabe = self.Owner
		
		if SERVER then
			if ( locker == wannabe and IsValid(locker) ) then 
				locker:ChatPrint("Door Unlocked!")
				door:SetNWBool("SBLocked", false)
				door:EmitSound( "buttons/latchunlocked2.wav" )
				door:Fire( "unlock", "", 0 )
				timer.Destroy(door:EntIndex() .. "DoorLockedTime")
				
				door:SetNWBool("DoorCooldown", true)
				timer.Create(door:EntIndex() .. "_CoolDown", self.CooldownTime, 1, function()
					door:SetNWBool("DoorCooldown", false)
					-- You lock then unlock a door and it will have to cool down for a short time before being used again.
					-- This is to prevent exploting of health with it
				end)
			elseif (locker ~= wannabe and IsValid(locker) ) then
				wannabe:ChatPrint("This is not your door to unlock!")
				locker:ChatPrint(Format("%s has tried to unlock your door!", wannabe:Nick() ))
			end
		end
	end
end

function SWEP:DrawHUD()
	local tr = self.Owner:GetEyeTrace() -- Simplified trace because I dont care about distance
	local door = tr.Entity
	if door:GetNWBool("SBLocked") then
		local timeleft = math.Clamp(  door:GetNWFloat("LockedUntil", 0)-CurTime(), 0, self.LockTime  )
		local timeleft = math.Round(timeleft,1)
		local owner = door:GetNWString("SBDoorOwner")
		local dhealth = door:GetNWInt(door:EntIndex() .. "_health")
		self.DrawCrosshair = false -- Hides the crosshair to make things look neater
		
		local w = ScrW()
		local h = ScrH()
		local x_axis, y_axis, width, height = w/2-w/14, h/2.8, w/7, h/20
		draw.RoundedBox(2, x_axis, y_axis, width , height, Color(10,10,10,200)) -- Onscreen stuff
		draw.SimpleText("Door locked by " ..owner:Nick(), "Trebuchet24", w/2, h/2.8 + height/2, Color(255, 40, 40,255), 1, 1)
		draw.RoundedBox(2, x_axis, y_axis * 1.3, width, height * 2, Color(10,10,10,200))
		draw.SimpleText("Health: "..dhealth, "Trebuchet24", w/2, h/2.8 + height*2.6, Color(255, 255, 255), 1, 1) 
		if DoorLock == true then
			draw.SimpleText("Unlocks in: "..timeleft, "Trebuchet24", w/2, h/2.8 + height*3.5, Color(255, 255, 255), 1, 1)
		end
	else
		self.DrawCrosshair = true -- Shows the crosshair again
	end
end

-- Runs the entity through a series of checks to make sure its the right type of door
function DCheck( prop, ply )
	if not IsValid( prop ) then print("[Debug]: " .. tostring(prop) .. " is not valid" ) return false end
	-- Do NOT check if the player is valid, it causes issues with the Entity Damage function
	
	 -- These types will not work because they cannot recieve a health value no matter what I try
	local b_list = { "func_door", "func_door_rotating" }
	local object = prop:GetClass()
	
	for h, i in pairs(b_list) do 
		if (object == "prop_door_rotating" and IsValid(prop) and object ~= i) then 
			return true
		elseif object == i then
			if SERVER then
				ply:ChatPrint("This door is incompatible with the Locker!")
				print("[Debug]: Player tried to use blacklisted door " .. tostring(i) )
				print("[Debug]: Send these to Exho if you have questions")
			end
			return false
		end
	end 
end

if SERVER then
	local function Sparkify( ent )
		-- Who doesnt like a little pyrotechnics eh?
		ent:EmitSound( "physics/wood/wood_crate_break3.wav" )
		local effectdata = EffectData()
		effectdata:SetOrigin( ent:GetPos() + ent:OBBCenter() )
		effectdata:SetMagnitude( 5 )
		effectdata:SetScale( 2 )
		effectdata:SetRadius( 5 )
		util.Effect( "Sparks", effectdata )
	end
	-- This could probably go in autorun too; it checks if the door needs to be destroyed.
	function DoorTakeDamage( prop, dmginfo )
		if ( DCheck( prop ) and prop:GetNWBool("SBLocked") ) then
			local doorhealth = prop:GetNWInt(prop:EntIndex() .. "_health")
			local dmgtaken = dmginfo:GetDamage()
			
			prop:SetNWInt(prop:EntIndex() .. "_health", doorhealth - dmgtaken)
			
			if doorhealth <= 0 then
				local d_own = prop:GetNWString("SBDoorOwner") 
				d_own:ChatPrint("One of your doors has been destroyed!")
				
				prop:Fire( "unlock", "", 0 )
				timer.Destroy(prop:EntIndex() .. "DoorLockedTime")
				timer.Destroy(prop:EntIndex() .. "_CoolDown")
				prop:SetNWBool("SBLocked", false) 
				if DoorBreak == false then 
					prop:Fire( "unlock", "", 0 )
					prop:Fire( "open", "", 0 )
					Sparkify(prop)
				else
					-- Now we create a prop version of the door to be knocked down for looks
					local dprop = ents.Create( "prop_physics" )
					dprop:SetCollisionGroup(COLLISION_GROUP_WEAPON) -- This
					dprop:SetMoveType(MOVETYPE_VPHYSICS) -- This
					dprop:SetSolid(SOLID_BBOX) -- And this, prevent against the prop from clipping horribly into the wall
					dprop:SetPos( prop:GetPos() + Vector(0, 0, 2))
					dprop:SetAngles( prop:GetAngles() ) 
					dprop:SetModel( prop:GetModel() )
					dprop:SetSkin( prop:GetSkin() ) -- This makes sure the doors are identical
					-- Removes the actual door and spawns the prop, might have to switch them around
					prop:Remove()
					dprop:Spawn()
					Sparkify(dprop)
				end
			end
		end
	end
	hook.Add("EntityTakeDamage","BreachAndClear2",DoorTakeDamage)
end
