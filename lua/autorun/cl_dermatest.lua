if SERVER then
	AddCSLuaFile()
end

print("hey")

--https://github.com/Steve4448/GMod-Lua/blob/master/addons/TestLuaCompiler/lua/autorun/client/cl_init.lua

if CLIENT then
	local function Open()
		local Frame = vgui.Create( "DFrame" )
		Frame:SetTitle( "Frame" )
		Frame:SetSize( 300,300 )
		Frame:Center()			
		Frame:MakePopup()
		
		local frame = vgui.Create("DFrame")
		frame:SetSize( 625, 275 )
		frame:SetTitle("")
		frame:ShowCloseButton( false )
		frame.btnClose:SetVisible( false )
		frame.btnMaxim:SetVisible( false )
		frame.btnMinim:SetVisible( false )
		frame:SetDraggable( false )
		Frame:Center()
		frame.Paint = function( self, w, h )
			--blur( self, 10, 20, 255 )
			draw.RoundedBox( 0, 0, 0, w, h, Color( 30, 30, 30, 200 ) )
		end
	
		--[[local slider = vgui.Create( "gPhoneSlider", Frame )
		slider:SetPos( 50, 50 )
		slider:SetWide( 150 )
		slider:SetMin(0)
		slider:SetMax(1)
		slider:SetValue(0.5)
		
		textBox = vgui.Create( "DTextEntry", Frame )
		textBox:SetText( "Hey" )
		textBox:SetMultiline( true )
		textBox:SetTextColor(Color(0,0,0))
		textBox:SetSize( screen:GetWide()/3 * 2, 20 )
		textBox:SetPos( 30, 5 )
		]]
		
		--[[local Shape = vgui.Create( "DImageLabelButton", Frame )
		Shape:SetSize(150,50)
		Shape:SetPos(100,100)
		Shape:SetImage("scripted/breen_fakemonitor_1")
		Shape:SetText("Test ImageLabelButton")
		Shape:SetTextColor(Color(0,0,0))
		
		surface2.DrawRect(0,0, 50, 50, Color(255,0,0))]]
		--[[local URL = vgui.Create( "DLabelURL", Frame )
		URL:SetText("My url")
		URL:SetURL("http://www.google.com")
		URL:SetFont("Trebuchet24")
		URL:SetPos(50,50)
		URL:SizeToContents()]]
		
	end

	concommand.Add( "dermatest",function(ply)
		Open()
	end)		
end