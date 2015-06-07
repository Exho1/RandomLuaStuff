if SERVER then
    AddCSLuaFile() 
end

--[[if CLIENT then
    SWEP.PrintName = "Pin Crossbow"
    SWEP.Slot = 7
    SWEP.DrawAmmo = true
    SWEP.DrawCrosshair = false
       
    SWEP.Icon = "vgui/ttt/icon.png"
 
	SWEP.EquipMenuData = {
      type = "item_weapon",
      desc = ""
   };
end]]

SWEP.Author			= "Exho"
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= ""

--SWEP.Base                = "weapon_tttbase"
SWEP.Kind                = WEAPON_EQUIP
SWEP.CanBuy              = { ROLE_TRAITOR }

SWEP.ViewModelFOV	= 54
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= "models/weapons/v_crossbow.mdl"
SWEP.WorldModel		= "models/weapons/w_crossbow.mdl"
SWEP.AnimPrefix		= "bow"
SWEP.HoldType		= "crossbow"

SWEP.m_bFiresUnderwater	= true

BOLT_MODEL	= "models/weapons/w_missile_closed.mdl"

BOLT_AIR_VELOCITY	= 3500
BOLT_WATER_VELOCITY	= 1500
BOLT_SKIN_NORMAL	= 0
BOLT_SKIN_GLOW		= 1

CROSSBOW_GLOW_SPRITE	= "sprites/light_glow02_noz.vmt"
CROSSBOW_GLOW_SPRITE2	= "sprites/blueflare1.vmt"

SWEP.Spawnable			= false
SWEP.AdminSpawnable		= false

SWEP.Primary.Sound			= Sound( "Weapon_Crossbow.Single" )
SWEP.Primary.Reload			= Sound( "Weapon_Crossbow.Reload" )
SWEP.Primary.Special1		= Sound( "Weapon_Crossbow.BoltElectrify" )
SWEP.Primary.Special2		= Sound( "Weapon_Crossbow.BoltFly" )
SWEP.Primary.Damage			= 100
SWEP.Primary.NumShots		= 1
SWEP.Primary.NumAmmo		= SWEP.Primary.NumShots
SWEP.Primary.Cone			= vec3_origin
SWEP.Primary.ClipSize		= 1					-- Size of a clip
SWEP.Primary.Delay			= 0.75
SWEP.Primary.DefaultClip	= 5					-- Default number of bullets in a clip
SWEP.Primary.Automatic		= true				-- Automatic/Semi Auto
SWEP.Primary.Ammo			= "XBowBolt"
SWEP.Primary.AmmoType		= "crossbow_bolt"

SWEP.Secondary.ClipSize		= -1				-- Size of a clip
SWEP.Secondary.DefaultClip	= -1				-- Default number of bullets in a clip
SWEP.Secondary.Automatic	= false				-- Automatic/Semi Auto
SWEP.Secondary.Ammo			= "None"



--[[---------------------------------------------------------
   Name: SWEP:Precache( )
   Desc: Use this function to precache stuff
---------------------------------------------------------]]
function SWEP:Precache()

	util.PrecacheSound( "Weapon_Crossbow.BoltHitBody" );
	util.PrecacheSound( "Weapon_Crossbow.BoltHitWorld" );
	util.PrecacheSound( "Weapon_Crossbow.BoltSkewer" );

	util.PrecacheModel( CROSSBOW_GLOW_SPRITE );
	util.PrecacheModel( CROSSBOW_GLOW_SPRITE2 );

	self.BaseClass:Precache();

end


--[[---------------------------------------------------------
   Name: SWEP:Initialize( )
   Desc: Called when the weapon is first loaded
---------------------------------------------------------]]
function SWEP:Initialize()

	if ( SERVER ) then
		self:SetNPCMinBurst( 0 )
		self:SetNPCMaxBurst( 0 )
		self:SetNPCFireRate( self.Primary.Delay )
	end

	self:SetWeaponHoldType( self.HoldType )

end


--[[---------------------------------------------------------
   Name: SWEP:PrimaryAttack( )
   Desc: +attack1 has been pressed
---------------------------------------------------------]]
function SWEP:PrimaryAttack()

	-- Make sure we can shoot first
	if ( !self:CanPrimaryAttack() ) then return end

	if ( self.m_bInZoom && IsMultiplayer() ) then
--		self:FireSniperBolt();
		self:FireBolt();
	else
		self:FireBolt();
	end

	-- Signal a reload
	self.m_bMustReload = true;

end


--[[---------------------------------------------------------
   Name: SWEP:SecondaryAttack( )
   Desc: +attack2 has been pressed
---------------------------------------------------------]]
function SWEP:SecondaryAttack()

	-- Make sure we can shoot first
	if ( !self:CanSecondaryAttack() ) then return end

	self:ToggleZoom();

end

--[[---------------------------------------------------------
   Name: SWEP:Reload( )
   Desc: Reload is being pressed
---------------------------------------------------------]]
function SWEP:Reload()

	if ( self.Weapon:DefaultReload( ACT_VM_RELOAD ) ) then
		self.m_bMustReload = false;
		return true;
	end

	return false;

end

-------------------------------------------------------------------------------
-- Purpose:
-------------------------------------------------------------------------------
function SWEP:CheckZoomToggle()

	local pPlayer = self.Owner;

	if ( pPlayer:KeyPressed( IN_ATTACK2 ) ) then
		self:ToggleZoom();
	end

end

--[[---------------------------------------------------------
   Name: SWEP:PreThink( )
   Desc: Called before every frame
---------------------------------------------------------]]
function SWEP:PreThink()
end


--[[---------------------------------------------------------
   Name: SWEP:Think( )
   Desc: Called every frame
---------------------------------------------------------]]
function SWEP:Think()

	-- Disallow zoom toggling
	-- self:CheckZoomToggle();

	if ( self.m_bMustReload ) then
		self:Reload();
	end

	local pPlayer = self.Owner;

	if ( !pPlayer ) then
		return;
	end

	self:PreThink();

	if ( pPlayer:WaterLevel() >= 3 ) then
		self.m_bIsUnderwater = true;
	else
		self.m_bIsUnderwater = false;
	end

end

-------------------------------------------------------------------------------
-- Purpose:
-------------------------------------------------------------------------------
function SWEP:FireBolt()

	if ( self.Weapon:Clip1() <= 0 && self.Primary.ClipSize > -1 ) then
		if ( self:Ammo1() > 0 ) then
			self:Reload();
		else
			self.Weapon:SetNextPrimaryFire( 0.15 );
		end

		return;
	end

	local pOwner = self.Owner;

	if ( pOwner == NULL ) then
		return;
	end

	if ( SERVER ) then
		local vecAiming		= pOwner:GetAimVector();
		local vecSrc		= pOwner:GetShootPos();

		local angAiming;
		angAiming = vecAiming:Angle();

		local pBolt = ents.Create( self.Primary.AmmoType );
		pBolt:SetPos( vecSrc );
		pBolt:SetAngles( angAiming );
		pBolt.m_iDamage = self.Primary.Damage;
		pBolt:SetOwner( pOwner );
		pBolt:Spawn()

		if ( pOwner:WaterLevel() == 3 ) then
			pBolt:SetVelocity( vecAiming * BOLT_WATER_VELOCITY );
		else
			pBolt:SetVelocity( vecAiming * BOLT_AIR_VELOCITY );
		end
		
		local tr = util.TraceLine( {
			start = vecSrc,
			endpos = vecSrc + (vecAiming * 100000),
			filter = {pBolt, self.Owner}
		} )
		
		local ply = tr.Entity
		if not IsValid(ply) or tr.HitWorld then return end
		
		ply:Kill()
		timer.Simple(1, function()
		local rag = ply:GetRagdollEntity()
		
		--local pBolt2 = ents.Create( self.Primary.AmmoType );
		local pBolt2 = ents.Create( "prop_physics" );
		pBolt2:SetModel("models/props_c17/oildrum001.mdl")
		pBolt2:SetPos( tr.HitPos );
		pBolt2:SetAngles( angAiming );
		pBolt2.m_iDamage = self.Primary.Damage;
		pBolt2:SetOwner( pOwner );
		pBolt2:Spawn()
		
		local physobj = pBolt2:GetPhysicsObject()
		physobj:Wake()
		
		pBolt2:SetVelocity( vecAiming * BOLT_AIR_VELOCITY );
		
		--[[local Ent1 = self
		local Ent2 = self.Owner:GetEyeTrace().Entity
		local Bone1, Bone2 = Ent1:GetBone( 1 ), Ent1:GetBone( 2 )
		local WPos1, WPos2 = self:GetPos( 1 ), self:GetPos( 2 )
		local LPos1, LPos2 = self:GetLocalPos( 1 ), self:GetLocalPos( 2 )
		local length = ( WPos1 - WPos2 ):Length()]]
		
		local length = ( pBolt2:GetPos() - rag:GetPos() ):Length()
		
		print(rag, pBolt2)
		
		local constraint, rope = constraint.Rope( pBolt2, rag, 0, 0, Vector(3,6,45), Vector(0,0,0), length, 0, 0, 5, "cable/rope", false )
		
		print(constraint,rope)
		end)
	end

	self:TakePrimaryAmmo( self.Primary.NumAmmo );

	if ( !pOwner:IsNPC() ) then
		pOwner:ViewPunch( Angle( -2, 0, 0 ) );
	end

	self.Weapon:EmitSound( self.Primary.Sound );
	self.Owner:EmitSound( self.Primary.Special2 );

	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK );

	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay );
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Primary.Delay );

	-- self:DoLoadEffect();
	-- self:SetChargerState( CHARGER_STATE_DISCHARGE );

end

--[[---------------------------------------------------------
   Name: SWEP:Holster( weapon_to_swap_to )
   Desc: Weapon wants to holster
   RetV: Return true to allow the weapon to holster
---------------------------------------------------------]]
function SWEP:Holster( wep )

	if ( self.m_bInZoom ) then
		self:ToggleZoom();
	end

	-- self:SetChargerState( CHARGER_STATE_OFF );

	return self.BaseClass:Holster( wep );

end

--[[---------------------------------------------------------
   Name: SWEP:Deploy( )
   Desc: Whip it out
---------------------------------------------------------]]
function SWEP:Deploy()

	if ( self.Weapon:Clip1() <= 0 ) then
		self.Weapon:SendWeaponAnim( ACT_CROSSBOW_DRAW_UNLOADED );
		return self:SetDeploySpeed( self.Weapon:SequenceDuration() );
	end

	self:SetSkin( BOLT_SKIN_GLOW );

	self.Weapon:SendWeaponAnim( ACT_VM_DRAW );
	return self:SetDeploySpeed( self.Weapon:SequenceDuration() );

end


-------------------------------------------------------------------------------
-- Purpose:
-------------------------------------------------------------------------------
function SWEP:ToggleZoom()

	local pPlayer = self.Owner;

	if ( pPlayer == NULL ) then
		return;
	end

if ( !CLIENT ) then

	if ( self.m_bInZoom ) then
		pPlayer:SetCanZoom( true )
		pPlayer:SetFOV( 0, 0.2 )
		self.m_bInZoom = false;
	else
		pPlayer:SetCanZoom( false )
		pPlayer:SetFOV( 20, 0.1 )
		self.m_bInZoom = true;
	end
end

end

BOLT_TIP_ATTACHMENT	= 2

-------------------------------------------------------------------------------
-- Purpose:
-- Input  : skinNum -
-------------------------------------------------------------------------------
function SWEP:SetSkin( skinNum )

	local pOwner = self.Owner;

	if ( pOwner == NULL ) then
		return;
	end

	local pViewModel = pOwner:GetViewModel();

	if ( pViewModel == NULL ) then
		return;
	end

	pViewModel:SetSkin( skinNum );

end

--[[---------------------------------------------------------
   Name: SWEP:CanPrimaryAttack( )
   Desc: Helper function for checking for no ammo
---------------------------------------------------------]]
function SWEP:CanPrimaryAttack()
	return true
end


--[[---------------------------------------------------------
   Name: SWEP:CanSecondaryAttack( )
   Desc: Helper function for checking for no ammo
---------------------------------------------------------]]
function SWEP:CanSecondaryAttack()
	return true
end


--[[---------------------------------------------------------
   Name: SetDeploySpeed
   Desc: Sets the weapon deploy speed.
		 This value needs to match on client and server.
---------------------------------------------------------]]
function SWEP:SetDeploySpeed( speed )

	self.m_WeaponDeploySpeed = tonumber( speed / GetConVarNumber( "phys_timescale" ) )

	self.Weapon:SetNextPrimaryFire( CurTime() + speed )
	self.Weapon:SetNextSecondaryFire( CurTime() + speed )

end
