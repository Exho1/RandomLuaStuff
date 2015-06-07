if SERVER then
	AddCSLuaFile()
end


SWEP.PrintName 			= "Crowbar"
SWEP.Author				= "Exho"
SWEP.Contact			= ""
SWEP.Purpose			= ""
SWEP.Instructions		= ""

SWEP.Slot				= 3
SWEP.SlotPos			 = 1
SWEP.DrawAmmo 			= true
SWEP.DrawCrosshair 		= true
SWEP.HoldType			 = "melee"
SWEP.Spawnable			 = true
SWEP.AdminSpawnable		 = true

SWEP.Primary.Ammo        = "none"
SWEP.Primary.Delay       = 0.1
SWEP.Secondary.Delay     = 2
SWEP.Primary.ClipSize    = 5
SWEP.Primary.ClipMax     = 5
SWEP.Primary.DefaultClip = 5
SWEP.Primary.Automatic	 = false

SWEP.ViewModel 			= "models/weapons/c_crowbar.mdl"
SWEP.WorldModel 		= "models/weapons/w_crowbar.mdl"
SWEP.ViewModelFlip		= false

SWEP.ShowViewModel = false
SWEP.DrawViewModel = false

SWEP.ShowViewModel = false
SWEP.ShowWorldModel = true
SWEP.ViewModelBoneMods = {}


function SWEP:PrimaryAttack()
	if CLIENT then
		self.Owner:SetAnimation( PLAYER_ATTACK1 )
	end
	
	self.Weapon:SendWeaponAnim( ACT_VM_MISSCENTER )
end

function SWEP:SecondaryAttack()
	if CLIENT then
		self.Owner:SetAnimation( PLAYER_ATTACK1 )
	end
	
	self.Weapon:SendWeaponAnim( ACT_VM_HITCENTER )
end

