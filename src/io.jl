include("io/2dm.jl")
include("io/off.jl")
include("io/ply.jl")
include("io/stl.jl")
include("io/obj.jl")

export mesh

function mesh(path::String; format=:autodetect, topology=false)
    io = open(path, "r")
    fmt = format
    msh = nothing
    if fmt == :autodetect
        if endswith(path, ".stl")
            header = ascii(readbytes(io, 5))
            if lowercase(header) == "solid"
                fmt = :asciistl
            else
                readbytes(io, 75) # throw out header
                fmt = :binarystl
            end
        elseif endswith(path, ".ply")
            fmt = :ply
        elseif endswith(path, ".2dm")
            fmt = :(2dm)
        elseif endswith(path, ".obj")
            fmt = :obj
        else
            error("Could not identify mesh format")
        end
    end
    if fmt == :binarystl
        msh = importBinarySTL(io, topology=topology, read_header=true)
    elseif fmt == :asciistl
        msh = importAsciiSTL(io, topology=topology)
    elseif fmt == :ply
        msh = importPly(io, topology=topology)
    elseif fmt == :(2dm)
        msh = import2dm(io)
    elseif fmt == :obj
        msh = importOBJ(io)
    else
        error("Could not identify mesh format")
    end
    close(io)
    return msh
end
