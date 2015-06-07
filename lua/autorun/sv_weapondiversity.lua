----// TTT Weapon Diversity //----
-- Author: Exho
-- V: 9/25/14

AddCSLuaFile()
local RandomStats = {}
math.randomseed(os.time()) 


-- Example:
	RandomStats["weapon_garryomatic"] = { -- Weapon's class/file name
		-- It goes (Mim Value, Max Value) and all of these NEED to be in decimal format even if they are integers. 
		dmg = math.Rand(0.0001, 10000 ), -- Damage
		recoil = math.Rand(1.0, 2.0), -- Recoil 
		cone = math.Rand(0.01, 0.04), -- Spread between each bullet
		delay = math.Rand(0.2, 0.3), -- Delay between shots
	} 

local function Randomize()
	-- Put custom weapon stat tables below this line
	
	--// Default TTT //--
	RandomStats["weapon_ttt_m16"] = { -- M16
		dmg = math.Rand(20.0, 28.5), 
		recoil = math.Rand(1.3, 2.0), 
		cone = math.Rand(0.015, 0.023),
		delay = math.Rand(0.17, 0.23),
	}
	RandomStats["weapon_ttt_glock"] = { -- Glock
		dmg = math.Rand(7.0, 15.0), 
		recoil = math.Rand(0.7,1.0),
		cone = math.Rand(0.015, 0.023),
		delay = math.Rand(0.1, 0.12),
	}
	RandomStats["weapon_zm_mac10"] = { -- Mac10
		dmg = math.Rand(9.0, 15.0), 
		recoil = math.Rand(1.0, 1.5),
		cone = math.Rand(0.025, 0.035),
		delay = math.Rand(0.05, 0.07),
	}
	RandomStats["weapon_zm_shotgun"] = { -- Shotgun
		dmg = math.Rand(9.1, 12.0), 
		recoil = math.Rand(5.1, 7.5),
		cone = math.Rand(0.07, 0.09),
		delay = math.Rand(0.6, 0.9),
	}
	RandomStats["weapon_zm_revolver"] = { -- Deagle
		dmg = math.Rand(35.0, 45.0), 
		recoil = math.Rand(5.5, 6.8),
		cone = math.Rand(0.018, 0.025),
		delay = math.Rand(0.5, 0.7),
	}
	RandomStats["weapon_zm_rifle"] = { -- Rifle
		dmg = math.Rand(43.0, 60.0), 
		recoil = math.Rand(6.0, 8.0),
		cone = math.Rand(0.003, 0.01),
		delay = math.Rand(1.4, 1.7),
	}
	RandomStats["weapon_zm_pistol"] = { -- Five Seven
		dmg = math.Rand(20.0, 30.0), 
		recoil = math.Rand(1.3, 1.6),
		cone = math.Rand(0.015, 0.035),
		delay = math.Rand(0.3, 0.45),
	}
	RandomStats["weapon_zm_sledge"] = { -- HUGE
		dmg = math.Rand(6.0, 10.0), 
		recoil = math.Rand(1.6, 2.0),
		cone = math.Rand(0.07, 0.09),
		delay = math.Rand(0.05, 0.08),
	}
end


-- This hook is called when each entity has become available to Lua so it will cycle through every entity in the map.
local function WeaponStatChanger(ent)
	if not ent:IsWeapon() then return end -- First check to weed out any non-weapons
	
	local class = ent:GetClass()
	Randomize() -- Its a weapon so we want to create our random variables
	for k,v in pairs(RandomStats) do
		if k == class then -- Its on the Stats table
			timer.Simple(0.5, function() -- Small delay to ensure it will work
				if not IsValid(ent) then return end
				if ent.Primary then 
					-- And then setting the variables
					ent.Primary.Damage = math.Round(v.dmg)
					ent.Primary.Recoil = v.recoil
					ent.Primary.Cone = v.cone
					ent.Primary.Delay = v.delay
				end
			end)
		end
	end
end
hook.Add( "OnEntityCreated", "RandomizeTheWeapons", WeaponStatChanger ) 


