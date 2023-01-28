--Var
local iScrh = ScrH()
local sMat = Material( "vgui/gradient-d", "smooth" )
local iSaver = 0
local iPlay = 1
local tCMDMenuOpen = {
    ["!scp_menu"] = true,
    ["!scp_alarm"] = true,
    ["!scp_alarms"] = true,
    ["!scp"] = true,
}
local iSongLink = {
    [1] = 0,
    [2] = 0
}

local tFunc = {
    [1] = {
        name = "locally",
        func = function()
            SCPALARM.PlaySound( iSaver, iSongLink[2] , false )
        end
    },
    [2] = {
        name = "globally",
        func = function()
            net.Start( "SCPAlarms::NetComm" )
            net.WriteUInt( 1, 4 )
            net.WriteUInt( iSaver, 8 )
            net.WriteUInt( iSongLink[2], 16 )
            net.WriteBool( false )
            net.SendToServer()
        end
    },
    [3] = {
        name = "globally loop",
        func = function()
            net.Start( "SCPAlarms::NetComm" )
            net.WriteUInt( 1, 4 )
            net.WriteUInt( iSaver, 8 )
            net.WriteUInt( iSongLink[2], 16 )
            net.WriteBool( true )
            net.SendToServer()
        end
    }
}

--Hook
hook.Add( "OnScreenSizeChanged", "SCPALARMS::ScreenSizeChange", function()
    iScrh = ScrH()
end )

--func
function SCPALARM.OpenConfigMenu(tParent, eBox)
    local SCPBackgroundConfig = vgui.Create( "DFrame" )
    SCPBackgroundConfig:SetSize( 0, 0 )
    SCPBackgroundConfig:SetPos(tParent:GetPos())
    SCPBackgroundConfig:SetTitle( "" )
    SCPBackgroundConfig:SetDraggable( false )
    SCPBackgroundConfig:ShowCloseButton( true )
    SCPBackgroundConfig:MakePopup()
    SCPBackgroundConfig.Paint = function( self, iW, iH )
        draw.RoundedBox( 8, 0, 0, iW, iH, Color(33, 34, 38,255))
        surface.SetDrawColor( Color(0,0,0,120) )
        surface.SetMaterial( sMat )
        surface.DrawTexturedRect( 0, iH/8, iW, iH/13 )
        draw.SimpleText( SCPALARM.lang[SCPALARM.config.lang].configtitle, "SCPALARM::DermaTitle", iW/2, iH/10.5+1, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end
    SCPBackgroundConfig:SizeTo( iScrh/1.7, iScrh/2.5, .4, 0, -1)
end

function SCPALARM.OpenMenu(eBox)
    local SCPBackground = vgui.Create( "DFrame" )
    SCPBackground:SetSize( iScrh/1.7, iScrh/2.5 )
    SCPBackground:Center()
    SCPBackground:SetTitle( "" )
    SCPBackground:SetDraggable( false )
    SCPBackground:ShowCloseButton( false )
    SCPBackground:MakePopup()
    SCPBackground.Paint = function( self, iW, iH )
        draw.RoundedBox( 8, 0, 0, iW, iH, Color(33, 34, 38,255))
        surface.SetDrawColor( Color(0,0,0,120) )
        surface.SetMaterial( sMat )
        surface.DrawTexturedRect( 0, iH/8, iW, iH/13 )
        draw.SimpleText( SCPALARM.lang[SCPALARM.config.lang].addonName, "SCPALARM::DermaTitle", iW/2, iH/10.5+1, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end

    local iWide, iTall = SCPBackground:GetWide(), SCPBackground:GetTall()
    if LocalPlayer():IsSuperAdmin() then
        local SCPCloseButton = vgui.Create( "DButton", SCPBackground )
        SCPCloseButton:SetFont( "SCPALARM::DermaTitle" )
        SCPCloseButton:SetText( "⚙" )
        SCPCloseButton:SetPos( iWide/50, iTall/100 )
        SCPCloseButton:SetSize( iWide/25, iTall/15 )
        SCPCloseButton.DoClick = function()
            SCPALARM.OpenConfigMenu(SCPBackground, eBox)
        end
        SCPCloseButton.Paint = function( self, iW, iH )
        end
    end

    local SCPCloseButton = vgui.Create( "DButton", SCPBackground )
    SCPCloseButton:SetFont( "SCPALARM::Cross" )
    SCPCloseButton:SetText( "✖" )
    SCPCloseButton:SetPos( iWide/1.05, iTall/50 )
    SCPCloseButton:SetSize( iWide/30, iTall/25 )
    SCPCloseButton.DoClick = function()
        SCPBackground:Remove()
    end
    SCPCloseButton.Paint = function( self, iW, iH )
    end

    local SCPListPanel = vgui.Create( "DPanel", SCPBackground )
    SCPListPanel:SetPos( iWide/50, iTall/4.5 )
    SCPListPanel:SetSize( iWide/3.5, iTall/1.34 )
    SCPListPanel.Paint = function( self, iW, iH )
        draw.RoundedBox( 8, 0, 0, iW, iH, Color(40, 42, 48,255))
    end

    local SCPSoundPanel = vgui.Create( "DPanel", SCPBackground )
    SCPSoundPanel:SetPos( iWide/3.1, iTall/4.5 )
    SCPSoundPanel:SetSize( iWide/1.515, iTall/1.8 )
    SCPSoundPanel.Paint = function( self, iW, iH )
        draw.RoundedBox( 8, 0, 0, iW, iH, Color(40, 42, 48,255))
        if iSaver ~= 0 and SCPALARM.config.sound[iSaver] and #SCPALARM.config.sound[iSaver].song ~= 0 then return end
        surface.SetDrawColor( 200, 200, 200, 255 )
        SCPALARM.DrawLoader( iW/3.8, iH/4.5, iW/2, iH/2, 10 )
    end

    local SCPInfoPanel = vgui.Create( "DPanel", SCPBackground )
    SCPInfoPanel:SetPos( iWide/3.1, iTall/1.145 )
    SCPInfoPanel:SetSize( iWide/1.515, iTall/10 )
    SCPInfoPanel.Paint = function( self, iW, iH )
        draw.RoundedBox( 32, 0, 0, iW, iH, Color(40, 42, 48,255))
        draw.RoundedBox( 32, iW/12.5, iH/1.5, iW/1.2, iH/10, Color(200, 200, 200,255))
        draw.SimpleText( SCPALARM.SoundName or SCPALARM.lang[SCPALARM.config.lang].nosound, "SCPALARM::Text", iW/2, iH/3.5, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end

    local iPsizeX, iPsizeY = SCPListPanel:GetWide(), SCPListPanel:GetTall()
    local SCPList = vgui.Create( "DScrollPanel", SCPListPanel )
    SCPList:SetSize( iPsizeX/1.1, iPsizeY/1.08 )
    SCPList:SetPos( iPsizeX/20, iPsizeY/25 )
    local sbar = SCPList:GetVBar()
    sbar:SetHideButtons( true )
    function sbar:Paint( w, h )
        draw.RoundedBox( 15, w/2, 0, w/3, h, Color( 45, 45, 45, 255 ) )
    end
    function sbar.btnUp:Paint( w, h )
        draw.RoundedBox( 0, 0, 0, w, h, Color( 150, 150, 150, 0 ) )
    end
    function sbar.btnDown:Paint( w, h )
        draw.RoundedBox( 0, 0, 0, w, h, Color( 150, 150, 150, 0 ) )
    end
    function sbar.btnGrip:Paint( w, h )
        draw.RoundedBox( 8, w/2, 0, w/3, h, Color( 80, 80, 80, 255 ) )
    end

    local iPSsizeX, iPSsizeY = SCPSoundPanel:GetWide(), SCPSoundPanel:GetTall()
    local SCPListSound = vgui.Create( "DScrollPanel", SCPSoundPanel )
    SCPListSound:SetSize( iPSsizeX/1.05, iPSsizeY/1.08 )
    SCPListSound:SetPos( iPSsizeX/35, iPSsizeY/25 )
    local sbar = SCPListSound:GetVBar()
    sbar:SetHideButtons( true )
    function sbar:Paint( w, h )
        draw.RoundedBox( 15, w/2, 0, w/3, h, Color( 45, 45, 45, 255 ) )
    end
    function sbar.btnUp:Paint( w, h )
        draw.RoundedBox( 0, 0, 0, w, h, Color( 150, 150, 150, 0 ) )
    end
    function sbar.btnDown:Paint( w, h )
        draw.RoundedBox( 0, 0, 0, w, h, Color( 150, 150, 150, 0 ) )
    end
    function sbar.btnGrip:Paint( w, h )
        draw.RoundedBox( 8, w/2, 0, w/3, h, Color( 80, 80, 80, 255 ) )
    end

    for i=1, #SCPALARM.config.sound do
        local SCPCatButton = SCPList:Add( "DButton" )
        SCPCatButton:Dock( TOP )
        SCPCatButton:DockMargin( 0, 0, 0, 8 )
        SCPCatButton:SetText( "" )
        SCPCatButton:SetSize( iPsizeX/6, iPsizeY/6.1 )
        SCPCatButton.Paint = function( self, iW, iH )
            if SCPCatButton:IsHovered() or i == iSaver then
                draw.RoundedBox( 8, 0, 0, iW, iH, Color( 89, 93, 105,255 ) )
                draw.SimpleText( SCPALARM.config.sound[i].name, "SCPALARM::Text", i == iSaver and iW/7 or iW/20, iH/2, i == iSaver and Color( 255, 255, 255, 255 ) or Color( 200, 200, 200, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
            else
                draw.RoundedBox( 8, 0, 0, iW, iH, i == iSaver and Color( 89, 93, 105,255 ) or Color( 59, 63, 75,255 ) )
                draw.SimpleText( SCPALARM.config.sound[i].name, "SCPALARM::Text", iW/20, iH/2, Color( 200, 200, 200, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
            end
            if i == iSaver then
                draw.RoundedBox( 20, iW/15, iH/6, iW/30, iH/1.5, Color( 46, 204, 113,255 ) )
            end
        end
        SCPCatButton.DoClick = function()
            chat.PlaySound()
            iSaver = i
            SCPListSound:GetCanvas():Clear()
            for i=1, #SCPALARM.config.sound[iSaver].song do
                SCPALARM.AddSoundButton( SCPListSound, iPSsizeX, iPSsizeY, iSaver, i )
            end
        end
    end

    if iSaver ~= 0 then
        for i=1, #SCPALARM.config.sound[iSaver].song do
            SCPALARM.AddSoundButton( SCPListSound, iPSsizeX, iPSsizeY, iSaver, i )
        end
    end

    local SCPPlayButton = vgui.Create( "DButton", SCPBackground )
    SCPPlayButton:SetFont( "SCPALARM::Cross" )
    SCPPlayButton:SetText( "" )
    SCPPlayButton:SetPos( iWide/3.1, iTall/1.25 )
    SCPPlayButton:SetSize( iWide/3.1, iTall/18 )
    SCPPlayButton.DoRightClick = function()
        if iSaver ~= 0 and SCPALARM.config.sound[iSaver] and #SCPALARM.config.sound[iSaver].song ~= 0 then
            local SCPOptionList = DermaMenu()
            SCPOptionList:AddOption("Play locally", function()
                iPlay = 1
            end)
            SCPOptionList:AddOption( "Play globally", function()
                iPlay = 2
            end)
            SCPOptionList:AddOption( "Play globally loop", function()
                iPlay = 3
            end)
            SCPOptionList:Open()
        end
    end
    SCPPlayButton.DoClick = function()
        if iSaver ~= 0 and iSongLink[1] ~= 0 and SCPALARM.config.sound[iSaver] and #SCPALARM.config.sound[iSaver].song ~= 0 then
            tFunc[iPlay].func()
        end
    end
    SCPPlayButton.Paint = function( self, iW, iH )
        draw.RoundedBox( 8, 0, 0, iW, iH, Color( 59, 63, 75,255 ) )
        draw.SimpleText( "Play".." "..tFunc[iPlay].name or "", "SCPALARM::Text", iW/2, iH/2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        if iSaver ~= 0 and iSongLink[1] ~= 0 and SCPALARM.config.sound[iSaver] and #SCPALARM.config.sound[iSaver].song ~= 0 then return end
            draw.RoundedBox( 8, 0, 0, iW, iH, Color( 40, 40, 40,190 ) )
    end

    local SCPStopButton = vgui.Create( "DButton", SCPBackground )
    SCPStopButton:SetFont( "SCPALARM::Cross" )
    SCPStopButton:SetText( "" )
    SCPStopButton:SetPos( iWide/1.515, iTall/1.25 )
    SCPStopButton:SetSize( iWide/3.1, iTall/18 )
    SCPStopButton.DoClick = function()
        net.Start( "SCPAlarms::NetComm" )
        net.WriteUInt( 2, 4 )
        net.SendToServer()
    end
    SCPStopButton.Paint = function( self, iW, iH )
        draw.RoundedBox( 8, 0, 0, iW, iH, Color( 59, 63, 75,255 ) )
        draw.SimpleText( "Stop", "SCPALARM::Text", iW/2, iH/2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        if iSaver ~= 0 and iSongLink[1] ~= 0 and SCPALARM.config.sound[iSaver] and #SCPALARM.config.sound[iSaver].song ~= 0 then return end
            draw.RoundedBox( 8, 0, 0, iW, iH, Color( 40, 40, 40,190 ) )
    end
end

function SCPALARM.AddSoundButton( tSelf, iPsizeX, iPsizeY, iCat, iSong )
    local SCPSoundButton = tSelf:Add( "DButton" )
    SCPSoundButton:Dock( TOP )
    SCPSoundButton:DockMargin( 0, 0, 0, 8 )
    SCPSoundButton:SetText( "" )
    SCPSoundButton:SetSize( iPsizeX/6, iPsizeY/6.3 )
    SCPSoundButton.Paint = function( self, iW, iH )
        if SCPSoundButton:IsHovered()  then
            draw.RoundedBox( 8, 0, 0, iW, iH, Color( 89, 93, 105,255 ) )
            draw.SimpleText( SCPALARM.config.sound[iSaver].song[iSong].name, "SCPALARM::Text", iW/20, iH/2, i == iSaver and Color( 255, 255, 255, 255 ) or Color( 200, 200, 200, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
        else
            draw.RoundedBox( 8, 0, 0, iW, iH, i == iSaver and Color( 89, 93, 105,255 ) or Color( 59, 63, 75,255 ) )
            draw.SimpleText( SCPALARM.config.sound[iSaver].song[iSong].name, "SCPALARM::Text", iW/20, iH/2, Color( 200, 200, 200, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
        end
        if iSong == iSongLink[2] and iCat == iSongLink[1] then
            draw.RoundedBoxEx( 8, 0, 0, iW/35, iH, Color( 46, 204, 113,255 ), true, false, true, false )
        end
    end
    SCPSoundButton.DoClick = function()
        chat.PlaySound()
        iSongLink = {
            iCat,
            iSong
        }
    end
end

-- Command for open
concommand.Add("scp_alarm", function(ply, cmd, args, argSstr)
    SCPALARM.OpenMenu()
end)

hook.Add("OnPlayerChat", "ScpA_open_menu", function(ply, text, teamChat, isDead)
    if (ply ~= LocalPlayer()) then return end
    local text = string.lower(text)
    if not tCMDMenuOpen[text] then return end
    SCPALARM.OpenMenu()
    return true
end)
