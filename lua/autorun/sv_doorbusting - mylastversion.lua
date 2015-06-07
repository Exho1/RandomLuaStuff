if SERVER then
	AddCSLuaFile()
	
	-- This entire thing is just the portion of my Door Locker code that allows for the door to be broken down.
	-- Its all my code but the idea started as a copy of a concept I saw on Coderhire but I didnt want to pay for
	
	CreateConVar("db_doorhealth", 300, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE, FCVAR_NOTIFY},"How strong the doors are.")
	cvars.AddChangeCallback("db_doorhealth", function()
		for k,v in pairs(ents.GetAll() ) do
			if v:GetClass() == "prop_door_rotating" then
				local health = GetConVar("db_doorhealth"):GetInt()
				v:SetHealth(health)
			end
		end
		print("[DoorBuster] Health changed. Updating doors...")
	end)	
	
	hook.Add( "InitPostEntity", "ITSALLIIIVVEEE", function()
		for k,v in pairs(ents.GetAll() ) do
			if v:GetClass() == "prop_door_rotating" then
				local health = GetConVar("db_doorhealth"):GetInt()
				v:SetHealth(health)
			end
		end
		print("[DoorBuster] All doors have been prepped")
	end)
	
	hook.Add("EntityTakeDamage","BigBadWolfIsJealous", function(prop, dmginfo)
		if (prop:GetClass() == "prop_door_rotating" and IsValid(prop) )then
			local doorhealth = prop:Health()
			local dmgtaken = dmginfo:GetDamage()
			
			prop:SetHealth(doorhealth - dmgtaken)  -- Takes damage for the door
			
			if prop:Health() <= 0 then
				-- Now we create a prop version of the door to be knocked down for looks
				local dprop = ents.Create( "prop_physics" )
					dprop:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE)
					dprop:SetMoveType(MOVETYPE_VPHYSICS)
					dprop:SetSolid(SOLID_BBOX) 
					dprop:SetPos( prop:GetPos() + Vector(0, 0, 2))
					dprop:SetAngles( prop:GetAngles() ) 
					dprop:SetModel( prop:GetModel() )
					dprop:SetSkin( prop:GetSkin() ) 
				prop:Remove()
				dprop:Spawn()
				-- Who doesnt like a little pyrotechnics eh?
				dprop:EmitSound( "physics/wood/wood_crate_break3.wav" )
				local effectdata = EffectData()
					effectdata:SetOrigin( dprop:GetPos() + dprop:OBBCenter() )
					effectdata:SetMagnitude( 5 )
					effectdata:SetScale( 2 )
					effectdata:SetRadius( 5 )
				util.Effect( "Sparks", effectdata )
			end
		end
	end)
	
	hook.Add("PlayerSay", "DoorsAndDoorAccessories", function(ply, text) -- Chat commands to make life easier
		local text = string.lower(text)
    
		if ( string.sub( text, 1, 11 ) == "!checkdoor" ) then
			local tr = ply:GetEyeTrace()
			local door = tr.Entity
			if (IsValid(door)) then
				if door:GetClass() == "prop_door_rotating" then
					ply:ChatPrint("That is a valid door!")
				else
					ply:ChatPrint("That is not a valid door!")
				end
			else
				ply:ChatPrint("That is not a door!")
			end
			return false 
		end
		
		if ( string.sub( text, 1, 11 ) == "!doorhealth" ) then
			local tr = ply:GetEyeTrace()
			local door = tr.Entity
			if (IsValid(door) and door:GetClass() == "prop_door_rotating") then
				ply:ChatPrint("That door's health is " .. door:Health())
			else
				ply:ChatPrint("That is not a valid door!")
			end
			return false
		end
	end) 
end


