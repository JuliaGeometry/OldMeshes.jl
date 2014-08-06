
data_path = Pkg.dir("Meshes")*"/test/data/"

# STL Import
binary_stl1 = importBinarySTL(data_path*"cube_binary.stl", topology=true)
@test length(binary_stl1.vertices) == 8
@test length(binary_stl1.faces) == 12

binary_stl1 = importBinarySTL(data_path*"cube_binary.stl", topology=false)
@test length(binary_stl1.vertices) == 36
@test length(binary_stl1.faces) == 12
