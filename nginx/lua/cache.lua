local redis = require "resty.redis"

-- cria cliente redis
local red = redis:new()
red:set_timeout(1000) -- 1s timeout

-- conecta no redis
local ok, err = red:connect("redis", 6379)

if not ok then
    ngx.say("failed to connect: ", err)
    return
end

-- pega contador
local res, err = red:get("counter")
if res == ngx.null then
    res = 0
end

-- incrementa contador
res = res + 1
red:set("counter", res)

-- retorna pro usuário
ngx.say("Redis counter value: ", res)

-- fecha conexão (pool)
red:set_keepalive(10000, 100)
