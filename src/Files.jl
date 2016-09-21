VERSION >= v"0.4.0-dev+6521" && __precompile__()

module Files

using Meshes
using Compat
using LightXML
using ZipFile

include("files/2dm.jl")
include("files/amf.jl")
include("files/obj.jl")
include("files/off.jl")
include("files/ply.jl")
include("files/stl.jl")
include("files/threejs.jl")

export mesh

function mesh(path::String; format=:autodetect)
    io = open(path, "r")
    fmt = format
    local msh
    lcase_path = lowercase(path)
    if fmt == :autodetect
        if endswith(lcase_path, ".stl")
            if detect_stlascii(io)
                fmt = :asciistl
            else
                fmt = :binarystl
            end
        elseif endswith(lcase_path, ".ply")
            header1 = ascii(readline(io))  # ply
            header2 = ascii(readline(io))  # format ascii 1.0
            if contains(lowercase(header2), "format ascii")
                fmt = :asciiply
            else
                fmt = :binaryply
            end
        elseif endswith(lcase_path, ".2dm")
            fmt = :(2dm)
        elseif endswith(lcase_path, ".obj")
            fmt = :obj
        elseif endswith(lcase_path, ".amf")
            fmt = :amf
        elseif endswith(lcase_path, ".off")
            fmt = :off
        elseif endswith(lcase_path, ".js")
            fmt = :threejs
        else
            error("Could not identify mesh format")
        end
    end
    if fmt == :binarystl
        msh = importBinarySTL(io)
    elseif fmt == :asciistl
        msh = importAsciiSTL(io)
    elseif fmt == :asciiply
        msh = importAsciiPly(io)
    elseif fmt == :binaryply
        error("Reading binary .ply files not yet implemented")
    elseif fmt == :(2dm)
        msh = import2dm(io)
    elseif fmt == :obj
        msh = importOBJ(io)
    elseif fmt == :amf
        # check if zipped
        header = read(io,4)
        close(io)
        if header == [0x50,0x4b,0x03,0x04]
            contents = ZipFile.Reader(path)
            io = contents.files[1] # TODO: analyize contents
        else # uncompressed
            io = open(path, "r")
        end
        msh = importAMF(io)
    elseif fmt == :off
        msh = importOFF(io)
    elseif fmt == :threejs
        msh = importThreejs(io)
    else
        error("Could not identify mesh format")
    end
    close(io)
    return msh
end

function detect_stlascii(io)
    position(io) != 0 && return false
    seekend(io)
    len = position(io)
    seekstart(io)
    len < 80 && return false
    header = read(io, 80) # skip header
    seekstart(io)
    return header[1:6] == b"solid " && !detect_stlbinary(io)
end

function detect_stlbinary(io)
    size_header = 80+sizeof(UInt32)
    size_triangleblock = (4*3*sizeof(Float32)) + sizeof(UInt16)

    position(io) != 0 && return false

    try
        seekend(io)
        len = position(io)
        seekstart(io)
        len < size_header && return false

        skip(io, 80) # skip header
        number_of_triangle_blocks = read(io, UInt32)
         #1 normal, 3 vertices in Float32 + attrib count, usually 0
        len != (number_of_triangle_blocks*size_triangleblock)+size_header && return false
        skip(io, number_of_triangle_blocks*size_triangleblock-sizeof(UInt16))
        attrib_byte_count = read(io, UInt16) # read last attrib_byte
        attrib_byte_count != zero(UInt16) && return false # should be zero as not used
        eof(io) && return true
        false
    finally
        seekstart(io)
    end
end

end #module
