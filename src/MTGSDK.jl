module MTGSDK

using HTTP: get, Response
using JSON: parse
using Pipe

export cards, sets, booster, types, subtypes, supertypes, formats, translate_to, translate_to_japanese

ROOT="https://api.magicthegathering.io"
VERSION="v1"

function _build_url(resource::AbstractString; id=nothing, query=nothing, raw=nothing, version=VERSION)
    url = "$ROOT/$version/$resource"

    id !== nothing && ( url *= "/" * string(id) )

    if raw !== nothing
        url *= raw
    elseif query !== nothing
        url *= '?' * join(["$(k)=$(v)" for (k, v) in query], '&')
    end

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
    _request(resource; <keyword arguments>) -> ResponseBody (Dict or Array)

_request to any resource.

example
```
_request("cards", id=386616)
```
"""
_request(resource::AbstractString; take=(r)->r[resource], kw...) = @pipe _build_url(resource; kw...) |> get |> _parse(_, take)

"""
    cards([id]; <keyword arguments>) -> ResponseBody (Dict or Array)

_request to cards and cards/:id resource.

example
```
cards()
cards(386616)
cards(id=386616)
cards(query=Dict("supertypes" => "legendary", "types" => "creature", "color" => "red"))
```
"""
cards(; id=nothing, kw...)   = id === nothing ? _request("cards"; kw...) : cards(id; kw...)
cards(id; kw...) = _request("cards"; id=id, take=(r)->r["card"], kw...)

"""
    sets([set]; <keyword arguments>) -> ResponseBody (Dict or Array)

_request to sets and sets/:id resource.

example
```
sets()
sets("rna")
sets(set="rna")
sets(query=Dict("supertypes" => "legendary", "types" => "creature", "color" => "red"))
```
"""
sets(; kw...)  = _request("sets"; kw...)
sets(set; kw...)  = _request("sets"; id=set, take=(r)->r["set"], kw...)

"""
    booster(set; <keyword arguments>) -> ResponseBody (Dict or Array)

_request to sets/:id/booster resource.

example
```
booster("rna")
```
"""
booster(set) = _request("sets"; id=set, raw="/booster", take=(r)->r["cards"])

"""
    types(; <keyword arguments>) -> ResponseBody (Dict or Array)

_request to types resource.
"""
types() = _request("types")

"""
    subtypes(; <keyword arguments>) -> ResponseBody (Dict or Array)

_request to subtypes resource.
"""
subtypes() = _request("subtypes")

"""
    supertypes(; <keyword arguments>) -> ResponseBody (Dict or Array)

_request to supertypes resource.
"""
supertypes() = _request("supertypes")

"""
    formats(; <keyword arguments>) -> ResponseBody (Dict or Array)

_request to formats resource.
"""
formats() = _request("formats")

"""
    translaete_to(language, card) -> translated_card

if card has foreignNames and `language` field, merge same key and delete other languages.
"""
function translate_to(language::AbstractString, card)
    haskey(card, "foreignNames") || return card
    f = filter(foreign -> foreign["language"] == language, card["foreignNames"])
    !isa(f, Array) && return card
    @pipe deepcopy(card) |> delete!(_, "foreignNames") |> merge(_, f[1])
end

translate_to_japanese(card) = translate_to("Japanese", card)

end # module
