include("../src/MTGSDK.jl") ; using .MTGSDK

function filter_attribute(card; pick_keys=["name", "manaCost", "rarity", "flavor"])
    filter(pair -> pair.first in pick_keys && !isa(pair.second, Nothing), card)
end

touchup(card) = translate_to_japanese(card) |> filter_attribute
cards = touchup.(booster("rna"))
for card in cards
    join(values(card), "\n") * "\n" |> println
end
