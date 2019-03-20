module MTGSDK

using HTTP: get
using JSON: parse

export cards, sets, booster, types, subtypes, supertypes, formats

baseurl="https://api.magicthegathering.io"
version="v1"

function _build_url(endpoint::AbstractString; id=nothing, query=nothing, raw=nothing)
    url = "$baseurl/$version/$endpoint"

    id    !== nothing && ( url *= "/" * string(id)                                   )
    raw   !== nothing && ( url *= raw                                                )
    query !== nothing && ( url *= '?' * join(["$(k)=$(v)" for (k, v) in query], '&') )

    return url
end

function _request(url::String)
    resp = get(url)
    resp.status == 200 || return resp.status
    resp.body |> String |> parse
end

"""
    cards([id])
    request to cards and cards/:id endpoint.
"""
cards(; kw...) = _build_url("cards"; kw...) |> _request
cards(id; kw...) = _build_url("cards"; id=id, kw...) |> _request

"""
    sets([set])
    request to sets and sets/:id endpoint.
"""
sets(; kw...)  = _build_url("sets"; kw...)  |> _request
sets(set; kw...)  = _build_url("sets"; id=set, kw...)  |> _request

"""
    booster(set)
    request to sets/:id/booster endpoint.
"""
booster(set; kw...) = _build_url("sets"; id=set, raw="/booster", kw...) |> _request

"""
    types()
    request to types endpoint.
"""
types() = _build_url("types") |> _request

"""
    subtypes()
    request to subtypes endpoint.
"""
subtypes() = _build_url("subtypes") |> _request

"""
    supertypes()
    request to supertypes endpoint.
"""
supertypes() = _build_url("supertypes") |> _request

"""
    formats()
    request to formats endpoint.
"""
formats() = _build_url("formats") |> _request

end # module
