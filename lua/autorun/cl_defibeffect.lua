
if SERVER then
	resource.AddFile( "materials/vgui/defib/medic.png" )
	resource.AddFile( "materials/vgui/defib/heartbeat.png" )
	AddCSLuaFile()
end

if CLIENT then	
	surface.CreateFont( "DefFont", {
	font = "Arial",
	size = 30,
	weight = 500,
	antialias = true,
} )

	local TIMER_TIME = 25
	local Counting = true
	
	timer.Create("TestTimer", TIMER_TIME, 1, function() Counting = false end)
	
	local r = 0
	local g = 255
	
	local cycle = 0
	local ChangeRate = 7 / TIMER_TIME -- Divide 7 by the time and you get a decimal that changes at the right speed
	ChangeRate = math.Round(ChangeRate, 5) -- Round to 5 places
	
	-- FIND A WAY TO MULTIPLY CHANGERATE BY FrameTime() TO GET PROPER COLORATION
	
	hook.Add( "Tick", "BouncyBall2s", function()
		if not Counting then return end
		
		if cycle == 0 then -- Approach Yellow from Green
			r = math.Approach(r, 255, ChangeRate)
			g = math.Approach(g, 255, ChangeRate)
			if r + g >= 510 then
				cycle = 1
			end
		elseif cycle == 1 then -- Approach Red from Yellow
			r = math.Approach(r, 255, ChangeRate)
			g = math.Approach(g, 0, ChangeRate)
		end -- Stay red
	end)
	
	local function ReviveCountdown()
		if not Counting then return end
		local MEDIC = Material( "materials/vgui/defib/heartbeat.png" )
		
		for k, v in pairs(ents.FindByClass("prop_ragdoll")) do
			local rag = v
			if not IsValid(rag) then return end
			
			local BoneIndx = rag:LookupBone("ValveBiped.Bip01_Head1")
			local BonePos, BoneAng = rag:GetBonePosition( BoneIndx )
			local pos = BonePos + Vector(0,0,80) -- Place above head bone
			local eyeang = LocalPlayer():EyeAngles().y - 90
			local ang = Angle( 0, eyeang, 90 )
			
			
			-- Start drawing 
			cam.Start3D2D(pos, ang, 0.1)
				-- X, Y, WIDTH, HEIGHT
				local Height = 84
				local Width = 84
				local Bar_Color = Color(r, g, 0, 200)
				
				-- Background
				surface.SetDrawColor( 0, 0, 0, 100 ) -- ( 57, 255, 20, 150)
				surface.DrawRect(-100 , 500, Width, Height )
				
				local TimeBase = TIMER_TIME
				local TimeL = math.Clamp( math.Round( timer.TimeLeft("TestTimer") or 0, 1), 0, TimeBase)
				local Seg = Height / TimeBase
				local Bar = math.Clamp(TimeL * Seg, 0, Height)
				
				-- Countdown color bar
				surface.SetDrawColor( Bar_Color )
				draw.RoundedBox( 0, -16, 500, Width - 54, Bar, Bar_Color )
				
				local div = 150 / TimeBase
				local al = TimeL * div
				
				-- Medic logo
				surface.SetDrawColor( 255, 255, 255, al)
				surface.SetMaterial( MEDIC )
				surface.DrawTexturedRect( -100 , 500, Width, Height )
				
				draw.DrawText( TimeL, "DefFont", -60, 530 , Bar_Color , TEXT_ALIGN_CENTER )
				
				-- Decor lines
				--surface.SetDrawColor( 255, 255, 255, 235)
				surface.SetDrawColor( Bar_Color )
				surface.DrawRect(-100 , 500, Width, 2 )
				surface.DrawRect(-100 , 582, Width, 2 )
				
				cam.IgnoreZ( true )
			cam.End3D2D()
			
			if TimeL == 0 then

			end
			
		end
	end

	hook.Add( "PostDrawOpaqueRenderables", "GoingToDie", ReviveCountdown )
end


