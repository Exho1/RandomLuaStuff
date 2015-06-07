if SERVER then 
	AddCSLuaFile() 
end

if CLIENT then
   -- To be honest, I have no idea if this even works but it was in the Health Station code so...
   ENT.Icon = "vgui/ttt/"
   ENT.PrintName = "ied"
end

ENT.Type = "anim"
ENT.Model = Model("models/props_junk/cardboard_box003a.mdl")

ENT.CanHavePrints = true

AccessorFunc(ENT, "Placer", "Placer")


function ENT:SetupDataTables()
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
	
	self:SetPlacer(nil)

   self.fingerprints = {}
end	


function ENT:DisplayInfo()
   if LocalPlayer():IsActiveTraitor() and LocalPlayer():IsActiveTraitor() ~= nil then
		self.TargetIDHint = {name="IMPROVISED EXPLOSIVE DEVICE",
			hint= "Get back! Who knows when it will go off!",
		}
   end
end

function ENT:Think()
	
	if self.Entity.Detonated then
		self.Explody()
	end
	return true
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

function ENT:Explody()
	if SERVER then
		print("EXPLODE")
		local explosion = ents.Create( "env_explosion" )
                explosion:SetPos(self:GetPos())
                explosion:SetKeyValue( "iMagnitude" , "80" )
                explosion:SetKeyValue( "spawnflags" , "328" )
                explosion:SetOwner( self.Owner )
                explosion:Spawn()
                explosion:Fire("explode",0,0)
                explosion:EmitSound("weapons/explode3.wav",100,100)
                explosion:Fire("kill","", .2 )
		self:Remove()
		return 
	end
end