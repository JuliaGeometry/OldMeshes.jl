#! /usr/bin/env julia
using Benchmark
using Meshes
using DataFrames

perf_dir = Pkg.dir("Meshes")*"/perf/"
perf_data_dir = perf_dir*"data/"
data_dir = Pkg.dir("Meshes")*"/test/data/"

include("file_loads.jl")

benchmarks = [stl_load_topology,
              stl_load,
              binary_stl_load,
              binary_stl_load_topology]

benchmark_results = {}

# run benchmarks
for test in benchmarks
    push!(benchmark_results, benchmark(test, "Meshes", string(test), 10))
end

outfiles = [perf_data_dir*string(test)*".csv" for test in benchmarks]

if !ispath(perf_data_dir)
    mkpath(perf_data_dir)
end

for i = 1:length(outfiles)
    if isfile(outfiles[i])
        previous = readtable(outfiles[i])
        benchmark_results[i] = vcat(previous, benchmark_results[i])
    end
    writetable(outfiles[i], benchmark_results[i])
end
