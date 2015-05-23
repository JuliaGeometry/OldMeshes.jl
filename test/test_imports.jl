
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

off1 = mesh(data_path*"cube.off") # quads
@test length(off1.vertices) == 8
@test length(off1.faces) == 12

# Test isempty
@test !isempty(off1)

# STL export import test.
io = IOBuffer()
exportBinaryStl(binary_stl1, io, false)
seekstart(io)
binary_stl1_rewritten = Meshes.importBinarySTL(io)
for i=1:length(binary_stl1_rewritten.vertices)
    binary_stl1_rewritten.vertices[i]==binary_stl1.vertices[i]
end
for i=1:length(binary_stl1_rewritten.faces)
    binary_stl1_rewritten.faces[i]==binary_stl1.faces[i]
end
