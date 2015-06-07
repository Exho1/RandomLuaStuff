if SERVER then
	AddCSLuaFile()
end


SWEP.PrintName 			= "Lightning Hands"
SWEP.Author				= "Exho"
SWEP.Contact			= ""
SWEP.Purpose			= ""
SWEP.Instructions		= ""
SWEP.Category			 = "Exho" 

SWEP.Slot				= 3
SWEP.SlotPos			 = 1
SWEP.DrawAmmo 			= true
SWEP.DrawCrosshair 		= true
SWEP.HoldType			 = "knife"
SWEP.Spawnable			 = true
SWEP.AdminSpawnable		 = true

SWEP.Primary.Ammo        = "none"
SWEP.Primary.Delay       = 0.1
SWEP.Secondary.Delay     = 2
SWEP.Primary.ClipSize    = 5
SWEP.Primary.ClipMax     = 5
SWEP.Primary.DefaultClip = 5
SWEP.Primary.Automatic	 = false

SWEP.ViewModel          	= "models/weapons/cstrike/c_knife_t.mdl"
SWEP.WorldModel        		= "models/weapons/w_knife_t.mdl"
SWEP.ViewModelFlip		= false

function SWEP:PrimaryAttack()
	if CLIENT then
		hook.Add( "PostDrawOpaqueRenderables", "tstasdfasdfad", function()
			local m = Material( "cable/physbeam" )
			render.SetMaterial( m )
			
			local pos = LocalPlayer():GetShootPos() - Vector( 0, 0, 20 )
			local endPos = pos + (LocalPlayer():GetForward() * 100)
			
			
			drawLightning( pos, endPos, 10, 3 )
		end)
	end
end

function SWEP:SecondaryAttack()
	if CLIENT then
		hook.Remove( "PostDrawOpaqueRenderables", "tstasdfasdfad")
	end
end

-- ROBOTBOYYYYYY
function drawLightning( start, endpos, deviations, power )
	local segments = {
		{ start, endpos }
	}
	for i=0, power do
		local newsegs = {}
		for id, seg in pairs( segments ) do
			local mid = Vector( (seg[1].x + seg[2].x) / 2, (seg[1].y + seg[2].y) / 2, (seg[1].z + seg[2].z) / 2 )
			local right = (start - endpos):Angle():Right()
			local up = (start - endpos):Angle():Up()
			local offsetpos = mid + right * math.random( -deviations, deviations ) + up * math.random( -deviations, deviations )
			table.insert( newsegs, {seg[1], offsetpos} )
			table.insert( newsegs, {offsetpos, seg[2]} )
		end
		segments = newsegs
	end
	for id, seg in pairs( segments ) do
		render.DrawBeam( seg[1], seg[2], 5, 0, seg[1]:Distance(seg[2]) / 25, Color( 255, 255, 255 ) )
	end
end

function SWEP:PreDrawViewModel( vm, ply, wep )
	vm:SetMaterial( "engine/occlusionproxy" )
end

function SWEP:PostDrawViewModel( vm, ply, wep )
	vm:SetMaterial()
end




