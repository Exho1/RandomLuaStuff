if SERVER then
	AddCSLuaFile()
end

-- V: 11/16/14

if CLIENT then
	local HUD = HUD or {}
	
	local Types = {
		"draw.RoundedBox"
	}
	
	local Tools = {
		["Box"] = Types[1],
		["Move"] = 2,
		["Fill"] = 4,
	}
	
	local function ToolAction(num, table)
		if num == 4 and table[2] then -- Fill
			print("Fill")
			
			local Corner = nil
			local uno = table[1] 
			local dos = table[2]
			if uno.x < dos.x and uno.y < dos.y then
				print("Corner is the first entry")
				Corner = table[1]
			elseif dos.x < uno.x and dos.y < uno.y then
				print("Corner is the second entry")
				Corner = table[2]
			else
				Corner = {}
				print("No winner, make your own")
				return
			end
			
			local w, h
			if Corner == table[1] then
				w = dos.x - uno.x + HUD.SnapTo
				h = dos.y - uno.y + HUD.SnapTo
			else
				w = uno.x - dos.x
				h = uno.y - dos.y
			end
			
			HUD.ShapeData[HUD.CurrentTool][HUD.ShapeID] = {x=Corner.x, y=Corner.y, width=w, height=h}
			HUD.ShapeID = HUD.ShapeID + 1
			HUD.FillData = {}
			HUD.FillPoint = 1
			
			for k, v in pairs(table) do
				HUD.ShapeData[HUD.CurrentTool][v.id] = nil
			end
		elseif num == 2 then -- Move
			print("Move")
			HUD.CurrentTool = Tools.Move
		end
	end

	local function OpenDesigner()
		HUD = {}
		
		HUD.SnapTo = 20
		
		HUD.ShapeData = {}
		for k, v in pairs(Types) do
			HUD.ShapeData[v] = {}
		end
		
		HUD.FillData = {}
		HUD.FillPoint = 1
		
		HUD.CurrentTool = Tools.Box
		HUD.MovingObj = nil
		HUD.ShapeID = 1
		
			HUD.Frame = vgui.Create("DFrame")
		HUD.Frame:SetSize(ScrW(),ScrH())
		HUD.Frame:SetPos(0,0)
		HUD.Frame:SetTitle("HUD Designer")
		HUD.Frame:MakePopup()
		HUD.Frame.Paint = function()
			draw.RoundedBox(0, 0, 0, ScrW(), 25, Color(80, 80, 80))
		end
		
			HUD.Canvas = vgui.Create("DPanel", HUD.Frame)
		HUD.Canvas:SetSize(ScrW()-4, ScrH()-35)
		HUD.Canvas:SetPos(2,30)
		function HUD.Canvas:PaintOver(w,h)
			for kind, shapes in pairs(HUD.ShapeData) do
				if kind == "draw.RoundedBox" then
					for key, tab in pairs(shapes) do
						local x = tab.x 
						local y = tab.y 
						local width = tab.width or HUD.SnapTo
						local height = tab.height or HUD.SnapTo
						local color = tab.color or Color(0,200,0)
						local id = tab.id or 0
						
						draw.RoundedBox(4, x, y, width, height, color)
					end
				end
			end
		end
		HUD.Canvas.Paint = function()
			for i=HUD.SnapTo, ScrW(), HUD.SnapTo do
				surface.DrawLine(i, 0, i, ScrH())
				surface.DrawLine(0, i, ScrW(), i)
			end
		end
		HUD.Canvas.OnMousePressed = function(self, mc)
			if mc == MOUSE_LEFT then -- New shape
				local mx, my = self:ScreenToLocal(gui.MouseX())-15, self:ScreenToLocal(gui.MouseY())-15
				mx, my = math.SnapTo(mx, HUD.SnapTo), math.SnapTo(my, HUD.SnapTo)
				
				if HUD.CurrentTool == Tools.Box then
					-- Check fill quality
					for id, tab in pairs(HUD.ShapeData[HUD.CurrentTool]) do
						if tab.x == mx and tab.y == my then
							print("Same square yo")
							if tab.color ~= Color(223,0,0) then
								tab.oldcol = tab.color
								tab.color = Color(223,0,0)
								
								HUD.FillData[HUD.FillPoint] = {x=tab.x, y=tab.y, id=tab.id}
								HUD.FillPoint = HUD.FillPoint + 1
								PrintTable(HUD.FillData)
							elseif tab.color == Color(223,0,0) then
								tab.color = tab.oldcol or Color(0,100,0)
								
								HUD.FillData[HUD.FillPoint] = nil
								HUD.FillPoint = HUD.FillPoint + 1
							end
							return
						end
					end
					
					-- Add new shape to the table
					HUD.ShapeData[HUD.CurrentTool][HUD.ShapeID] = {x=mx, y=my, id=HUD.ShapeID}
					HUD.ShapeID = HUD.ShapeID + 1
					PrintTable(HUD.ShapeData)
				elseif HUD.CurrentTool == Tools.Move then
					print("Move tool in use")
					
					local mx, my = self:ScreenToLocal(gui.MouseX())-15, self:ScreenToLocal(gui.MouseY())-15
					mx, my = math.SnapTo(mx, HUD.SnapTo), math.SnapTo(my, HUD.SnapTo)
					
					PrintTable(HUD.ShapeData["draw.RoundedBox"])
					for id, tab in pairs(HUD.ShapeData["draw.RoundedBox"]) do
						if tab.x == mx and tab.y == my then
							if not tab.oldcolor then 
								print("no old color")
								tab.oldcol = tab.color
							elseif tab.color then
								print("change color")
								tab.color = Color(tab.color.r, tab.color.g, tab.color.b, 100)
							else
								print("no color")
								tab.color = Color(0,100,0,100)
							end
							print(HUD.ShapeData["draw.RoundedBox"][id])
						end
					end
				end
			elseif mc == MOUSE_RIGHT then -- Delete shape
				local mx, my = self:ScreenToLocal(gui.MouseX())-15, self:ScreenToLocal(gui.MouseY())-15
				mx, my = math.SnapTo(mx, HUD.SnapTo), math.SnapTo(my, HUD.SnapTo)
				
				for id, tab in pairs(HUD.ShapeData[HUD.CurrentTool]) do
					if tab.x == mx and tab.y == my then
						HUD.ShapeData[HUD.CurrentTool][id] = nil
					end
				end
			end
		end
		
		--// Toolbar
			HUD.Toolbar = vgui.Create("DFrame", HUD.Frame)
		HUD.Toolbar:SetSize(60, 210)
		HUD.Toolbar:SetPos(ScrW()-100,ScrH()/2 - 50)
		HUD.Toolbar:SetDraggable( true )
		HUD.Toolbar:ShowCloseButton( false )
		HUD.Toolbar:SetTitle("Tools")
		HUD.Toolbar.Paint = function()
			local self = HUD.Toolbar
			draw.RoundedBox(0, 0, 0, self:GetWide(), self:GetTall(), Color(80, 80, 80))
		end
		
			HUD.IconLayout = vgui.Create( "DIconLayout", HUD.Toolbar )
		HUD.IconLayout:SetSize( 40, 150 )
		HUD.IconLayout:SetPos( 10, 30 )
		HUD.IconLayout:SetSpaceY( 5 )
		HUD.IconLayout:SetSpaceX( 5 ) 
		
		HUD.Tools = {}
		table.sort(Tools)
		for k, v in pairs(Tools) do 
				HUD.Tools[k] = HUD.IconLayout:Add( "DButton" ) 
			HUD.Tools[k]:SetSize( 40, 30 )
			HUD.Tools[k]:SetText(k)
			HUD.Tools[k].DoClick = function()
				print("Tool click",k,v)
				if type(v) ~= "number" then
					HUD.CurrentTool = v
				else
					ToolAction(v, HUD.FillData)
				end
			end
		end
	end

	concommand.Add("design", function(ply)
		OpenDesigner()
	end)
end

function math.SnapTo(num, point)
	num = math.Round(num)
	local possible = {min=0, max=0}
	for i=1, point do
		if math.IsDivisible(num+i, point) then
			possible.max = num+i
		end
		if math.IsDivisible(num-i, point) then
			possible.min = num-i
		end
	end
	
	if possible.max - num <= num - possible.min then
		return possible.max
	else
		return possible.min
	end
end

function math.IsDivisible(divisor, dividend)
	return divisor%dividend == 0
end


