
local PANEL = {}

function PANEL:Init()

	self.m_Image = vgui.Create( "DImage", self )
	self.m_Label = vgui.Create("DLabel", self)

end

function PANEL:SetImage( mat )

	self.m_Image:SetImage( mat )
	
end

function PANEL:SetText( txt )
	
	self.m_Label:SetText( txt )
	
end

function PANEL:SetFont( font )

	self.m_Label:SetFont( font )
	
end


function PANEL:SetTextColor( col )

	self.m_Label:SetTextColor( col )

end

function PANEL:PerformLayout()
	-- Size button, size picture, size label, position picture and label

	local w, h = self:GetSize()
	local buffer = h/10
	
	self.m_Image:SetSize(h-buffer*2, h-buffer*2)
	self.m_Image:SetPos(w/2-self.m_Image:GetWide(), (h/2) - (self.m_Image:GetTall()/2))
	
	local x, y = self.m_Image:GetPos()
	local imgw, imgh = self.m_Image:GetSize()
	
	self.m_Label:SetPos(x + imgw + buffer*2, (h/2) - (self.m_Label:GetTall()/2) )
	
end

function PANEL:Paint( w, h )

	derma.SkinHook( "Paint", "Button", self, w, h )
	return true

end


derma.DefineControl( "DImageLabelButton", "A standard Button", PANEL, "DButton" )





