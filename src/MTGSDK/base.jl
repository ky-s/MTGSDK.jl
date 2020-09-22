import HTTP, JSON

export ResponseError

ROOT="https://api.magicthegathering.io"
VERSION="v1"

function build_url(resource::AbstractString; id = nothing, query = nothing, raw = nothing, version = VERSION)
    url = "$ROOT/$version/$resource"

    id !== nothing && ( url *= "/" * string(id) )

    if raw !== nothing
        url *= raw
    elseif query !== nothing
        url *= '?' * join(["$k=$v" for (k, v) in query], '&')
    end

    url
end

struct ResponseError
    response :: HTTP.Response
    message  :: String
end

function generate_error(response::HTTP.Response)
    message = if response.status == 400
        "400: We could not process that action"
    elseif response.status == 403
        "403: You exceeded the rate limit"
    elseif response.status == 404
        "404: The requested resource could not be found"
    elseif response.status == 500
        "500: We had a problem with our server. Please try again later"
    elseif response.status == 503
        "503: We are temporarily offline for maintenance. Please try again later"
    else
        "$(response.status): undefined HTTP status. ->($response)"
    end

    ResponseError(response, message)
end

function parse_response(response::HTTP.Response, take::Function)
    response.status != 200 && return generate_error(response)

    response.body |> String |> JSON.parse |> take
end

"""
    apirequest(resource; <keyword arguments>) -> ResponseBody (Dict or Array)

apirequest to any resource.

example
```
apirequest("cards", id=386616)
```
"""
function apirequest(resource::AbstractString; take::Function = body -> body[resource], kw...)
    url = build_url(resource; kw...)
    response = HTTP.get(url)

    parse_response(response, take)
end
