module Meshes

using Compat
using ImmutableArrays
using LightXML
using ZipFile

include("core.jl")
include("io.jl")
include("isosurface.jl")
include("csg.jl")
include("slice.jl")
include("algorithms.jl")
#include("simplification.jl")

end # module Meshes
