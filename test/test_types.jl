data_path = Pkg.dir("Meshes")*"/test/data/"

f1 = Face([1,2,3])
f2 = Face(1,2,3)
@test f1.v1 == f2.v1
@test f1.v2 == f2.v2
@test f1.v3 == f2.v3

let
    m = mesh(data_path*"cube.stl")
    c1 = convert(Mesh{Vector3{Int}, Face{Int}}, m)
    c2 = convert(Mesh{Vector3{Int}, Face{Int}}, m, 1000)
    @test length(m.faces) == length(c1.faces) == length(c2.faces)
    for i = 1:length(m.faces)
        @test m.faces[i] == c1.faces[i] == c2.faces[i]
    end
    for i = 1:length(m.vertices)
        @test m.vertices[i] == c1.vertices[i] == c2.vertices[i]/1000
    end
end
