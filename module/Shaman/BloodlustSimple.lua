local bloodlust = {
    bloodlust_spell_ids = {
        [2825] = "|cFF0070DE嗜血 Bloodlust|r",
        [32182] = "|cFF0070DE英勇 Heroism|r",
        [80353] = "|cFF69CCF0时光扭曲 Time Warp|r",
        [264667] = "|cFFABD473原始狂怒 Primal Rage|r",
        [390386] = "|cFF33937F守护巨龙之怒 Fury of the Aspects|r",
        [178207] = "|cFFC69B6D狂怒战鼓|r",
        [230935] = "|cFFC69B6D高山战鼓|r",
        [256740] = "|cFFC69B6D漩涡战鼓|r",
        [308084] = "|cFFC69B6D尊主打击|r",
        [354646] = "|cFFC69B6D戈姆毒气|r",
    },

    bloodlust_debuffs = { 57723, 57724, 80354, 95809, 160455, 207400, 264689, 390435 },

    d_spell_ids = {
        [192106] = "闪电护盾",
        [52127] = "水之护盾",
        [383648] = "大地护盾",
    },

    -- 语音文件路径
    voice_file = "Interface/AddOns/MzxMedia/void_voice.ogg",
    yurin = "Interface/AddOns/MzxMedia/yurin.wav",

    hasBloodlust = false,
    lastPlayTime = 0,
}

function MzxToolFrame:GetGroupBuffs()
    local timestamp, subevent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destRaidFlags =
        CombatLogGetCurrentEventInfo()
    print(subevent, hideCaster, sourceGUID, sourceName)
    if subevent == "SPELL_SUMMON" and sourceGUID == UnitGUID("player") then
        local spellId, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand =
            select(12, CombatLogGetCurrentEventInfo())

        if tContains(totem_dance.windfury_totem_spell_id, spellId) then
            -- 更新时间
            totem_dance.totem_end_time = GetTime() + 10.000
        end
        -- 更新时间
    end
end

---# 监控嗜血buff
function MzxToolFrame:GetBloodlust(updateInfo)
    local foundBuff, buffName, spellIdFound = false, "", 0

    C_Timer.After(0.5, function()
        if updateInfo.addedAuras then
            for _, bloodlustId in ipairs(bloodlust.bloodlust_debuffs) do
                local aura = _G.C_UnitAuras.GetPlayerAuraBySpellID(bloodlustId)
                if aura then
                    foundBuff = true
                    buffName = aura.name
                    spellIdFound = bloodlustId
                    break
                end
                print("嗜血", bloodlustId, foundBuff, bloodlust.hasBloodlust)
            end
        elseif updateInfo.removedAuraInstanceIDs then
            for _, bloodlustId in ipairs(bloodlust.bloodlust_debuffs) do
                local aura = _G.C_UnitAuras.GetPlayerAuraBySpellID(bloodlustId)
                if aura then
                    foundBuff = true
                    buffName = aura.name
                    spellIdFound = aura.spellId
                    break
                end
            end
        end

        print("status", foundBuff, buffName, spellIdFound, bloodlust.hasBloodlust)
        -- 处理buff状态变化
        if foundBuff and not bloodlust.hasBloodlust then
            self:OnBloodlustGained(buffName, spellIdFound, "wav")
            bloodlust.hasBloodlust = true
        elseif not foundBuff and bloodlust.hasBloodlust then
            bloodlust.hasBloodlust = false
        end
    end)
end

---# 监控嗜血buff
function MzxToolFrame:CheckBloodlust()
    local foundBuff, buffName, spellIdFound, hasteState = false, "", 0, 0

    -- local haste = GetHaste()
    -- if haste - MzxToolCharacterDB.haste >= 30 then
    --     hasteState = 1
    -- elseif MzxToolCharacterDB.haste - haste >= 30 then
    --     hasteState = -1
    -- else
    --     hasteState = 0
    -- end

    C_Timer.After(0.5, function()
        for _, bloodlustId in ipairs(bloodlust.bloodlust_debuffs) do
            local auraData = C_UnitAuras.GetUnitAuraBySpellID("player", bloodlustId)
            if auraData then
                foundBuff = true
                buffName = auraData.name
                spellIdFound = auraData.spellId
                break
            end
        end

        -- 处理buff状态变化
        if foundBuff and not bloodlust.hasBloodlust then
            self:OnBloodlustGained(buffName, spellIdFound, "wav")
            bloodlust.hasBloodlust = true
        elseif not foundBuff and bloodlust.hasBloodlust then
            bloodlust.hasBloodlust = false
        else
            bloodlust.hasBloodlust = false
        end
    end)
end

function MzxToolFrame:OnBloodlustGained(buffName, spellId, ogg)
    local currentTime = GetTime()

    -- 防止重复播放（40秒内）
    if currentTime - bloodlust.lastPlayTime < 600 then
        return
    end

    bloodlust.lastPlayTime = currentTime

    -- 在聊天框显示
    DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000※ 你获得了 " .. buffName .. " (ID:" .. spellId .. ")！|r")

    -- 播放语音
    self:PlayBloodlustVoice(ogg)

    -- 屏幕提示
    self:ShowSimpleAlert(buffName)
end

---# 播放外部语音文件
---@param ogg table
function MzxToolFrame:PlayBloodlustVoice(ogg)
    if PlaySoundFile then
        if ogg == "ogg" then
            PlaySoundFile(bloodlust.voice_file, "Master")
        else
            PlaySoundFile(bloodlust.yurin, "Master")
        end
    else
        -- 备选：使用游戏内置音效
        PlaySound(569200, "Master") -- 嗜血音效
    end
end

function MzxToolFrame:ShowSimpleAlert(buffName)
    -- 屏幕中央错误提示
    UIErrorsFrame:AddMessage("※ " .. buffName .. "！", 1.0, 1.0, 0.0, 1.0)

    -- 创建大文字提示
    if not self.alertText then
        self.alertText = UIParent:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
        self.alertText:SetPoint("CENTER", 0, 100)
        self.alertText:SetTextColor(1, 0, 0, 1)
        self.alertText:SetShadowColor(0, 0, 0, 1)
        self.alertText:SetShadowOffset(2, -2)
    end

    self.alertText:SetText("※ " .. buffName .. "！")
    self.alertText:SetAlpha(1)

    -- 淡出动画
    self.alertText.fadeInfo = {}
    self.alertText.fadeInfo.mode = "OUT"
    self.alertText.fadeInfo.timeToFade = 3
    self.alertText.fadeInfo.startAlpha = 1
    self.alertText.fadeInfo.endAlpha = 0
    UIFrameFade(self.alertText, self.alertText.fadeInfo)
end

---# 检测嗜血Buff
---* 任意职业测试时
---* 需有嗜血职业组队
function MzxToolFrame:DebugBuffs()
    DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00=== 嗜血Buff检测 ===|r")
    for bloodlustId, bloodlustName in pairs(bloodlust.bloodlust_spell_ids) do
        local auraData = C_UnitAuras.GetUnitAuraBySpellID("player", bloodlustId)
        if auraData then
            DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00已激活|r" ..
                bloodlustName:sub(1, 10) .. (auraData.name or "未知") .. " (ID: " .. (auraData.spellId or "?") .. ")|r")
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000未找到|r" .. bloodlustName)
        end
    end

    -- 显示当前嗜血状态
    DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00当前嗜血状态: " ..
        (bloodlust.hasBloodlust and "|cFF00FF00已激活|r" or "|cFFFF0000未激活|r"))
end

---# 检测萨满三种元素护盾
---* 使用萨满作为测试职业时
function MzxToolFrame:DebugEleBuff()
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00护盾Buff检测|r")
    for spellId, spellName in pairs(bloodlust.d_spell_ids) do
        local auraData = C_UnitAuras.GetUnitAuraBySpellID("player", spellId)
        if auraData then
            DEFAULT_CHAT_FRAME:AddMessage("|cFF888888" ..
                (auraData.name or "未知") .. " (ID: " .. (auraData.spellId or "?") .. ")|r")
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000未找到" .. spellName .. "护盾|r")
        end
    end
end

---# 嗜血测试
---@param ogg table
function MzxToolFrame:TestAlert(ogg)
    DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00测试嗜血提示...|r")
    self:OnBloodlustGained("嗜血测试", 2825, ogg)
end
