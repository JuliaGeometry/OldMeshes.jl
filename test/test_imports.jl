
data_path = Pkg.dir("Meshes")*"/test/data/"

# STL Import
binary_stl = importBinarySTL(data_path*"cube_binary.stl")
@test length(binary_stl.vertices) == 8
@test length(binary_stl.faces) == 12
