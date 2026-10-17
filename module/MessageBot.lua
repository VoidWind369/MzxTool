---# 收到密语时的处理
---@param sender string 发送者名称
---@param text string 密语内容
function MzxToolFrame:MessageStart(sender, text)
    if not sender or not text then
        return
    end
    text = strtrim(text)
    print("|cFA500FF0" .. sender .. "|r: " .. text)

    if text == "123" then
        C_PartyInfo.InviteUnit(sender)
        return
    end
    if text == "团队" then
        C_PartyInfo.ConfirmConvertToRaid()
        return
    end
    if text == "小队" then
        C_PartyInfo.ConvertToParty()
        return
    end
    local num_str = string.match(text, "倒数%s*(%d*)")
    if num_str then
        local num = tonumber(num_str) or 10
        print("|cFFFF0000开始倒数|r " .. num .. " |cFFFF0000秒|r")
        C_PartyInfo.DoCountdown(num)
        return
    end
    if text == "属性" then
        SendChatMessage(self:BuildPlayerInfoText(), "WHISPER", nil, sender)
    end
end

---# 把属性面板内容拼成纯文本（供密语发送）
function MzxToolFrame:BuildPlayerInfoText()
    local first, last = self:Void_PlayerInfo()
    local lines = {}
    for _, v in ipairs(first) do
        lines[#lines + 1] = v.name .. " " .. tostring(v.value)
    end
    for _, v in ipairs(last) do
        lines[#lines + 1] = v.name .. " " .. tostring(v.value)
    end
    return table.concat(lines, " | ")
end

function MzxToolFrame:PartyStart(name)
    if name then
        print("被|cFA500FF0" .. name .. "|r邀请进组")
    end
end
