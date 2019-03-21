module MTGSDK

using HTTP: get, Response
using JSON: parse
using Pipe

export request, cards, sets, booster, types, subtypes, supertypes, formats

ROOT="https://api.magicthegathering.io"
VERSION="v1"

function _build_url(resource::AbstractString; id=nothing, query=nothing, raw=nothing, version=VERSION)
    url = "$ROOT/$version/$resource"

    id    !== nothing && ( url *= "/" * string(id)                                   )
    raw   !== nothing && ( url *= raw                                                )
    query !== nothing && ( url *= '?' * join(["$(k)=$(v)" for (k, v) in query], '&') )

    return url
end

function _parse(resp::Response, take)
    resp.status == 200 && return (resp.body |> String |> parse |> take)
    resp.status == 400 && return "400: We could not process that action"
    resp.status == 403 && return "403: You exceeded the rate limit"
    resp.status == 404 && return "404: The requested resource could not be found"
    resp.status == 500 && return "500: We had a problem with our server. Please try again later"
    resp.status == 503 && return "503: We are temporarily offline for maintenance. Please try again later"
    "$(resp.status): undefined HTTP status. ->($resp)"
end

"""
    request(resource; <keyword arguments>) -> Dict{String,Any}

request to any resource.

example
```
request("cards", id=386616)
```
"""
request(resource::AbstractString; take=(r)->r[resource], kw...) = @pipe _build_url(resource; kw...) |> get |> _parse(_, take)

"""
    cards([id]; <keyword arguments>) -> Dict{String,Any}

request to cards and cards/:id resource.

example
```
cards()
cards(386616)
cards(id=386616)
cards(query=Dict("supertypes" => "legendary", "types" => "creature", "color" => "red"))
```
"""
cards(; id=nothing, kw...)   = id === nothing ? request("cards"; kw...) : cards(id; kw...)
cards(id; kw...) = request("cards"; id=id, take=(r)->r["card"], kw...)

"""
    sets([set]; <keyword arguments>) -> Dict{String,Any}

request to sets and sets/:id resource.

example
```
sets()
sets("rna")
sets(set="rna")
sets(query=Dict("supertypes" => "legendary", "types" => "creature", "color" => "red"))
```
"""
sets(; kw...)  = request("sets"; kw...)
sets(set; kw...)  = request("sets"; id=set, take=(r)->r["set"], kw...)

"""
    booster(set; <keyword arguments>) -> Dict{String,Any}

request to sets/:id/booster resource.

example
```
booster("rna")
```
"""
booster(set) = request("sets"; id=set, raw="/booster", take=(r)->r["cards"])

"""
    types(; <keyword arguments>) -> Dict{String,Any}

request to types resource.
"""
types() = request("types")

"""
    subtypes(; <keyword arguments>) -> Dict{String,Any}

request to subtypes resource.
"""
subtypes() = request("subtypes")

"""
    supertypes(; <keyword arguments>) -> Dict{String,Any}

request to supertypes resource.
"""
supertypes() = request("supertypes")

"""
    formats(; <keyword arguments>) -> Dict{String,Any}

request to formats resource.
"""
formats() = request("formats")

end # module
