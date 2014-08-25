
data_path = Pkg.dir("Meshes")*"/test/data/"

# STL Import
binary_stl1 = mesh(data_path*"cube_binary.stl", topology=true)
@test length(binary_stl1.vertices) == 8
@test length(binary_stl1.faces) == 12
@test binary_stl1.has_topology

binary_stl1 = mesh(data_path*"cube_binary.stl", topology=false)
@test length(binary_stl1.vertices) == 36
@test length(binary_stl1.faces) == 12
@test !binary_stl1.has_topology

ascii_stl1 = mesh(data_path*"cube.stl", topology=true)
@test length(ascii_stl1.vertices) == 8
@test length(ascii_stl1.faces) == 12
@test ascii_stl1.has_topology

ascii_stl1 = mesh(data_path*"cube.stl", topology=false)
@test length(ascii_stl1.vertices) == 36
@test length(ascii_stl1.faces) == 12
@test !ascii_stl1.has_topology

ply1 = mesh(data_path*"cube.ply") # quads
@test length(ply1.vertices) == 24
@test length(ply1.faces) == 12

ply1 = mesh(data_path*"cube.ply", topology=true) # quads
@test length(ply1.vertices) == 8
@test length(ply1.faces) == 12

obj1 = mesh(data_path*"cube.obj") # quads
@test length(obj1.vertices) == 8
@test length(obj1.faces) == 12

amf1 = mesh(data_path*"pyramid.amf")
@test length(amf1[1].vertices) == 5
@test length(amf1[1].faces) == 4
@test length(amf1[2].vertices) == 5
@test length(amf1[2].faces) == 4

amf1 = mesh(data_path*"pyramid_zip.amf")
@test length(amf1[1].vertices) == 5
@test length(amf1[1].faces) == 4
@test length(amf1[2].vertices) == 5
@test length(amf1[2].faces) == 4
