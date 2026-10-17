local boneShield = {
    BloodDeathKnight_SpecId = 250,

    -- 骨盾光环法术ID
    spell_id = 433925,
    -- 英雄天赋： exterminate（霜死骑「 exterminate」），存在时框体变蓝
    heroTalent_spell_id = 441416,

    -- 显示设置
    max_stacks = 12,
    dot_size = 20,   -- 每个小圆点的大小
    dot_spacing = 1, -- 圆点间距

    up = {
        p = "CENTER",
        x = 0,
        y = -260
    },

    currentStacks = 0,
}

function MzxToolFrame:CreateBoneShieldDotProgress()
    MzxToolCharacterDB.point.boneShield = MzxToolCharacterDB.point.boneShield or {
        p = boneShield.up.p,
        x = boneShield.up.x,
        y = boneShield.up.y
    }

    -- 主框架
    self.dotFrameDeathKnight = CreateFrame("Frame", "MzxBoneShieldFrame", UIParent, "BackdropTemplate")
    self.dotFrameDeathKnight:SetPoint(MzxToolCharacterDB.point.boneShield.p,
        MzxToolCharacterDB.point.boneShield.x,
        MzxToolCharacterDB.point.boneShield.y)
    WhiteTransparentFrame(self.dotFrameDeathKnight, boneShield)

    -- 创建 max_stacks 个小圆点
    self.boneShieldDots = {}

    for i = 1, boneShield.max_stacks do
        local boneShieldDot = CreateFrame("Frame", nil, self.dotFrameDeathKnight)
        WhiteTransparentDot(i, boneShieldDot, boneShield)

        boneShieldDot.glow = boneShieldDot:CreateTexture(nil, "BACKGROUND")
        WhiteTransparentDotGlow(boneShieldDot.glow, boneShield)

        boneShieldDot.tex = boneShieldDot:CreateTexture(nil, "OVERLAY")
        WhiteTransparentDotTex(boneShieldDot.tex, boneShield)

        self.boneShieldDots[i] = boneShieldDot
    end

    -- 不是血dk初始隐藏
    if GetSpecializationInfo(GetSpecialization()) ~= boneShield.BloodDeathKnight_SpecId then
        self.dotFrameDeathKnight:Hide()
    end

    MovableDisplay(self.dotFrameDeathKnight)
    MovableFrameStop(self.dotFrameDeathKnight, MzxToolCharacterDB.point.boneShield, boneShield.up)

    -- 初始刷新一次
    self:UpdateDeathKnightBuff()
end

function MzxToolFrame:UpdateDeathKnightDotFrameProgress(hasHeroTalentData)
    if hasHeroTalentData then
        self.dotFrameDeathKnight:SetBackdropColor(0, 0.4, 1, 0.55)
        self.dotFrameDeathKnight:SetBackdropBorderColor(0, 0.1, 0.4, 0.8)
    else
        self.dotFrameDeathKnight:SetBackdropColor(0, 0, 0, 0.15)
        self.dotFrameDeathKnight:SetBackdropBorderColor(0.2, 0.2, 0.2, 0.5)
    end
end

-- 设定骨盾层数颜色
function MzxToolFrame:UpdateDeathKnightDotProgress(stacks)
    local alpha = 1
    for i = 1, boneShield.max_stacks do
        local dot = self.boneShieldDots[i]

        if i <= stacks then
            -- 激活的小圆点 - 饱满的纵向渐变
            local topColor, bottomColor = self:GetDeathKnightGradientColors(i, alpha)
            dot.tex:SetGradient("VERTICAL", topColor, bottomColor)

            -- 发光效果
            dot.glow:SetGradient("VERTICAL", topColor, bottomColor)
            dot.glow:Show()
            dot:SetAlpha(1)
        else
            -- 未激活的小圆点 - 深灰色渐变
            dot.tex:SetGradient("VERTICAL",
                CreateColor(0.5, 0.5, 0.5, alpha),
                CreateColor(0.2, 0.2, 0.2, alpha)
            )
            dot.glow:Hide()
            dot:SetAlpha(0.3)
        end
    end
end

function MzxToolFrame:GetDeathKnightGradientColors(dotIndex, alpha)
    -- 饱满的金属渐变色
    if dotIndex <= 4 then
        -- 红色金属
        return CreateColor(1.0, 0.4, 0.4, alpha), CreateColor(1.0, 0.0, 0.0, alpha)
    elseif dotIndex <= 7 then
        -- 橙色金属
        return CreateColor(1.0, 0.8, 0.7, alpha), CreateColor(1.0, 0.5, 0.1, alpha)
    elseif dotIndex <= 9 then
        -- 金色金属
        return CreateColor(1.0, 1.0, 0.7, alpha), CreateColor(0.8, 0.6, 0.2, alpha)
    else
        -- 蓝色金属
        return CreateColor(0.8, 0.9, 1.0, alpha), CreateColor(0.2, 0.4, 0.9, alpha)
    end
end

function MzxToolFrame:UpdateDeathKnightBuff()
    if not self.dotFrameDeathKnight then
        return
    end

    -- GetAuraDataBySlot 的第二参数是光环槽位号，必须按 spellID 查询
    local boneShieldData = C_UnitAuras.GetUnitAuraBySpellID("player", boneShield.spell_id)
    local heroTalentData = C_UnitAuras.GetUnitAuraBySpellID("player", boneShield.heroTalent_spell_id)

    if GetSpecializationInfo(GetSpecialization()) == boneShield.BloodDeathKnight_SpecId then
        self.dotFrameDeathKnight:Show()
    else
        self.dotFrameDeathKnight:Hide()
    end

    boneShield.currentStacks = (boneShieldData and boneShieldData.applications) or 0

    -- 更新小圆点进度
    self:UpdateDeathKnightDotProgress(boneShield.currentStacks)
    self:UpdateDeathKnightDotFrameProgress(heroTalentData ~= nil)
end
