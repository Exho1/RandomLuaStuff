if SERVER then
	AddCSLuaFile()
end


SWEP.PrintName 			= "Strike"
SWEP.Author				= "Exho"
SWEP.Contact			= ""
SWEP.Purpose			= ""
SWEP.Instructions		= ""
SWEP.Category			 = "Exho" 

SWEP.Slot				= 3
SWEP.SlotPos			 = 1
SWEP.DrawAmmo 			= true
SWEP.DrawCrosshair 		= true
SWEP.HoldType			 = "ar2"
SWEP.Spawnable			 = true
SWEP.AdminSpawnable		 = true

SWEP.Primary.Ammo        = "none"
SWEP.Primary.Delay       = 0.1
SWEP.Secondary.Delay     = 2
SWEP.Primary.ClipSize    = 5
SWEP.Primary.ClipMax     = 5
SWEP.Primary.DefaultClip = 5
SWEP.Primary.Automatic	 = false

SWEP.ViewModel 			= "models/weapons/v_RPG.mdl"
SWEP.WorldModel 		= "models/weapons/w_rocket_launcher.mdl"
SWEP.ViewModelFlip		= false

SWEP.Fired = false
SWEP.HitPos = nil
SWEP.SkyPos = nil
local Fired = false
local HitPos = nil
local SkyPos = nil

function SWEP:PrimaryAttack()
	self.Fired = true
	Fired = true
	
	local pos = self.Owner:GetShootPos()
	local ang = self.Owner:GetAimVector()
	local tracedata = {}
	tracedata.start = pos
	tracedata.endpos = pos+(ang*5000)
	tracedata.filter = self.Owner
	local trace = util.TraceLine(tracedata)
	
	self.HitPos = trace.HitPos
	HitPos = self.HitPos
	
	print(self.HitPos)
	if self.HitPos then
		local pos = HitPos
		local ang = Vector(0,0,90)
		local tracedata = {}
		tracedata.start = pos
		tracedata.endpos = pos+(ang*5000)
		local trace = util.TraceLine(tracedata)
		
		self.SkyPos = trace.HitPos - Vector(0,0,100)
		SkyPos = self.SkyPos
		print(self.SkyPos)
		
		if self.SkyPos.z - self.HitPos.z < 1000 then
			print("Too short") 
			Fired = false
			return 
		end
		
		timer.Create("StrikeExploder", 5, 1, function()
			if SERVER then
				if Fired then
					local expl = ents.Create("env_explosion")
					expl:SetPos(HitPos)
					expl:SetKeyValue("iMagnitude","700")
					expl:SetKeyValue("iRadiusOverride", 500)
					expl:Spawn()
					expl:Activate()
					expl:Fire("explode", "", 0)
					expl:Fire("kill","",0)
					Fired = false
				end
			else
				Fired = false
			end
		end)
	end
end

function SWEP:SecondaryAttack()
	Fired = false
	self.Fired = false
end

if CLIENT then
	local ID = Material( "cable/redlaser" )
	hook.Add( "PostDrawOpaqueRenderables", "tstasdfasdfad", function()
		if not Fired then return end
		
		--render.DrawLine( HitPos, SkyPos, Color(255,0,0), false )
		
		render.SetMaterial( ID )
		render.DrawBeam( HitPos, SkyPos, 30, 0, 3, Color(255,255,255) )
		--Vector startPos, Vector endPos, number width, number textureStart, number textureEnd, table color )
		
		local effectdata = EffectData()
		effectdata:SetOrigin( HitPos )
		effectdata:SetMagnitude( 1 )
		effectdata:SetScale( 2 )
		effectdata:SetRadius( 3 )
		util.Effect( "Sparks", effectdata )
		
		local effectdata = EffectData()
		effectdata:SetOrigin( HitPos )
		effectdata:SetMagnitude( 1 )
		effectdata:SetScale( 2 )
		effectdata:SetRadius( 3 )
		util.Effect( "Impact", effectdata )
	end)
end





