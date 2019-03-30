include("../src/MTGSDK.jl")

using Test
using HTTP
using JSON
using .MTGSDK

@testset "_build_url" begin
    baseurl = "$(MTGSDK.ROOT)/$(MTGSDK.VERSION)"
    @test MTGSDK._build_url("cards") == "$baseurl/cards"
    @test MTGSDK._build_url("cards", id=65535) == "$baseurl/cards/65535"
    @test MTGSDK._build_url("cards", query=Dict("name" => "khans", "color" => "red,black")) == "$baseurl/cards?name=khans&color=red,black"
    @test MTGSDK._build_url("sets", raw="?page=2&pageSize=10") == "$baseurl/sets?page=2&pageSize=10"
    @test MTGSDK._build_url("cards", version="v2") == "$(MTGSDK.ROOT)/v2/cards"
end

@testset "_parse" begin
    @test MTGSDK._parse(HTTP.Response(200, JSON.json(Dict("take" => "taken"))), (r) -> r["take"]) == "taken"
    @test match(r"^400:", MTGSDK._parse(HTTP.Response(400, ""), +)) !== nothing
    @test match(r"^403:", MTGSDK._parse(HTTP.Response(403, ""), +)) !== nothing
    @test match(r"^404:", MTGSDK._parse(HTTP.Response(404, ""), +)) !== nothing
    @test match(r"^500:", MTGSDK._parse(HTTP.Response(500, ""), +)) !== nothing
    @test match(r"^503:", MTGSDK._parse(HTTP.Response(503, ""), +)) !== nothing
    @test match(r"^418:", MTGSDK._parse(HTTP.Response(418, "I'm a tea pot."), +)) !== nothing
end

@testset "cards" begin
    cards = Dict("cards" => [Dict("name" => "Black Lotus"), Dict("name" => "Mox Ruby")])
    HTTP.get(url) = HTTP.Response(JSON.json(cards)) # mock
    @test MTGSDK.cards() == cards["cards"]
    @test MTGSDK.cards(query=Dict("name" => "khans", "color" => "red,black")) == cards["cards"]

    card = Dict("card" => Dict("name" => "Black Lotus"))
    HTTP.get(url) = HTTP.Response(JSON.json(card)) # mock
    @test MTGSDK.cards(1234) == card["card"]
    @test MTGSDK.cards(id=1234) == card["card"]
end

@testset "sets" begin
    sets = Dict("sets" => [Dict("name" => "Alpha"), Dict("name" => "Beta")])
    HTTP.get(url) = HTTP.Response(JSON.json(sets)) # mock

    @test MTGSDK.sets() == sets["sets"]
    @test MTGSDK.sets(query=Dict("page" => "2", "pageSize" => "10")) == sets["sets"]

    set = Dict("set" => Dict("name" => "Alpha"))
    HTTP.get(url) = HTTP.Response(JSON.json(set)) # mock
    @test MTGSDK.sets("rna") == set["set"]
end

@testset "booster" begin
    cards = Dict("cards" => [Dict("name" => "Black Lotus"), Dict("name" => "Mox Ruby")]) # mock
    HTTP.get(url) = HTTP.Response(JSON.json(cards))

    @test MTGSDK.booster("ktk") == cards["cards"]
end

@testset "other resouces" begin
    HTTP.get(url) = HTTP.Response(JSON.json( reduce(merge, map(r->Dict(r=>r),("types", "subtypes", "supertypes", "formats"))) )) # mock

    @test MTGSDK.types()      == "types"
    @test MTGSDK.subtypes()   == "subtypes"
    @test MTGSDK.supertypes() == "supertypes"
    @test MTGSDK.formats()    == "formats"
end

@testset "translate_to" begin
     card1 = Dict("name" => "OriginalName1", "flavor" => "OriginalFlavor1",
          "foreignNames" => [
                             Dict("language" => "Japanese", "name" => "日本語名1",    "flavor" => "日本語フレイバーテキスト1"   ),
                             Dict("language" => "English",  "name" => "EnglishName1", "flavor" => "English Flavor Text1"        ),
                            ]
         )
     card2 = Dict("name" => "OriginalName2", "flavor" => "OriginalFlavor2",
          "foreignNames" => [
                             Dict("language" => "Japanese", "name" => "日本語名2",    "flavor" => "日本語フレイバーテキスト2"   ),
                             Dict("language" => "English",  "name" => "EnglishName2", "flavor" => "English Flavor Text2"        ),
                            ]
         )
    cards = [ card1, card2 ]

    @test MTGSDK.translate_to("English",  card1)["name"] == card1["foreignNames"][2]["name"]
    @test MTGSDK.translate_to("Japanese", card1)["name"] == MTGSDK.translate_to_japanese(card1)["name"] == card1["foreignNames"][1]["name"]
end
