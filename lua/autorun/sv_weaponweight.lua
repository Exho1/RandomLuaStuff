--[[
AddCSLuaFile()
 
---- TTT Weapon Weight ----
-- Author: Exho and Fus Ro Doug
-- V: 8/15/14
 
-- Let our tables EXIST
local Weapons = {}

 
------ CONFIGURATION ------
local WeightMultiplier = 0.01 -- 0.05 means the guns are heavy, 0.001 means the guns are light
local WeightMin = 0.5 -- Minimum amount of weight allowed
local WeightMax = 1 -- Max amount allowed. This is the default speed

local ChatCommands = { "!weightcheck", "!wc", "!checkweight", "!weight", "!getweight", "!weaponweight", }
local ChatPrint = true -- If a command is typed in chat, does it show up for everyone else? False for silent

---- Approximate weight (in pounds) of each weapon. ----
-- Primaries
Weapons["weapon_ttt_m16"] = 6
Weapons["weapon_zm_rifle"] = 7
Weapons["weapon_zm_shotgun"] = 7
Weapons["weapon_zm_sledge"] = 10
Weapons["weapon_zm_mac10"] = 6

-- Secondaries
Weapons["weapon_zm_pistol"] = 1.6
Weapons["weapon_ttt_glock"] = 1.4
Weapons["weapon_zm_revolver"] = 4
 
-- Grenades
Weapons["weapon_zm_molotov"] = 2
Weapons["weapon_ttt_confgrenade"] = 1
Weapons["weapon_ttt_smokegrenade"] = 1

-- Specials
Weapons["weapon_ttt_c4"] = 1
Weapons["weapon_ttt_defuser"] = 2
Weapons["weapon_ttt_decoy"] = 1
Weapons["weapon_ttt_knife"] = 1.5
Weapons["weapon_ttt_health_station"] = 6
Weapons["weapon_ttt_flaregun"] = 3
Weapons["weapon_ttt_stungun"] = 4
Weapons["weapon_ttt_push"] = 4
Weapons["weapon_ttt_phammer"] = 4
Weapons["weapon_ttt_radio"] = 1
Weapons["weapon_ttt_sipistol"] = 2
Weapons["weapon_ttt_teleport"] = 1

------ //END CONFIGURATION//------

local speedchat
local function SpeedChanger( ply, slowed )
	local iWeight = iWeight or 0
    for k, v in pairs( Weapons ) do
			iWeight = iWeight + v
		if not ply:HasWeapon(k) then
			iWeight = iWeight - v
		end
    end
    local total = (iWeight) * WeightMultiplier
    local newspeed = 1 - total
	local newspeed = math.Clamp( newspeed, 0.5, 1 ) -- 0.5 is low enough, the speed should never go over 1
	
	--print(newspeed) -- Use for debugging in real time, it spams console though
	speedchat = newspeed 
	
    if not slowed then
        return newspeed
    else
        return newspeed / 1.7 -- If zoomed, slow the player even more
    end
end

local function SpeedChecker( ply, text )
	text = string.lower(text)
	for k, command in pairs( ChatCommands ) do
		if (string.sub( text, 1, string.len(command) ) == string.lower(command) ) then
			ply:ChatPrint("[WeaponWeight]: Your current speed is "..speedchat.." out of 1")
			if not ChatPrint then return false end
		end
	end
end

hook.Add( "TTTPlayerSpeed", "WeaponsHavePOWER", SpeedChanger )
hook.Add( "PlayerSay", "PrintingTheirSpeed", SpeedChecker )

]]

