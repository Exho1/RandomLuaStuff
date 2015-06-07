if SERVER then
	AddCSLuaFile( "weapon_ttt_finalcloak.lua" )
end

-- TODO: Make a bar for the cloak time, fix the message not displaying on injury uncloak, and maybe just do it over again.

if( CLIENT ) then
    SWEP.PrintName = "Cloaking Device";
    SWEP.Slot = 7;
    SWEP.DrawAmmo = false;
    SWEP.DrawCrosshair = false;
	
	SWEP.Icon = "vgui/ttt/exho_cloak.png"
 
   SWEP.EquipMenuData = {
      type = "item_weapon",
      desc = [[Makes you invisible for a
	 short period of time]]
   };
   
end

SWEP.Base = "weapon_tttbase"
SWEP.Spawnable= false
SWEP.AdminSpawnable= true
SWEP.HoldType = "normal"
 
SWEP.Kind = WEAPON_EQUIP2
SWEP.CanBuy = {ROLE_TRAITOR}

SWEP.ViewModelFOV= 60
SWEP.ViewModelFlip= false
SWEP.ViewModel      = "models/weapons/v_slam.mdl"
SWEP.WorldModel      = ""
SWEP.Secondary.Delay= 0.5
SWEP.Secondary.Recoil= 0
SWEP.Secondary.Damage= 0
SWEP.Secondary.NumShots= 1
SWEP.Secondary.Cone= 0
SWEP.Secondary.ClipSize= -1
SWEP.Secondary.DefaultClip= -1
SWEP.Secondary.Automatic   = false

-- Cloak variables 
SWEP.Cloaked = false 
SWEP.Notes = ""
-- Edit these below, not the above ones
SWEP.CloakTime = 25
SWEP.CloakSound = "buttons/button1.wav"
SWEP.CloakPowerCoolDown = 6
SWEP.CloakDamageCooldown = 2
SWEP.NextUnCloak = 1
SWEP.NextCloak = 1
SWEP.ThirdPer = false


function SWEP:PrimaryAttack()
	exhoweaponself = self
	-- NOTE TO FUTURE SELF, IN ORDER TO FIX THIS CALL THE FUNCTIONS WITH A SEMICOLON INSTEAD OF APERIOD
	
	if self.Owner:GetNWBool("IsCloaked") == false then
		self:Cloak(self.Owner, self)	
	end
	self.AllowDrop = false
end

function SWEP:SecondaryAttack()
	if self.Owner:GetNWBool("IsCloaked") == true then
		self:UnCloak(self.Owner, self, "Cloak Off" )
	end
	self.AllowDrop = true
end
 


function SWEP:Cloak( ply, weapon )
	ply:SetNWBool( "IsCloaked", true)
	ply:SetColor( Color(255, 255, 255, 3) ) 			
	ply:SetMaterial( "sprites/heatwave" )
	self:Notify( ply, "Cloak On" )
	sound.Play(self.CloakSound, ply:GetPos(), 70, 100)
	ply:DrawShadow(false)
	weapon:SetNextSecondaryFire(CurTime()+self.NextUnCloak)
	ply:ConCommand("ttt_set_disguise 1")
		
	if self.ThirdPer == true then
		ply:ConCommand("thirdperson")
	end	
		
	timer.Create( "CloakingTime", self.CloakTime, 1, function()
		self:UnCloak( ply, weapon, "Out of power!" )
		weapon:SetNextPrimaryFire(CurTime()+self.CloakPowerCoolDown)
	end)
end


function SWEP:UnCloak( ply, weapon, args )
	
	ply:SetNWBool( "IsCloaked", false)
	timer.Destroy( "CloakingTime")
	ply:SetMaterial("models/glass")
	self:Notify( ply, args)
	sound.Play(self.CloakSound, ply:GetPos(), 70, 100)
	ply:DrawShadow(true)
	exhoweaponself:SetNextPrimaryFire(CurTime()+self.NextCloak)
	ply:ConCommand("ttt_set_disguise 0")
	
	if self.ThirdPer == true then
		ply:ConCommand("firstperson")
	end
end

function SWEP:Notify( ply, args )
	ply:SetNWBool("CloakDraw", true)
	self.Notes = tostring(args)
	
	timer.Create("Remove", 3, 1, function()
		self.Notes = ""
		-- I probably should've used a SWEP variable instead of a networked boolean since this is all clientside.
		ply:SetNWBool("CloakDraw", false)
	end)
end

function SWEP:DrawHUD()
	if LocalPlayer():GetNWBool("CloakDraw") == true then
		local w = ScrW()
		local h = ScrH()
		local x_axis, y_axis, width, height = w/2-w/14, h/2.8, w/7, h/20
		draw.RoundedBox(2, x_axis, y_axis, width, height, Color(10,10,10,200))
		draw.SimpleText(self.Notes, "Trebuchet24", w/2, h/2.8 + height/2, Color(255,255,255,255), 1, 1)
	end
end

function SWEP:Deploy()

end

--[[

hook.Add("DoPlayerDeath", "DeathUnCloak", function(ply)
	if ply:GetNWBool("IsCloaked") == true then
		exhoweaponself:UnCloak(ply, self, "Your cloak was destroyed!")
		timer.Destroy("CloakingTime")
	end
end)

-- This uncloaks properly but does not display the message
hook.Add("PlayerHurt", "DamageUnCloak", function(ply)
	if ply:GetNWBool("IsCloaked") == true then
		timer.Destroy("CloakingTime")
		exhoweaponself:UnCloak(ply, exhoweaponself, "Your cloak is damaged!!")
		exhoweaponself:SetNextPrimaryFire(CurTime()+self.CloakDamageCooldown)
	end
end)

hook.Add("TTTPrepareRound", "UnCloakAll",function()
    for k, v in pairs(player.GetAll()) do
        v:SetMaterial("models/glass")
		timer.Destroy( "CloakingTime")
		v:SetNWBool("IsCloaked", false)
    end
end)
]]


