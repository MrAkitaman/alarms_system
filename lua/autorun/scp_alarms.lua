local VERSION = {"3.2", "06/07/2021"}

if SERVER then
    util.AddNetworkString("SCPAlarms::PlayGloballyToServer")
    util.AddNetworkString("SCPAlarms::PlayGloballyToClient")
    util.AddNetworkString("SCPAlarms::StopLoopToServer")
    util.AddNetworkString("SCPAlarms::StopLoopToClient")
    util.AddNetworkString("SCPAlarms::Notification")

    net.Receive("SCPAlarms::PlayGloballyToServer", function(len, ply)
        local url = net.ReadString()
        local looping = net.ReadBool()
        local soundName = net.ReadString()
        local volume = net.ReadFloat()
        if not ply:IsAdmin() then
            --looping = false
            return
        end
        print(string.format("[SCP Alarms] User \"%s\" (SteamID : %s) just globally ran \"%s\" (looping = %s, volume = %s):\n%s", ply:GetName(), ply:SteamID(), soundName, looping, tostring(math.Round(volume, 1)), url))
        net.Start("SCPAlarms::PlayGloballyToClient")
            net.WriteString(url)
            net.WriteBool(looping)
            net.WriteFloat(volume)
        net.Broadcast()
    end )

    net.Receive("SCPAlarms::StopLoopToServer", function(len, ply)
        print(string.format("[SCP Alarms] User \"%s\" (SteamID : %s) just stopped the global sound looping.", ply:GetName(), ply:SteamID()))
        net.Start("SCPAlarms::StopLoopToClient")
        net.Broadcast()
    end )

    --Creator joining annoucement
    local tCreator = {
        ["STEAM_0:0:90915574"] = true,
        ["STEAM_0:1:178656014"] = true,
    }

    hook.Add("PlayerInitialSpawn", "FullLoadSetup", function( pPly )
        if tCreator[pPly:SteamID()] then
            net.Start("SCPAlarms::Notification")
            net.WriteString("My creator "..pPly:Name().." just join the server.")
            net.Broadcast()
        end
    end)
end

-- CLIENT
if CLIENT then
    local cRed = Color(255,0,0)
    local cWhite = Color(255,255,255)
    local cYellow = Color(255,229,0)
    -- Alphanum Algorithm
        -- split a string into a table of number and string values
        function splitbynum(s)
            local result = {}
            for x, y in (s or ""):gmatch("(%d*)(%D*)") do
                if x ~= "" then table.insert(result, tonumber(x)) end
                if y ~= "" then table.insert(result, y) end
            end
            return result
        end

        -- compare two strings
        function alnumcomp(x, y)
            local xt, yt = splitbynum(x), splitbynum(y)
            for i = 1, math.min(#xt, #yt) do
                    local xe, ye = xt[i], yt[i]
                    if type(xe) == "string" then ye = tostring(ye)
                    elseif type(ye) == "string" then xe = tostring(xe) end
                    if xe ~= ye then return xe < ye end
            end
            return #xt < #yt
        end

        -- sort a given table of strings the way humans would expect
        function sortnicely(t)
            return table.sort(t, alnumcomp)
        end

    surface.CreateFont("Custom1", {
        font = "Roboto",
        size = 24
    } )
    surface.CreateFont("Custom2", {
        font = "Roboto",
        size = 12
    } )

    net.Receive("SCPAlarms::Notification", function()
        chat.AddText(cWhite, "[", cRed, "SCP Alarms", cWhite, "] ", cYellow, net.ReadString())
    end)

    net.Receive("SCPAlarms::PlayGloballyToClient", function()
        local url = net.ReadString()
        local looping = net.ReadBool()
        local volume = net.ReadFloat()
        sound.PlayURL(url, "noblock noplay", function(MySound, errorID, errorName)
            if ( IsValid(MySound) ) then
                MySound:SetVolume(volume)
                if looping then
                    MySound:EnableLooping(true)
                    MySound:Play()
                    LocalPlayer():ChatPrint("[SCP Alarms] A new sound is looping, type \"!stoploop\" to disable the loop")
                    hook.Add("OnPlayerChat", "SCPKillLoopTimer", function(ply, text)
                        if (ply ~= LocalPlayer()) then return end
                        if (text ~= "!stoploop") then return end
                        MySound:EnableLooping(false)
                        hook.Remove("OnPlayerChat", "SCPKillLoopTimer")
                        timer.Simple(1, function() LocalPlayer():ChatPrint("[SCP Alarms] No more looping for you!") end)
                    end)
                    hook.Add("serverDisableLoop", "SCPKillLoopServer", function()
                        MySound:EnableLooping(false)
                        hook.Remove("serverDisableLoop", "SCPKillLoopServer")
                    end)
                else
                    MySound:Play()
                end
            else
                LocalPlayer():ChatPrint(string.format("[SCP Alarms] Error while trying to play a sound (%s: %s).", errorID, errorName))
            end
        end )
    end )

    net.Receive("SCPAlarms::StopLoopToClient", function()
        hook.Call("serverDisableLoop")
    end )

    function open_vgui(eBox)

        // Base vgui
        local frame = vgui.Create("DFrame")
        frame:SetSizable(false)
        frame:SetSize(512, 530)
        frame:SetTitle(string.format("[%s] SCP Alarms", VERSION[1]))
        frame:Center()
        frame:MakePopup()

        local welcome_txt = vgui.Create("DLabel", frame)
        welcome_txt:SetSize(180, 20)
        welcome_txt:SetPos(166, 40)
        welcome_txt:SetFont("Custom1")
        welcome_txt:SetText(string.format("Welcome %s !", LocalPlayer():GetName()))


        // Dlist
        local dlist = vgui.Create("DListView", frame)
        dlist:SetSize(246, 339)
        dlist:SetPos(256, 75)
        dlist:SetMultiSelect(false)
        dlist:SetSortable(false)

        dlist:AddColumn("Sound")

        // Dtree
        local dtree = vgui.Create("DTree", frame)
        dtree:SetSize(246, 326)
        dtree:SetPos(10, 88)

        local choose_a_folder_warning = vgui.Create("DLabel", frame)
        choose_a_folder_warning:SetPos(329, 224)
        choose_a_folder_warning:SetSize(101, 42)
        choose_a_folder_warning:SetText("Please select a folder\n    on the left menu.")

        local thisFolderIsEmpty = vgui.Create("DLabel", frame)
        thisFolderIsEmpty:SetPos(343, 224)
        thisFolderIsEmpty:SetSize(83, 42)
        thisFolderIsEmpty:SetText("This folder have\n     no sounds.")
        thisFolderIsEmpty:SetVisible(false)

        local downloadingList = vgui.Create("DLabel", frame)
        downloadingList:SetPos(92, 224)
        downloadingList:SetSize(93, 42)
        local downloadingListDefaultText = "Retrieving sounds\n   list from server"
        downloadingList:SetText(downloadingListDefaultText)

        local downloadingListAnimI = 0
        timer.Create("downloadingListAnimation", 1, 0, function()
            if IsValid(frame) then
                downloadingListAnimI = downloadingListAnimI + 1
                if (downloadingListAnimI == 1) then
                    downloadingList:SetText(downloadingListDefaultText..".")
                elseif (downloadingListAnimI == 2) then
                    downloadingList:SetText(downloadingListDefaultText.."..")
                else
                    downloadingList:SetText(downloadingListDefaultText.."...")
                    downloadingListAnimI = 0
                end
            else
                timer.Destroy("downloadingListAnimation")
            end
        end)

        local dtree_head = vgui.Create("DButton", frame)
        dtree_head:SetText("Library")
        dtree_head:SetSize(246, 16)
        dtree_head:SetPos(10, 75)
        dtree_head.DoClick = function() end

        local background_footer = vgui.Create("DPanel", frame)
        background_footer:SetSize(512, 100)
        background_footer:SetPos(0, 430)
        background_footer:SetBackgroundColor(Color(96, 96, 96, 255))

        local play_locally_button = vgui.Create("DButton", frame)
        play_locally_button:SetSize(250, 41)
        play_locally_button:SetPos(5, 444)
        play_locally_button:SetText("Play the sound locally")
        play_locally_button:SetEnabled(false)

        local play_globally_button = vgui.Create("DButton", frame)
        play_globally_button:SetSize(250, 41)
        play_globally_button:SetPos(257, 444)
        play_globally_button:SetText("Play the sound globally")
        play_globally_button:SetEnabled(false)

        local stopsounds_button = vgui.Create("DButton", frame)
        stopsounds_button:SetSize(250, 15)
        stopsounds_button:SetPos(5, 487)
        stopsounds_button:SetText("Run \"stopsound\" command")
        stopsounds_button.DoClick = function()
            RunConsoleCommand("stopsound")
        end

        local loop_activate_button = vgui.Create("DButton", frame)
        loop_activate_button:SetSize(124, 15)
        loop_activate_button:SetPos(257, 487)
        loop_activate_button:SetText("Enable loop")
        loop_activate_button:SetEnabled(LocalPlayer():IsAdmin())

        local loop_disable_button = vgui.Create("DButton", frame)
        loop_disable_button:SetSize(124, 15)
        loop_disable_button:SetPos(383, 487)
        loop_disable_button:SetText("Stop loop")
        loop_activate_button:SetEnabled(LocalPlayer():IsAdmin())

        // Volume slider
        local background_volume_slider = vgui.Create("DPanel", frame)
        background_volume_slider:SetSize(170, 19)
        background_volume_slider:SetPos(335, 507)
        background_volume_slider:SetBackgroundColor(Color(180, 180, 180, 255))

        local volume_slider_text = vgui.Create("DLabel", frame)
        volume_slider_text:SetPos(340, 506)
        volume_slider_text:SetSize(40, 19)
        volume_slider_text:SetText("Volume:")
        volume_slider_text:SetTextColor(Color(0, 0, 0, 255))

        local volume_slider = vgui.Create("DNumSlider", frame)
        volume_slider:SetPos(275, 507)
        volume_slider:SetSize(250, 19)
        volume_slider:SetMinMax(0, 3)
        volume_slider:SetDecimals(1)
        volume_slider:SetDefaultValue(1.0)
        volume_slider:SetValue(volume_slider:GetDefaultValue())

        local background_volume_slider1 = vgui.Create("DPanel", frame)
        background_volume_slider1:SetSize(83, 19)
        background_volume_slider1:SetPos(257, 507)
        background_volume_slider1:SetBackgroundColor(Color(0, 0, 0, 0))


        // Footer buttons
        local background_footer_button = vgui.Create("DPanel", frame)
        background_footer_button:SetSize(55, 19)
        background_footer_button:SetPos(7, 507)
        background_footer_button:SetBackgroundColor(Color(180, 180, 180, 255))

        local workshop_button = vgui.Create("DImageButton", frame)
        workshop_button:SetSize(15, 15)
        workshop_button:SetPos(9, 509)
        workshop_button:SetImage("icon16/cart_go.png")
        workshop_button:SizeToContents()
        workshop_button.DoClick = function()
            gui.OpenURL("https://steamcommunity.com/sharedfiles/filedetails/?id=1166449179")
        end

        local bug_button = vgui.Create("DImageButton", frame)
        bug_button:SetSize(15, 15)
        bug_button:SetPos(27, 509)
        bug_button:SetImage("icon16/bug_go.png")
        bug_button:SizeToContents()
        bug_button.DoClick = function()
            gui.OpenURL("https://steamcommunity.com/sharedfiles/filedetails/discussions/1166449179")
        end

        local credits_button = vgui.Create("DImageButton", frame)
        credits_button:SetSize(15, 15)
        credits_button:SetPos(45, 509)
        credits_button:SetImage("icon16/book_go.png")
        credits_button:SizeToContents()
        credits_button.DoClick = function()
            Derma_Message(string.format("Thank you for downloading and using my add-on.\n\n---------ADD-ON---------\nVersion: %s (%s).\nCreator of the add-on: Cyborger\nLicense: GNU GENERAL PUBLIC LICENSE V3\n\nThe Alphanum Algorithm (Values Sorting algorithm): http://www.davekoelle.com/alphanum.html\n\n---------SOUNDS---------\nSCP:CB Sounds: Undertow Games (https://www.scpcbgame.com/ http://undertowgames.com/)\nSCP:SL Sounds: Northwood Studios (https://store.steampowered.com/developer/NWStudios)", VERSION[1], VERSION[2]), "About", "Close")
        end


        -- #######################################

        local dListLines = {}
        local nodes = {}
        local volumeValue = volume_slider:GetDefaultValue()

        if not LocalPlayer():IsAdmin() then
            LocalPlayer():ChatPrint("[SCP Alarms] You must be a server admin to loop sounds")
        end

        function local_playsound(url, looping)
            local looping = looping or false
            sound.PlayURL(url, "noplay", function(soundchannel, errorID, errorName)
                if ( IsValid(soundchannel) ) then
                    function playSound()
                        if looping then
                            LocalPlayer():ChatPrint("[SCP Alarms] Warning, looping sounds locally is not supported. Please play the sound globally to use this function.")
                        end
                        soundchannel:SetVolume(volumeValue)
                        soundchannel:Play()
                    end

                    if (volumeValue > 2.0) then
                        Derma_Query("The volume is superior to 2.0, this can be very loud. Do you really want to play the sound at this volume?", "Confirmation", "NO", function() end, "YES", function() playSound() end)
                    elseif (volumeValue == 0) then
                        Derma_Message("You can't play the sound at volume 0.0!", "Alert", "OK")
                        return
                    else
                        playSound()
                    end
                else
                    LocalPlayer():ChatPrint(string.format("[SCP Alarms] Error while trying to play the sound (%s: %s).", errorID, errorName))
                end
            end )
        end

        function volume_slider:OnValueChanged(value)
            local roundedValue = math.Round(value, 1)
            volume_slider:SetValue(roundedValue)
            volumeValue = roundedValue
        end

        loop_activate_button.DoClick = function()
            if (loop_activate_button:GetText() == "Enable loop") then
                loop_activate_button:SetText("Disable loop")
            else
                loop_activate_button:SetText("Enable loop")
            end
        end

        loop_disable_button.DoClick = function()
            net.Start("SCPAlarms::StopLoopToServer")
            net.SendToServer()
        end

        function setUrl(rowIndex)
            return dListLines[rowIndex][2]
        end

        function dlist:DoDoubleClick(lineID, line)
            local_playsound(setUrl(lineID))
        end

        function dlist:OnRowRightClick(lineID, line)
            local menu = DermaMenu()
            menu:AddOption("Play locally", function() playLocally() end)
            menu:AddOption("Play globally", function() playGlobally() end)
            menu:AddOption("Close", function() end)
            menu:Open()
        end

        function dlist:OnRowSelected(rowIndex, row)
            local url = setUrl(rowIndex)
            if url ~= "nil" then
                play_locally_button:SetEnabled(true)
                play_globally_button:SetEnabled(true)
            end
        end

        function dlist_reset()
            dlist:Clear()
            dListLines = {}
            thisFolderIsEmpty:SetVisible(false)
            choose_a_folder_warning:SetVisible(false)
            play_locally_button:SetEnabled(false)
            play_globally_button:SetEnabled(false)
        end

        -- Play functions
        function playLocally()
            local_playsound(setUrl(dlist:GetSelectedLine()))
        end

        function playGlobally()
            function playSound()
                local selectedLineID, selectedLine = dlist:GetSelectedLine()
                net.Start("SCPAlarms::PlayGloballyToServer")
                    net.WriteString(setUrl(selectedLineID))
                    net.WriteBool(loop_activate_button:GetText() == "Disable loop")
                    net.WriteString(selectedLine:GetValue(1))
                    net.WriteFloat(volumeValue)
                net.SendToServer()
            end

            if (volumeValue > 2.0) then
                Derma_Query("The volume is superior to 2.0, this can be very loud for some people. If this was not set intentionally, please set the volume to 1.0. Do you really want to play the sound at this volume?", "Confirmation", "NO", function() end, "YES", function() playSound() end)
            elseif (volumeValue == 0) then
                Derma_Message("You can't play the sound at volume 0.0!", "Alert", "OK")
                return
            else
                playSound()
            end
        end

        -- Buttons function
        play_locally_button.DoClick = function()
            playLocally()
        end

        play_globally_button.DoClick = function()
            playGlobally()
        end

        -- DTree

        function dtree:OnNodeSelected(node)
            if nodes ~= {} then
                for k, v in pairs(nodes) do
                    if node == v[1] and v[2] ~= nil then
                        local unsortedKeys = table.GetKeys(v[2])
                        local sortedKeys = {}

                        for __, v1 in pairs(unsortedKeys) do
                            table.insert(sortedKeys, tostring(v1))
                        end

                        sortnicely(sortedKeys)
                        dlist_reset()

                        local empty = true
                        for __, v1 in ipairs(sortedKeys) do
                            local key = v1
                            local value = v[2][key]
                            if type(value) == "string" then
                                empty = false
                                table.insert(dListLines, {dlist:AddLine(key), value})
                            end
                        end
                        if (empty) then
                            thisFolderIsEmpty:SetVisible(true)
                        end
                    end
                end
            end
        end

        function listDownloaded(rawDTree)
            if rawDTree ~= nil then

                function addNodes(raw, parent)
                    if raw ~= nil then
                        local rawKeys = table.GetKeys(raw)
                        local stringKeys = {}

                        for k, v in pairs(raw) do
                            table.insert(stringKeys, tostring(k))
                        end

                        sortnicely(stringKeys)
                        downloadingList:SetVisible(false)
                        timer.Destroy("downloadingListAnimation")

                        for k, v in ipairs(stringKeys) do
                            local key = v
                            local value = raw[v]
                            if (value == nil) then value = raw[tonumber(v)] end
                            if type(value) == "table" then
                                local newParent = parent:AddNode(key, "icon16/folder.png")
                                table.insert(nodes, {newParent, value})
                                addNodes(raw[key], newParent)
                            end
                        end
                    end
                end

                addNodes(rawDTree, dtree)

                for k, v in pairs(nodes) do
                    if (v[1]:GetParentNode() == dtree:Root()) then
                        v[1]:SetExpanded(true, true)
                    end
                end
            end
        end

        function getList()
            -- json file to tell where to find remote content
            http.Fetch("https://gist.githubusercontent.com/Cyborger/d2a9a256de9a5d428735f60d3d9d8d66/raw/03bacaa80473e48c48406201ab1936342eba8aa2/scp_alarms.json",
                function (body, size , headers, code)
                    listDownloaded(util.JSONToTable(body))
                end,
                function (error)
                    local error_message = Derma_Message(string.format("An error has occured! Unable to request the list of sounds. (%s)", error), "Error", "Close")
                    function error_message:OnClose()
                        frame:Close()
                    end
                    return nil
                end)
        end

        getList()
    end

    function onCommand(ply, cmd)
        if ply:IsAdmin() then
            open_vgui()
        else
            LocalPlayer():ChatPrint("[SCP Alarms] Sorry, only admins can use this command. As a normal user please use the entity.")
        end
    end


    hook.Add("OnPlayerChat", "ScpA_open_menu", function(ply, text, teamChat, isDead)
        if (ply ~= LocalPlayer()) then return end
        local text = string.lower(text)
        local accpeted_input = {"!scp_menu", "!scp_alarm", "!scp_alarms", "!scp"}
        if not isDead and table.KeyFromValue(accpeted_input, text) then
            onCommand(ply, text)
        end
    end)

    concommand.Add("scp_alarm", function(ply, cmd, args, argSstr)
        onCommand(ply, cmd)
    end)

    net.Receive("SCPAlarms::OpenGui", function()
        open_vgui(net.ReadEntity())
    end)
end
