if SERVER then
    AddCSLuaFile() 
end

if CLIENT then
    SWEP.PrintName = "NAME"
    SWEP.Slot = 7
    SWEP.DrawAmmo = true
    SWEP.DrawCrosshair = false
       
    SWEP.Icon = "vgui/ttt/icon_rock"
 
	SWEP.EquipMenuData = {
      type = "item_weapon",
      desc = ""
   };
end
 
SWEP.Author              = "Exho"
SWEP.HoldType            = "normal"
SWEP.Base                = "weapon_tttbase"
SWEP.Kind                = WEAPON_EQUIP
SWEP.CanBuy              = { ROLE_TRAITOR }

SWEP.Primary.Ammo        = "none"
SWEP.Primary.Delay       = 2
SWEP.Secondary.Delay     = 2
SWEP.Primary.ClipSize    = -1
SWEP.Primary.ClipMax     = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic   = false
SWEP.AllowDrop			 = false

SWEP.Spawnable           = true
SWEP.AdminSpawnable      = true
SWEP.AutoSpawnable       = false
SWEP.ViewModel           = "models/weapons/v_pistol.mdl"
SWEP.WorldModel          = "models/weapons/w_crowbar.mdl"
SWEP.ViewModelFlip       = false
SWEP.LimitedUse 		 = true

function SWEP:PrimaryAttack()
	
end

function SWEP:SecondaryAttack()
	
end

function SWEP:Reload()

end
