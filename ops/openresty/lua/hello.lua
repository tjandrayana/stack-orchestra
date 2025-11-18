-- Sample Lua script for OpenResty
local function get_greeting()
    local hour = tonumber(os.date("%H"))
    if hour >= 5 and hour < 12 then
        return "Good morning"
    elseif hour >= 12 and hour < 17 then
        return "Good afternoon"
    elseif hour >= 17 and hour < 21 then
        return "Good evening"
    else
        return "Good night"
    end
end

ngx.header["Content-Type"] = "text/html"
ngx.say("<html><head><title>OpenResty Lua Example</title></head><body>")
ngx.say("<h1>", get_greeting(), " from OpenResty!</h1>")
ngx.say("<p>This is a Lua script running in OpenResty.</p>")
ngx.say("<p>Current time: ", os.date("%Y-%m-%d %H:%M:%S"), "</p>")
ngx.say("<p>Request URI: ", ngx.var.request_uri, "</p>")
ngx.say("<p>Remote Address: ", ngx.var.remote_addr, "</p>")
ngx.say("</body></html>")

