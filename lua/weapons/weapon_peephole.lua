if SERVER then
	AddCSLuaFile()
end

SWEP.PrintName 			= "Peep hole placer"
SWEP.Author				= "Exho"
SWEP.Contact			= ""
SWEP.Purpose			= ""
SWEP.Instructions		= ""

SWEP.Slot				 = 3
SWEP.SlotPos			 = 1
SWEP.DrawAmmo 			 = true
SWEP.DrawCrosshair 		 = true
SWEP.HoldType			 = "ar2"
SWEP.Spawnable			 = true
SWEP.AdminSpawnable		 = true

SWEP.Primary.Ammo        = "none"
SWEP.Primary.Delay       = 0.1
SWEP.Primary.ClipSize    = 1
SWEP.Primary.ClipMax     = 1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Automatic	 = false

SWEP.ViewModel           = "models/weapons/v_pistol.mdl"
SWEP.WorldModel          = "models/weapons/w_pistol.mdl"
SWEP.ViewModelFlip		= false

function SWEP:PrimaryAttack()
	local spos = self.Owner:GetShootPos()
	local sdest = spos + (self.Owner:GetAimVector() * 70)
	
	local data = {}
	data.start = self.Owner:GetShootPos()
	data.endpos = data.start + (self.Owner:GetAimVector() * 70)
	data.filter = self.Owner
	
	local tr = util.TraceLine( data )
	
	local door = tr.Entity
	
	if IsValid( door ) and isDoor( door ) then
		print("Is door")
		self.Owner.door = door
	end
end

function SWEP:SecondaryAttack()
	
end

if CLIENT then
	surface.CreateFont( "debugfont", {
		font = "Arial",
		size = 20,
		weight = 500,
		antialias = true,
	} )

end

local phone = Material( "vgui/gphone/gphone.png" )
hook.Add( "PostDrawOpaqueRenderables", "ViewModelInfo", function()
	local client = LocalPlayer()
	
	if IsValid(client.door) then
		local door = client.door
		
		local center = door:OBBCenter()
		local fwd = door:GetForward()
		--print(center)
		local pos = door:GetPos() + Vector( fwd.x * 3, fwd.y * 3, 20 ) + center
		local dAng = door:GetAngles()
		local ang = Angle( 0, dAng.y + 90, 90 )
		local dAng = door:GetAngles()
		
		-- Start drawing 
		cam.Start3D2D(pos, ang, 1)
			surface.SetDrawColor( color_white )
			surface.SetMaterial( phone ) 
			surface.DrawTexturedRect( -5, 0, 10, 10 )
			
			--[[local CamData = {}
			CamData.angles = ang
			CamData.origin = pos
			
			local localPos = pos:ToScreen()
			CamData.x = localPos.x
			CamData.y = localPos.y
			CamData.w = 10
			CamData.h = 1
			
			render.RenderView( CamData )]]
		cam.End3D2D()
	end
end)

function isDoor( ent )
	local class = ent:GetClass()
	
	local doors = {
		"func_door",
		"func_door_rotating",
		"prop_door_rotating",
	}
	
	for _, type in pairs( doors ) do
		if class == type then
			return true
		end
	end
end




