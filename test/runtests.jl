using Base.Test
using Meshes
using ImmutableArrays

include("test_types.jl")
include("test_meshes.jl")
include("test_imports.jl")
include("test_slice.jl")

# run lint if run with --lint
if "--lint" in ARGS
    using Lint
    println("Running Lint...")
    lintpkg("Meshes")
end
