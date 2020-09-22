module MTGSDK
# WEB-API Original Docs: https://docs.magicthegathering.io/

# WEB-API Base
include("MTGSDK/base.jl")

# support endpoints:
#   https://api.magicthegathering.io/v1/cards
#   https://api.magicthegathering.io/v1/cards/:id
include("MTGSDK/cards.jl")

# support endpoints:
#   https://api.magicthegathering.io/v1/sets
#   https://api.magicthegathering.io/v1/sets/:id
#   https://api.magicthegathering.io/v1/sets/:id/booster
include("MTGSDK/sets.jl")

# support endpoints:
#   https://api.magicthegathering.io/v1/types
#   https://api.magicthegathering.io/v1/subtypes
#   https://api.magicthegathering.io/v1/supertypes
#   https://api.magicthegathering.io/v1/formats
include("MTGSDK/other_resources.jl")

include("MTGSDK/translations.jl")

end # module
