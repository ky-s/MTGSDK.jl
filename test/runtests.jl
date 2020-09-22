include("../src/MTGSDK.jl")

using Test
import HTTP, JSON
import .MTGSDK

@testset "base: build_url" begin
    baseurl = "$(MTGSDK.ROOT)/$(MTGSDK.VERSION)"

    @testset "no options" begin
        url = MTGSDK.build_url("cards")
        @test url == "$baseurl/cards"
    end

    @testset "id" begin
        url = MTGSDK.build_url("cards", id=65535)
        @test url == "$baseurl/cards/65535"
    end

    @testset "query" begin
        url = MTGSDK.build_url("cards", query=Dict("name" => "khans", "color" => "red,black"))
        @test url == "$baseurl/cards?name=khans&color=red,black"
    end

    @testset "raw" begin
        url = MTGSDK.build_url("sets", raw="?page=2&pageSize=10")
        @test url== "$baseurl/sets?page=2&pageSize=10"
    end

    @testset "version" begin
        url = MTGSDK.build_url("cards", version="v2")
        @test url == "$(MTGSDK.ROOT)/v2/cards"
    end
end

@testset "base: generate_error" begin
    @testset "400" begin
        response = HTTP.Response(400, "")
        error = MTGSDK.generate_error(response)
        @test match( r"^400:", error.message) !== nothing
        @test error.response == response
    end

    @testset "403" begin
        error = MTGSDK.generate_error( HTTP.Response(403, "") )
        @test match( r"^403:", error.message) !== nothing
    end

    @testset "404" begin
        error = MTGSDK.generate_error( HTTP.Response(404, "") )
        @test match( r"^404:", error.message) !== nothing
    end

    @testset "500" begin
        error = MTGSDK.generate_error( HTTP.Response(500, "") )
        @test match( r"^500:", error.message) !== nothing
    end

    @testset "other status code" begin
        error = MTGSDK.generate_error( HTTP.Response(418, "I'm a tea pot.") )
        @test match( r"^418:", error.message) !== nothing
    end
end

@testset "base: parse_response" begin
    @testset "success" begin
        response = HTTP.Response(200, JSON.json( Dict("take" => "taken") ))
        @test MTGSDK.parse_response(response, r -> r["take"]) == "taken"
    end

    @testset "failure" begin
        response = HTTP.Response(400, "")
        error = MTGSDK.parse_response(response, r -> r["take"])
        @test error isa MTGSDK.ResponseError
    end
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
