-- 默认状态表：集中在这里，InitDatabase 会为缺失的键补齐
local DEFAULT_STATUS = {
    PlayerInfo = true,
    BloodlustSimple = true,
    TotemWeaponMonitor = true,
    BoneShieldMonitor = false,
    Debug = false,
}

local function ApplyDefaults(status)
    for key, value in pairs(DEFAULT_STATUS) do
        if status[key] == nil then
            status[key] = value
        end
    end
    -- 清理历史版本遗留的无效键（曾被 /mzx show 错误写入）
    for _, key in ipairs({ "ShieldInfo", "SkillLine", "TotemInfo", "TotemTool" }) do
        status[key] = nil
    end
end

function InitDatabase()
    MzxToolDB = MzxToolDB or {}
    MzxToolCharacterDB = MzxToolCharacterDB or {}
    MzxToolCharacterDB.point = MzxToolCharacterDB.point or {}
    MzxToolCharacterDB.status = MzxToolCharacterDB.status or {}
    ApplyDefaults(MzxToolCharacterDB.status)
end

function NewDatabase()
    MzxToolDB = {}
    MzxToolCharacterDB = {
        point = {},
        status = {},
    }
    ApplyDefaults(MzxToolCharacterDB.status)
    ReloadUI()
end
