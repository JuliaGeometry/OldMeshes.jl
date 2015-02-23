using Meshes
using Base.Test

data_path = Pkg.dir("Meshes")*"/test/data/"

cube = mesh(data_path*"cube_binary.stl", topology=true)
o = IOBuffer()
exportStl(cube, "foo.stl")
expected = """Paths([
    Path([(58,58), (-8,58), (-8,-8), (58,-8)]),
    Path([(18,2), (2,2), (2,10), (18,10)])
)"""
@show ASCIIString(o.data)
@test ASCIIString(o.data) == expected
