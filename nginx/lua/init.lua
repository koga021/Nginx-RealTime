local function init_cache(premature)
    if premature then return end

    local redis = require "resty.redis"
    local red = redis:new()
    red:set_timeout(1000)

    local ok, err = red:connect("redis", 6379)
    if not ok then
        ngx.log(ngx.ERR, "Failed to connect to Redis: ", err)
        return
    end

    local val, err = red:get("counter")
    if val == ngx.null then val = 0 end

    ngx.shared.my_cache:set("counter", val)
    red:set_keepalive(10000, 100)
end

-- cria timer para executar no worker
ngx.timer.at(0, init_cache)
