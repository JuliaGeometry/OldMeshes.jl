module Meshes

include("MarchingTetrahedra.jl")
using MarchingTetrahedra

export Mesh, merge, isosurface, read2dm, exportToPly, exportTo2dm


type Mesh
    vertices :: Vector{(Float64,Float64,Float64)}
    faces :: Vector{(Int64,Int64,Int64)}
end

# concatenates two meshes
function merge(m1::Mesh, m2::Mesh)
    v1 = copy(m1.vertices)
    f1 = copy(m1.faces)
    nV = size(v1,1)
    f2 = m2.faces
    nF = size(f2,1)
    newF2 = [ (f2[i][1]+nV, f2[i][2]+nV, f2[i][3]+nV) for i = 1:nF ]
    Mesh(append!(v1,m2.vertices),append!(f1,newF2))
end

function isosurface(lsf,isoval)
    # get marching tetrahedra version of the mesh
    (vts,fcs) = marchingTetrahedra(lsf,isoval)

    # normalize the mesh representation
    prs = collect(vts)
    nV = size(prs,1)
    vtD = Dict{Int64,Int64}()
    for k = 1:nV
        vtD[prs[k][1]] = k
    end
    newFace(f) = (vtD[f[1]],vtD[f[2]],vtD[f[3]])
    nF = size(fcs,1)
    fcAry = [ (vtD[fcs[i][1]],vtD[fcs[i][2]],vtD[fcs[i][3]]) for i = 1:nF ]
    vtAry = (Float64,Float64,Float64)[prs[i][2] for i = 1:nV]

    Mesh(vtAry,fcAry)
end

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
        (x,y,z) = vts[i]
        write(str,float32(x))
        write(str,float32(y))
        write(str,float32(z))
    end

   for i = 1:nF
        (v1,v2,v3) = fcs[i]
        write(str,uint8(3))
        write(str,int32(v1-1))
        write(str,int32(v2-1))
        write(str,int32(v3-1))
    end
    close(str)
end

# | Read a .2dm (SMS Aquaveo) mesh-file and construct a @Mesh@
function read2dm(file::String)
    parseNode(w::Array{String}) = (float64(w[3]), float64(w[4]), float64(w[5]))
    parseTriangle(w::Array{String}) = (int64(w[3]), int64(w[4]), int64(w[5]))
    # Qudrilateral faces are split up into triangles
    function parseQuad(w::Array{String})
        w[7] = w[3]                     # making a circle
        (Int64,Int64,Int64)[(int64(w[i]), int64(w[i+1]), int64(w[i+2])) for i = [3,5]]
    end 
    con = open(file, "r")
    nd =  Array((Float64,Float64,Float64), 0)
    ele = Array((Int64,Int64,Int64),0)
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
function exportTo2dm(f::IO,m::Mesh)
    function renderVertex(i::Int,v::(Float64, Float64, Float64))
        (x,y,z) = v 
        "ND $i $x $y $z\n"
    end
    function renderFace(i::Int, f::(Int64, Int64, Int64))
        (v1,v2,v3) = f
        "E3T $i $v1 $v2 $v3 0\n"
    end
    for i = 1:length(m.faces)
        write(f, renderFace(i, m.faces[i]))
    end
    for i = 1:length(m.vertices)
        write(f, renderVertex(i, m.vertices[i]))
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
end # module Mesh
