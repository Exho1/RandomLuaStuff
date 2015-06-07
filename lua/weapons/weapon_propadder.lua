if SERVER then
	AddCSLuaFile()
end

SWEP.PrintName 				= "Prop Adder"
SWEP.Author					= "Exho"
SWEP.Contact				= "STEAM_0:0:53332328"
SWEP.Purpose				= "To 'rearm' Prop Hunt maps with prop_physics"
SWEP.Instructions			= "M1 to spawn, M2 to copy model, and Reload to save"
SWEP.Category				= "Prop Hunt" 

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

-- Why are these not SWEP variables? Because I used a local function below and I cant call self in them
local SelectedModel 		= "models/props_junk/wood_crate001a.mdl"
local BoundingRad 			= 35 -- Bounding radius of the model


local seen = false
function SWEP:PrimaryAttack()
	-- Create entity
	if seen then return end
	seen = true -- Prevent message spam 
	timer.Simple(0.5, function() seen = false end)
	
	local ply = self.Owner
	local tr = ply:GetEyeTrace()
	
	local hit = tr.HitPos

	if SERVER then
		local ent = ents.Create("prop_physics")
		ent:SetPos(hit + Vector(0, 0, BoundingRad))
		ent:SetModel(SelectedModel)
		ent:Spawn()
		ent.PSpawned = true -- This was spawned through the weapon

		ent:SetColor( Color( 0, 255, 0, 230 - BoundingRad ) ) -- Make it noticeable against the regular props
		ent:SetRenderMode( RENDERMODE_TRANSALPHA ) -- This apparently is needed to make it color
		
		-- Because everyone makes mistakes
		undo.Create("prop")
			undo.AddEntity(ent)
			undo.SetPlayer(ply)
		undo.Finish()
	end
	ply:ChatPrint("Prop created!")
end

function SWEP:SecondaryAttack()
	-- Copy entity
	if seen then return end
	seen = true
	timer.Simple(0.5, function() seen = false end)
	
	local ply = self.Owner
	local tr = ply:GetEyeTrace()
	local ent = tr.Entity
	
	if string.sub( ent:GetClass(), 1, 5 ) ~= "prop_" or not IsValid(ent) then 
		ply:ChatPrint("That object is not a prop!")
		return
	end
	
	BoundingRad = ent:BoundingRadius() -- So the prop doesnt clip too badly
	ply:ChatPrint("Chosen prop model is "..ent:GetModel())
	SelectedModel = ent:GetModel() 
end

function SWEP:Reload()
	-- Save
	if seen then return end
	seen = true
	timer.Simple(0.5, function() seen = false end)
	
	local ply = self.Owner
	
	local TxtTable = {}
 	for k, v in pairs(ents.GetAll()) do
		if v.PSpawned then
			-- If the prop is spawned, we need it...
			TxtTable[k] = {pos = v:GetPos(), ang = v:GetAngles(), mdl = v:GetModel()}
		end
	end
	
	local tab = util.TableToJSON( TxtTable )
	if tab ~= "[]" then -- Because Reload gets called more than once, the table can sometimes be empty
		file.CreateDir( "propadder" )
		file.Write( PropSpawnerDir, tab)
	
		ply:ChatPrint("Prop Spawns written to data/"..PropSpawnerDir )
	end
end


local function SetModel(mdl)
	mdl = table.concat( mdl, " " )
	SelectedModel = string.Trim(mdl)
	if SelectedModel == "" then print("Invalid model") return end
	
	-- We need a bounding radius to prevent clipping
	local RefEnt = ents.Create("prop_physics") -- Create a fake prop
	RefEnt:SetPos( Vector(0,0,0) ) -- Put it somewhere no one should find it
	RefEnt:SetModel(SelectedModel) 
	RefEnt:Spawn() -- Create it
	BoundingRad = RefEnt:BoundingRadius() -- Get our radius
	timer.Simple(0.5, function() SafeRemoveEntity(RefEnt) end) -- Get rid of it before anyone notices
end
concommand.Add( "padd_setmodel",function(ply, cmd, args)
	if not ply:IsSuperAdmin() then return false end
	SetModel(args)
end)	


