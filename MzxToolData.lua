function InitDatabase()
    MzxToolDB = MzxToolDB or {}
    MzxToolCharacterDB = MzxToolCharacterDB or {
        point = {}
    }
    MzxToolCharacterDB.status = MzxToolCharacterDB.status or {
        PlayerInfo = true,
        BloodlustSimple = true,
        TotemWeaponMonitor = true,
        BoneShieldMonitor = false,
    }
end

function NewDatabase()
    MzxToolDB = {}
    MzxToolCharacterDB = {
        point = {}
    }
    MzxToolCharacterDB.status = {
        PlayerInfo = true,
        BloodlustSimple = true,
        TotemWeaponMonitor = true,
        BoneShieldMonitor = false,
    }
    ReloadUI()
end
