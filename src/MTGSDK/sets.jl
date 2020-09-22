export sets, booster

"""
    sets([set]; <keyword arguments>) -> ResponseBody (Dict or Array)

apirequest to sets and sets/:id resource.

example
```
sets()
sets("rna")
sets(set="rna")
sets(query=Dict("supertypes" => "legendary", "types" => "creature", "color" => "red"))
```
"""
sets(; kw...)  = apirequest("sets"; kw...)
sets(set; kw...)  = apirequest("sets"; id = set, take = body -> body["set"], kw...)

"""
    booster(set; <keyword arguments>) -> ResponseBody (Dict or Array)

apirequest to sets/:id/booster resource.

example
```
booster("rna")
```
"""
booster(set) = apirequest("sets"; id = set, raw = "/booster", take = body -> body["cards"])
