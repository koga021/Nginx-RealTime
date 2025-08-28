local redis = require "resty.redis"

local red = redis:new()
red:set_timeout(1000)

local ok, err = red:connect("redis", 6379)
if not ok then
    ngx.status = 500
    ngx.say("Redis connection error: ", err)
    return
end

-- Incrementa no Redis
local new_count, err = red:incr("counter")
if not new_count then
    ngx.status = 500
    ngx.say("Failed to increment counter: ", err)
    return
end

-- Publica para que o subscriber atualize o cache
red:publish("counter_channel", new_count)

red:set_keepalive(10000, 100)

ngx.say(new_count)
