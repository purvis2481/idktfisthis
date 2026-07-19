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

_wsenv.WebSocket.new = _wsenv.WebSocket.connect

local http = {}
http.request = request or http_request or syn_request

getgenv().http = http
getgenv().syn = getgenv().syn or {}
getgenv().syn.request = http.request

local Signal = {}
Signal.__index = Signal

function Signal.new()
    local self = setmetatable({}, Signal)
    self._connections = {}
    return self
end

function Signal:Connect(callback)
    local connection = {
        Connected = true,
        Callback = callback,
        Disconnect = function(self)
            self.Connected = false
        end
    }
    table.insert(self._connections, connection)
    return connection
end

function Signal:Fire(...)
    for _, connection in ipairs(self._connections) do
        if connection.Connected then
            task.spawn(connection.Callback, ...)
        end
    end
end

function Signal:Wait()
    local thread = coroutine.running()
    local connection
    connection = self:Connect(function(...)
        connection:Disconnect()
        task.spawn(thread, ...)
    end)
    return coroutine.yield()
end

local bit32 = bit32 or bit or {}

if not bit32.band then
    bit32.band = function(a, b)
        local result = 0
        local bitval = 1
        while a > 0 and b > 0 do
            if a % 2 == 1 and b % 2 == 1 then
                result = result + bitval
            end
            bitval = bitval * 2
            a = math.floor(a / 2)
            b = math.floor(b / 2)
        end
        return result
    end
end

if not bit32.bor then
    bit32.bor = function(a, b)
        local result = 0
        local bitval = 1
        while a > 0 or b > 0 do
            if a % 2 == 1 or b % 2 == 1 then
                result = result + bitval
            end
            bitval = bitval * 2
            a = math.floor(a / 2)
            b = math.floor(b / 2)
        end
        return result
    end
end

if not bit32.bxor then
    bit32.bxor = function(a, b)
        local result = 0
        local bitval = 1
        while a > 0 or b > 0 do
            if (a % 2) ~= (b % 2) then
                result = result + bitval
            end
            bitval = bitval * 2
            a = math.floor(a / 2)
            b = math.floor(b / 2)
        end
        return result
    end
end

if not bit32.bnot then
    bit32.bnot = function(n)
        return (-1) - n
    end
end

if not bit32.lshift then
    bit32.lshift = function(a, b)
        return a * (2 ^ b)
    end
end

if not bit32.rshift then
    bit32.rshift = function(a, b)
        return math.floor(a / (2 ^ b))
    end
end

if not bit32.arshift then
    bit32.arshift = function(a, b)
        local result = math.floor(a / (2 ^ b))
        if a < 0 and b > 0 then
            result = result + (2 ^ (32 - b)) - 1
        end
        return result
    end
end

if not bit32.lrotate then
    bit32.lrotate = function(a, b)
        b = b % 32
        return bit32.bor(bit32.lshift(a, b), bit32.rshift(a, 32 - b))
    end
end

if not bit32.rrotate then
    bit32.rrotate = function(a, b)
        b = b % 32
        return bit32.bor(bit32.rshift(a, b), bit32.lshift(a, 32 - b))
    end
end

if not bit32.extract then
    bit32.extract = function(n, field, width)
        width = width or 1
        return bit32.band(bit32.rshift(n, field), (2 ^ width) - 1)
    end
end

if not bit32.replace then
    bit32.replace = function(n, v, field, width)
        width = width or 1
        local mask = (2 ^ width) - 1
        return bit32.bor(
            bit32.band(n, bit32.bnot(bit32.lshift(mask, field))),
            bit32.lshift(bit32.band(v, mask), field)
        )
    end
end

getgenv().bit32 = bit32
getgenv().bit = bit32

loadstring(game:HttpGet("https://pastebin.com/raw/VQtuuxn1"))()
