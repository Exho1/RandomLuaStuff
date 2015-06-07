AddCSLuaFile()
resource.AddFile("vgui/ttt/exho_martyrdom.png")

EQUIP_MARTYR = 1024 -- Our unique value

if not EquipmentItems then return end

-- TODO: Add an indicator or sound

hook.Add( "InitPostEntity", "FindAMartyr", function() 
       local MartyrDumb = {
              id = EQUIP_MARTYR,
              loadout = false,
              type = "item_passive",
              material = "vgui/ttt/exho_martyrdom.png",
              name = "Martyrdom",
              desc = "Drops a live grenade upon your death!\n"
      }
      table.insert( EquipmentItems[ROLE_TRAITOR], MartyrDumb )
end)

hook.Add("TTTOrderedEquipment", "PraiseTheNade", function(ply)
	print( ply:HasEquipmentItem(EQUIP_MARTYR)) -- HasEquipmentItem does not work in the Death hook, this works nicely
	if ply:HasEquipmentItem(EQUIP_MARTYR) then
		ply.shouldmartyr = true -- So we set a boolean on the player
	end
end)

local function GrenadeHandler(ply, infl, att)
	if ply.shouldmartyr then
		local proj = "ttt_martyr_proj" -- Create our grenade
		local martyr = ents.Create(proj)
		martyr:SetPos(ply:GetPos())
		martyr:SetAngles(ply:GetAngles())
		martyr:Spawn()
		martyr:SetThrower(ply) -- Someone has to be accountible for this tragedy!
			
		local spos = ply:GetPos()
		local tr = util.TraceLine({start=spos, endpos=spos + Vector(0,0,-32), mask=MASK_SHOT_HULL, filter=ply})
		timer.Simple(3, function()
			martyr:Explode(tr)
			ply.shouldmartyr = false -- No need to explode again, you have fufilled your purpose
		end)
	end
end

local function Resettin()
	for k,v in pairs(player.GetAll()) do
		v.shouldmartyr = false
	end
end

hook.Add( "TTTPrepareRound", "hoobalooba", Resettin )
hook.Add( "PlayerDeath", "hoobalooba", GrenadeHandler )

