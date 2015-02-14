using Base.Test
using Lint
using Meshes

include("test_types.jl")
include("test_meshes.jl")
include("test_imports.jl")
include("test_slice.jl")

# run lint
println("Running Lint...")
lintpkg("Meshes")
