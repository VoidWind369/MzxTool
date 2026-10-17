-- 调试用：查看目标身上的毒镰层数
-- 用法：/run GetTargetBuff()
local FESTERING_WOUND_SPELL_ID = 194310 -- 毒镰切口（Festering Wound）

function GetTargetBuff()
    if not UnitExists("target") then
        print("|cFFFF0000没有目标|r")
        return
    end
    local aura = C_UnitAuras.GetUnitAuraBySpellID("target", FESTERING_WOUND_SPELL_ID)
    if aura then
        local remain = aura.expirationTime and (aura.expirationTime - GetTime()) or 0
        print(string.format("|cFFFF0000毒镰|r 层数:%d  剩余:%.1fs", aura.applications or 0, math.max(remain, 0)))
    else
        print("|cFF00FF00目标身上没有毒镰|r")
    end
end

-- 调试用：按法术ID打印法术名
function PrintSpell(spellId)
    local info = C_Spell.GetSpellInfo(spellId or FESTERING_WOUND_SPELL_ID)
    if info then
        print(string.format("[%s] %s", info.id, info.name))
    else
        print(string.format("|cFFFF0000法术ID %s 无效|r", tostring(spellId or FESTERING_WOUND_SPELL_ID)))
    end
end
