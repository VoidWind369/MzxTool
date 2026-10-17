-- 创建主框架
MzxToolFrame = CreateFrame("Frame", "MzxToolFrame", UIParent)
MzxToolFrame:RegisterEvent("PLAYER_LOGIN")         -- 用户登录
MzxToolFrame:RegisterEvent("UNIT_AURA")            -- 获得或消失的增益、减益、状态或物品加成
MzxToolFrame:RegisterEvent("CHAT_MSG_WHISPER")     -- 收到其他玩家的低语
MzxToolFrame:RegisterEvent("PARTY_INVITE_REQUEST") -- 收到组队邀请
-- MzxToolFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED") -- 战斗日志

local ENHANCEMENT_SHAMAN_SPEC_ID = 263

---# 当前专精ID，未选专精时返回 nil
local function GetSpecId()
    local specIndex = GetSpecialization()
    if not specIndex then
        return nil
    end
    return GetSpecializationInfo(specIndex)
end

MzxToolFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        self:Initialize()
        return
    end

    if event == "UNIT_AURA" then
        local unitTarget = ...
        if unitTarget == "player" then
            local status = MzxToolCharacterDB and MzxToolCharacterDB.status
            if status then
                if status.BloodlustSimple == true then
                    self:CheckBloodlust()
                end
                if status.TotemWeaponMonitor == true and self.dotFrame then
                    if GetSpecId() == ENHANCEMENT_SHAMAN_SPEC_ID then
                        self.dotFrame:Show()
                        self:UpdateTotemWeaponStacks()
                    else
                        self.dotFrame:Hide()
                    end
                end
                if status.BoneShieldMonitor == true and self.dotFrameDeathKnight then
                    self:UpdateDeathKnightBuff()
                end
            end
        end
        return
    end

    if event == "CHAT_MSG_WHISPER" then
        local sender, text = ...
        self:MessageStart(sender, text)
        return
    end

    if event == "PARTY_INVITE_REQUEST" then
        local name = ...
        self:PartyStart(name)
    end
end)

C_Timer.NewTicker(.5, function()
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

    -- WOW客户端信息
    self:ClientInfo()

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

    -- 斜杠命令由 commend/MzxAddon.lua 通过 Ace3 注册后转发到此处
    DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000恶！龙！咆！哮！|r|cFF00FF00启动！|r 输入 /mzx 打开设置|r")
end

function MzxToolFrame:HandleSlashCommand(msg)
    local command = strlower(strtrim(msg or ""))
    local args = { strsplittable(" ", command) }

    if command == "" then
        return
    elseif args[1] == "bls" then
        if args[2] == "test" then
            self:TestAlert("ogg")
        elseif args[2] == "wav" then
            self:TestAlert("wav")
        elseif args[2] == "debug" then
            self:DebugBuffs()
        elseif args[2] == "ele" then
            self:DebugEleBuff()
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000用法: /void bls test|wav|debug|ele|r")
        end
    elseif args[1] == "twm" then
        if args[2] == "test" then
            self:TestDisplay()
        elseif args[2] == "reset" then
            DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00双击面板可复位位置|r")
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000用法: /void twm test|reset|r")
        end
    elseif args[1] == "show" then
        self:ToggleModules(true, unpack(args, 2))
    elseif args[1] == "hide" then
        self:ToggleModules(false, unpack(args, 2))
    elseif args[1] == "debug" then
        MzxToolCharacterDB.status.Debug = (args[2] ~= "off")
        print(MzxToolCharacterDB.status.Debug and "调试模式已开启" or "调试模式已关闭")
    elseif command == "info" then
        print(self:BuildPlayerInfoText())
    elseif command == "cr" then
        PrintCombatRating()
    elseif command == "new" then
        NewDatabase()
    elseif command == "help" then
        self:ClientInfo()
        self:PrintHelp()
    else
        local AceConfigDialog = LibStub("AceConfigDialog-3.0")
        if AceConfigDialog.OpenFrames and AceConfigDialog.OpenFrames["MzxToolAddon"] then
            AceConfigDialog:Close("MzxToolAddon")
        else
            AceConfigDialog:Open("MzxToolAddon")
        end
    end
end

function MzxToolFrame:ClientInfo()
    local version, build, date, toc_version = GetBuildInfo()
    print("|cFF33937FVoidMod|r |cFF69CCF0Client|r |cFF00FF00Info:|r \n » Version: " ..
        version .. "\n » Build: " .. build .. "\n » Date: " .. date .. "\n » TocVersion: " .. toc_version)
end

function MzxToolFrame:PrintHelp()
    DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00恶龙咆哮菜单:|r")
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00/mzx|r |cFF00FF00/void|r - 打开设置面板")
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00/void show|r |cFF00CCFF[编号]|r - 开启模块（需 /reload）")
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00/void hide|r |cFF00CCFF[编号]|r - 关闭模块（需 /reload）")
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00/void debug on|off|r - 调试模式")
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00/void info|r - 聊天框打印当前属性")
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00/void cr|r - 打印全部战斗等级")
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00/void bls test|wav|debug|ele|r - 嗜血模块")
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00/void twm test|reset|r - 漩涡武器模块")
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00/void new|r - 重置所有设置")
    DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00模块编号:|r |cFF00CCFF1|r骨盾 |cFF00CCFF2|r属性 |cFF00CCFF3|r漩涡武器 |cFF00CCFF4|r嗜血")
end
