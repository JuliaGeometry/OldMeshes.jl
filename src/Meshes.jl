module Meshes

using Compat
using ImmutableArrays
using Polygons
using Lines
using LightXML
using ZipFile

import Base: slice

include("core.jl")
include("io.jl")
include("isosurface.jl")
include("csg.jl")
include("slice.jl")
#include("simplification.jl")

end # module Meshes
