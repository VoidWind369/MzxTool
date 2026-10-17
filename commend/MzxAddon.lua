-- ============================================
-- 插件主文件: core.lua
-- ============================================

local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local MzxToolAddon = LibStub("AceAddon-3.0"):NewAddon("MzxToolAddon", "AceConsole-3.0")

-- 模块编号 <-> status 键名映射
local MODULE_KEYS = {
    [1] = "BoneShieldMonitor", -- 血DK骨盾监控
    [2] = "PlayerInfo",         -- 角色属性面板
    [3] = "TotemWeaponMonitor", -- 增强萨漩涡武器监控
    [4] = "BloodlustSimple",    -- 嗜血提示
}

-- ============================================
-- 1. 初始化
-- ============================================
function MzxToolAddon:OnInitialize()
    -- 调用你的数据库初始化
    InitDatabase()

    -- 将全局表关联到插件对象（方便后续调用）
    self.db = MzxToolDB
    self.charDB = MzxToolCharacterDB

    -- 注册选项表
    AceConfig:RegisterOptionsTable("MzxToolAddon", self.options)

    -- 添加到游戏设置面板
    self.optionsFrame = AceConfigDialog:AddToBlizOptions("MzxToolAddon", "MzxTool 设置")

    -- 注册聊天命令
    self:RegisterChatCommand("mzx", "ShowConfig")
    self:RegisterChatCommand("mzxtool", "ShowConfig")
    self:RegisterChatCommand("mzxtoolbox", "ShowConfig")
    self:RegisterChatCommand("voidmod", "ShowConfig")
    self:RegisterChatCommand("void", "ShowConfig")
    self:RegisterChatCommand("moon", "ShowConfig")
    self:RegisterChatCommand("mt", "ShowConfig")
    self:RegisterChatCommand("vm", "ShowConfig")

    print("|cFF33FF99MzxToolAddon|r 已加载，输入 /mzx 打开设置")
end

-- ============================================
-- 2. 打开配置窗口
-- ============================================
function MzxToolAddon:ShowConfig(input)
    -- 如果输入为空或空格，打开设置面板
    MzxToolFrame:HandleSlashCommand(input)
end

-- ============================================
-- 3. 选项表定义
-- ============================================
MzxToolAddon.options = {
    type = "group",
    name = "MzxTool 设置",
    desc = "MzxTool 插件配置",
    args = {
        -- ===== 状态开关组 =====
        statusGroup = {
            type = "group",
            name = "功能开关",
            desc = "开启或关闭各项功能",
            order = 1,
            inline = true,
            args = {
                PlayerInfo = {
                    type = "toggle",
                    name = "玩家属性面板",
                    desc = "显示玩家详细信息",
                    order = 1,
                    get = function() return MzxToolCharacterDB.status.PlayerInfo end,
                    set = function(info, value)
                        MzxToolCharacterDB.status.PlayerInfo = value
                    end,
                },
                BloodlustSimple = {
                    type = "toggle",
                    name = "嗜血音效",
                    desc = "嗜血开启时播放自定义音效",
                    order = 2,
                    get = function() return MzxToolCharacterDB.status.BloodlustSimple end,
                    set = function(info, value)
                        MzxToolCharacterDB.status.BloodlustSimple = value
                    end,
                },
                TotemWeaponMonitor = {
                    type = "toggle",
                    name = "增强萨漩涡武器监控",
                    desc = "显示增强萨漩涡武器层数",
                    order = 3,
                    get = function() return MzxToolCharacterDB.status.TotemWeaponMonitor end,
                    set = function(info, value)
                        MzxToolCharacterDB.status.TotemWeaponMonitor = value
                    end,
                },
                BoneShieldMonitor = {
                    type = "toggle",
                    name = "鲜血死亡骑士骨盾监控",
                    desc = "显示鲜血死亡骑士骨盾层数",
                    order = 4,
                    get = function() return MzxToolCharacterDB.status.BoneShieldMonitor end,
                    set = function(info, value)
                        MzxToolCharacterDB.status.BoneShieldMonitor = value
                    end,
                },
                Debug = {
                    type = "toggle",
                    name = "调试模式",
                    desc = "开启调试信息输出",
                    order = 5,
                    get = function() return MzxToolCharacterDB.status.Debug end,
                    set = function(info, value)
                        MzxToolCharacterDB.status.Debug = value
                        if value then
                            print("|CFFFFAA00调试模式已开启|r")
                        else
                            print("调试模式已关闭")
                        end
                    end,
                },
            }
        },

        -- ===== 全选/重置操作 =====
        actionGroup = {
            type = "group",
            name = "快捷操作",
            order = 2,
            inline = true,
            args = {
                enableAll = {
                    type = "execute",
                    name = "全部开启",
                    desc = "开启所有功能",
                    order = 1,
                    width = "0.5",
                    func = function()
                        for key in pairs(MODULE_KEYS) do
                            MzxToolCharacterDB.status[MODULE_KEYS[key]] = true
                        end
                        print("|CFF00FF00所有功能已开启|r（需 /reload 生效）")
                        -- 刷新配置面板显示
                        if AceConfigDialog.OpenFrames and AceConfigDialog.OpenFrames["MzxToolAddon"] then
                            AceConfigDialog:Close("MzxToolAddon")
                            AceConfigDialog:Open("MzxToolAddon")
                        end
                    end,
                },
                disableAll = {
                    type = "execute",
                    name = "全部关闭",
                    desc = "关闭所有功能",
                    order = 2,
                    width = "0.5",
                    func = function()
                        for key in pairs(MODULE_KEYS) do
                            MzxToolCharacterDB.status[MODULE_KEYS[key]] = false
                        end
                        print("|CFFFF0000所有功能已关闭|r（需 /reload 生效）")
                        if AceConfigDialog.OpenFrames and AceConfigDialog.OpenFrames["MzxToolAddon"] then
                            AceConfigDialog:Close("MzxToolAddon")
                            AceConfigDialog:Open("MzxToolAddon")
                        end
                    end,
                },
                resetBtn = {
                    type = "execute",
                    name = "重置默认值",
                    desc = "恢复所有设置为默认状态",
                    order = 3,
                    width = "0.5",
                    func = function()
                        NewDatabase()
                        print("|CFFFFAA00设置已重置为默认值|r")
                        if AceConfigDialog.OpenFrames and AceConfigDialog.OpenFrames["MzxToolAddon"] then
                            AceConfigDialog:Close("MzxToolAddon")
                            AceConfigDialog:Open("MzxToolAddon")
                        end
                        ReloadUI()
                    end,
                },
            }
        },

        -- ===== ElvUI 相关 =====
        elvuiGroup = {
            type = "group",
            name = "ElvUI 集成",
            order = 4,
            inline = true,
            args = {
                elvuiStatus = {
                    type = "description",
                    name = function()
                        if ElvUI then
                            return "|CFF00FF00 ElvUI 已安装并检测到|r\n材质可通过 LibSharedMedia 调用"
                        else
                            return "|CFFFFAA00 ElvUI 未安装|r\n将使用默认材质"
                        end
                    end,
                    order = 1,
                },
                texturePreview = {
                    type = "description",
                    name = function()
                        if ElvUI then
                            local LSM = LibStub("LibSharedMedia-3.0")
                            local texture = LSM:Fetch("statusbar", "ElvUI Norm")
                            if texture then
                                return "|CFF00FF00 ElvUI 标准材质可用|r\n路径: " .. texture
                            else
                                return "|CFFFF0000 无法获取 ElvUI 材质|r"
                            end
                        else
                            return "需要 ElvUI 才能使用此功能"
                        end
                    end,
                    order = 2,
                },
            }
        },
        reloadBtn = {
            type = "execute",
            name = "保存并重载",
            desc = "开关改动需重载界面后生效",
            order = 5,
            width = "full", -- 独占一行更醒目
            func = function()
                -- 先保存（其实 AceDB 已经自动保存了，这里主要是给用户一个反馈）
                print("|CFF00FF00设置已保存，正在重载界面...|r")
                -- 延迟0.5秒重载，让打印信息能显示出来
                ReloadUI()
            end,
        },
    }
}

-- ============================================
-- 命令菜单
-- 说明：/void 等命令统一由 MzxTool.lua 中的 MzxToolFrame:HandleSlashCommand 处理，
--      本文件只负责转发（见 ShowConfig），避免重复定义互相覆盖。
-- ============================================

function MzxToolFrame:ToggleModules(enable, ...)
    local wanted = { ... }
    local hasIndex = false
    for _, key in ipairs(wanted) do
        local moduleKey = MODULE_KEYS[tonumber(key)]
        if moduleKey then
            MzxToolCharacterDB.status[moduleKey] = enable
            hasIndex = true
        end
    end
    -- 未指定任何有效编号时，按全选/全关处理（不含 Debug）
    if not hasIndex then
        for _, moduleKey in pairs(MODULE_KEYS) do
            MzxToolCharacterDB.status[moduleKey] = enable
        end
    end
    print(enable and "|cFF00FF00模块已开启（需 /reload 生效）|r" or "|cFFFF0000模块已关闭（需 /reload 生效）|r")
end
