AddCSLuaFile()

---- TTT Hover Stats ----
-- Author: Exho
-- V: 9/11/14


------ CONFIGURATION ------
local Range 		= 500 -- How close you have to be to the weapon to see the stats

local NameCol		= Color( 255, 255, 255, 255 ) -- The Guns title, default white
local DmgCol 		= Color( 220, 80, 80, 255 ) -- Red
local ClipCol		= Color( 128, 255, 0, 255 ) -- Green
local RecoilCol 	= Color(0, 191, 255, 255 ) -- Blue
local AutoCol 		= Color(204, 204, 0, 255 ) -- Yellow
local SpreadCol		= Color( 205, 61, 205, 255 ) -- Pink 

local Base = 400 -- This is the default height of the stats
local BounceHigh = Base + 50 -- The height it goes up to when bouncing
local BounceLow = Base - 50 -- Guess what this one does
------ //END CONFIGURATION//------


------ DECLARING VARIABLES ------
local enable = CreateClientConVar("hs_enabled", "1", true, true)	
local bounce = CreateClientConVar("hs_bounce", "1", true, true)
local numbers = CreateClientConVar("hs_numbers", "0", true, true)
local name 
local dmg 
local recoil 
local clip 
local maxclip 
local cone 
local auto 
local none = "ERROR" -- Nil fixer
local nfix = {} -- TTT uses language variables instead of names for some weps, this fixes that. 
	-- Custom weapons wont have this problem unless you did use languages in which case add it at the bottom.
	-- Example: nfix.translationname = "New Name"
	nfix.rifle_name, nfix.sipistol_name, nfix.shotgun_name, nfix.pistol_name = "Rifle", "S. Pistol", "Shotgun", "Pistol"
	nfix.defuser_name, nfix.newton_name, nfix.tele_name, nfix.flare_name = "Defuser", "Newton", "Teleporter", "Flare Gun"
	nfix.knife_name, nfix.grenade_fire, nfix.grenade_smoke = "Knife", "Incendinary", "Smoke"
------ //END DECLARING VARIABLES// ------
	

if CLIENT then -- Creates fonts
	surface.CreateFont( "GunFont", {
	font = "Arial",
	size = 30,
	weight = 500,
	antialias = true,
} )

	surface.CreateFont( "GunTitle", {
	font = "Arial",
	size = 50,
	weight = 500,
	antialias = true,
} )
end


local function IsTTTWep( ent )
	-- Checks to make sure only TTT weapons recieve these stats
	if not IsValid( ent ) then return end
	if not ent:IsWeapon() then return end
	
	local class = string.lower(ent:GetClass())
	if string.sub( class, 1, 10 ) == "weapon_ttt" or "weapon_zm" then
		if ent.Primary then -- If its not a weapon, this doesnt happen.
			if ent.Base == "weapon_tttbase" then
				return true
			end
		end
	end
	return false
end

-- The bouncing effect 
local Goal = 350 
local Counting = false -- Constantly counting is inefficient
hook.Add( "Tick", "BouncyBalls", function()
	if not bounce:GetBool() then return false end
	
	if Counting then
		Base = math.Approach(Base, Goal, 2) 
	
		-- These variables are referenced from the Config area
		if Base == BounceLow then
			Goal = BounceHigh
		elseif Base == BounceHigh then
			Goal = BounceLow
		end
	end
end)

------ DRAWING STATS ------
local function DrawYourStats()
	local ply = LocalPlayer()
	
	-- Tracing. No eye trace this time cause I need range
	local pos = ply:GetShootPos()
	local ang = ply:GetAimVector()
	local tracedata = {}
	tracedata.start = pos
	tracedata.endpos = pos+(ang*Range) 
	tracedata.filter = ply
	local trace = util.TraceLine(tracedata)
	
	local gun = trace.Entity
	
	-- Enabled check
	if enable:GetBool() ~= true then return false end
	
	-- Checking if the target is a valid weapon and if we should display stats
	if IsTTTWep( gun ) then
		Counting = true
		-- Set each of the variables that I reference later
		name = gun.PrintName or none
		if gun.Primary.NumShots then
			dmg = (gun.Primary.Damage * gun.Primary.NumShots) or none
		else
			dmg = gun.Primary.Damage or none
		end
		recoil = gun.Primary.Recoil or none
		auto = gun.Primary.Automatic or none
		clip = gun:Clip1() or none
		maxclip = gun.Primary.DefaultClip or none
		cone = gun.Primary.Cone or none
		
		if clip == -1 then
			clip = maxclip
		end
		
		if numbers:GetBool() then
			recoil = math.Round(recoil, 2)
		elseif recoil <= 1.4 then -- Make recoil have a fancy name instead of numbers
			recoil = "Low"
		elseif recoil > 1.4 and recoil <= 1.9 then
			recoil = "Average"
		elseif recoil > 1.9 and recoil <= 5 then
			recoil = "High"
		elseif recoil > 5 then
			recoil = "Very High"
		else recoil = none 
		end
		
		if numbers:GetBool() then
			cone = math.Round(cone, 3)
		elseif cone <= 0.02 then -- Same deal, cause numbers wont mean anything
			cone = "Great"
		elseif cone > 0.02 and cone <= 0.05 then
			cone = "Good"
		elseif cone > 0.05 and cone <= 0.7 then
			cone = "Average"
		elseif cone > 0.07 and cone <= 0.9 then
			cone = "Poor"
		elseif cone > 0.9 then 
			cone = "Horrible"
		else cone = none end
			
		if auto == true then
			auto = "Yes"
		else
			auto = "No"
		end
 			
		-- Fix all the screwed up names
		for k,v in pairs( nfix ) do
			if k == name then
				name = v
			end
		end
		if name == "UMP Prototype" then -- Some names I could not use for keys 
			name = "UMP"
		elseif name == "H.U.G.E-249" then
			name = "HUGE-249"
		elseif name == "Discombobulator" then
			name = "Discombob"
		end
			
		-- Minor calculations to make the thing actually stand up
		local pos = gun:GetPos() + Vector(0,0,90)
		local eyeang = LocalPlayer():EyeAngles().y - 90
		local ang = Angle( 0, eyeang, 90 )
			
		-- Start drawing 
		cam.Start3D2D(pos, ang, 0.1)
			surface.SetDrawColor( 0, 0, 0, 150) -- A near-transparent black works nicely
			surface.DrawRect(-200 , Base - 100, 250, 330 ) -- Base is used in the bouncing effect
			surface.SetDrawColor( 255,255, 255, 255)
			surface.DrawLine( -150, Base - 30, 0, Base - 30 ) -- The line under the gun name
			
			draw.DrawText( name, "GunTitle", -75, Base -80 , NameCol, TEXT_ALIGN_CENTER )
			
			draw.DrawText( "Damage:", "GunFont", -180, Base, DmgCol, TEXT_ALIGN_LEFT )
			draw.DrawText( dmg, "GunFont", 30, Base, DmgCol, TEXT_ALIGN_RIGHT )
			
			draw.DrawText( "Clip:", "GunFont", -180, Base + 40, ClipCol, TEXT_ALIGN_LEFT )
			draw.DrawText( clip.."/"..maxclip, "GunFont", 30, Base + 40, ClipCol, TEXT_ALIGN_RIGHT )
			
			draw.DrawText( "Recoil:", "GunFont", -180, Base + 80, RecoilCol, TEXT_ALIGN_LEFT )
			draw.DrawText( recoil, "GunFont", 30, Base + 80, RecoilCol, TEXT_ALIGN_RIGHT )
			
			draw.DrawText( "Automatic:", "GunFont", -180, Base + 120, AutoCol, TEXT_ALIGN_LEFT )
			draw.DrawText( auto, "GunFont", 30, Base + 120, AutoCol, TEXT_ALIGN_RIGHT )
			
			draw.DrawText( "Accuracy:", "GunFont", -180, Base + 160, SpreadCol, TEXT_ALIGN_LEFT )
			draw.DrawText( cone, "GunFont", 30, Base + 160, SpreadCol, TEXT_ALIGN_RIGHT )
		cam.End3D2D()
	else
		Counting = false -- If you are not looking at a valid gun, dont count.... Duh
	end
end
hook.Add( "PostDrawOpaqueRenderables", "PopUpBlockerFailed", DrawYourStats )
------ //END DRAWING STATS// ------


