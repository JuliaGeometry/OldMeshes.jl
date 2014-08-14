# https://en.wikipedia.org/wiki/Wavefront_.obj_file

function importOBJ(fn::String; topology=false)
    str = open(fn,"r")
    mesh = importOBJ(str, topology=topology)
    close(str)
    return mesh
end


function importOBJ(io::IO; topology=false, vertextype=Float64, faceindextype=Int)
    vts = Vertex{vertextype}[]
    fcs = Face{faceindextype}[]
    vertexconvertfunc = vertextype == Float64 ? float64 : (vertextype == Float32 ? float32 : error("Vertex type: ", vertextype, " not supported"))
    faceconvertfunc = faceindextype == Int ? int : (
        faceindextype == Int32 ? int32 : (
            faceindextype == Uint64 ? uint64 : faceindextype == Uint32 ? uint32 : error("Faceindex type: ", faceindextype, " not supported")))

    nV = 0
    nF = 0
    while !eof(io)
        txt = readline(io)
        if !beginswith(txt, "#") && !isempty(txt) && !iscntrl(txt)
            line = split(txt)
            if line[1] == "v" #vertex
                push!(vts, Vertex{vertextype}(vertexconvertfunc(line[2]),
                                  vertexconvertfunc(line[3]),
                                  vertexconvertfunc(line[4])))
            elseif line[1] == "f" #face
                #get verts

                verts = faceindextype[faceconvertfunc(split(line[i], "/")[1]) for i = 2:length(line)]
                for i = 3:length(verts) #triangulate
                    push!(fcs, Face{faceindextype}(verts[1], verts[i-1], verts[i]))
                end
            #=    
            elseif line[1] == "vt" #UV coordinates
                push!(uvs, Vector3{vertextype}(vertexconvertfunc(line[2]),
                                  vertexconvertfunc(line[3]),
                                  vertexconvertfunc(line[4])))
            elseif line[1] == "vn" #Normals
                push!(nvs, Vector3{vertextype}(-vertexconvertfunc(line[2]),
                                  -vertexconvertfunc(line[3]),
                                  - vertexconvertfunc(line[4])))=#
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

