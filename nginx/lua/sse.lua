-- -- Configura headers para SSE
-- ngx.header["Content-Type"] = "text/event-stream"
-- ngx.header["Cache-Control"] = "no-cache"
-- ngx.header["Connection"] = "keep-alive"
-- ngx.header["Access-Control-Allow-Origin"] = "*"  -- permite qualquer origem

-- -- não deixar a conexão fechar automaticamente
-- ngx.flush(true)

-- local redis = require "resty.redis"

-- -- loop infinito para manter SSE ativo
-- while true do
--     local red = redis:new()
--     red:set_timeout(1000)
--     local ok, err = red:connect("redis", 6379)
--     if not ok then
--         ngx.say("data: failed to connect\n\n")
--         ngx.flush(true)
--         ngx.sleep(1)
--     else
--         -- pega valor atual do contador
--         local val, err = red:get("counter")
--         if not val or val == ngx.null then
--             val = 0
--         end

--         -- envia no formato SSE
--         ngx.say("data: " .. val .. "\n\n")
--         ngx.flush(true)
--         red:set_keepalive(10000, 100)
--     end

--     -- atualiza a cada 2 segundos
--     ngx.sleep(2)
-- end


-- ngx.header["Content-Type"] = "text/event-stream"
-- ngx.header["Cache-Control"] = "no-cache"
-- ngx.header["Connection"] = "keep-alive"
-- ngx.header["Access-Control-Allow-Origin"] = "*"

-- local redis = require "resty.redis"
-- local red = redis:new()
-- red:set_timeout(0)  -- sem timeout para Pub/Sub
-- local ok, err = red:connect("redis", 6379)
-- if not ok then
--     ngx.say("data: failed to connect\n\n")
--     return
-- end

-- -- se inscreve no canal "counter_channel"
-- local res, err = red:subscribe("counter_channel")
-- if not res then
--     ngx.say("data: failed to subscribe\n\n")
--     return
-- end

-- while true do
--     local msg, err = red:read_reply()
--     if msg then
--         local value = msg[3]  -- o payload do publish é o índice 3
--         ngx.say("data: " .. value .. "\n\n")
--         ngx.flush(true)
--     else
--         ngx.sleep(0.1)  -- evita loop pesado
--     end
-- end

local redis = require "resty.redis"
local cache = ngx.shared.my_cache

ngx.header["Content-Type"] = "text/event-stream"
ngx.header["Cache-Control"] = "no-cache"
ngx.header["Connection"] = "keep-alive"
ngx.header["Access-Control-Allow-Origin"] = "*"

local red = redis:new()
red:set_timeout(1000)
local ok, err = red:connect("redis", 6379)
if not ok then
    ngx.say("data: failed to connect\n\n")
    return
end

-- 1️⃣ Tenta pegar valor do cache Lua
local val = cache:get("counter")
if not val then
    -- se não tiver cache, pega do Redis
    val, err = red:get("counter")
    if not val or val == ngx.null then
        val = 0
    end
    -- salva no cache Lua
    cache:set("counter", val)
end

-- envia valor inicial imediatamente
ngx.say("data: " .. val .. "\n\n")
ngx.flush(true)

-- 2️⃣ Inscreve no canal Pub/Sub para updates
local res, err = red:subscribe("counter_channel")
if not res then
    ngx.say("data: failed to subscribe\n\n")
    return
end

while true do
    local msg, err = red:read_reply()
    if msg then
        local value = msg[3]
        -- atualiza cache Lua
        cache:set("counter", value)
        -- envia update SSE
        ngx.say("data: " .. value .. "\n\n")
        ngx.flush(true)
    else
        ngx.sleep(0.1)
    end
end
