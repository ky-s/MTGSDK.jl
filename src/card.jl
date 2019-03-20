foreignCard(card::Dict; lang="Japanese") =
    filter(foreign -> foreign["language"] == lang, card["foreignNames"])

function name_and_flavor_text(card::Dict)
    foreignnames = card["foreignNames"]
    foreign = filter(foreign -> foreign["language"] == "Japanese", foreignnames)
    foreign === nothing && return nothing
    ja = foreign[1]
    ja["name"], ja["flavor"]
end
