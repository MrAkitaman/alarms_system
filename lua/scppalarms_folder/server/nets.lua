util.AddNetworkString( "SCPAlarms::NetComm" )

local tNets = {
    [1] = function( pPly )
        if not pPly:IsAdmin() then return end
        local iCat = net.ReadUInt(8)
        local iSong = net.ReadUInt(16)
        local bLoop = net.ReadBool()
        net.Start( "SCPAlarms::NetComm" )
        net.WriteUInt( 2, 4 )
        net.WriteUInt( iCat, 8 )
        net.WriteUInt( iSong, 16 )
        net.WriteBool( bLoop )
        net.Broadcast()
    end,
    [2] = function( pPly )
        if not pPly:IsAdmin() then return end
        net.Start( "SCPAlarms::NetComm" )
        net.WriteUInt( 3, 4 )
        net.Broadcast()
    end,
}

net.Receive( "SCPAlarms::NetComm", function( _, pPly )
    local iKey = net.ReadUInt( 4 )
    if not ( IsValid( pPly ) and tNets[iKey] and isfunction( tNets[iKey] ) ) then return end
    tNets[iKey]( pPly )
end )
