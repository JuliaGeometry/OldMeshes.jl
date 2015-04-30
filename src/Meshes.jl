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


include("core.jl")
export facetype
export attributes
export Mesh
export HomogenousMesh
export HMesh
export NormalMesh
export UVWMesh
export UVMesh2D
export UVMesh
export PlainMesh
export Mesh2D
export NormalAttributeMesh
export NormalColorMesh

export GLMesh2D
export GLNormalMesh
export GLUVWMesh
export GLUVMesh2D
export GLUVMesh
export GLPlainMesh
export GLNormalAttributeMesh
export GLNormalColorMesh

include("primitives.jl")
include("merge.jl")
include("algorithms.jl")

include("io.jl")
include("isosurface.jl")
export isosurface
include("csg.jl")
#include("slice.jl")
#include("simplification.jl")

end # module Meshes
