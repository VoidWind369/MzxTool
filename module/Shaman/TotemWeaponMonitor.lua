local totemWeapon = {
    EnhancementShaman_SpecId = 263,

    -- 漩涡武器法术ID
    spell_id = 344179,

    -- 显示设置
    max_stacks = 10,
    dot_size = 30,   -- 每个小圆点的大小
    dot_spacing = 1, -- 圆点间距

    currentStacks = 0,

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
    self.dotFrame = CreateFrame("Frame", "MzxTotemWeaponFrame", UIParent, "BackdropTemplate")
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

-- 设定框体颜色（层数越高底色越深）
function MzxToolFrame:UpdateDotFrameProgress(stacks)
    if not self.dotFrame then
        return
    end
    self.dotFrame:SetBackdropColor(0, 0, 0.1, stacks > 9 and 0.65 or 0.4)
end

-- 设定漩涡武器层数颜色
function MzxToolFrame:UpdateDotProgress(stacks)
    if not self.dotFrame then
        return
    end
    local alpha = 1
    local topColor, bottomColor = self:GetGradientColorsSM(stacks, alpha)
    for i = 1, totemWeapon.max_stacks do
        local dot = self.totemWeaponDots[i]

        if i <= stacks then
            -- 激活的小圆点 - 饱满的纵向渐变
            dot.tex:SetGradient("VERTICAL", topColor, bottomColor)
            dot:SetAlpha(1)
        else
            -- 未激活的小圆点 - 深灰色渐变
            dot.tex:SetGradient("VERTICAL",
                CreateColor(0.5, 0.5, 0.5, 1),
                CreateColor(0.6, 0.6, 0.6, 1)
            )
            dot:SetAlpha(0.3)
        end
    end
    self:UpdateDotFrameProgress(stacks)
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

-- 增强萨buff监控进程
function MzxToolFrame:UpdateTotemWeaponStacks()
    if not self.dotFrame then
        return
    end
    local totemWeaponData = C_UnitAuras.GetUnitAuraBySpellID("player", totemWeapon.spell_id)

    if totemWeaponData then
        totemWeapon.currentStacks = totemWeaponData.applications or 0
    else
        totemWeapon.currentStacks = 0
    end

    -- 更新小圆点进度
    self:UpdateDotProgress(totemWeapon.currentStacks)
end

function MzxToolFrame:TestDisplay()
    if not self.dotFrame then
        print("|cFFFF0000漩涡武器监控未启用|r")
        return
    end
    -- 测试显示不同层数
    DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00测试小圆点进度...|r")

    -- 循环测试不同层数
    local testIndex = 1
    local ticks = 35
    C_Timer.NewTicker(0.3, function()
        self:UpdateDotProgress(testIndex)
        self.dotFrame:Show()
        testIndex = testIndex + 1
        if testIndex > 10 then
            testIndex = 1
        end
    end, ticks) -- 35 * 0.3 = 10.5 秒

    C_Timer.After(10.5, function()
        if totemWeapon.currentStacks == 0 then
            self.dotFrame:Hide()
        else
            self:UpdateDotProgress(totemWeapon.currentStacks)
        end
    end)
end
