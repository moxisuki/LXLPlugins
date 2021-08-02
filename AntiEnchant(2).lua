--- by moxicat
--- Q:3601594248
---@diagnostic disable: undefined-field
local config = data.openConfig('.\\plugins\\AntiEnchant\\config.json', 'json', '{}')
logger.setConsole(true)
logger.setFile('.\\plugins\\AntiEnchant\\AntiEnchant.log')
logger.setTitle('AntiEnchant')
if config:get('检测等级') == nil then
    config:set('检测等级', 10)
    config:set('通报模板', '[通报]玩家 {player} 违规操作 {level} 级的 {name}')
    config:set('是否输出清理消息', true)
end
local level = config:get('检测等级')
local demo = config:get('通报模板')
local isOutput = config:get('是否输出清理消息')

local json = require('dkjson')
mc.listen(
    'onUseItemOn',
    function(player, item, block)
        if player:isOP() == false then
            checkItem(item, player, 'Useitem')
        end
    end
)
cahce = {}
function kickU(type, player, lvl, item, inv)
    if cahce[player.realName] == nil then
        cahce[player.realName] = false
        if inv then
            logger.warn('检测到玩家 ' .. player.realName .. '的物品栏第' .. type .. '格违规拥有 ' .. lvl .. ' 级的 ' .. item.name)
            setTimeout(
                function()
                    local res = mc.runcmdEx('/execute "' .. player.realName .. '" ~ ~ ~ clear @s ' .. item.type)
                    if isOutput then
                        local msg = string.gsub(demo, '{player}', player.realName)
                        msg = string.gsub(msg, '{name}', item.name)
                        msg = string.gsub(msg, '{level}', lvl)
                        mc.broadcast(msg, 0)
                        mc.broadcast(res.output)
                    end
                    cahce[player.realName] = nil
                end,
                000
            )
        end
    end
end

function checkItem(item, obj, type, inv)
    local dat = json.decode(item:getTag():toString())
    if dat['tag'] ~= nil then
        if dat['tag']['ench'] ~= nil then
            for key, value in pairs(dat['tag']['ench']) do
                if value['lvl'] >= level then
                    kickU(type, obj, value['lvl'], item, inv)
                    return
                end
            end
        end
    end
end

playerState= {}


mc.listen(
    'onJoin',
    function(player)
        playerState[player.realName] = true
    end
)


mc.listen(
    'onInventoryChange',
    function(player, slotNum, isPutin, item)
        if item:isNull() == false and playerState[player.realName] then
            checkItem(item, player, slotNum, true)
        end
    end
)
