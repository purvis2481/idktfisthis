local _wsenv = getgenv()
_wsenv.WebSocket = _wsenv.WebSocket or {}

local _sleep = (task and task.wait) or wait

local function _wait_for_websocket_service(timeout_seconds)
    local timeout = timeout_seconds or 15
    local deadline = os.clock() + timeout

    pcall(function()
        if game and game.IsLoaded and not game:IsLoaded() then
            game.Loaded:Wait()
        end
    end)

    repeat
        local ok, svc = pcall(function()
            return game:GetService("WebSocketService")
        end)

        if ok and svc and type(svc.CreateClient) == "function" then
            return svc
        end

        _sleep(0.1)
    until os.clock() >= deadline

    return nil
end

_wsenv.WebSocket.connect = function(u)
    if type(u) ~= "string" then
        error("Invalid WebSocket URL: expected string")
    end

    if u == "ws://" or u == "wss://" then
        error("Invalid WebSocket URL: missing host/port")
    end

    if not string.match(u, "^wss?://") then
        error("Invalid WebSocket URL: expected ws:// or wss://")
    end

    local service = _wait_for_websocket_service(15)
    if not service then
        error("WebSocketService unavailable: timed out waiting for service readiness")
    end

    local last_error = "unknown error"
    for _ = 1, 40 do
        local ok, result = pcall(function()
            return service:CreateClient(u)
        end)

        if ok and result then
            local client = result
            return {
                OnMessage = client.MessageReceived,
                OnClose = client.Closed,
                Send = function(self, message)
                    client:Send(message)
                end,
                Close = function(self)
                    client:Close()
                end
            }
        end

        last_error = tostring(result)
        _sleep(0.1)
    end

    error("Failed to create WebSocket client: " .. last_error)
end

loadstring(game:HttpGet("https://pastebin.com/raw/VQtuuxn1"))()
