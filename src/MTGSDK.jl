module MTGSDK

using HTTP: get

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

"""
    request(resource; <keyword arguments>) -> HTTP.Response

request to any resource.

example
```
request("cards", id=386616)
```
"""
request(resource::AbstractString; kw...) = get(_build_url(resource; kw...))

"""
    cards([id]; <keyword arguments>) -> HTTP.Response

request to cards and cards/:id resource.

example
```
cards()
cards(386616)
cards(id=386616)
cards(query=Dict("supertypes" => "legendary", "types" => "creature", "color" => "red"))
```
"""
cards(; kw...)   = request("cards"; kw...)
cards(id; kw...) = request("cards"; id=id, kw...)

"""
    sets([set]; <keyword arguments>) -> HTTP.Response

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
sets(set; kw...)  = request("sets"; id=set, kw...)

"""
    booster(set; <keyword arguments>) -> HTTP.Response

request to sets/:id/booster resource.

example
```
booster("rna")
```
"""
booster(set) = request("sets"; id=set, raw="/booster")

"""
    types(; <keyword arguments>) -> HTTP.Response

request to types resource.
"""
types() = request("types")

"""
    subtypes(; <keyword arguments>) -> HTTP.Response

request to subtypes resource.
"""
subtypes() = request("subtypes")

"""
    supertypes(; <keyword arguments>) -> HTTP.Response

request to supertypes resource.
"""
supertypes() = request("supertypes")

"""
    formats(; <keyword arguments>) -> HTTP.Response

request to formats resource.
"""
formats() = request("formats")

end # module
