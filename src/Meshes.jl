module Meshes

using Compat
using ImmutableArrays
using GeometryTypes
using FixedPointNumbers
using ColorTypes

import Base.merge
import Base.convert
import Base.getindex
import Base.show

using MeshIO

include("core.jl")
include("Files.jl")

include("primitives.jl")
include("merge.jl")

include("isosurface.jl")
include("csg.jl")
include("slice.jl")
include("algorithms.jl")
#include("simplification.jl")

end # module Meshes
