if SERVER then
	AddCSLuaFile()
end

SWEP.PrintName 				= "Spawn Editor"
SWEP.Author					= "Exho"
SWEP.Contact				= "STEAM_0:0:53332328"
SWEP.Purpose				= ""
SWEP.Instructions			= ""
SWEP.Category				= "" 

SWEP.Slot					= 3
SWEP.SlotPos				= 1
SWEP.DrawAmmo 				= false
SWEP.DrawCrosshair 			= true
SWEP.HoldType				= "normal"
SWEP.Spawnable			 	= false
SWEP.AdminSpawnable			= true 

SWEP.ViewModel          	= "models/weapons/v_pistol.mdl"
SWEP.WorldModel          	= "models/weapons/w_pistol.mdl"
SWEP.ViewModelFlip		 	= false

local SpawnIndicators = {}
local NewSpawns = {}
local DeletedSpawns = {}
-- List of spawns, gathered from TTT and personal knowledge
local SpawnTypes = {
	"info_player_terrorist",
	"info_player_counterterrorist",
	"hostage_entity",
	"info_player_teamspawn",
	"info_player_deathmatch", 
	"info_player_combine",
	"info_player_rebel", 
	"info_player_axis", 
	"info_player_allies", 
	"gmod_player_start",
}

function SWEP:PrimaryAttack()
	local ply = self.Owner
	local tr = ply:GetEyeTrace()
	local Spot = tr.HitPos
	
	if SERVER then
			local Spawn = ents.Create("prop_physics")
		Spawn:SetPos(Spot)
		Spawn:SetModel("models/Kleiner.mdl")
		Spawn:Spawn()
		Spawn.IsRevealedSpawn = true
		table.insert(SpawnIndicators, Spawn)
		-- Insert into the new spawn table
				
		Spawn:SetCollisionGroup( COLLISION_GROUP_WEAPON )
		local PhysObj = Spawn:GetPhysicsObject()
		if IsValid(PhysObj) then
			PhysObj:EnableMotion(false) 
		end
				
		Spawn:SetColor( Color( 0, 255, 0, 230 ) ) 
		Spawn:SetRenderMode( RENDERMODE_TRANSALPHA )
		
		undo.Create("prop")
			undo.AddEntity(Spawn)
			-- Remove the entity from the table
			undo.SetPlayer(ply)
		undo.Finish()
	end
end

function SWEP:SecondaryAttack()
	-- Remove bad spawn points
	local ply = self.Owner
	local tr = ply:GetEyeTrace()
	local ent = tr.Entity
	
	if IsValid(ent) and ent.IsRevealedSpawn then
		local Data = {pos = ent:GetPos(), class = ent:GetClass()}
		table.insert(DeletedSpawns, Data)
		ent:Remove()
		ply:ChatPrint("Deleted spawn!")
	else
		ply:ChatPrint("Not a spawn point or not pointed at the spawn's feet")
	end
end

function SWEP:Reload()
	
end

local function RevealSpawns(ply)
	for k, v in pairs(ents.GetAll()) do
		for o, p in pairs(SpawnTypes) do
			if v:GetClass() == p then
				--print(v:GetClass().." exists in the world")
					local Spawn = ents.Create("prop_physics")
				Spawn:SetPos(v:GetPos())
				Spawn:SetModel("models/Kleiner.mdl")
				Spawn:Spawn()
				Spawn.IsRevealedSpawn = true
				table.insert(SpawnIndicators, Spawn)
				
				Spawn:SetCollisionGroup( COLLISION_GROUP_WEAPON )
				local PhysObj = Spawn:GetPhysicsObject()
				if IsValid(PhysObj) then
					PhysObj:EnableMotion(false) 
				end
				
				Spawn:SetColor( Color( 0, 255, 0, 230 ) ) 
				Spawn:SetRenderMode( RENDERMODE_TRANSALPHA )
			end
		end
	end
end
local function CleanUpReveals()
	for k, v in pairs( SpawnIndicators ) do
		SafeRemoveEntity(v)
	end
end

concommand.Add( "se_revealspawns",function(ply, cmd, args)
	if not ply:IsSuperAdmin() then return false end
	RevealSpawns(ply)
end)	

concommand.Add( "se_cleanup",function(ply, cmd, args)
	if not ply:IsSuperAdmin() then return false end
	CleanUpReveals()
end)	


