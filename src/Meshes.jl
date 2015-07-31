module Meshes

using Compat
using GeometryTypes

# overwritten base functions
import Base.hypot


include("isosurface.jl")
export isosurface

include("csg.jl")
export volume,
       sphere,
       cylinderX,
       cylinderY,
       cylinderZ,
       box,
       coneZ

#include("slice.jl")
#include("simplification.jl")

end # module Meshes
