module Meshes

using Compat
using GeometryTypes
using FixedPointNumbers
using ColorTypes # silly dependency for just one color value, but it doesn't matter as we need Geometry types anyways
# GeometryTypes and ColorTypes both use FixedSizeArrays for the types, so loading ColorTypes should be really fast, 
# when GeometryTypes is already present.

using LightXML
using ZipFile

import Base.merge
import Base.convert
import Base.getindex
import Base.show

using MeshIO
importall MeshIO

include("primitives.jl")
include("merge.jl")
include("algorithms.jl")

#include("io.jl")
include("isosurface.jl")
export isosurface


include("csg.jl")
#include("slice.jl")
#include("simplification.jl")

end # module Meshes
