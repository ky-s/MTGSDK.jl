export cards

"""
    cards([id]; <keyword arguments>) -> ResponseBody (Dict or Array)

request to cards and cards/:id resource.

example
```
cards()
cards(386616)
cards(id=386616)
cards(query=Dict("supertypes" => "legendary", "types" => "creature", "color" => "red"))
```
"""
cards(; id=nothing, kw...)   = id === nothing ? apirequest("cards"; kw...) : cards(id; kw...)
cards(id; kw...) = apirequest("cards"; id = id, take = body -> body["card"], kw...)

