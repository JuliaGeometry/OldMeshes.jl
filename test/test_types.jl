data_path = Pkg.dir("Meshes")*"/test/data/"

let
    m = mesh(data_path*"cube.stl")
    c1 = convert(Mesh{Point3{Int}, Face3{Int,0}}, m)
    c2 = convert(Mesh{Point3{Int}, Face3{Int,0}}, m, 1000)
    @test length(m.faces) == length(c1.faces) == length(c2.faces)
    for i = 1:length(m.faces)
        @test m.faces[i] == c1.faces[i] == c2.faces[i]
    end
    for i = 1:length(m.vertices)
        @test m.vertices[i] == c1.vertices[i] == c2.vertices[i]/1000
    end
end
