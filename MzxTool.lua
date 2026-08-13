-- 创建主框架
MzxToolFrame = CreateFrame("Frame", "VoidModFrame", UIParent)
MzxToolFrame:RegisterEvent("PLAYER_LOGIN")         -- 用户登录
MzxToolFrame:RegisterEvent("UNIT_AURA")            -- 获得或消失的增益、减益、状态或物品加成
MzxToolFrame:RegisterEvent("CHAT_MSG_WHISPER")     -- 收到其他玩家的低语
MzxToolFrame:RegisterEvent("PARTY_INVITE_REQUEST") -- 排本邀请
MzxToolFrame:RegisterEvent("UNIT_COMBAT")          -- 当 NPC 或玩家参与战斗并受到伤害时触发
MzxToolFrame:RegisterEvent("LFG_QUEUE_STATUS_UPDATE")
MzxToolFrame:RegisterEvent("GROUP_INVITE_CONFIRMATION")
MzxToolFrame:RegisterEvent("LFG_ROLE_CHECK_SHOW")
MzxToolFrame:RegisterEvent("LFG_PROPOSAL_SHOW")    -- 排到副本
-- MzxToolFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED") -- 战斗日志

MzxToolFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        self:Initialize()
    elseif event == "UNIT_AURA" then
        local unitTarget, updateInfo = ...
        if unitTarget == "player" then
            if MzxToolCharacterDB.status.BloodlustSimple == true then
                -- self:GetBloodlust(updateInfo)
                self:CheckBloodlust()
            end

            -- 判断是否增强萨满
            if GetSpecializationInfo(GetSpecialization()) == 263 then
                self.dotFrame:Show()
                self:UpdateTotemWeaponStacks()
            else
                self.dotFrame:Hide()
            end
        end
        -- self:Void_UpdatePlayerInfoDisplay()
    end
    if event == "CHAT_MSG_WHISPER" then
        self:MessageStart(...)
    end
    if event == "PARTY_INVITE_REQUEST" or event == "GROUP_INVITE_CONFIRMATION" then
        local unit = ...
        if unit ~= nil then
            self:PartyStart(...)
        end
    end
    if event == "UNIT_COMBAT" then
        self:Void_UpdatePlayerInfoDisplay()
    end
    if event == "LFG_ROLE_CHECK_SHOW" then
        print("排本选择职责")
        C_Timer.After(0.5, function() LFDRoleCheckPopupAcceptButton:Click() end)
    end
    if event == "LFG_PROPOSAL_SHOW" then
        print("排本匹配成功")
        C_Timer.After(0.5, function()
            if self.autoEnterButton then
                print("匹配成功！准备自动进本...")
                -- LFGTeleport(IsInLFGDungeon())
                self.autoEnterButton:Click()
                print("自动进入副本...")
            end
        end)
    end
    -- if event == "COMBAT_LOG_EVENT_UNFILTERED" then
    --     self:GetGroupBuffs()
    -- end
end)

C_Timer.NewTicker(.1, function()
    MzxToolFrame:Void_UpdatePlayerInfoDisplay()
end)

-- MzxToolFrame:SetScript("OnUpdate", function(self, delta)
--     self:Void_UpdatePlayerInfoDisplay()
--     -- if InCombatLockdown() then
--     --     GetTargetBuff()
--     -- end
-- end)

function MzxToolFrame:Initialize()
    -- 加载数据库
    InitDatabase()

    -- 调试打印区域
    print("专精" .. GetSpecializationInfo(GetSpecialization()))

    -- WOW客户端信息
    self:ClientInfo()

    self:CreateAutoButton()

    -- 创建骨盾框架
    if MzxToolCharacterDB.status.BoneShieldMonitor == true then
        self:CreateBoneShieldDotProgress()
    end

    -- 创建漩涡武器框架
    if MzxToolCharacterDB.status.TotemWeaponMonitor == true then
        self:CreateDotProgress()
    end


    -- 创建属性显示框架
    if MzxToolCharacterDB.status.PlayerInfo == true then
        self:Void_CreatePlayerInfoDisplay()
    end

    -- 注册斜杠命令
    SLASH_VOID_MOD1 = "/void"
    SlashCmdList["VOID_MOD"] = function(msg)
        self:HandleSlashCommand(msg)
    end
    DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000恶！龙！咆！哮！|r|cFF00FF00启动！|r")
end

function MzxToolFrame:HandleSlashCommand(msg)
    local command = strlower(strtrim(msg))

    if command == "bls test" then
        self:TestAlert("ogg")
    elseif command == "bls wav" then
        self:TestAlert("wav")
    elseif command == "bls debug" then
        self:DebugBuffs()
    elseif command == "bls ele" then
        self:DebugEleBuff()
    elseif command == "twm test" then
        self:TestDisplay()
    elseif command == "twm move" then
        self:ToggleMoveMode()
    elseif command == "twm reset" then
        self:ResetPosition()
    elseif command == "twm scale" then
        self:ToggleScale()
    elseif command == "info" then
        -- self:Void_PlayerInfo()
        PrintCombatRating()
    elseif command == "new" then
        NewDatabase()
    else
        self:ClientInfo()
        self:PrintHelp()
    end
end

function MzxToolFrame:ClientInfo()
    local version, build, date, toc_version = GetBuildInfo()
    print("|cFF33937FVoidMod|r |cFF69CCF0Client|r |cFF00FF00Info:|r \n » Version: " ..
        version .. "\n » Build: " .. build .. "\n » Date: " .. date .. "\n » TocVersion: " .. toc_version)
end

function MzxToolFrame:PrintHelp()
    DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00恶龙咆哮:|r")
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00/void bls test|r - 测试提示效果")
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00/void bls debug|r - 显示当前所有buff和ID")
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00/void bls ele|r - 显示萨满激活护盾")
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00/void twm test|r - 测试显示效果")
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00/void twm move|r - 切换移动模式")
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00/void twm scale|r - 切换大小")
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00/void twm reset|r - 重置位置和大小")
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00/void|r - 显示帮助")
end
