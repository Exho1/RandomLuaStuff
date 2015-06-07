AddCSLuaFile()

SWEP.HoldType			= "ar2"

if CLIENT then
   SWEP.PrintName			= "M16"
   SWEP.Slot				= 2

   SWEP.Icon = "vgui/ttt/icon_m16"
end

SWEP.Base				= "weapon_tttbase"
SWEP.Spawnable = true

SWEP.Kind = WEAPON_HEAVY
SWEP.WeaponID = AMMO_M16

SWEP.Primary.Delay			= 0.19
SWEP.Primary.Recoil			= 1.6
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "Pistol"
SWEP.Primary.Damage = 23
SWEP.Primary.Cone = 0.018
SWEP.Primary.ClipSize = 20
SWEP.Primary.ClipMax = 60
SWEP.Primary.DefaultClip = 60 -- default 20
SWEP.AutoSpawnable      = true
SWEP.AmmoEnt = "item_ammo_pistol_ttt"

SWEP.UseHands			= true
SWEP.ViewModelFlip		= false
SWEP.ViewModelFOV		= 64
SWEP.ViewModel			= "models/weapons/cstrike/c_rif_m4a1.mdl"
SWEP.WorldModel			= "models/weapons/w_rif_m4a1.mdl"

SWEP.Primary.Sound = Sound( "Weapon_M4A1.Single" )

SWEP.IronSightsPos = Vector(-7.58, -9.2, 0.55)
SWEP.IronSightsAng = Vector(2.599, -1.3, -3.6)

if CLIENT then
	surface.CreateFont( "VMFont", {
	font = "PCap Terminal",
	size = 30,
	weight = 500,
	antialias = true,
} )

end

function SWEP:SetZoom(state)
   if CLIENT then return end
   if not (IsValid(self.Owner) and self.Owner:IsPlayer()) then return end
   if state then
      self.Owner:SetFOV(35, 0.5)
   else
      self.Owner:SetFOV(0, 0.2)
   end
end

-- Add some zoom to ironsights for this gun
function SWEP:SecondaryAttack()
   if not self.IronSightsPos then return end
   if self:GetNextSecondaryFire() > CurTime() then return end

   bIronsights = not self:GetIronsights()

   self:SetIronsights( bIronsights )

   if SERVER then
      self:SetZoom( bIronsights )
   end

   self:SetNextSecondaryFire( CurTime() + 0.3 )
end

function SWEP:PreDrop()
   self:SetZoom(false)
   self:SetIronsights(false)
   return self.BaseClass.PreDrop(self)
end

function SWEP:Reload()
	local ply = self.Owner
    if (self:Clip1() == self.Primary.ClipSize or
        self.Owner:GetAmmoCount(self.Primary.Ammo) <= 0) then
       return
    end
	
    self:DefaultReload(ACT_VM_RELOAD)
    self:SetIronsights(false)
    self:SetZoom(false)

	local function GetTextSize(text, font)
		surface.SetFont(font)
		local width, height = surface.GetTextSize(text)
		return width, height
	end

	hook.Add( "PostDrawOpaqueRenderables", "ViewModelInfo", function()
		local client = LocalPlayer()
		
		local gun = client:GetActiveWeapon()
		if not IsValid(gun) then return end
		local vm = client:GetViewModel()
		local muzzle = vm:LookupAttachment( "muzzle" )
		muzzle = vm:GetAttachment( muzzle or 0 )
		if muzzle == nil then return end
		
		local pos = muzzle.Pos + Vector(0,0,5)
		local eyeang = LocalPlayer():EyeAngles().y - 90
		local ang = Angle( 0, eyeang, 90 )
		
		local width, height = GetTextSize(gun:GetPrintName(), "VMFont")
			
		-- Start drawing 
		cam.Start3D2D(pos, ang, 0.1)
				surface.SetDrawColor( 255,255, 255, 255)
			
				draw.DrawText( gun:GetPrintName(), "VMFont", -width/2, 20 , Color(255,255,0,255), TEXT_ALIGN_RIGHT )
		cam.End3D2D()
	end)
	
	timer.Simple(2, function()
		hook.Remove( "PostDrawOpaqueRenderables", "ViewModel2222")
	end)
end

function SWEP:Holster()
   self:SetIronsights(false)
   self:SetZoom(false)
   return true
end
