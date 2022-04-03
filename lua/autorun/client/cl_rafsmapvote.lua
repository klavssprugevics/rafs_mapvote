AddCSLuaFile()
include('rafsmapvote_config.lua')


if CLIENT then

    -- Fonts
    surface.CreateFont('TitleFont', {
        font = 'Trebuchet24',
        extended = true,
        size = 40,
        weight = 900,
        antialias = true,
    })

    surface.CreateFont('ButtonFont', {
        font = 'Trebuchet24',
        extended = true,
        size = 30,
        weight = 600,
        antialias = true,
    })

    surface.CreateFont('XFont', {
        font = 'Trebuchet24',
        extended = true,
        size = 40,
        weight = 6000,
        antialias = true,
    })

    surface.CreateFont('TextOverImageFont', {
        font = 'Trebuchet24',
        extended = true,
        size = 30,
        weight = 3000,
        antialias = true,
    })





    -- Read config file
    settings = rafsconfig()
    local thumbnailDir = settings['thumbnail_directory']
    local screenW = ScrW()
    local screenH = ScrH()
    local uiWidth = screenW * 0.75
    local uiHeight = screenH * 0.8
    local imgWidth = (uiWidth - 20) / 3  
    local imgHeight = (imgWidth- 20) / 16 * 9 
    local startingPosX = 5
    local startingPosY = 55
    local mapVotes = {}
    local avatarStartingSize = 32
    local avatarSize = (imgWidth - 65) / 12
    local allAvatars = {}
    local allPlayers = {}
    local allPos = {}
    local playerVotes = {}
    local closed = false


    local function bumpAvatar(av, vo, pos) 

        pos = pos + 0
        local xpos, ypos = av:GetPos()
        local imgpos = allPos[vo]

        if pos <= 12 and pos ~= 1 then
            -- Bump everyone back by xpos
            xpos = xpos - avatarSize - 5

        elseif pos == 13 then
            -- Bump 2nd row 1st to 1st row last
            xpos = imgpos[1] + 11 * (5 + avatarSize) + 5
            ypos = ypos - avatarSize - 5

        elseif pos > 13 and pos <= 24 then
            -- Bump everyone back by xpos
            xpos = xpos - avatarSize - 5

        elseif pos == 25 then
            -- Bump 3rd row 1st to 2nd row last
            xpos = imgpos[1] + 11 * (5 + avatarSize) + 5
            ypos = ypos - avatarSize - 5

        elseif pos > 25 and pos <= 36 then
            -- Bump everyone back by xpos
            xpos = xpos - avatarSize - 5

        elseif pos == 37 then
            -- Bump 4th row 1st to 3rd row last
            xpos = imgpos[1] + 11 * (5 + avatarSize) + 5
            ypos = ypos - avatarSize - 5

        elseif pos > 37 then
            -- Bump everyone back by xpos
            xpos = xpos - avatarSize - 5
        end

        av:MoveTo(xpos, ypos, 0.3, 0.1, -5)
        -- av:SetPos(xpos, ypos, 0.3, 0.1, -5)
        print('------------')
    end


    net.Receive('start_mapvote', function(len)
        local maps = net.ReadTable()
        allPlayers = player:GetAll()

        local Frame = vgui.Create('DFrame')
        Frame:SetTitle('')
        Frame:SetSize(uiWidth, uiHeight)
        Frame:Center()
        Frame:SetDraggable(false)
        Frame:ShowCloseButton(false)
        Frame:MakePopup()
        
        Frame.Paint = function(self, width, height)
            draw.RoundedBox(0, 0, 0, width, height, Color(125, 125, 125, 0))
            Derma_DrawBackgroundBlur(self, SysTime())
            draw.RoundedBox(0, 0, 0, width, 45, Color(50, 50, 50, 200))
            draw.RoundedBox(0, startingPosX - 15, startingPosY - 5, width + 15, imgHeight * 2 + 15, Color(50, 50, 50, 200))
            draw.RoundedBox(0, startingPosX - 15, startingPosY + (imgHeight + 5) * 2 + 5, (imgWidth + 10) * 2, imgHeight / 3, Color(50, 50, 50, 200))
            -- surface.SetDrawColor(255, 255, 255, 200)
            -- draw.NoTexture()
            -- radius = imgHeight / 3 / 2 - 7
            -- draw.Circle(startingPosX + radius, startingPosY + (imgHeight + 5) * 2 + 5 + radius + 5, radius, 100)
            -- surface.SetDrawColor(50, 50, 50, 255)
        end
        
        titleLabel = vgui.Create('DLabel', Frame)
        titleLabel:SetText('Vote for the next map:')
        titleLabel:SetTextColor(Color(255, 255, 255))
        titleLabel:SetFont('TitleFont')
        titleLabel:SetPos(10, 0)
        titleLabel:SizeToContents()
        

        local closeButton = vgui.Create('DButton', Frame)
        closeButton:SetText('X')
        closeButton:SetPos(uiWidth - 40, 0)
        closeButton:SetTextColor(Color(255, 255, 255))
        closeButton:SetFont('XFont')
        closeButton:SetSize(40, 40)

        closeButton.Paint = function(self, width, height)
            draw.RoundedBox(0, uiWidth - 60, 5, 16, 16, Color(255, 255, 255, 0))
        end

        closeButton.DoClick = function()
            Frame:Close()
            closed = true
        end
        
  
        local randomButton = vgui.Create('DButton', Frame)
        randomButton:SetText('Random map')
        randomButton:SetPos((imgWidth + 5) * 2 + 5, startingPosY + (imgHeight + 5) * 2 + 5)
        randomButton:SetSize(imgWidth + 15, imgHeight / 3)
        randomButton:SetTextColor(Color(255, 255, 255))
        randomButton:SetFont('ButtonFont')
        
        randomButton.Paint = function(self, width, height)
            draw.RoundedBox(0, 0, 0, width, height, Color(50, 50, 50, 200))
        end      

        randomButton.DoClick = function()
            net.Start('map_choice')
            net.WriteString('random')
            net.SendToServer()
        end

        for k, v in pairs(maps) do
    
            local mapName = v
            
            local mapVoteImage = vgui.Create('DImageButton', Frame)
            local mapLabel = vgui.Create('DLabel', Frame)
            mapLabel:SetText(mapName)
            mapLabel:SetTextColor(Color(255, 255, 255))
            mapLabel:SetFont('TextOverImageFont')
            mapLabel:SetSize(imgWidth, 40)
            
            if k < 4 then
                xpos = startingPosX + (imgWidth + 5) * (k - 1)
                ypos = startingPosY
                mapVoteImage:SetPos(xpos,ypos)
                mapLabel:SetPos(xpos + 5, ypos + imgHeight - 40)
            else
                xpos = startingPosX + (imgWidth + 5) * (k - 4)
                ypos = startingPosY + imgHeight + 5
                mapVoteImage:SetPos(xpos,ypos)
                mapLabel:SetPos(xpos + 5, ypos + imgHeight - 40)
            end
        
            mapVoteImage:SetSize(imgWidth, imgHeight)

            fileName = thumbnailDir .. mapName .. '.jpg'
            if file.Exists(fileName, 'data') then
                mapVoteImage:SetImage('data/' .. fileName)
            else
                mapVoteImage:SetMaterial('models/rendertarget')
            end
            
            local temp = {}
            mapVotes[v] = temp
            allPos[v] = {xpos, ypos}

            mapVoteImage.DoClick = function()
                net.Start('map_choice')
                net.WriteString(mapName)
                net.SendToServer()
            end

        end


        -- Initial position of avatars
        local xposCounter, yposCounter = startingPosX, startingPosY + (imgHeight + 5) * 2 + 10
        local counter = 1
        for key, p in pairs(allPlayers) do
            playerVotes[p] = -1
            local avatar = vgui.Create('AvatarImage', Frame)
            avatar:SetSize(avatarStartingSize, avatarStartingSize)
            avatar:SetPos(xposCounter, yposCounter)
            avatar:SetPlayer(p, 32)
            avatar:SetTooltip(p:GetName())
            avatar:SetParent(Frame)
            allAvatars[p] = avatar
            if counter == 18 then
                yposCounter = yposCounter + avatarStartingSize + 5
                xposCounter = startingPosX
            else
                xposCounter = xposCounter + avatarStartingSize + 5
            end
            counter = counter + 1
        end


        net.Receive('next_map', function()
            if closed then
                return
            end
            local nextMap = net.ReadString()
            titleLabel:SetText('Vote for the next map: ' .. nextMap)
            titleLabel:SizeToContents()
    
            -- To do: Some flashy effect
        end)

        -- Update avatars 
        net.Receive('refresh_votes', function(len)
            if closed then
                return
            end
            local votes = net.ReadTable()
            print('~_~__~_~__~_~_~__~_~_')
            PrintTable(mapVotes)


            -- Update mapvotes
            for player, vote in pairs(votes) do
                local playerPrevVote = playerVotes[player]
                local swapIndex = -1


                if playerPrevVote ~= vote then
                    if playerPrevVote ~= -1 then
                        local votesToUpdate = mapVotes[playerPrevVote]
                        print('yeey!')
                        PrintTable(votesToUpdate)
                        
                        -- Remove vote from list
                        for k, v in pairs(votesToUpdate) do
                            if player == v then
                                print('REMOVING!!!!!!')
                                print(k, v)
                                votesToUpdate[k] = nil
                                swapIndex = k
                                break
                            end
                        end
                        print('--')
                        PrintTable(votesToUpdate)
                        print('ooff')
                        local bump = false
                        -- Bump up everyone else
                        if swapIndex ~= #votesToUpdate then
                            for i = swapIndex, #votesToUpdate, 1 do
                                if votesToUpdate[i + 1] ~= nil then
                                    votesToUpdate[i] = votesToUpdate[i + 1]

                                    for pl, vo in pairs(playerVotes) do
                                        if vo == playerPrevVote then
                                            local av = allAvatars[pl]
                                            bumpAvatar(av, vo, i + 1)
                                            bump = true
                                        end
                                    end
                                end
                            end
                            PrintTable(votesToUpdate)
                            print(playerPrevVote)
                            if bump then
                                votesToUpdate[#votesToUpdate] = nil
                            end
                            PrintTable(votesToUpdate)

                        end
                        print('nooff')
                        PrintTable(mapVotes)
                        mapVotes[playerPrevVote] = votesToUpdate
                        PrintTable(mapVotes)
                    end

                    print('~_~__~_~__~_~_~__~_~_')

                    local av = allAvatars[player]
                    local pos = allPos[vote]
                    av:SetSize(avatarSize, avatarSize)

                    local newXpos = 0
                    local newYpos = 0
                    local currVotes = #mapVotes[vote] + 0
                    
                    print('=============')
                    print(currVotes)




                    -- Calculate new position
                    if currVotes < 12 then
                        newXpos = pos[1] + currVotes * (5 + avatarSize) + 5
                        newYpos = pos[2]
                    elseif currVotes >= 12 and currVotes < 24 then
                        newXpos = pos[1] + (currVotes - 12) * (5 + avatarSize) + 5
                        newYpos = pos[2] + avatarSize + 10
                    elseif currVotes >= 24 and currVotes < 36 then
                        newXpos = pos[1] + (currVotes - 24) * (5 + avatarSize) + 5
                        newYpos = pos[2] + 2 * avatarSize + 15
                    else
                        newXpos = pos[1] + (currVotes - 36) * (5 + avatarSize) + 5
                        newYpos = pos[2] + 3 * avatarSize + 20
                    end
                    
                    av:MoveTo(newXpos, newYpos + 5, 0.3, 0.1, -20)

                    -- Add new vote to the ending
                    local temp = mapVotes[vote]
                    temp[#mapVotes[vote] + 1] = player
                    mapVotes[vote] = temp
                    playerVotes[player] = vote

                    PrintTable(mapVotes)
                    print('=============')



                end
            end

            -- To do: Maybe some funny sound
        end)

    end)
end