local bloodlust = {
    bloodlust_spell_ids = {
        [2825] = "嗜血 Bloodlust",
        [32182] = "英勇 Heroism",
        [80353] = "时光扭曲 Time Warp",
        [264667] = "原始狂怒 Primal Rage",
        [390386] = "守护巨龙之怒 Fury of the Aspects",
    },

    -- 真正表示「吃到嗜血类增益」的减益ID
    bloodlust_debuffs = {
        57723,  -- Exhaustion 疲劳
        57724,  -- Sated 饱足
        80354,  -- Temporal Displacement 时间位移
        390435, -- Exhaustion Deserter 临阵脱逃（战场/评级）
    },

    d_spell_ids = {
        [192106] = "闪电护盾",
        [52127] = "水之护盾",
        [383648] = "大地护盾",
    },

    -- 语音文件路径（需随插件一同分发 media 目录）
    voice_file = "Interface/AddOns/MzxTool/media/void_voice.ogg",
    yurin = "Interface/AddOns/MzxTool/media/yurin.wav",

    hasBloodlust = false,
    lastPlayTime = 0,
    pendingTimer = nil,
    lastState = nil,
}

---# 查找玩家身上任一嗜血类减益
function bloodlust:FindAura()
    for _, spellId in ipairs(self.bloodlust_debuffs) do
        local auraData = C_UnitAuras.GetUnitAuraBySpellID("player", spellId)
        if auraData then
            return auraData.name or ("ID:" .. spellId), spellId
        end
    end
    return nil, nil
end

---# 监控嗜血减益（去抖，避免 UNIT_AURA 高频触发时堆积定时器）
function MzxToolFrame:CheckBloodlust()
    if bloodlust.pendingTimer then
        return
    end
    bloodlust.pendingTimer = C_Timer.After(0.5, function()
        bloodlust.pendingTimer = nil

        local buffName, spellId = bloodlust:FindAura()
        local found = buffName ~= nil

        -- 状态未变化则不做任何事
        if found == bloodlust.lastState then
            return
        end
        bloodlust.lastState = found

        if found then
            bloodlust.hasBloodlust = true
            self:OnBloodlustGained(buffName, spellId, "wav")
        else
            bloodlust.hasBloodlust = false
        end
    end)
end

function MzxToolFrame:OnBloodlustGained(buffName, spellId, ogg)
    local currentTime = GetTime()

    -- 防止重复播放（40秒内）
    if currentTime - bloodlust.lastPlayTime < 40 then
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

---# 播放外部语音文件（文件缺失时回退到游戏内置音效）
---@param ogg string "ogg" 或 "wav"
function MzxToolFrame:PlayBloodlustVoice(ogg)
    local path = (ogg == "ogg") and bloodlust.voice_file or bloodlust.yurin
    local played = false
    if PlaySoundFile then
        played = pcall(PlaySoundFile, path, "Master")
    end
    if not played then
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
function MzxToolFrame:DebugBuffs()
    DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00=== 嗜血Buff检测 ===|r")
    for bloodlustId, bloodlustName in pairs(bloodlust.bloodlust_spell_ids) do
        local auraData = C_UnitAuras.GetUnitAuraBySpellID("player", bloodlustId)
        if auraData then
            DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00已激活|r " ..
                bloodlustName .. " (ID: " .. bloodlustId .. ")|r")
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000未找到|r " .. bloodlustName)
        end
    end

    DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00当前嗜血状态: " ..
        (bloodlust.hasBloodlust and "|cFF00FF00已激活|r" or "|cFFFF0000未激活|r"))
end

---# 检测萨满三种元素护盾
function MzxToolFrame:DebugEleBuff()
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00护盾Buff检测|r")
    for spellId, spellName in pairs(bloodlust.d_spell_ids) do
        local auraData = C_UnitAuras.GetUnitAuraBySpellID("player", spellId)
        if auraData then
            DEFAULT_CHAT_FRAME:AddMessage("|cFF888888" .. spellName .. " " ..
                (auraData.name or "未知") .. " (ID: " .. spellId .. ")|r")
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000未找到" .. spellName .. "护盾|r")
        end
    end
end

---# 嗜血测试
---@param ogg string "ogg" 或 "wav"
function MzxToolFrame:TestAlert(ogg)
    DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00测试嗜血提示...|r")
    self:OnBloodlustGained("嗜血测试", 2825, ogg)
end
