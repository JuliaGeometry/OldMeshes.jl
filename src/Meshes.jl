VERSION >= v"0.4.0-dev+6521" && __precompile__()

module Meshes

using Compat
using ImmutableArrays

include("core.jl")
include("Files.jl")
include("isosurface.jl")
include("csg.jl")
include("slice.jl")
include("algorithms.jl")
#include("simplification.jl")

end # module Meshes
