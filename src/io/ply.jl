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

