local totemWeapon = {
    EnhancementShaman_SpecId = 263,

    -- 漩涡武器法术ID
    spell_id = 344179,
    galeWinds_spell_id = 454015,

    -- 显示设置
    max_stacks = 10,
    dot_size = 30,   -- 每个小圆点的大小
    dot_spacing = 1, -- 圆点间距
    position_x = 0,
    position_y = -260,

    currentStacks = 0,
    lastStacks = 0,

    up = {
        p = "CENTER",
        x = 0,
        y = -270
    }
}

function MzxToolFrame:CreateDotProgress()
    MzxToolCharacterDB.point.totemWeapon = MzxToolCharacterDB.point.totemWeapon or {
        p = totemWeapon.up.p,
        x = totemWeapon.up.x,
        y = totemWeapon.up.y
    }

    -- 主框架
    self.dotFrame = CreateFrame("Frame", "TotemWeapon", UIParent, "BackdropTemplate")
    self.dotFrame:SetPoint(MzxToolCharacterDB.point.totemWeapon.p,
        MzxToolCharacterDB.point.totemWeapon.x,
        MzxToolCharacterDB.point.totemWeapon.y)
    WhiteTransparentFrame(self.dotFrame, totemWeapon)

    -- 创建10个小圆点
    self.totemWeaponDots = {}

    for i = 1, totemWeapon.max_stacks do
        local dot = CreateFrame("Frame", nil, self.dotFrame)
        WhiteTransparentDot(i, dot, totemWeapon)

        dot.tex = dot:CreateTexture(nil, "OVERLAY")
        WhiteTransparentDotTex(dot.tex, totemWeapon)

        self.totemWeaponDots[i] = dot
    end

    -- 不是增强初始隐藏
    if GetSpecializationInfo(GetSpecialization()) ~= totemWeapon.EnhancementShaman_SpecId then
        self.dotFrame:Hide()
    end

    MovableDisplay(self.dotFrame)
    MovableFrameStop(self.dotFrame, MzxToolCharacterDB.point.totemWeapon, totemWeapon.up)
end

-- 设定狂风怒号颜色
function MzxToolFrame:UpdateDotFrameProgress(hasGaleWindsData)
    if hasGaleWindsData then
        self.dotFrame:SetBackdropColor(0, 0.4, 1, 0.55)
        self.dotFrame:SetBackdropBorderColor(0, 0.1, 0.4, 0.8)
    else
        self.dotFrame:SetBackdropColor(0, 0, 0, 0.15)
        self.dotFrame:SetBackdropBorderColor(0.2, 0.2, 0.2, 0.5)
    end
end

-- 设定漩涡武器层数颜色
function MzxToolFrame:UpdateDotProgress(stacks)
    local alpha = 1
    local topColor, bottomColor = self:GetGradientColorsSM(stacks, alpha)
    for i = 1, totemWeapon.max_stacks do
        local dot = self.totemWeaponDots[i]

        if i <= stacks then
            -- 激活的小圆点 - 饱满的纵向渐变
            dot.tex:SetGradient("VERTICAL", topColor, bottomColor)
            if stacks > 9 then
                self.dotFrame:SetBackdropColor(0, 0, 0.1, 0.65)
            else
                self.dotFrame:SetBackdropColor(0, 0, 0.1, 0.4)
            end
            dot:SetAlpha(1)
        else
            -- 未激活的小圆点 - 深灰色渐变
            dot.tex:SetGradient("VERTICAL",
                CreateColor(0.5, 0.5, 0.5, 1),
                CreateColor(0.6, 0.6, 0.6, 1)
            )
            self.dotFrame:SetBackdropColor(0, 0, 0.1, 0.4)
            dot:SetAlpha(0.3)
        end
    end
end

function MzxToolFrame:GetGradientColorsSM(stacks, alpha)
    -- 饱满的金属渐变色
    if stacks <= 5 then
        -- 蓝色金属
        return CreateColor(0, 0.8, 1.0, alpha), CreateColor(0, 1.0, 0.9, alpha)
    elseif stacks <= 9 then
        -- 金色金属
        return CreateColor(1.0, 0.5, 0.0, alpha), CreateColor(1.0, 1.0, 0.0, alpha)
    else
        -- 红色金属
        -- return CreateColor(1.0, 0.3, 0.3, alpha), CreateColor(1.0, 0.5, 0.5, alpha)
        return CreateColor(1.0, 0, 0, alpha), CreateColor(1.0, 0.8, 0.8, alpha)
    end
end

function MzxToolFrame:GetGradientColors(stacks, alpha)
    if stacks <= 5 then
        -- 蓝色金属
        return CreateColor(0.8, 0.9, 1.0, alpha)
    elseif stacks <= 9 then
        -- 金色金属
        return CreateColor(1.0, 0.9, 0.5, alpha)
    else
        -- 红色金属
        return CreateColor(1.0, 0.4, 0.4, alpha)
    end
end

-- 增强萨buff监控进程
function MzxToolFrame:UpdateTotemWeaponStacks()
    local totemWeaponData = C_UnitAuras.GetUnitAuraBySpellID("player", totemWeapon.spell_id)
    local galeWindsData = C_UnitAuras.GetUnitAuraBySpellID("player", totemWeapon.galeWinds_spell_id)

    if totemWeaponData then
        totemWeapon.currentStacks = totemWeaponData.applications or 0
    else
        totemWeapon.currentStacks = 0
        totemWeapon.lastStacks = 0
    end

    -- 更新小圆点进度
    self:UpdateDotProgress(totemWeapon.currentStacks)
    -- if galeWindsData then
    --     self:UpdateDotFrameProgress(true)
    -- else
    --     self:UpdateDotFrameProgress(false)
    -- end
end

function MzxToolFrame:TestDisplay()
    -- 测试显示不同层数
    DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00测试小圆点进度...|r")

    -- 循环测试不同层数
    local testIndex = 1
    C_Timer.NewTicker(0.3, function()
        self:UpdateDotProgress(testIndex)
        self.dotFrame:Show()
        testIndex = testIndex + 1
        if testIndex > 10 then
            testIndex = 1
        end
    end, 10) -- 测试10秒

    C_Timer.After(10.5, function()
        if totemWeapon.currentStacks == 0 then
            self.dotFrame:Hide()
        else
            self:UpdateDotProgress(totemWeapon.currentStacks)
        end
    end)
end
