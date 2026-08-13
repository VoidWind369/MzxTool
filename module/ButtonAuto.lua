function SimulateButtonClick(buttonName)
    local button = _G[buttonName]
    if button then
        button:Click()
    else
        print("按钮 " .. buttonName .. " 未找到")
    end
end

function MzxToolFrame:CreateAutoButton()
    self.autoEnterButton = CreateFrame("Button", "AutoEnterButton", UIParent, "SecureActionButtonTemplate")
    self.autoEnterButton:SetAttribute("type", "macro")  -- 按钮类型为“执行宏”
    -- self.autoEnterButton:SetAttribute("macrotext", [[
    --     /click LFDRoleCheckPopupAcceptButton
    --     /click LFGDungeonReadyDialogEnterDungeonButton
    --     /click StaticPopup1Button1
    -- ]])
    -- self.autoEnterButton:SetAttribute("macrotext", "/click LFGDungeonReadyDialogEnterDungeonButton")
    self.autoEnterButton:SetAttribute("macro", "进副本")
    self.autoEnterButton:RegisterForClicks("AnyUp", "AnyDown")
    -- self.autoEnterButton:Hide() -- 隐藏按钮，我们不需要它显示在界面上
end
