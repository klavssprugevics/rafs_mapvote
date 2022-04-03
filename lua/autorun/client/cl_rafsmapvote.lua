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

    -- Calculate UI element sizes based on screen size
    local screenW = ScrW()
    local screenH = ScrH()
    local uiWidth = screenW * 0.75
    local uiHeight = screenH * 0.8
    local _imgWidth = (uiWidth - 20) / 3  
    local _imgHeight = (_imgWidth- 20) / 16 * 9 
    local startingPosX = 5
    local startingPosY = 55
    local avatarStartingSize = 32
    local avatarSize = (_imgWidth - 65) / 12

    local mapVotes = {}
    local allAvatars = {}
    local allPlayers = {}
    local allPos = {}
    local playerVotes = {}
    local closed = false


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
            draw.RoundedBox(0, startingPosX - 15, startingPosY - 5, width + 15, _imgHeight * 2 + 15, Color(50, 50, 50, 200))
            draw.RoundedBox(0, startingPosX - 15, startingPosY + (_imgHeight + 5) * 2 + 5, (_imgWidth + 10) * 2, _imgHeight / 3, Color(50, 50, 50, 200))
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
        randomButton:SetPos((_imgWidth + 5) * 2 + 5, startingPosY + (_imgHeight + 5) * 2 + 5)
        randomButton:SetSize(_imgWidth + 15, _imgHeight / 3)
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
            mapLabel:SetSize(_imgWidth, 40)
            
            if k < 4 then
                xpos = startingPosX + (_imgWidth + 5) * (k - 1)
                ypos = startingPosY
                mapVoteImage:SetPos(xpos,ypos)
                mapLabel:SetPos(xpos + 5, ypos + _imgHeight - 40)
            else
                xpos = startingPosX + (_imgWidth + 5) * (k - 4)
                ypos = startingPosY + _imgHeight + 5
                mapVoteImage:SetPos(xpos,ypos)
                mapLabel:SetPos(xpos + 5, ypos + _imgHeight - 40)
            end
        
            mapVoteImage:SetSize(_imgWidth, _imgHeight)

            fileName = settings['thumbnail_directory'] .. mapName .. '.jpg'
            if file.Exists(fileName, 'data') then
                mapVoteImage:SetImage('data/' .. fileName)
            else
                mapVoteImage:SetMaterial('models/rendertarget')
            end
            
            allPos[v] = {xpos, ypos}

            mapVoteImage.DoClick = function()
                net.Start('map_choice')
                net.WriteString(mapName)
                net.SendToServer()
            end

        end


        -- Initial position of avatars
        local xposCounter, yposCounter = startingPosX, startingPosY + (_imgHeight + 5) * 2 + 10
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

            -- Update mapvotes
            for _pl, _vote in pairs(votes) do
                local prev_vote = playerVotes[_pl]

                if _prevVote ~= _vote then

                    playerVotes[player] = _vote

                end
            end

        end)

    end)
end