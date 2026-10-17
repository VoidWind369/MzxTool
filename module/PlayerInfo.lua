local point = {
    player_up = {
        p = "BOTTOMLEFT",
        x = -20.0,
        y = 145.0
    },
    player_down = {
        p = "BOTTOMLEFT",
        x = -20.0,
        y = 5.0
    }
}

---# 12.0.5+ 部分单位属性在受限环境下会返回 secret value，
---# 秘密值不能参与字符串拼接/格式化，此处统一兜底
local function IsSecret(value)
    return type(issecretvalue) == "function" and issecretvalue(value)
end

---# 安全转成字符串
local function SafeStr(value)
    if IsSecret(value) then
        return "???"
    end
    return tostring(value)
end

---# 安全格式化百分比
local function SafePercent(value)
    if IsSecret(value) then
        return "???"
    end
    return string.format("%.2f%%", value)
end

function MzxToolFrame:Void_PlayerInfo()
    local specIndex = GetSpecialization()
    local specID, name, description, icon, role, primaryStat
    if specIndex then
        specID, name, description, icon, role, primaryStat = GetSpecializationInfo(specIndex)
    end
    -- 主属性
    local attribute = UnitStat("player", primaryStat or 3)

    local primaryStatName = "主属性"
    if primaryStat == 1 then
        primaryStatName = "力量"
    elseif primaryStat == 2 then
        primaryStatName = "敏捷"
    elseif primaryStat == 4 then
        primaryStatName = "智力"
    end

    -- 装等
    local avgItemLevel, avgItemLevelEquipped = GetAverageItemLevel()
    local itemLevel
    if IsSecret(avgItemLevelEquipped) or IsSecret(avgItemLevel) then
        itemLevel = "|cFFFF69B4???|r"
    elseif avgItemLevelEquipped == avgItemLevel then
        itemLevel = "|cFFFF69B4" .. avgItemLevelEquipped .. "|r"
    else
        itemLevel = string.format("|cFFFF69B4%.1f|r/%.1f", avgItemLevelEquipped, avgItemLevel)
    end

    local health = UnitHealthMax("player")
    local armor = select(3, UnitArmor("player"))

    -- 移动速度
    local SPEED_FORMAT_OPTIONS = {
        breakpointData = {
            {
                breakpoint = 0,
                abbreviation = "%",
                significandDivisor = 0.006999,
                fractionDivisor = 10,
                abbreviationIsGlobal = false,
            },
        },
    }
    local isGliding, canGlide, forwardSpeed = C_PlayerInfo.GetGlidingInfo()
    local currentSpeed = (isGliding and forwardSpeed) or GetUnitSpeed("player")
    local speedPercent = SafeStr(AbbreviateNumbers(currentSpeed, SPEED_FORMAT_OPTIONS))

    -- 副属性
    local crit, crit_value = GetCritChance(), GetCombatRating(CR_CRIT_MELEE)
    local haste, haste_value = GetHaste(), GetCombatRating(CR_HASTE)
    local mastery, mastery_value = GetMasteryEffect(), GetCombatRating(CR_MASTERY)
    local versatility, versatility_value = GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE),
        GetCombatRating(CR_VERSATILITY_DAMAGE_DONE)

    local leech, leech_value = GetLifesteal(), GetCombatRating(CR_LIFESTEAL)             -- 吸血 (Leech)
    local avoidance, avoidance_value = GetCombatRatingBonus(CR_AVOIDANCE),
        GetCombatRating(CR_AVOIDANCE)                                                    -- 闪避 (Avoidance)
    local speed, speed_value = GetCombatRatingBonus(CR_SPEED), GetCombatRating(CR_SPEED) -- 加速 (Speed)

    local first_table = {
        { name = "|cFFFFFF00装等|r", value = itemLevel },
        { name = "|cFFFFFF00生命|r", value = SafeStr(health) },
        { name = "|cFFFFFF00" .. primaryStatName .. "|r", value = SafeStr(attribute) },
        { name = "|cFFFFFF00护甲|r", value = SafeStr(armor) },
        { name = "|cFFFFFF00移速|r", value = speedPercent },
    }

    local last_table = {
        { name = "|cFF00FF00暴击|r", value = SafePercent(crit) .. "  |cFFFF8C00" .. SafeStr(crit_value) .. "|r" },
        { name = "|cFF00FF00急速|r", value = SafePercent(haste) .. "  |cFFFF8C00" .. SafeStr(haste_value) .. "|r" },
        { name = "|cFF00FF00精通|r", value = SafePercent(mastery) .. "  |cFFFF8C00" .. SafeStr(mastery_value) .. "|r" },
        {
            name = "|cFF00FF00全能|r",
            value = SafePercent(versatility) .. "  |cFFFF8C00" .. SafeStr(versatility_value) .. "|r"
        },
        { name = "|cFF228B22吸血|r", value = SafePercent(leech) .. "  |cFFFF8C00" .. SafeStr(leech_value) .. "|r" },
        {
            name = "|cFF228B22闪避|r",
            value = SafePercent(avoidance) .. "  |cFFFF8C00" .. SafeStr(avoidance_value) .. "|r"
        },
        { name = "|cFF228B22加速|r", value = SafePercent(speed) .. "  |cFFFF8C00" .. SafeStr(speed_value) .. "|r" }
    }
    return first_table, last_table
end

function PrintCombatRating()
    for i = 1, 32, 1 do
        if CombatRatingMetaData and CombatRatingMetaData[i] then
            local bonus, value = GetCombatRatingBonus(i), GetCombatRating(i)
            print(CombatRatingMetaData[i].label, i, bonus, value)
        end
    end
end

--- # 创建主属性框体
function MzxToolFrame:Void_CreatePlayerInfoDisplay_UP(first)
    MzxToolCharacterDB.point.player_up = MzxToolCharacterDB.point.player_up or {
        p = point.player_up.p,
        x = point.player_up.x,
        y = point.player_up.y
    }

    self.voidPlayerInfo_UP = CreateFrame("Frame", "PlayerInfo_UP", UIParent, "BackdropTemplate")
    self.voidPlayerInfo_UP:SetSize(150, #first * 20 + 10)
    self.voidPlayerInfo_UP:SetPoint(MzxToolCharacterDB.point.player_up.p, MzxToolCharacterDB.point.player_up.x,
        MzxToolCharacterDB.point.player_up.y)
    SetInfoFrameStyle(self.voidPlayerInfo_UP, true)

    self.voidPlayerInfoText_UP = {}
    for index, value in ipairs(first) do
        self.voidPlayerInfoText_UP[index] = {
            self.voidPlayerInfo_UP:CreateFontString(nil, "OVERLAY", "GameTooltipText"),
            self.voidPlayerInfo_UP:CreateFontString(nil, "OVERLAY", "GameTooltipText"),
        }
        AddStringLeft(self.voidPlayerInfoText_UP[index][1], value.name, 1, 6, (1 - index) * 20 + (#first - 1) * 10)
        AddStringRight(self.voidPlayerInfoText_UP[index][2], value.value, 1, -5, (1 - index) * 20 + (#first - 1) * 10)
    end
end

--- # 创建副属性框体
function MzxToolFrame:Void_CreatePlayerInfoDisplay_Down(last)
    MzxToolCharacterDB.point.player_down = MzxToolCharacterDB.point.player_down or {
        p = point.player_down.p,
        x = point.player_down.x,
        y = point.player_down.y
    }
    self.voidPlayerInfo_DOWN = CreateFrame("Frame", "PlayerInfo_DOWN", UIParent, "BackdropTemplate")
    self.voidPlayerInfo_DOWN:SetSize(150, #last * 20 + 10)
    self.voidPlayerInfo_DOWN:SetPoint(MzxToolCharacterDB.point.player_down.p, MzxToolCharacterDB.point.player_down.x,
        MzxToolCharacterDB.point.player_down.y)
    SetInfoFrameStyle(self.voidPlayerInfo_DOWN, true)

    self.voidPlayerInfoText_DOWN = {}
    for index, value in ipairs(last) do
        self.voidPlayerInfoText_DOWN[index] = {
            self.voidPlayerInfo_DOWN:CreateFontString(nil, "OVERLAY", "GameTooltipText"),
            self.voidPlayerInfo_DOWN:CreateFontString(nil, "OVERLAY", "GameTooltipText"),
        }
        AddStringLeft(self.voidPlayerInfoText_DOWN[index][1], value.name, nil, 6, (1 - index) * 20 + (#last - 1) * 10)
        AddStringRight(self.voidPlayerInfoText_DOWN[index][2], value.value, nil, -5, (1 - index) * 20 + (#last - 1) * 10)
    end
end

--- # 创建玩家信息框体
function MzxToolFrame:Void_CreatePlayerInfoDisplay()
    -- 逐键复制默认值，避免把模块级 point 表原引用写入 DB
    if not MzxToolCharacterDB.point then
        MzxToolCharacterDB.point = {}
    end
    MzxToolCharacterDB.point.player_up = MzxToolCharacterDB.point.player_up or {
        p = point.player_up.p,
        x = point.player_up.x,
        y = point.player_up.y
    }
    MzxToolCharacterDB.point.player_down = MzxToolCharacterDB.point.player_down or {
        p = point.player_down.p,
        x = point.player_down.x,
        y = point.player_down.y
    }

    local first, last = MzxToolFrame:Void_PlayerInfo()
    self:Void_CreatePlayerInfoDisplay_UP(first)
    self:Void_CreatePlayerInfoDisplay_Down(last)

    MovableDisplay(self.voidPlayerInfo_UP)
    MovableDisplay(self.voidPlayerInfo_DOWN)

    MovableFrameStop(self.voidPlayerInfo_UP, MzxToolCharacterDB.point.player_up, point.player_up)
    MovableFrameStop(self.voidPlayerInfo_DOWN, MzxToolCharacterDB.point.player_down, point.player_down)
end

--- # 刷新玩家信息框体
function MzxToolFrame:Void_UpdatePlayerInfoDisplay()
    if self.voidPlayerInfo_UP and self.voidPlayerInfo_DOWN then
        local first, last = MzxToolFrame:Void_PlayerInfo()
        for index, value in ipairs(first) do
            self.voidPlayerInfoText_UP[index][1]:SetText(value.name)
            self.voidPlayerInfoText_UP[index][2]:SetText(value.value)
        end
        for index, value in ipairs(last) do
            self.voidPlayerInfoText_DOWN[index][1]:SetText(value.name)
            self.voidPlayerInfoText_DOWN[index][2]:SetText(value.value)
        end
    end
end
