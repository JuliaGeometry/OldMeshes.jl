export exportToPly,
       importPly,
       exportToOFF,
       exportToStl,
       import2dm,
       exportTo2dm,
       importBinarySTL

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


function importPly(fn::String)
    vts = Vertex[]
    fcs = Face[]

    str = open(fn,"r")

    # read the header
    txt0 = readline(str)   # ply
    txt1 = readline(str)   # format ascii 1.0
    txt2 = readline(str)   # element vertex 352
    txt3 = readline(str)   # property float32 x
    txt4 = readline(str)   # property float32 y
    txt5 = readline(str)   # property float32 z

    txt3 = readline(str)   # property float32 nx
    txt4 = readline(str)   # property float32 ny
    txt5 = readline(str)   # property float32 nz

    txt6 = readline(str)   # element face 671
    txt7 = readline(str)   # property list uint8 int32 vertex_indices
    txt8 = readline(str)   # end_header

    nV = int(split(txt2)[3])
    nF = int(split(txt6)[3])

    # write the data
    for i = 1:nV
        txt = readline(str)   # -0.018 0.038 0.086
        vs = [float(i) for i in split(txt)]
        push!(vts, Vertex(vs[1], vs[2], vs[3]))
    end

    for i = 1:nF
        txt = readline(str)   # 3 0 1 2
        fs = [int(i) for i in split(txt)]
        if fs[1]!=3
            println("Error, cannot read more than three vertex faces")
            return nothing
        end
        push!(fcs, Face(fs[2]+1, fs[3]+1, fs[4]+1))
    end
    close(str)

    return Mesh(vts, fcs)
end


function exportToStl(msh::Mesh, fn::String)
    vts = msh.vertices
    fcs = msh.faces
    nV = size(vts,1)
    nF = size(fcs,1)

    str = open(fn,"w")

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


function importBinarySTL(fn::String)
    #Binary STL
    #https://en.wikipedia.org/wiki/STL_%28file_format%29#Binary_STL

    binarySTLvertex(file) = Vertex(read(file, Float32),
                                   read(file, Float32),
                                   read(file, Float32))

    vts = Vertex[]
    fcs = Face[]

    file = open(fn,"r")

    readbytes(file, 80) # throw out header
    read(file, Uint32) # throwout triangle count

    vert_count = 0
    vert_idx = [0,0,0]
    while !eof(file)
        normal = binarySTLvertex(file)
        for i = 1:3
            vertex = binarySTLvertex(file)
            idx = findfirst(vts, vertex)
            if idx != 0
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

    close(file)

    return Mesh(vts, fcs)
end


function exportToOFF(msh::Mesh, fn::String, rgba)
    # writes an OFF geometry file, with colors
    #  see http://people.sc.fsu.edu/~jburkardt/data/off/off.html
    #  for format description
    vts = msh.vertices
    fcs = msh.faces
    nV = size(vts,1)
    nF = size(fcs,1)
    nE = nF*3

    str = open(fn,"w")

    # write the header
    write(str,"OFF\n")
    write(str,"$nV $nF $nE\n")

    # write the data
    for i = 1:nV
        v = vts[i]
        txt = @sprintf " %f %f %f\n" float32(v.e1) float32(v.e2) float32(v.e3)
        write(str,txt)
    end

    for i = 1:nF
        f = fcs[i]
        c = rgba[i,:]
        txt = @sprintf "  3 %i %i %i  %f %f %f %f\n" int32(f.v1-1) int32(f.v2-1) int32(f.v3-1)  float32(c[1]) float32(c[2]) float32(c[3]) float32(c[4])
        write(str,txt)
    end
    close(str)
end


# | Read a .2dm (SMS Aquaveo) mesh-file and construct a @Mesh@
function import2dm(file::String)
    parseNode(w::Array{String}) = Vertex(float64(w[3]), float64(w[4]), float64(w[5]))
    parseTriangle(w::Array{String}) = Face(int64(w[3]), int64(w[4]), int64(w[5]))
    # Qudrilateral faces are split up into triangles
    function parseQuad(w::Array{String})
        w[7] = w[3]                     # making a circle
        Face[Face(int64(w[i]), int64(w[i+1]), int64(w[i+2])) for i = [3,5]]
    end 
    con = open(file, "r")
    nd =  Array(Vertex, 0)
    ele = Array(Face,0)
    for line = readlines(con)
        line = chomp(line)
        w = split(line)
        if w[1] == "ND"
            push!(nd, parseNode(w))
        elseif w[1] == "E3T"
            push!(ele,parseTriangle(w))
        elseif w[1] == "E4Q"
            append!(ele, parseQuad(w))
        else
            continue
        end
    end
    close(con)
    Mesh(nd,ele)
end


# | Write @Mesh@ to an IOStream
function exportTo2dm(con::IO,m::Mesh)
    function renderVertex(i::Int,v::Vertex)
        "ND $i $(v.e1) $(v.e2) $(v.e3)\n"
    end
    function renderFace(i::Int, f::Face)
        "E3T $i $(f.v1) $(f.v2) $(f.v3) 0\n"
    end
    write(con, "MESH2D\n")
    for i = 1:length(m.faces)
        write(con, renderFace(i, m.faces[i]))
    end
    for i = 1:length(m.vertices)
        write(con, renderVertex(i, m.vertices[i]))
    end
    nothing
end

# | Write a @Mesh@ to file in SMS-.2dm-file-format
function exportTo2dm(f::String,m::Mesh)
    con = open(f, "w")
    exportTo2dm(con, m)
    close(con)
    nothing
end
