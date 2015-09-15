VERSION >= v"0.4.0-dev+6521" && __precompile__()

module Meshes

using Compat
using GeometryTypes
using Meshing

export HomogenousMesh
export Mesh
export Point3
export isosurface


typealias Mesh HomogenousMesh
typealias Point3{T} Point{3,T}

include("Files.jl")
include("slice.jl")
#include("simplification.jl")

end # module Meshes
