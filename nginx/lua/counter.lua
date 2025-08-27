-- local redis = require "resty.redis"
-- local red = redis:new()
-- red:set_timeout(1000)

-- local ok, err = red:connect("redis", 6379)
-- if not ok then
--     ngx.say("failed to connect: ", err)
--     return
-- end

-- -- incrementa contador
-- local res, err = red:incr("counter")
-- if not res then
--     ngx.say("failed to increment: ", err)
--     return
-- end

-- -- responde ao cliente
-- ngx.say("Visit registered! Current count: ", res)


-- local redis = require "resty.redis"
-- local red = redis:new()
-- red:set_timeout(1000)

-- local ok, err = red:connect("redis", 6379)
-- if not ok then
--     ngx.say("failed to connect: ", err)
--     return
-- end

-- -- incrementa contador
-- local val, err = red:incr("counter")
-- if not val then
--     ngx.say("failed to increment: ", err)
--     return
-- end

-- -- publica o novo valor no canal "counter_channel"
-- red:publish("counter_channel", val)

-- ngx.say("Visit registered! Current count: ", val)

-- red:set_keepalive(10000, 100)


local redis = require "resty.redis"
local red = redis:new()
red:set_timeout(1000)

local ok, err = red:connect("redis", 6379)
if not ok then
    ngx.say("failed to connect: ", err)
    return
end

-- incrementa contador
local val, err = red:incr("counter")
if not val then
    ngx.say("failed to increment: ", err)
    return
end

-- publica no canal Pub/Sub
red:publish("counter_channel", val)

-- atualiza cache Lua
local cache = ngx.shared.my_cache
cache:set("counter", val)

ngx.say("Visit registered! Current count: ", val)

red:set_keepalive(10000, 100)
