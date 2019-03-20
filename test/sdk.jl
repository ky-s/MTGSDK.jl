include("../src/MTGSDK.jl")

using Test
using HTTP
using JSON
using .MTGSDK

@testset "_build_url" begin
    @test MTGSDK._build_url("cards") == "$(MTGSDK.ROOT)/$(MTGSDK.VERSION)/cards"
    @test MTGSDK._build_url("cards", id=65535) == "$(MTGSDK.ROOT)/$(MTGSDK.VERSION)/cards/65535"
    @test MTGSDK._build_url("cards", query=Dict("name" => "khans", "color" => "red,black")) == "$(MTGSDK.ROOT)/$(MTGSDK.VERSION)/cards?name=khans&color=red,black"
    @test MTGSDK._build_url("sets", raw="?page=2&pageSize=10") == "$(MTGSDK.ROOT)/$(MTGSDK.VERSION)/sets?page=2&pageSize=10"
    @test MTGSDK._build_url("cards", version="v2") == "$(MTGSDK.ROOT)/v2/cards"
end

@testset "request status:ok" begin
    HTTP.get(url) = HTTP.Response(JSON.json(Dict("url" => url))) # mock

    resp = MTGSDK.request("cards")
    @test resp.status == 200
    @test JSON.parse(String(resp.body)) == Dict("url" => "$(MTGSDK.ROOT)/$(MTGSDK.VERSION)/cards")
end

@testset "request status:not found" begin
    error = Dict("error" => "Error: Not Found")
    HTTP.get(url) = HTTP.Response(404, JSON.json(error)) # mock

    resp = MTGSDK.request("nothing")
    @test resp.status == 404
    @test JSON.parse(String(resp.body)) == error
end

@testset "cards" begin
    cards = Dict("cards" => [Dict("name" => "Black Lotus"), Dict("name" => "Mox Ruby")])
    HTTP.get(url) = HTTP.Response(JSON.json(cards)) # mock

    resp = MTGSDK.cards()
    @test resp.status == 200
    @test JSON.parse(String(resp.body)) == cards
end

@testset "cards(id)" begin
    HTTP.get(url) = HTTP.Response(JSON.json(Dict("url" => url))) # mock

    resp = MTGSDK.cards(1234)
    @test resp.status == 200
    @test JSON.parse(String(resp.body)) == Dict("url" => "$(MTGSDK.ROOT)/$(MTGSDK.VERSION)/cards/1234")

    resp = MTGSDK.cards(id=5678)
    @test resp.status == 200
    @test JSON.parse(String(resp.body)) == Dict("url" => "$(MTGSDK.ROOT)/$(MTGSDK.VERSION)/cards/5678")
end

@testset "cards(query)" begin
    HTTP.get(url) = HTTP.Response(JSON.json(Dict("url" => url))) # mock

    resp = MTGSDK.cards(query=Dict("name" => "khans", "color" => "red,black"))
    @test resp.status == 200
    # TODO: もしかしたら Dict の順番は保証されないかも。そうすると URL 中の name と color の順番は入れ替わるかもしれない。
    @test JSON.parse(String(resp.body)) == Dict("url" => "$(MTGSDK.ROOT)/$(MTGSDK.VERSION)/cards?name=khans&color=red,black")
end

@testset "sets" begin
    HTTP.get(url) = HTTP.Response(JSON.json(Dict("url" => url))) # mock

    resp = MTGSDK.sets()
    @test resp.status == 200
    @test JSON.parse(String(resp.body)) == Dict("url" => "$(MTGSDK.ROOT)/$(MTGSDK.VERSION)/sets")
end

@testset "sets(set)" begin
    HTTP.get(url) = HTTP.Response(JSON.json(Dict("url" => url))) # mock

    resp = MTGSDK.sets("rna")
    @test resp.status == 200
    @test JSON.parse(String(resp.body)) == Dict("url" => "$(MTGSDK.ROOT)/$(MTGSDK.VERSION)/sets/rna")
end

@testset "sets(query)" begin
    HTTP.get(url) = HTTP.Response(JSON.json(Dict("url" => url))) # mock

    resp = MTGSDK.sets(query=Dict("page" => "2", "pageSize" => "10"))
    @test resp.status == 200
    @test JSON.parse(String(resp.body)) == Dict("url" => "$(MTGSDK.ROOT)/$(MTGSDK.VERSION)/sets?pageSize=10&page=2")
end

@testset "other resouces" begin
    HTTP.get(url) = HTTP.Response(JSON.json(Dict("url" => url))) # mock

    resp = MTGSDK.types()
    @test resp.status == 200
    @test JSON.parse(String(resp.body)) == Dict("url" => "$(MTGSDK.ROOT)/$(MTGSDK.VERSION)/types")

    resp = MTGSDK.subtypes()
    @test resp.status == 200
    @test JSON.parse(String(resp.body)) == Dict("url" => "$(MTGSDK.ROOT)/$(MTGSDK.VERSION)/subtypes")

    resp = MTGSDK.supertypes()
    @test resp.status == 200
    @test JSON.parse(String(resp.body)) == Dict("url" => "$(MTGSDK.ROOT)/$(MTGSDK.VERSION)/supertypes")

    resp = MTGSDK.formats()
    @test resp.status == 200
    @test JSON.parse(String(resp.body)) == Dict("url" => "$(MTGSDK.ROOT)/$(MTGSDK.VERSION)/formats")

    resp = MTGSDK.booster("rna")
    @test resp.status == 200
    @test JSON.parse(String(resp.body)) == Dict("url" => "$(MTGSDK.ROOT)/$(MTGSDK.VERSION)/sets/rna/booster")
end
