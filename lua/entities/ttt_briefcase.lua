if SERVER then 
	AddCSLuaFile("ttt_briefcase.lua") 
	--CreateConVar("ttt_briefcaseammo", 15, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE},"How much ammo the Briefcase holds.")
	-- Use the variable on line 26
end

if not LANG then return end

if CLIENT then
   -- To be honest, I have no idea if this even works but it was in the Health Station code so...
   ENT.Icon = "vgui/ttt/exho_briefcase.png"
   ENT.PrintName = "Briefcase"

   local GetPTranslation = LANG.GetParamTranslation

   ENT.TargetIDHint = {
      name = "Briefcase",
      hint = "Drops ammo and stuff",
      fmt  = function(ent, txt)
                return 
                                       { usekey = Key("+use", "USE"),
                                         num    = ent:GetAmmoLeft() or 0 } 
             end
   };

end

ENT.BC_AMMO = 15 -- How much ammo it starts with
ENT.Type = "anim"
ENT.Model = Model("models/weapons/w_suitcase_passenger.mdl")
ENT.CanHavePrints = true

-- Custom entity variables 
ENT.NextDrop = 0
ENT.DropRate = 1

AccessorFunc(ENT, "Placer", "Placer")

function ENT:SetupDataTables()
	self:NetworkVar( "Int", 0, "AmmoLeft" )
end

function ENT:Initialize()
	self:SetModel(self.Model)

	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_BBOX)

	local b = 32
	self:SetCollisionBounds(Vector(-b, -b, -b), Vector(b,b,b))

	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	if SERVER then
    
		local phys = self:GetPhysicsObject()
		if IsValid(phys) then
			phys:SetMass(150)
		end

		self:SetUseType(SIMPLE_USE)
	end

	self:SetHealth(150)

	if CLIENT then
		self:DisplayInfo()
	end

	self:SetColor(Color(180, 180, 250, 255))
	
	local preammo = self.BC_AMMO
	self:SetAmmoLeft(preammo or 15) 
	self:SetPlacer(nil)

   self.fingerprints = {}
end	


function ENT:DisplayInfo()
		local GetPTranslation = LANG.GetParamTranslation
		local hintammo = self:GetAmmoLeft()
		self.TargetIDHint = {
		name="Briefcase",
		hint= "Press " .. Key("+use", "USE") .. " to recieve ammo! Ammo Remaining: %d",
		fmt=function(ent, str)
			return Format(str, IsValid(self) and self:GetAmmoLeft() or 0)
		end
		}
end


function ENT:GiveAmmo(ply)
	local AmmoLeft = self:GetAmmoLeft()
	
	if AmmoLeft > 0 then
		self:SetAmmoLeft(AmmoLeft - 1)
		
		-- Randomizes the ammo type and sets it to a variable
		local ammotypes = {"item_box_buckshot_ttt", "item_ammo_357_ttt", "item_ammo_pistol_ttt", "item_ammo_smg1_ttt" }
		local ammochoice = table.Random(ammotypes)
	
		-- Positions the ammo above the prop and then creates it
		local thing = ents.Create(ammochoice)
		local weppos = self:GetPos()
		weppos.z = weppos.z + 5
		thing:SetPos(weppos)
		thing:Spawn()
		
		-- Adds a little randomness to the trajectory of the ammo case 
		local thecase = thing:GetPhysicsObject()
		local a, b, c = math.random(-70,70) , math.random(-70,70) , math.random (10, 90)
		thecase:SetVelocity( Vector(a,b,c ) )
	
	else
		ply:ChatPrint("No ammo left!")
	end
 end


function ENT:Use(ply)
	if IsValid(ply) and ply:IsPlayer()  then
		local cur = CurTime()
		--if cur > self.NextDrop then
			self:GiveAmmo(ply)
			self.NextDrop = cur + self.DropRate
		--end
	end
	
	if not table.HasValue(self.fingerprints, ply) then
			table.insert(self.fingerprints, ply)
	end
end

function ENT:OnTakeDamage(dmginfo)
	self:TakePhysicsDamage(dmginfo)
   
	self:SetHealth(self:Health() - dmginfo:GetDamage())

	local att = dmginfo:GetAttacker()
	if IsPlayer(att) then
		DamageLog(Format("%s damaged the briefcase for %d dmg",
						att:Nick(), dmginfo:GetDamage()))
	end

	if self:Health() < 0 then
		util.EquipmentDestroyed(self:GetPos())
				DamageLog(Format("%s destroyed the briefcase",
						att:Nick(), dmginfo:GetDamage()))
		self:Remove()

	end
end
