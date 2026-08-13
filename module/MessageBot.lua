function MzxToolFrame:MessageStart(text, playerName, languageName, channelName)
    if not text then
        return
    end
    print(channelName .. "|cFA500FF0" .. playerName .. "|r say: " .. text)
    if text == "123" then
        C_PartyInfo.InviteUnit(playerName)
    end
    if text == "团队" then
        C_PartyInfo.ConfirmConvertToRaid()
    end
    if text == "小队" then
        C_PartyInfo.ConvertToParty()
    end
    if string.find(text, "倒数") then
        local num_str = string.gsub(text, "倒数", "")
        local num = tonumber(strtrim(num_str)) or 10
        print("|cFFFF0000开始倒计时|r", num, "|cFFFF0000秒|r")
        C_PartyInfo.DoCountdown(num)
    end
    if text == "属性" then
        SendChatMessage(self:Void_PlayerInfo(), "WHISPER", nil, playerName)
    end
end

function MzxToolFrame:PartyStart(name, isTank, isHealer, isDamage, isNativeRealm, allowMultipleRoles, inviterGUID,
                              questSessionActive)
    -- AcceptGroup()
    -- StaticPopup_Hide("PARTY_INVITE")
    print("被|cFA500FF0" .. name .. "|r邀请进组")
end
