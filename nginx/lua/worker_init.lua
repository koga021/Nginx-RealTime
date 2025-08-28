local redis = require "resty.redis"
local dict = ngx.shared.my_cache

-- 1️⃣ Inicializa cache com valor atual do Redis
local function init_cache(premature)
    if premature then return end

    local red = redis:new()
    red:set_timeout(1000)  -- timeout curto só para GET inicial

    local ok, err = red:connect("redis", 6379)
    if not ok then
        ngx.log(ngx.ERR, "Failed to connect to Redis: ", err)
        return
    end

    local val, err = red:get("counter")
    if val == ngx.null then val = 0 end
    dict:set("counter", tonumber(val))

    red:set_keepalive(10000, 100)
end

ngx.timer.at(0, init_cache)

-- 2️⃣ Subscriber seguro
local function subscriber(premature)
    if premature then return end

    local red = redis:new()
    red:set_timeout(0)  -- timeout infinito para Pub/Sub

    local ok, err = red:connect("redis", 6379)
    if not ok then
        ngx.log(ngx.ERR, "Failed to connect Redis for subscriber: ", err)
        return
    end

    local res, err = red:subscribe("counter_channel")
    if not res then
        ngx.log(ngx.ERR, "Failed to subscribe: ", err)
        return
    end

    ngx.log(ngx.NOTICE, "Worker subscribed to counter_channel")

    while true do
        local msg, err = red:read_reply()
        if msg then
            if msg[1] == "message" then
                local new_val = tonumber(msg[3])
                dict:set("counter", new_val)
            end
        elseif err then
            ngx.log(ngx.ERR, "Redis subscriber read error: ", err)
            ngx.sleep(1)  -- espera 1s e tenta continuar
        end
    end
end

ngx.timer.at(0, subscriber)
