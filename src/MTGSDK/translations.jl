using Pipe

export translaete_to, translate_to_japanese

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
