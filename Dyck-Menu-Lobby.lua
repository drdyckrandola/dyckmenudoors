    -- DENTRO DO SEU SCRIPT PRINCIPAL (APÓS A CRIAÇÃO DAS TABS)

    if IsLobby then
        local LobbyTab = Window:AddTab("Lobby")
        
        -- 1. AUTO JOIN ELEVATOR
        LobbyTab:AddToggle("AutoJoinElevator", {
            Text = "Auto Join Elevator",
            Default = false,
            Tooltip = "Automatically joins the selected player's elevator."
        })
        LobbyTab:AddDropdown("AutoJoinElevatorTarget", {
            Text = "Target",
            SpecialType = "Player",
            ExcludeLocalPlayer = true,
            Searchable = true
        })

        -- 2. REDEEM CODES
        local CodesList = {
            "67", "54", "41", "CHEDDAR BALLS", "XQC", "PENGUINZ0", 
            "KREEKCRAFT", "ISHOWSPEED", "DANTDM", "KUBZ SCOUTS", 
            "FIND THE TROLLFACES", "THINKNOODLES", "W", "RAGDOLL UNIVERSE", 
            "RAGDOLL MAYHEM", "BIJUU MIKE", "8BITRYAN", "SCREECHSUCKS", 
            "LORE", "ABCDEFGHIJKLMNOPQRSTUVWXYZ", "3rd", "LAZYDEVS", 
            "RAGDOLL COMBAT", "VOCAB HAVOC", "PATHSWAP", "JUMP OVER THE BRICK"
        }
        
        LobbyTab:AddButton("Redeem All Codes", function()
            Library:Notify("<b>[" .. MENU_NAME .. "]</b> Redeeming codes...")
            for _, Code in pairs(CodesList) do
                if RemotesFolder:FindFirstChild("ShopCode") then
                    RemotesFolder.ShopCode:FireServer(Code)
                end
                task.wait(5.1) -- Respeita o cooldown do jogo
            end
            Library:Notify("<b>[" .. MENU_NAME .. "]</b> Codes redeemed!")
        end)

        -- 3. CYCLE ACHIEVEMENTS
        local UnlockedBadges = {}
        local function ScanBadges()
            local list = Player.PlayerGui.MainUI:FindFirstChild("LobbyFrame")
            if not list then return end
            local achievements = list:FindFirstChild("Achievements")
            if not achievements then return end
            local badgeList = achievements:FindFirstChild("List")
            if not badgeList then return end
            
            for _, Frame in pairs(badgeList:GetChildren()) do
                if Frame:IsA("ImageButton") and Frame.ImageTransparency == 0 then
                    table.insert(UnlockedBadges, Frame.Name)
                end
            end
        end
        ScanBadges()

        LobbyTab:AddToggle("CycleAchievements", {
            Text = "Cycle Achievements",
            Default = false,
            Tooltip = "Rapidly equips a random badge."
        })
        LobbyTab:AddSlider("CycleAchievementsDelay", {
            Text = "Cycle Delay",
            Min = 0,
            Max = 1,
            Default = 0.1,
            Rounding = 2,
            Compact = true
        })

        local PreviousBadge = nil
        local LastBadgeChange = tick()
        
        task.spawn(function()
            while task.wait() do
                if not Toggles.CycleAchievements.Value then continue end
                if #UnlockedBadges == 0 then continue end
                
                if tick() - LastBadgeChange > Options.CycleAchievementsDelay.Value then
                    local Badge = UnlockedBadges[math.random(1, #UnlockedBadges)]
                    if Badge ~= PreviousBadge then
                        if RemotesFolder:FindFirstChild("FlexAchievement") then
                            RemotesFolder.FlexAchievement:FireServer(Badge)
                        end
                        PreviousBadge = Badge
                        LastBadgeChange = tick()
                    end
                end
            end
        end)

        -- 4. WALK SPEED (LOBBY)
        local CurrentWS = 16
        local WS_Enabled = false
        local Humanoid = Character and Character:FindFirstChild("Humanoid")

        local function ApplyLobbyWS()
            if Humanoid then
                Humanoid.WalkSpeed = WS_Enabled and CurrentWS or 16
            end
        end

        Player.CharacterAdded:Connect(function(char)
            Character = char
            Humanoid = char:WaitForChild("Humanoid")
            ApplyLobbyWS()
        end)

        LobbyTab:AddSlider("WSSLIDER", {
            Text = "Walk Speed",
            Default = 16,
            Min = 16,
            Max = 85,
            Rounding = 0,
            Compact = true,
            Callback = function(v)
                CurrentWS = v
                ApplyLobbyWS()
            end
        })
        LobbyTab:AddToggle("EnableWS", {
            Text = "Enable Walk Speed",
            Default = false,
            Callback = function(state)
                WS_Enabled = state
                ApplyLobbyWS()
            end
        })

        -- ESCONDE TABS DE GAMEPLAY NO LOBBY
        Tabs.Main:SetVisible(false)
        Tabs.visual:SetVisible(false)
        Tabs.Exploits:SetVisible(false)
        Tabs.floortab:SetVisible(false)
    else
        -- SE ESTIVER NO JOGO, ESCONDE A ABA DE LOBBY (SE EXISTIR)
        if Tabs.Main then Tabs.Main:SetVisible(true) end
        if Tabs.visual then Tabs.visual:SetVisible(true) end
        if Tabs.Exploits then Tabs.Exploits:SetVisible(true) end
        if Tabs.floortab then Tabs.floortab:SetVisible(true) end
    end
