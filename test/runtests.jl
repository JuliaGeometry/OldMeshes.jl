using Base.Test
using Meshes
using FileIO
using GeometryTypes

include("test_slice.jl")

# run lint if run with --lint
if "--lint" in ARGS
    using Lint
    println("Running Lint...")
    lintpkg("Meshes")
end
