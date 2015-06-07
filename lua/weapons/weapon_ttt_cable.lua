if SERVER then
    AddCSLuaFile() 
end

if CLIENT then
    SWEP.PrintName = "Spy Cable"
    SWEP.Slot = 7
    SWEP.DrawAmmo = true
    SWEP.DrawCrosshair = false
       
    SWEP.Icon = "vgui/ttt/icon_rock"
 
	SWEP.EquipMenuData = {
      type = "item_weapon",
      desc = "f"
   };
end
 
SWEP.HoldType            = "normal"
SWEP.Base                = "weapon_tttbase"
SWEP.Kind                = WEAPON_EQUIP
SWEP.CanBuy              = { ROLE_TRAITOR }

SWEP.Primary.Ammo        = "none"
SWEP.Primary.Delay       = 1
SWEP.Secondary.Delay     = 1
SWEP.Primary.ClipSize    = -1
SWEP.Primary.ClipMax     = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic   = false
SWEP.AllowDrop			 = false

SWEP.Spawnable           = true
SWEP.AdminSpawnable      = true
SWEP.AutoSpawnable       = false
SWEP.ViewModel           = "models/weapons/v_pistol.mdl"
SWEP.WorldModel          = "models/weapons/w_crowbar.mdl"
SWEP.ViewModelFlip       = false
SWEP.LimitedUse 		 = true

SWEP.door = nil
SWEP.footPos = nil

local function isDoor(ent) -- Check if the entity is a door, function from Destructible Doors
	if not IsValid(ent) then return false end
	local doors = {"func_door", "func_door_rotating", "prop_door", "prop_door_rotating",}

	for k,v in pairs(doors) do
		if ent:GetClass() == v then
			return true
		end
	end
	return false
end

function SWEP:PrimaryAttack()
	local ply = self.Owner
	
	--if not self:CanPrimaryAttack() then return end
    self:SetNextPrimaryFire(CurTime()+self.Primary.Delay)
    self:SetNextSecondaryFire(CurTime()+self.Secondary.Delay)
       
    local pos = self.Owner:GetShootPos()
    local ang = self.Owner:GetAimVector()
    local tracedata = {}
    tracedata.start = pos
    tracedata.endpos = pos+(ang*100)
    tracedata.filter = self.Owner
    local trace = util.TraceLine(tracedata)
       
    local door = trace.Entity
	
	if isDoor(door) then
		self.isLooking = true
		self.door = door
		self.footPos = ply:GetPos()
		
		--hook.Add("CalcView", "ttt_cableview_"..self.Owner:SteamID(), function()

		--end)
	end
end

function SWEP:SecondaryAttack()
	self.isLooking = false
	self.door = nil
	
	--hook.Remove("CalcView", "ttt_cableview_"..self.Owner:SteamID())
end

function SWEP:Reload()

end

local function degree180to360( num )
	if num < 0 then
		return math.abs(num) + 180
	else
		return num
	end
end

local function degree360to180( num )
	if num > 180 then
		return num - 180
	else
		return num
	end
end

function SWEP:DrawHUD()
	local ply = self.Owner
	
	if self.isLooking then
		local eyeAng = ply:EyeAngles()
		-- pitch/x, roll/y, yaw/z
		
		eyeAng.x = math.Clamp(eyeAng.x, -30, 24)
		local doorAng = self.door:GetAngles()
		
		local y = degree180to360( eyeAng.y )
		eyeAng.y = degree360to180(math.Clamp(y, y - 90, y + 90))

		--eyeAng.y = math.Clamp(eyeAng.y, -90, 90)
		
		--print(eyeAng.y, doorAng.y)
		
		-- To Do: Find a good way of finding the current direction, rounding it to 90, 180, -90, or 0, and clamping the view based off that.
		-- Fix the door position not be centered on a certain axies
		
		ply:ChatPrint(degree180to360(ply:EyeAngles().y))
		
		local CamData = {}
		CamData.angles = Angle(eyeAng.x, eyeAng.y, 0) -- Angles, supposed to be clamped
		local footPos = self.footPos -- Declared once because jumping
		local doorpos = self.door:GetPos() + self.door:OBBCenter()
		
		CamData.origin = Vector(doorpos.x, doorpos.y, footPos.z + 5) -- Position, supposed to be the at the center and forward 10 
		
		CamData.x = 0
		CamData.y = 0
		CamData.w = ScrW() -- Takes up the entire screen, for now..
		CamData.h = ScrH() 
		render.RenderView( CamData )
	end
end


