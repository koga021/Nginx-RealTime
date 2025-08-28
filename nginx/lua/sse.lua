

ngx.header["Content-Type"] = "text/event-stream"
ngx.header["Cache-Control"] = "no-cache"
ngx.header["Connection"] = "keep-alive"
ngx.header["Access-Control-Allow-Origin"] = "*"

local dict = ngx.shared.my_cache
local last_sent = dict:get("counter") or 0

-- Envia valor inicial
ngx.say("data: " .. last_sent .. "\n")
ngx.flush(true)

while true do
    ngx.sleep(0.5)  -- pooling leve só para verificar cache

    local current = dict:get("counter") or 0
    if current ~= last_sent then
        last_sent = current
        ngx.say("data: " .. current .. "\n")
        ngx.flush(true)
    end
end
