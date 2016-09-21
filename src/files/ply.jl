export exportBinaryPly,
       exportAsciiPly,
       importAsciiPly

function exportBinaryPly(msh::Mesh, fn::String)
    vts = msh.vertices
    fcs = msh.faces
    nV = size(vts,1)
    nF = size(fcs,1)

    io = open(fn,"w")

    # write the header
    write(io, "ply\n")
    write(io, "format binary_little_endian 1.0\n")
    write(io, "element vertex $nV\n")
    write(io, "property float x\nproperty float y\nproperty float z\n")
    write(io, "element face $nF\n")
    write(io, "property list uchar int vertex_index\n")
    write(io, "end_header\n")

    # write the vertices and faces
    for v in vts
        write(io, @compat Float32(v.e1))
        write(io, @compat Float32(v.e2))
        write(io, @compat Float32(v.e3))
    end

    for f in fcs
        write(io, @compat Uint8(3))
        write(io, @compat Int32(f.v1-1))
        write(io, @compat Int32(f.v2-1))
        write(io, @compat Int32(f.v3-1))
    end

    close(io)
end


function exportAsciiPly(msh::Mesh, fn::String)
    vts = msh.vertices
    fcs = msh.faces
    nV = size(vts,1)
    nF = size(fcs,1)

    io = open(fn, "w")

    # write the header
    write(io, "ply\n")
    write(io, "format ascii 1.0\n")
    write(io, "element vertex $nV\n")
    write(io, "property float x\nproperty float y\nproperty float z\n")
    write(io, "element face $nF\n")
    write(io, "property list uchar int vertex_index\n")
    write(io, "end_header\n")

    # write the vertices and faces
    for v in vts
        print(io, "$(v.e1) $(v.e2) $(v.e3)\n")
    end

    for f in fcs
        print(io, "3 $(f.v1-1) $(f.v2-1) $(f.v3-1)\n")
    end

    close(io)
end


function importAsciiPly(fn::String)
    io = open(fn, "r")
    mesh = importAsciiPly(io)
    close(io)
    return mesh
end


function importAsciiPly(io::IO)
    vts = Vertex[]
    fcs = Face{Int}[]

    nV = 0
    nF = 0
    properties = String[]

    # read the header
    line = readline(io)
    while !startswith(line, "end_header")
        if startswith(line, "element vertex")
            nV = parse(Int, split(line)[3])
        elseif startswith(line, "element face")
            nF = parse(Int, split(line)[3])
        elseif startswith(line, "property")
            push!(properties, line)
        end
        line = readline(io)
    end

    # write the data
    for i = 1:nV
        txt = readline(io)   # -0.018 0.038 0.086
        vs = [parse(Float64, i) for i in split(txt)]
        push!(vts, Vertex(vs[1], vs[2], vs[3]))
    end

    for i = 1:nF
        txt = readline(io)   # 3 0 1 2
        fs = [parse(Int, i) for i in split(txt)]
        for i = 3:fs[1] #triangulate
            push!(fcs, Face{Int}(fs[2]+1, fs[i]+1, fs[i+1]+1))
        end
    end

    return Mesh{Vertex, Face{Int}}(vts, fcs)
end

