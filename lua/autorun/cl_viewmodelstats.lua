--[[

if CLIENT then
	surface.CreateFont( "VMFont", {
	font = "PCap Terminal",
	size = 20,
	weight = 500,
	antialias = true,
} )
	
	local function GetTextSize(text, font)
		surface.SetFont(font)
		local width, height = surface.GetTextSize(text)
		return width, height
	end

	hook.Add( "PostDrawOpaqueRenderables", "ViewModelInfo", function()
		local client = LocalPlayer()
		
		local gun = client:GetActiveWeapon()
		if not IsValid(gun) then return end
		local vm = client:GetViewModel()
		local muzzle = vm:LookupAttachment( "muzzle" )
		muzzle = vm:GetAttachment( muzzle or 0 )
		if muzzle == nil then return end
		
		local pos = muzzle.Pos + Vector(0,0,5)
		local eyeang = LocalPlayer():EyeAngles().y - 90
		local ang = Angle( 0, eyeang, 90 )
		
		local width, height = GetTextSize(gun:GetPrintName(), "VMFont")
			
		-- Start drawing 
		cam.Start3D2D(pos, ang, 0.1)
				surface.SetDrawColor( 255,255, 255, 255)
			
				draw.DrawText( gun:GetPrintName(), "VMFont", -width/2, 20 , Color(255,255,0,255), TEXT_ALIGN_RIGHT )
		cam.End3D2D()
	end)
end
]]

