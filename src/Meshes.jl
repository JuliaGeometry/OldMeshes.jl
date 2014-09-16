module Meshes

using Compat
using ImmutableArrays
using Polygons
using Lines
using LightXML
using ZipFile

include("core.jl")
include("io.jl")
include("isosurface.jl")
include("csg.jl")
#include("simplification.jl")

end # module Meshes
