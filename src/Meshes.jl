VERSION >= v"0.4.0-dev+6521" && __precompile__()

module Meshes

using Compat
using GeometryTypes
using Meshing
using MeshIO
using FileIO

export HomogenousMesh
export Mesh
export isosurface
export load, save #FileIO

typealias Mesh HomogenousMesh

#include("simplification.jl")

end # module Meshes
