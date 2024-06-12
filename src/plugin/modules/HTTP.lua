local HTTP = {}
local internal = {}

internal.project = game
internal.service = internal.project:GetService('HttpService')

function HTTP.Get(Url, Body, Headers)
    return internal.service:RequestAsync({
        Url = Url,
        Method = "GET",
        Headers = Headers,
        Body = Body,
        Compress = Enum.HttpCompression.Gzip
    })
end

function HTTP.Post(Url, Body, Headers)
    return internal.service:RequestAsync({
        Url = Url,
        Method = "POST",
        Headers = Headers,
        Body = Body,
        Compress = Enum.HttpCompression.Gzip
    })
end

function HTTP.Decode(Content) return internal.service:JSONDecode(Content) end

function HTTP.Encode(Content) return internal.service:JSONEncode(Content) end

function HTTP.Test()
    local Response = internal.service:RequestAsync({
        Url = 'https://roblox-apis.bracketed.co.uk',
        Method = "GET"
    })

    if Response.StatusCode ~= 200 then return false end
    return true
end

return HTTP
