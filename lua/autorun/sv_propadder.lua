----// Prop Adder //----
-- Author: Exho
-- Version: 10/15/14

if SERVER then
	AddCSLuaFile()
	
	PropSpawnerDir = "propadder/"..game.GetMap().."_props.txt" -- Directory where the spawn files are CREATED under the /data/ folder
	PropSpawnerReadDir = "maps/" ..game.GetMap().. "_props.txt" -- Directory where spawn files should BE in order to be read
	local col = Color( 241, 196, 15 ) 
	
	local function SpawnPropFromTxt()
		MsgC( col, "* Creating Props *\n" )
		
		if not file.Exists( PropSpawnerReadDir, "GAME" ) then
			MsgC( col, "* No props needed on this map! *\n" ) 
			return 
		end
		
		local txt = file.Read( PropSpawnerReadDir, "GAME" ) -- Read the spawns file
		local tab = util.JSONToTable( txt ) 
		for k, v in pairs(tab) do -- Loop through the table of spawns
			local ent = ents.Create("prop_physics")
			ent:SetPos(v.pos)
			ent:SetModel(v.mdl)
			ent:SetAngles(v.ang)
			ent:Spawn()
			ent.TxtSpawned = true -- In case we need to clean them up
		end
		MsgC( col, "* Finished Creating Props *\n" )
	end
	
	local function DestroySpawnedProps()
		MsgC( col, "* Cleaning up Spawned Props *\n" )
		
		local Count = 0
		for k, v in pairs(ents.GetAll()) do
			if v.TxtSpawned or v.PSpawned and IsValid(v) then -- If spawned from Txt or the Wep, remove
				v:Remove()
				Count = Count + 1
			end
		end
		if Count == 0 then
			MsgC( col, "* No spawned props to clean up *\n" )
			return
		end
		MsgC( col, "* All spawned props are banished *\n" )
	end
	hook.Add( "InitPostEntity", "AutomaticPropRearming", SpawnPropFromTxt) -- Spawn custom props after all the regular ones have 
	
	
	concommand.Add( "padd_spawn",function(ply)
		if not ply:IsSuperAdmin() then return false end
		SpawnPropFromTxt()
	end)
	concommand.Add( "padd_cleanup",function(ply)
		if not ply:IsSuperAdmin() then return false end
		DestroySpawnedProps()
	end)
end

