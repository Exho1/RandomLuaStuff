AddCSLuaFile()
local bList = {} or bList
	
---- Entity Remover ----
-- Author: Exho
-- V: 8/15/14	


------ //BLACKLIST//------
local Range = 60 -- The radius around the Vectors that Entity Remover searches
	-- Place the copied code from console in here 
bList[1] = {map = 'mapname', class = 'prop_physics', index = 000, pos = Vector(0, 0, 0)}



------ //END BLACKLIST//------
	
local function BlacklistEntity(ply)
	local tr = ply:GetEyeTrace()
	local object = tr.Entity
	if not IsValid( object ) then return false end
	
	if not tr.HitWorld and not object:IsPlayer() and not object:IsNPC() then
		local pos = object:GetPos()
		local class = object:GetClass()
		local map = game.GetMap()
		local index = object:EntIndex()
		local loc = (#bList + 1)
		local x = math.Round(pos.x)
		local y = math.Round(pos.y)
		local z = math.Round(pos.z)
		print("****")
		print("[ER]: Created new Blacklist entry")
		print("bList["..loc.."] = {map = '"..map.."', class = '"..class.."', index = "..index..",  pos = Vector("..x..","..y..","..z..")}")
		print("[ER]: Paste this into the Entity Remove lua file under the other table entries")
		print("****")
	else
		ply:ChatPrint("You cannot blacklist that entity")
	end
end
	
local Sayings = {"was nuked from orbit", "bombed like Hiroshima", "got rekt", "was deleted", "met its demise",
"was kaboomed", "was transported to the 4th dimension", "was smitted", "got whooped",
}
	
local function RemoveBListEntities()
	print("****")
	print("Removing blacklisted entities")
	local map = game.GetMap()
	for k,v in pairs(bList) do
		if v.map == map then
			local class = v.class
			local pos = v.pos
			local index = v.index
			--print(tostring(pos))
				
			possibles = ents.FindInSphere(pos, Range)
			for o, p in pairs(possibles) do
				if p:GetClass() == class then
					if p:EntIndex() == index then
						local phrase = Sayings[math.random(#Sayings)]
						print(class.." "..phrase.." by Entity Remover at "..tostring(pos))
						p:Remove()
					end
				end
			end
		else
			print("This map does not have any blacklisted entities")
		end
	end
	print("Finished removing any blacklisted entities!")
	print("****")
end
	
hook.Add("PlayerSay", "ChatEntitySelector", function(ply, text)
	local text = string.lower(text)
	
	if ( string.sub( text, 1, 11 ) == "!entremove" ) then
		if ply:IsSuperAdmin() then -- Nobody else should be able to use this
			ply:ChatPrint("Check your console!")
			ply:ConCommand("er_blacklistent")
		else
			ply:ChatPrint("Sorry but your rank cannot remove entities :(")
		end
		return false 
	end
end)
hook.Add("InitPostEntity", "RemovingTheBaddies", RemoveBListEntities)

concommand.Add( "er_nukemap",function(ply)
	if not ply:IsSuperAdmin() then return false end
	print( "Removed all the blacklisted entities from this map!" )
    RemoveBListEntities()
end )
concommand.Add( "er_blacklistent",function( ply )
	if not ply:IsSuperAdmin() then return false end
	print( "Blacklisting entity directly in front of player!" )
    BlacklistEntity(ply)
end )
concommand.Add( "er_blacklist_print",function(ply)
	print("Printing the blacklist table!")
    PrintTable(bList)
end )

