include("MTGSDK.jl")
using .MTGSDK

# @show MTGSDK.cards()
# @show MTGSDK.cards(id=386616)
# @show MTGSDK.cards(386616)
# @show MTGSDK.cards(query=Dict("name" => "khans"))
# @show MTGSDK.sets(query=Dict("page" => "2", "pageSize" => "10"))
# @show MTGSDK.sets(id="ktk")
# @show MTGSDK.sets("ktk")
# @show MTGSDK.types()
# @show MTGSDK.subtypes()
# @show MTGSDK.supertypes()
# @show MTGSDK.formats()
# @show MTGSDK.booster("ktk")
function name_and_flavor_text(card::Dict)
    isa(card, Dict) || return nothing
    foreignnames = card["foreignNames"]
    foreign = filter(foreign -> foreign["language"] == "Japanese", foreignnames)
    foreign === nothing && return nothing
    ja = foreign[1]
    ja["name"], ja["flavor"]
end

booster = MTGSDK.booster("rna")
map(name_and_flavor_text, booster["cards"]) |> println

