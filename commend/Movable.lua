-- 双击检测状态（每个框架一份，避免拖动结束被误判为双击）
local doubleClickState = setmetatable({}, { __mode = "k" })

function MovableDisplay(frame)
    -- 启用拖动
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")

    -- 拖动开始
    frame:SetScript("OnDragStart", function(self)
        self:StartMoving()
        doubleClickState[self] = false
    end)

    -- 双击检测
    local lastClickTime = 0
    frame:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            local currentTime = GetTime()
            if currentTime - lastClickTime < 0.3 then -- 300ms内
                doubleClickState[self] = true
            else
                doubleClickState[self] = false
            end
            lastClickTime = currentTime
        end
    end)

    return frame
end

--- # 拖动停止
--- * frame: 拖动停止的框架
--- * database: 框架的位置数据
function MovableFrameStop(frame, database, default_point)
    -- 拖动停止
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        doubleClickState[self] = false
        local p, _, _, xOfs, yOfs = self:GetPoint()
        database.p = p    -- 保存
        database.x = xOfs -- 保存
        database.y = yOfs -- 保存
    end)

    -- 双击复位到默认位置
    frame:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" and doubleClickState[self] then
            doubleClickState[self] = false
            self:ClearAllPoints()
            self:SetPoint(default_point.p, default_point.x, default_point.y)
            local p, _, _, xOfs, yOfs = self:GetPoint()
            -- 保存到变量或保存文件
            database.p = p    -- 保存
            database.x = xOfs -- 保存
            database.y = yOfs -- 保存
        end
    end)
end
