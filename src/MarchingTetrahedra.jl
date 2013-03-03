#
# *** Marching Tetrahedra ***
#
# Marching Tetrahedra is an algorithm for extracting a triangular
# mesh representation of an isosurface of a scalar volumetric
# function sampled on a rectangular grid.
#
# We divide the cube into six tetrahedra. [It is possible to divide
# a cube into five tetrahedra, but not in a way that a translated
# version of the division would share face diagonals. (It reqires a
# reflection.)]
#
# Voxel corner and edge indexing conventions
#
#        Z
#        |
#  
#        5------5------6              Extra edges not drawn
#       /|            /|              -----------
#      8 |           6 |              - face diagonals
#     /  9          /  10                - 13: 1 to 3
#    8------7------7   |                 - 14: 1 to 8
#    |   |         |   |                 - 15: 1 to 6
#    |   1------1--|---2  -- Y           - 16: 5 to 7
#    12 /          11 /                  - 17: 2 to 7
#    | 4           | 2                   - 18: 4 to 7
#    |/            |/                 - body diagonal
#    4------3------3                     - 19: 1 to 7
#
#  /
# X
module MarchingTetrahedra

export marchingTetrahedra

typealias Vec3f (Float64,Float64,Float64)
typealias Vec3i (Int64,Int64,Int64)

# (X,Y,Z)-coordinates for each voxel corner ID
const voxCrnrPos = [[0 0 0],
                    [0 1 0],
                    [1 1 0],
                    [1 0 0],
                    [0 0 1],
                    [0 1 1],
                    [1 1 1],
                    [1 0 1]]'

# the voxel IDs at either end of the tetrahedra edges, by edge ID
const voxEdgeCrnrs = [[1 2],
                      [2 3],
                      [4 3],
                      [1 4],
                      [5 6],
                      [6 7],
                      [8 7],
                      [5 8],
                      [1 5],
                      [2 6],
                      [3 7],
                      [4 8],
                      [1 3],
                      [1 8],
                      [1 6],
                      [5 7],
                      [2 7],
                      [4 7],
                      [1 7]]'


# direction codes:
# 0 => +x, 1 => +y, 2 => +z, 
# 3 => +xy, 4 => +xz, 5 => +yz, 6 => +xyz
const voxEdgeDir = [1,0,1,0,1,0,1,0,2,2,2,2,3,4,5,3,4,5,6]

# For a pair of corner IDs, the edge ID joining them
# 0 denotes a pair with no edge
const voxEdgeIx = [[ 0  1 13  4  9 15 19 14],
                   [ 1  0  2  0  0 10 17  0],
                   [13  2  0  3  0  0 11  0],
                   [ 4  0  3  0  0  0 18 12],
                   [ 9  0  0  0  0  5 16  8],
                   [15 10  0  0  5  0  6  0],
                   [19 17 11 18 16  6  0  7],
                   [14  0  0 12  8  0  7  0]]

# voxel corners that comprise each of the six tetrahedra
const subTets = [[1 3 2 7],
                 [1 8 4 7],
                 [1 4 3 7],
                 [1 2 6 7],
                 [1 5 8 7],
                 [1 6 5 7]]'

# tetrahedron corners for each edge (indices 1-4)
const tetEdgeCrnrs = [[1 2],
                      [2 3],
                      [1 3],
                      [1 4],
                      [2 4],
                      [3 4]]'

# triangle cases for a given tetrahedron edge code
const tetTri = [[0 0 0 0 0 0],
                [1 3 4 0 0 0],
                [1 5 2 0 0 0],
                [3 5 2 3 4 5],
                [2 6 3 0 0 0],
                [1 6 4 1 2 6],
                [1 5 6 1 6 3],
                [4 5 6 0 0 0],
                [4 6 5 0 0 0],
                [1 6 5 1 3 6],
                [1 4 6 1 6 2],
                [2 3 6 0 0 0],
                [3 2 5 3 5 4],
                [1 2 5 0 0 0],
                [1 4 3 0 0 0],
                [0 0 0 0 0 0]]'

# Checks if a voxel has faces. Should be false for most voxels.
# This function should be made as fast as possible.
function hasFaces{T<:Real}(vals::Vector{T}, iso::T)
    hasFcs = false
    if vals[1] < iso
        for i = 2:8
            if vals[i] >= iso
                hasFcs = true
                break
            end
        end
    else
        for i = 2:8
            if vals[i] < iso
                hasFcs = true
                break
            end
        end
    end 
    hasFcs
end

# Determines which case in the triangle table we are dealing with
function tetIx{T<:Real}(tIx::Int64, vals::Vector{T}, iso::T)
    crnrs = subTets[:,tIx]
    (vals[crnrs[1]] < iso ? 1 : 0) +
    (vals[crnrs[2]] < iso ? 2 : 0) +
    (vals[crnrs[3]] < iso ? 4 : 0) +
    (vals[crnrs[4]] < iso ? 8 : 0) + 1
end

# Determines a unique integer ID associated with the edge. This is used
# as a key in the vertex dictionary. It needs to be both unambiguous (no
# two edges get the same index) and unique (every edge gets the same ID
# regardless of which of its neighboring voxels is asking for it) in order
# for vertex sharing to be implemented properly.
function vertId(e::Int64, x::Int64, y::Int64, z::Int64,
                nx::Int64, ny::Int64)
    dx = voxCrnrPos[:,voxEdgeCrnrs[1,e]]
    voxEdgeDir[e]+7*(x-1+dx[1]+nx*(y-1+dx[2]+ny*(z-1+dx[3])))
end

# Assuming an edge crossing, determines the point in space at which it
# occurs.
function vertPos{T<:Real}(e::Int64, x::Int64, y::Int64, z::Int64,
                          vals::Vector{T}, iso::T)
    ixs = voxEdgeCrnrs[:,e]
    srcVal = float(vals[ixs[1]])
    tgtVal = float(vals[ixs[2]])
    a = (float(iso)-srcVal)/(tgtVal-srcVal)
    b = 1.0-a
    org = float([x,y,z])
    src = org+float(voxCrnrPos[:,ixs[1]])
    tgt = org+float(voxCrnrPos[:,ixs[2]])
    vrt = a*tgt+b*src
    (vrt[1],vrt[2],vrt[3])
end

# Gets the vertex ID, adding it to the vertex dictionary if not already
# present.
function getVertId{T<:Real}(e::Int64, x::Int64, y::Int64, z::Int64,
                            nx::Int64, ny::Int64,
                            vals::Vector{T}, iso::T,
                            vts::Dict{Int64,Vec3f})
    vId = vertId(e,x,y,z,nx,ny)
    if !has(vts,vId)
        vts[vId] = vertPos(e,x,y,z,vals,iso)
    end
    vId
end

# Given a sub-tetrahedron case and a tetrahedron edge ID, determines the
# corresponding voxel edge ID.
function voxEdgeId(subTetIx::Int64, tetEdgeIx::Int64)
    tetCrnrs = tetEdgeCrnrs[:,tetEdgeIx]
    srcVoxCrnr = subTets[tetCrnrs[1],subTetIx]
    tgtVoxCrnr = subTets[tetCrnrs[2],subTetIx]
    voxEdgeIx[srcVoxCrnr,tgtVoxCrnr]
end

# Processes a voxel, adding any new vertices and faces to the given
# containers as necessary.
function procVox{T<:Real}(vals::Vector{T}, iso::T,
                          x::Int64, y::Int64, z::Int64,
                          nx::Int64, ny::Int64,
                          vts::Dict{Int64,Vec3f}, fcs::Vector{Vec3i})

    # check each sub-tetrahedron in the voxel
    for i = 1:6
        tIx = tetIx(i,vals,iso)

        for j = Range(1,3,2)
            e1 = tetTri[j,tIx]
            e2 = tetTri[j+1,tIx]
            e3 = tetTri[j+2,tIx]

            # bail if there are no more faces
            if e1 == 0 break end

            # add the face to the list
            vId(e) = getVertId(voxEdgeId(i,e),x,y,z,nx,ny,vals,iso,vts)
            push!(fcs,(vId(e1),vId(e2),vId(e3)))
        end
    end
end

# Given a 3D array and an isovalue, extracts a mesh represention of the 
# an approximate isosurface by the method of marching tetrahedra.
function marchingTetrahedra{T<:Real}(lsf::AbstractArray{T,3},iso::T)
    vts = Dict{Int64,Vec3f}()
    fcs = Array(Vec3i,0)

    # a helper function for fetching the values at the corners of a voxel
    function ix(i,j,k,l)
        dx = voxCrnrPos[:,l]
        lsf[i+dx[1],j+dx[2],k+dx[3]]
    end

    # process each voxel
    (nx,ny,nz) = size(lsf)
    for k = 1:nz-1
        for j = 1:ny-1
            for i = 1:nx-1
                vals = T[ix(i,j,k,l) for l = 1:8]
                if hasFaces(vals,iso)
                    procVox(vals,iso,i,j,k,nx,ny,vts,fcs)
                end
            end
        end
    end

    (vts,fcs)
end

end
