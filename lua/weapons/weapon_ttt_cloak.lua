if SERVER then
    AddCSLuaFile() 
end

if CLIENT then
    SWEP.PrintName = "Cloaking Device"
    SWEP.Slot = 7
    SWEP.DrawAmmo = false
    SWEP.DrawCrosshair = false
       
    SWEP.Icon = "vgui/ttt/exho_cloak.png"
 
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
SWEP.ViewModel           = "models/weapons/v_slam.mdl"
SWEP.WorldModel          = ""
SWEP.ViewModelFlip       = false
SWEP.LimitedUse 		 = true

SWEP.CloakTime = 25
SWEP.CloakSound = "buttons/button1.wav"
SWEP.CloakPowerCoolDown = 6
SWEP.CloakDamageCooldown = 2
SWEP.NextUnCloak = 1
SWEP.NextCloak = 1
SWEP.ThirdPer = false

SWEP.Cloaked = false
SWEP.CloakedPly = nil
SWEP.Notes = nil

local plymeta = FindMetaTable( "Player" )
function plymeta:IsCloaked()
	return self:GetNWBool("IsCloaked", false)
end

function SWEP:PrimaryAttack()
	if not self.Owner:IsCloaked() then
		self:Cloak()	
	end
	self.AllowDrop = false
end

function SWEP:SecondaryAttack()
	if self.Owner:IsCloaked() then
		self:UnCloak("Cloak disabled!")
	end
	self.AllowDrop = true
end

function SWEP:Cloak()
	local ply = self.Owner
	
	ply:SetNWBool( "IsCloaked", true)
	self.Cloaked = true
	self.CloakedPly = ply
	
	self:TellEm("Cloak enabled!")
	
	ply:SetColor( Color(255, 255, 255, 1) ) 			
	ply:SetMaterial( "sprites/heatwave" )
	sound.Play(self.CloakSound, ply:GetPos(), 70, 100)
	
	ply:DrawShadow(false)
	self:SetNextSecondaryFire(CurTime()+self.NextUnCloak)
	ply:ConCommand("ttt_set_disguise 1")

	if self.ThirdPer == true then
		ply:ConCommand("thirdperson")
	end	
		
	timer.Create( "CloakingTime", self.CloakTime, 1, function()
		if self.Cloaked then
			self:UnCloak( "Out of power!" )
		end
	end)
end

function SWEP:UnCloak(text)
	local ply = self.Owner
	
	ply:SetNWBool( "IsCloaked", false)
	self.Cloaked = false
	self.CloakedPly = nil
	
	timer.Destroy( "CloakingTime")
	ply:SetMaterial("models/glass")
	sound.Play(self.CloakSound, ply:GetPos(), 70, 100)
	ply:DrawShadow(true)
	self:SetNextPrimaryFire(CurTime()+self.NextCloak)
	ply:ConCommand("ttt_set_disguise 0")
	
	if self.ThirdPer == true then
		ply:ConCommand("firstperson")
	end
end

local seen = false
function SWEP:TellEm(args)
	if CLIENT then
		if seen then return end
		
		chat.AddText(Color(231, 56, 60),
		"[Traitor HQ]",
		Color(255,255,255),
		": ",
		args)
		seen = true
		timer.Simple(0.5, function() seen = false end)
	end
end

function plymeta:TellEm(args)
	if CLIENT then
		if seen then return end
		
		chat.AddText(Color(231, 56, 60),
		"[Traitor HQ]",
		Color(255,255,255),
		": ",
		args)
		seen = true
		timer.Simple(0.5, function() seen = false end)
	end
end

function SWEP:Reload()

end

-- Clientside messages dont work in these server only hooks
hook.Add("DoPlayerDeath", "DeathUnCloak", function(ply)
	if ply:IsCloaked() then
		local wep = ply:GetActiveWeapon()
		wep:UnCloak() 
	end
end)
hook.Add("PlayerHurt", "DamageUnCloak", function(ply)
	if ply:IsCloaked() then
		local wep = ply:GetActiveWeapon()
		wep:UnCloak()
	end
end)

hook.Add("TTTPrepareRound", "UnCloakAll",function()
    for k, v in pairs(player.GetAll()) do
		timer.Destroy( "CloakingTime")
		v:SetNWBool("IsCloaked", false)
    end
end)






