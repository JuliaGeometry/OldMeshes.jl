using Base.Test
using Lint

include("test_types.jl")
include("test_meshes.jl")
include("test_imports.jl")

# run lint
println("Running Lint...")
lintpkg("Meshes")
