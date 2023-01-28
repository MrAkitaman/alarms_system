local tNets = {
    [1] = function()
        local eBox = net.ReadEntity()
        if not IsValid( eBox ) then return end
        SCPALARM.OpenMenu(eBox)
    end,
    [2] = function()
        local iCat = net.ReadUInt(8)
        local iSong = net.ReadUInt(16)
        local bLoop = net.ReadBool()
        SCPALARM.PlaySound(iCat, iSong , bLoop)
    end,
    [3] = function()
        SCPALARM.SoundName = nil
        RunConsoleCommand("stopsound")
    end,
}

net.Receive( "SCPAlarms::NetComm", function()
    local iKey = net.ReadUInt(4)
    if not ( tNets[iKey] and isfunction( tNets[iKey] ) ) then return end
    tNets[iKey]()
end )
