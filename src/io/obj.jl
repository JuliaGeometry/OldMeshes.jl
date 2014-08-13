# https://en.wikipedia.org/wiki/Wavefront_.obj_file

function importOBJ(fn::String; topology=false)
    str = open(fn,"r")
    mesh = importOBJ(str, topology=topology)
    close(str)
    return mesh
end


function importOBJ(io::IO; topology=false)
    vts = Vertex[]
    fcs = Face[]

    nV = 0
    nF = 0

    while !eof(io)
        txt = readline(io)
        line = split(txt)
        if line[1] == "v" #vertex
            push!(vts, Vertex(float64(line[2]),
                              float64(line[3]),
                              float64(line[4])))
        elseif line[1] == "f" #face
            #get verts
            verts = [int(split(line[i], "/")[1]) for i = 2:length(line)]
            for i = 3:length(verts) #triangulate
                push!(fcs, Face(verts[1], verts[i-1], verts[i]))
            end
        end
    end

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

