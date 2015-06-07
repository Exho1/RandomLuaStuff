--[[
if SERVER then
	AddCSLuaFile()
end


if CLIENT then
	local client = LocalPlayer()
	
	function cam.StartHUD( tbl3d, tbl3d2d )
		cam.Start3D( tbl3d.pos, tbl3d.ang, tbl3d.x, tbl3d.y, tbl3d.w, tbl3d.h, tbl3d.znear, tbl3d.zfar )
		cam.Start3D2D( tbl3d2d.pos, tbl3d2d.ang, tbl3d2d.fov )
	end
	
	function cam.EndHUD()
		cam.End3D2D()
		cam.End3D()
	end
	
	function eyeAngleDif( old, new )
		return old.y - new.y, old.x - new.x
	end
	
	local oldAng, nextUpdate = client:EyeAngles(), 0
	function GAMEMODE:HUDPaint()
		
		if CurTime() > nextUpdate then
			oldAng = client:EyeAngles()
			nextUpdate = CurTime() + 0.01
		end
		
		--client:ChatPrint(tostring(client:EyeAngles()))
	
		local pos = client:EyePos()
		local ang = client:EyeAngles()
		local pos3d2d = pos + ( ang:Forward() * 15 )
		
		local tbl3d = {pos = pos, ang = ang + Angle(0,0,-90)}
		local tbl3d2d = {pos = pos3d2d, ang = ang + Angle(-90,0,0), fov = 0.02}
		--Angle(-130,3,-30)
		
		cam.StartHUD( tbl3d, tbl3d2d )
			local x, y = eyeAngleDif( oldAng, client:EyeAngles() )
			
			draw.RoundedBox( 0, 0, 0, ScrW(), ScrH(), Color(0,200,0,50) )
			
			draw.DrawText( "TESTING TESTING", "Trebuchet24", x*10, y*10, color_black )
		cam.EndHUD()
		
		--[[
		cam.Start3D( pos, ang + Angle(0,0,-90) )
			cam.Start3D2D( pos3d2d, ang + Angle(-130,3,-30), 0.02 )
				draw.RoundedBox( 0, 0, 0, ScrW(), ScrH(), Color(0,200,0,50) )
				
				draw.DrawText( "TESTING TESTING", "Trebuchet24", 0, 0, color_black )
			cam.End3D2D()
		cam.End3D()]]
		
		--[[cam.Start3D( pos, ang + Angle(0,0,-90) )
			cam.Start3D2D( pos3d2d, ang + Angle(130,3,30), 0.02 )
				draw.RoundedBox( 0, 0, 0, ScrW(), ScrH(), Color(200,0,0,50) )
				
				draw.DrawText( "TESTING TESTING", "Trebuchet24", 0, 0, color_black )
			cam.End3D2D()
		cam.End3D()]]
	end
	
	
	
	
	local hud = {"CHudHealth", "CHudBattery", "CHudAmmo", "CHudSecondaryAmmo"}
	function GAMEMODE:HUDShouldDraw(name)
	   for k, v in pairs(hud) do
		  if name == v then return false end
	   end

	   return true
	end
end

]]
