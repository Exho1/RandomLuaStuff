if SERVER then
	AddCSLuaFile()
end

SWEP.HoldType = "normal"


if CLIENT then
   SWEP.PrintName = "ied"
   SWEP.Slot = 6

   SWEP.ViewModelFOV = 10

   SWEP.EquipMenuData = {
      type = "item_weapon",
      desc = [[dfa
	  ]]
   };

   SWEP.Icon = "vgui/ttt/"
end

SWEP.Base = "weapon_tttbase"

SWEP.ViewModel          = "models/weapons/v_crowbar.mdl"
SWEP.WorldModel         = ""

SWEP.DrawCrosshair      = false
SWEP.Primary.ClipSize       = -1
SWEP.Primary.DefaultClip    = -1
SWEP.Primary.Automatic      = true
SWEP.Primary.Ammo       = "none"
SWEP.Primary.Delay = 1.0

SWEP.Secondary.ClipSize     = -1
SWEP.Secondary.DefaultClip  = -1
SWEP.Secondary.Automatic    = true
SWEP.Secondary.Ammo     = "none"
SWEP.Secondary.Delay = 1.0

SWEP.Kind = WEAPON_EQUIP
SWEP.CanBuy = {ROLE_TRAITOR} 
SWEP.LimitedStock = true 

SWEP.AllowDrop = false

SWEP.NoSights = true
SWEP.Case = nil

function SWEP:OnDrop()
   self:Remove()
end

function SWEP:PrimaryAttack()
   self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
   self:HealthDrop()
end
function SWEP:SecondaryAttack()
   self.Weapon:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )
   print("Secondary fire")
   for k, v in pairs ( ents.FindByClass( "ttt_iedbomb") ) do	
		if v:GetNWEntity("Owner") == self.Owner then
			v.Detonated = true
			print("Detonated")
		end
	end	
end

local throwsound = Sound( "Weapon_SLAM.SatchelThrow" )

-- ye olde droppe code
function SWEP:HealthDrop()
   if SERVER then
      local ply = self.Owner
      if not IsValid(ply) then return end

      if self.Planted then return end

      local vsrc = ply:GetShootPos()
      local vang = ply:GetAimVector()
      local vvel = ply:GetVelocity()
      
      local vthrow = vvel + vang * 100

      local case = ents.Create("ttt_iedbomb")
      if IsValid(case) then
		self.Case = case
        case:SetPos(vsrc + vang * 10)
        case:Spawn()
		case:SetPlacer(ply)
		case:SetNWEntity("Owner", self.Owner)
	
        case:PhysWake()
        local phys = case:GetPhysicsObject()
        if IsValid(phys) then
            phys:SetVelocity(vthrow)
        end   

        self.Planted = true
      end
   end

   self.Weapon:EmitSound(throwsound)
   self.Planted = true
   self.AllowDrop = true
end

function SWEP:DrawHUD()
	local w = ScrW()
	local h = ScrH()
	local x_axis, y_axis, width, height = w/2-w/14, h/2.8, w/7, h/20
	if self.Planted == true then
		draw.RoundedBox(2, x_axis, y_axis, width , height, Color(10,10,10,200))
		draw.SimpleText("Right Click to detonate the IED!", "Trebuchet24", w/2, h/2.8 + height/2, Color(255,255,255,255), 1, 1)
		self.AllowDrop = true
	else
		draw.RoundedBox(2, x_axis, y_axis, width , height, Color(10,10,10,200))
		draw.SimpleText("Left Click to drop the IED!", "Trebuchet24", w/2, h/2.8 + height/2, Color(255,255,255,255), 1, 1)
	end
	
end


function SWEP:Reload()
   return false
end

function SWEP:OnRemove()
   if CLIENT and IsValid(self.Owner) and self.Owner == LocalPlayer() and self.Owner:Alive() then
      RunConsoleCommand("lastinv")
   end
end



function SWEP:Deploy()
   if SERVER and IsValid(self.Owner) then
      self.Owner:DrawViewModel(false)
   end
   return true
end

function SWEP:DrawWorldModel()
end

function SWEP:DrawWorldModelTranslucent()
end

