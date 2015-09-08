VERSION >= v"0.4.0-dev+6521" && __precompile__()

module Meshes

using Compat
using GeometryTypes
using Meshing

export HomogenousMesh
export Mesh
export isosurface

typealias Mesh HomogenousMesh

include("slice.jl")
#include("simplification.jl")

end # module Meshes
