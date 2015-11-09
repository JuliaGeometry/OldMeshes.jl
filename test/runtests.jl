using Base.Test
using Meshes

# run lint if run with --lint
if "--lint" in ARGS
    using Lint
    println("Running Lint...")
    lintpkg("Meshes")
end
