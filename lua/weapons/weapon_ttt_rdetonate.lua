if SERVER then
   AddCSLuaFile( "shared.lua" )
   
end
 
SWEP.HoldType                   = "slam"
 
   SWEP.PrintName = "Remote Detonator"
if CLIENT then
   SWEP.Slot = 6
 
   SWEP.ViewModelFOV = 10
 
   SWEP.EquipMenuData = {
      type = "item_weapon",
      desc = "Primary: Plant bomb on player or\na corpse.\n\nSecondary: Trigger explosive."
   };
 
   SWEP.Icon = "VGUI/ttt/icon_splode"
end
 
 
SWEP.Base = "weapon_tttbase"
 
SWEP.ViewModel = "models/weapons/v_crowbar.mdl"
SWEP.WorldModel = "models/weapons/w_defuser.mdl"

SWEP.DrawCrosshair              = false
SWEP.Secondary.Damage         	= 400
SWEP.Primary.ClipSize           = -1
SWEP.Primary.DefaultClip        = -1
SWEP.Primary.Automatic          = true
SWEP.Primary.Delay = 0.15
SWEP.Primary.Ammo               = "none"
SWEP.Secondary.ClipSize         = -1
SWEP.Secondary.DefaultClip      = -1
SWEP.Secondary.Automatic        = true
SWEP.Secondary.Ammo             = "none"
SWEP.Secondary.Delay = 0.1
 
SWEP.Kind = WEAPON_EQUIP
SWEP.CanBuy = {ROLE_TRAITOR} -- only traitors can buy
SWEP.WeaponID = AMMO_DEFUSER
SWEP.LimitedStock = true -- only buyable once
 
 
--SWEP.AllowDrop = false
 
local sou = Sound("Weapon_TMP.Clipin")
local sou2 = Sound("Default.PullPin_Grenade")
 
local function tWarn(ent,armed)
  umsg.Start("c4_warn", GetTraitorFilter(true))
  umsg.Short(ent:EntIndex())
  umsg.Bool(armed)
  umsg.Vector(ent:GetPos())
  umsg.Float(0)
  umsg.End()
end
 
function SWEP:PrimaryAttack()
        if not IsValid(self.Owner) then return end
   self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
   if self.attach then return false end
   if SERVER and self.Owner:GetNWBool('disguised',false) == true and string.len(self.Owner:GetNWString('disgas','')) > 0 then self.Owner:ConCommand('ttt_set_disguise 0') end
        if SERVER and _rdm then
                local stid = self.Owner:SteamID()
                if not _rdm.shotsFired[stid] then _rdm.shotsFired[stid] = {} end
                table.insert(_rdm.shotsFired[stid],CurTime())
        end
        if SERVER and ShootLog then ShootLog(Format("WEAPON:\t %s [%s] planted a %s", self.Owner:Nick(), self.Owner:GetRoleString(), self.Weapon:GetClass())) end
 
   local spos = self.Owner:GetShootPos()
   local sdest = spos + (self.Owner:GetAimVector() * 120)
        if self.Owner.LagCompensation then -- for some reason not always true
      self.Owner:LagCompensation(true)
   end
   local tr = util.TraceLine({start=spos, endpos=sdest, filter=self.Owner, mask=MASK_SHOT})
   if not tr.Entity or not IsValid(tr.Entity) then return end
        if IsValid(tr.Entity) and tr.Entity:GetClass() == "player" then
                if SERVER then
                        local ply = tr.Entity
                        if not self.attach then
                                self.attach = ply:UniqueID()
                                self.atype = 'ply'
                                sound.Play(sou,ply:GetPos(),40)
                                if tWarn then tWarn(ply,true) end
                        end
                end
        elseif IsValid(tr.Entity) and tr.Entity:GetClass() == "prop_ragdoll" and tr.Entity.player_ragdoll then
                if SERVER then
                        local rag = tr.Entity
                        if not self.attach then
                                self.attach = rag.uqid
                                self.atype = 'rag'
                                sound.Play(sou,rag:GetPos(),40)
                                if tWarn then tWarn(rag,true) end
                        end
                end
        elseif IsValid(tr.Entity) and tr.Entity:GetClass() == 'ttt_health_station' then
                if SERVER then
                        tr.toexp = self.Owner
                        self.attach = tr.Entity:EntIndex()
                        self.atype = 'hs'
                        sound.Play(sou,tr.Entity:GetPos(),40)
                        if tWarn then tWarn(tr.Entity,true) end
                end
        end
        if self.attach then
                self.planted = CurTime()
                self.Owner:ChatPrint("Planted!")
                self.Owner:AnimPerformGesture(ACT_GMOD_GESTURE_ITEM_GIVE)
        end
        self.Weapon:SetNextPrimaryFire( CurTime() + (self.Primary.Delay * 2) )
        if self.Owner.LagCompensation then
      self.Owner:LagCompensation(false)
   end
end
 
function SWEP:Detonate(v,t)
        if SERVER and self.Owner:GetNWBool('disguised',false) == true and string.len(self.Owner:GetNWString('disgas','')) > 0 then self.Owner:ConCommand('ttt_set_disguise 0') end
        if SERVER and _rdm then
                local stid = self.Owner:SteamID()
                if not _rdm.shotsFired[stid] then _rdm.shotsFired[stid] = {} end
                table.insert(_rdm.shotsFired[stid],CurTime())
        end
        if SERVER and ShootLog then ShootLog(Format("WEAPON:\t %s [%s] detonated a %s", self.Owner:Nick(), self.Owner:GetRoleString(), self.Weapon:GetClass())) end
        local pos = v:GetPos()
        local effect = EffectData()
        effect:SetStart(pos)
        effect:SetOrigin(pos)
        local rad = 240
        local dmg = 400
        effect:SetScale(rad * 0.3)
        effect:SetRadius(rad)
        effect:SetMagnitude(dmg)
        util.Effect("Explosion", effect, true, true)
        local ent = ents.Create("weapon_ttt_remote")
        util.BlastDamage(ent, self.Owner, pos, rad, dmg)
        ent:Remove()
end
 
function SWEP:SecondaryAttack()
        if SERVER then
                if self.planted and CurTime()-self.planted < 1 then return end
                if self.attach and self.attach != -1 then
                        if self.atype == 'hs' then
                                for k,v in pairs(ents.FindByClass('ttt_new_hp')) do
                                        if v:EntIndex() == self.attach then
                                                self.attach = -1
                                                sound.Play(Sound("Default.PullPin_Grenade"),v:GetPos())
                                                --timer.Simple(2, function()
                                                        if tWarn then tWarn(v,false) end
                                                        self:Detonate(v,1)
                                                        self:Remove()
                                                --end)
                                                break
                                        end
                                end
                        else
                                for _, v in ipairs( player.GetAll() ) do
                                        if v:UniqueID() == self.attach then
                                                if not v:Alive() then
                                                        for _, v2 in ipairs( ents.FindByClass("prop_ragdoll") ) do
                                                                if IsValid(v2) then
                                                                        if v2.player_ragdoll and v2.uqid == self.attach then
                                                                                self.attach = -1
                                                                                sound.Play(sou2,v2:GetPos())
                                                                                --timer.Simple(2, function()
                                                                                        if tWarn then tWarn(v,false) tWarn(v2,false) end
                                                                                        self:Detonate(v2,1)
                                                                                        self:Remove()
                                                                                --end)
                                                                                break
                                                                        end
                                                                end
                                                        end
                                                else
                                                        self.attach = -1
                                                        sound.Play(sou2,v:GetPos())
                                                        --timer.Simple(2, function()
                                                                if tWarn then tWarn(v,false) end
                                                                self:Detonate(v,2)
                                                                self:Remove()
                                                        --end)
                                                end
                                                return true
                                        end
                                end
                        end
                end
        end
   self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
   self.Weapon:SetNextSecondaryFire( CurTime() + 0.1 )
end
 
 
if CLIENT then
   function SWEP:Initialize()
      //self:AddHUDHelp("defuser_help", nil, true)
                self.attach = nil
      return self.BaseClass.Initialize(self)
   end
 
   function SWEP:DrawWorldModel()
      if not IsValid(self.Owner) then
         self:DrawModel()
      end
   end
end
 
function SWEP:Reload()
   return false
end
 
function SWEP:Deploy()
   if SERVER and IsValid(self.Owner) then
      self.Owner:DrawViewModel(false)
   end
   return true
end
 
 
function SWEP:OnDrop()
end