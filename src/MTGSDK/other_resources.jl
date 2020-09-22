export types, subtypes, supertypes, formats

"""
    types(; <keyword arguments>) -> ResponseBody (Dict or Array)

apirequest to types resource.
"""
types() = apirequest("types")

"""
    subtypes(; <keyword arguments>) -> ResponseBody (Dict or Array)

apirequest to subtypes resource.
"""
subtypes() = apirequest("subtypes")

"""
    supertypes(; <keyword arguments>) -> ResponseBody (Dict or Array)

apirequest to supertypes resource.
"""
supertypes() = apirequest("supertypes")

"""
    formats(; <keyword arguments>) -> ResponseBody (Dict or Array)

apirequest to formats resource.
"""
formats() = apirequest("formats")

