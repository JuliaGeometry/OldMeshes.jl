module Meshes

using Compat
using GeometryTypes

include("core.jl")
include("Files.jl")
include("isosurface.jl")
include("csg.jl")
include("slice.jl")
include("algorithms.jl")
#include("simplification.jl")

end # module Meshes
