export exportToPly,
       importPly

function exportToPly(msh::Mesh, fn::String)
    vts = msh.vertices
    fcs = msh.faces
    nV = size(vts,1)
    nF = size(fcs,1)

    str = open(fn,"w")

    # write the header
    write(str,"ply\n")
    write(str,"format binary_little_endian 1.0\n")
    write(str,"element vertex $nV\n")
    write(str,"property float x\nproperty float y\nproperty float z\n")
    write(str,"element face $nF\n")
    write(str,"property list uchar int vertex_index\n")
    write(str,"end_header\n")

    # write the data
    for i = 1:nV
        v = vts[i]
        write(str,float32(v.e1))
        write(str,float32(v.e2))
        write(str,float32(v.e3))
    end

   for i = 1:nF
        f = fcs[i]
        write(str,uint8(3))
        write(str,int32(f.v1-1))
        write(str,int32(f.v2-1))
        write(str,int32(f.v3-1))
    end
    close(str)
end


function importPly(fn::String; topology=false)
    vts = Vertex[]
    fcs = Face[]

    str = open(fn,"r")

    nV = 0
    nF = 0
    properties = String[]

    # read the header
    line = readline(str)
    while !beginswith(line, "end_header")
        if beginswith(line, "element vertex")
            nV = int(split(line)[3])
        elseif beginswith(line, "element face")
            nF = int(split(line)[3])
        elseif beginswith(line, "property")
            push!(properties, line)
        end
        line = readline(str)
    end

    # write the data
    for i = 1:nV
        txt = readline(str)   # -0.018 0.038 0.086
        vs = [float(i) for i in split(txt)]
        push!(vts, Vertex(vs[1], vs[2], vs[3]))
    end

    for i = 1:nF
        txt = readline(str)   # 3 0 1 2
        fs = [int(i) for i in split(txt)]
        for i = 3:length(fs)-1 #handle quads, etc...
            push!(fcs, Face(fs[2]+1, fs[i]+1, fs[i+1]+1))
        end
    end
    close(str)

    if topology
        uvts = unique(vts)
        for i = 1:length(fcs)
            #repoint indices to unique vertices
            v1 = findfirst(uvts, vts[fcs[i].v1])
            v2 = findfirst(uvts, vts[fcs[i].v2])
            v3 = findfirst(uvts, vts[fcs[i].v3])
            fcs[i] = Face(v1,v2,v3)
        end
        vts = uvts
    end

    return Mesh(vts, fcs, topology)
end

