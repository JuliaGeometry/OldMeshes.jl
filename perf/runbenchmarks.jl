#! /usr/bin/env julia
using Benchmark
using Meshes
using DataFrames

perf_fir = Pkg.dir("Meshes")*"/perf/"
data_dir = Pkg.dir("Meshes")*"/test/data/"

function stl_load_topology()
    mesh = importSTL(data_dir*"cube.stl", topology=true);
end

function stl_load()
    mesh = importSTL(data_dir*"cube.stl", topology=false);
end

function binary_stl_load()
    mesh = importSTL(data_dir*"cube_binary.stl");
end


loads = [stl_load_topology,stl_load,binary_stl_load]

out = benchmark(slice1, "STL Load", "cell lamp", 10)

if isfile(outfile)
    previous = readtable(outfile)
    out = vcat(previous, out)
end
writetable(outfile, out)

