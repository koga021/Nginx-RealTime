local redis = require "resty.redis"
local cache = ngx.shared.my_cache

-- pega último valor do cache
local last_val = cache:get("counter")
if not last_val then
    last_val = 0
    cache:set("counter", last_val)
end

-- envia imediatamente para o cliente SSE
ngx.header["X-Accel-Buffering"] = "no"  -- desabilita buffering no Nginx
ngx.header["Content-Type"] = "text/event-stream"
ngx.header["Cache-Control"] = "no-cache"
ngx.header["Connection"] = "keep-alive"
ngx.header["Access-Control-Allow-Origin"] = "*"


ngx.say("data:" .. last_val .. "\n\n")
ngx.flush(true)

-- armazenamos cada cliente SSE no dict (apenas para demo, pode ser um array global)
local client_id = ngx.var.request_id
local clients = cache:get("sse_clients") or {}
clients[client_id] = true
cache:set("sse_clients", clients)

-- **A única conexão Redis Pub/Sub** (criada em init_worker ou em outro worker)
-- aqui simplificamos para demo: cada worker cria uma conexão Pub/Sub única
local red = redis:new()
red:set_timeout(0)
red:connect("redis", 6379)
red:subscribe("counter_channel")

while true do
    local msg = red:read_reply()
    if msg then
        local value = msg[3]
        cache:set("counter", value)
        ngx.say("data:" .. value .. "\n\n")
        ngx.flush(true)
    else
        ngx.sleep(0.1)
    end
end
