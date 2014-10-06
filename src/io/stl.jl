export exportToStl,
       importBinarySTL,
       importAsciiSTL

import Base.writemime

function exportToStl(msh::Mesh, fn::String)
  exportToStl(msh, open(fn, "w"))
end

function exportToStl(msh::Mesh, str::IO)
    vts = msh.vertices
    fcs = msh.faces
    nV = size(vts,1)
    nF = size(fcs,1)

    # write the header
    write(str,"solid vcg\n")

    # write the data
    for i = 1:nF
        f = fcs[i]
        n = [0,0,0] # TODO: properly compute normal(f)
        txt = @sprintf "  facet normal %e %e %e\n" n[1] n[2] n[3]
        write(str,txt)
        write(str,"    outer loop\n")
        v = vts[f.v1]
        txt = @sprintf "      vertex  %e %e %e\n" v[1] v[2] v[3]
        write(str,txt)

        v = vts[f.v2]
        txt = @sprintf "      vertex  %e %e %e\n" v[1] v[2] v[3]
        write(str,txt)

        v = vts[f.v3]
        txt = @sprintf "      vertex  %e %e %e\n" v[1] v[2] v[3]
        write(str,txt)

        write(str,"    endloop\n")
        write(str,"  endfacet\n")
    end

    write(str,"endsolid vcg\n")
    close(str)
end

function writemime(io::IO, ::MIME"model/stl+ascii", msh::Mesh)
  exportToSTL(msh, io)
end


function importBinarySTL(file::String; topology=false)
    fn = open(file,"r")
    mesh = importBinarySTL(fn, topology=topology)
    close(fn)
    return mesh
end

function importBinarySTL(file::IO; topology=false, read_header=false)
    #Binary STL
    #https://en.wikipedia.org/wiki/STL_%28file_format%29#Binary_STL

    binarySTLvertex(file) = Vertex(float64(read(file, Float32)),
                                   float64(read(file, Float32)),
                                   float64(read(file, Float32)))

    vts = Vertex[]
    fcs = Face[]

    if !read_header
        readbytes(file, 80) # throw out header
    end
    read(file, Uint32) # throwout triangle count

    vert_count = 0
    vert_idx = [0,0,0]
    while !eof(file)
        normal = binarySTLvertex(file)
        for i = 1:3
            vertex = binarySTLvertex(file)
            if topology
                idx = findfirst(vts, vertex)
            end
            if topology && idx != 0
                vert_idx[i] = idx
            else
                push!(vts, vertex)
                vert_count += 1
                vert_idx[i] = vert_count
            end
        end
        skip(file, 2) # throwout 16bit attribute
        push!(fcs, Face(vert_idx...))
    end

    return Mesh(vts, fcs, topology)
end

function importAsciiSTL(file::String; topology=false)
    fn = open(file,"r")
    mesh = importAsciiSTL(fn, topology=topology)
    close(fn)
    return mesh
end

function importAsciiSTL(file::IO; topology=false)
    #ASCII STL
    #https://en.wikipedia.org/wiki/STL_%28file_format%29#ASCII_STL

    vts = Vertex[]
    fcs = Face[]

    vert_count = 0
    vert_idx = [0,0,0]
    while !eof(file)
        line = split(lowercase(readline(file)))
        if line[1] == "facet"
            normal = Vertex(float64(line[3:5])...)
            readline(file) # Throw away outerloop
            for i = 1:3
                vertex = Vertex(float64(split(readline(file))[2:4])...)
                if topology
                    idx = findfirst(vts, vertex)
                end
                if topology && idx != 0
                    vert_idx[i] = idx
                else
                    push!(vts, vertex)
                    vert_count += 1
                    vert_idx[i] = vert_count
                end
            end
            readline(file) # throwout endloop
            readline(file) # throwout endfacet
            push!(fcs, Face(vert_idx...))
        end
    end

    return Mesh(vts, fcs, topology)
end
