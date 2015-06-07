if SERVER then
	AddCSLuaFile()
	util.AddNetworkString( "entscreate" )
	
	net.Receive( "entscreate", function( len, ply )
		local class = net.ReadString()
	
		local ent = ents.Create( class )
		ent:SetPos( ply:GetEyeTrace().HitPos )
		ent:Spawn()
	end)
	
	return
end

if CLIENT then
	concommand.Add("create", function( ply, cmd, args )
		if not args[1] then return end
		
		net.Start( "entscreate" )
			net.WriteString( args[1] )
		net.SendToServer()
	end)

end



