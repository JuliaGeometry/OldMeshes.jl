VERSION >= v"0.4.0-dev+6521" && __precompile__()

module Meshes

using Compat
using GeometryTypes

export Mesh
export Face3
export Point3

typealias Mesh HomogenousMesh
typealias Point3{T} Point{3,T}
typealias Face3{T,S} Face{3,T,S}

include("Files.jl")
include("isosurface.jl")
include("csg.jl")
include("slice.jl")
#include("simplification.jl")

end # module Meshes
