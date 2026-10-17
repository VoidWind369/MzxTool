-- ============================================================
-- 自动进本 / 自动接受职责检查
--
-- 12.0.5 起 Blizzard 的 Restricted Actions 体系会拦截插件对
-- 暴雪受保护框架（LFDRoleCheckPopupAcceptButton、
-- LFGDungeonReadyDialogEnterDungeonButton 等）的非安全上下文 :Click()，
-- 该方案已不可用，这里保留文件但默认停用，不再自动触发。
--
-- 如需自动化，请使用暴雪自带的「队列后自动进入」游戏内选项，
-- 或改用带安全上下文的宏（例如创建宏后手动 /run 执行）。
-- ============================================================

local function IsRestricted()
    if type(C_RestrictedActions) == "table" and C_RestrictedActions.GetAddOnRestrictionState then
        return true
    end
    return false
end

---# 在受保护的受限环境中安全地尝试点击（失败时静默）
function MzxToolFrame:SafeClick(frame)
    if not frame then
        return false
    end
    if IsRestricted() then
        MzxDebug("|cFFFFAA00受限环境下已跳过自动点击|r")
        return false
    end
    local ok = pcall(frame.Click, frame)
    return ok and true or false
end
