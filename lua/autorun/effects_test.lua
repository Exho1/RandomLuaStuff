if CLIENT then
	print("Effects test")

	local function Effect(ply)
	
		local ang = ply:GetAngles()

		local edata_up = EffectData()
		edata_up:SetOrigin(ply:GetPos())
		ang = Angle(0, ang.y, ang.r)
		edata_up:SetAngles(ang)
		edata_up:SetEntity(ply)
		edata_up:SetMagnitude(1)
		edata_up:SetRadius(1)

		util.Effect("teleporter_thing", edata_up)
	
	end
	
	concommand.Add( "effectstest",function(ply)
		Effect(ply)
	end)


end