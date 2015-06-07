
AddCSLuaFile()

if CLIENT then

   SWEP.PrintName = "Zombie Infector"
   SWEP.Slot = 6

   SWEP.ViewModelFOV  = 54
   SWEP.ViewModelFlip = false

   SWEP.EquipMenuData = {
      type = "item_weapon",
      desc = "d"
   };


   SWEP.Icon = "vgui/ttt/h"
end

SWEP.Base = "weapon_tttbase"
SWEP.Primary.Recoil	= 4
SWEP.Primary.Damage = 7
SWEP.Primary.Delay = 1.0
SWEP.Primary.Cone = 0.01
SWEP.Primary.ClipSize = 4
SWEP.Primary.Automatic = false
SWEP.Primary.DefaultClip = 4
SWEP.Primary.ClipMax = 4

SWEP.HoldType = "pistol"

SWEP.Kind = WEAPON_EQUIP
SWEP.CanBuy = {ROLE_TRAITOR} 
SWEP.LimitedStock = true 

SWEP.UseHands			= true
SWEP.ViewModel	= Model("models/weapons/c_357.mdl")
SWEP.WorldModel	= Model("models/weapons/w_357.mdl")

SWEP.Primary.Sound = Sound( "Weapon_USP.SilencedShot" )



function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

	if not self:CanPrimaryAttack() then return end
	self:EmitSound( self.Primary.Sound )
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self:TakePrimaryAmmo( 1 )
	
	--http://wiki.garrysmod.com/page/NPC/AddEntityRelationship
	
end

function SWEP:SecondaryAttack()
end
