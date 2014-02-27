# Mesh simplification via edge collapse. 
#
# The implementation follows for the most part the algorithm
# described in:
#
#   Garland, Michael, and Paul S. Heckbert. "Surface 
#   simplification using quadric error metrics." 
#   Proceedings of the 24th annual conference on Computer 
#   graphics and interactive techniques. 
#   ACM Press/Addison-Wesley Publishing Co., 1997.
#
# The principal ways in which the implementation deviates are:
#  1. Only edges, and not vertex pairs in general, are
#     collapsible. We require that simplification preserves
#     topology.
#  2. Collapse is only performed on edges that are incident on 
#     interior vertices. Boundaries are not simplified. This
#     allows for a variety of simplifications in the logic of 
#     collapse.

###########################################################
#
# CollapsibleMesh
#
# A data structure representing a triangular mesh that
# admits edge collapse.
#
type HalfEdge
    src :: Int64 # vertex index at the root of the half-edge
    nxt :: Int64 # the next edge in this (oriented) face
    opp :: Int64 # the other edge in the adjoining face (if not on bdy)
    HalfEdge(s,n,o) = new(s,n,o)
end

type CollapsibleMesh
    vPositions :: Vector{Vertex}
    vEdges     :: Vector{Int64}
    edges      :: Vector{HalfEdge}
end

# vertex accessors
edg(cm::CollapsibleMesh,v::Int64) = cm.vEdges[v]
pos(cm::CollapsibleMesh,v::Int64) = cm.vPositions[v]

# edge accessors
src(cm::CollapsibleMesh,e::Int64) = cm.edges[e].src
nxt(cm::CollapsibleMesh,e::Int64) = cm.edges[e].nxt
opp(cm::CollapsibleMesh,e::Int64) = cm.edges[e].opp
tgt(cm::CollapsibleMesh,e::Int64) = src(cm,nxt(cm,e))
prv(cm::CollapsibleMesh,e::Int64) = nxt(cm,nxt(cm,e))

# clockwise edge iteration
start(it::(CollapsibleMesh,Int64)) = (false,it[2])
done(it::(CollapsibleMesh,Int64), st::(Bool,Int64)) =
    st[1] && st[2] == it[2]
function next(it::(CollapsibleMesh,Int64), st::(Bool,Int64))
    nxt = next(it[1],opp(it[1],st[2]))
    (nxt, (true,nxt))
end

# predicates
isDeletedEdge(cm::CollapsibleMesh,e::Int64) = nxt(cm,e) == 0
isDeletedVertex(cm::CollapsibleMesh,v::Int64) = edg(cm,v) == 0
isBoundaryEdge(cm::CollapsibleMesh,e::Int64) = opp(cm,e) == 0
function isBoundaryVertex(cm::CollapsibleMesh,v::Int64)
    for e = (cm,edg(cm,v))
        if isBoundaryEdge(cm,e)
            return true
        end
    end
    false
end
function isCollapsibleEdge(cm::CollapsibleMesh,e::Int64)
    src = src(cm,e)
    tgt = tgt(cm,e)

    # check for boundary
    if isBoundaryEdge(cm,e); return false; end
    if isBoundaryVertex(cm,src); return false; end
    if isBoundaryVertex(cm,tgt); return false; end

    # check for topological conditions
    #
    # We only allow collapse if exactly two vertices are
    # connected by an edge to both the source and target vertex.

    srcNbrs = IntSet()
    for se = (cm,edg(cm,src))
        push!(srcNbrs,tgt(cm,se))
    end

    tgtNbrs = IntSet()
    for te = (cm,edg(cm,tgt))
        push!(tgtNbrs,tgt(cm,te))
    end

    if length(intersect(srcNbrs,tgtNbrs)) != 2; return false; end

    # if there are 4 nbrs, we're a tetrahedron: don't collapse
    if length(union(srcNbrs,tgtNbrs)) <= 4; return false; end

    true
end

# edge collapse
function collapse!(cm::CollapsibleMesh, e::Int64, pos::Vertex)
        
    if !isCollapsibleEdge(cm,e) return false end

    # id the relevant edges, vertices
    # 
    #          tgt
    #          +
    #         /|\
    #        / | \
    #    eno/  |  \opo
    #      /en | op\
    #     /    |    \
    # vl +    e|o    + vr
    #     \    |    /
    #      \ep | on/
    #    epo\  |  /ono
    #        \ | /
    #         \|/
    #          +
    #          src
    #
    en = nxt(cm,e)
    eno = opp(cm,en)
    ep = prv(cm,e)
    epo = opp(cm,ep)
    o = opp(cm,e)
    on = nxt(cm,o)
    ono = opp(cm,on)
    op = prv(cm,o)
    opo = opp(cm,op)
    src = src(cm,e)
    tgt = src(cm,o)
    vl = src(cm,ep)
    vr = src(cm,op)

    # check that the new vertex position doesn't cause an inversion. 
    function causesInversion(ee::Int64)
        v0 = src(cm,ee)
        v1 = tgt(cm,ee)
        v2 = tgt(cm,nxt(cm,ee))
        p0 = pos(cm,v0)
        p1 = pos(cm,v1)
        p2 = pos(cm,v2)
        n1 = unit(cross(p1-p0,p2-p0))
        n2 = unit(cross(p1-pos,p2-pos))
        dot(n1,n2) < 0.01
    end

    # circle source vertex
    for ee = (cm,e)
        if ee != e && ee != on
            if causesInversion(ee); return false; end
        end
    end

    # circle target vertex
    for ee = (cm,o)
        if ee != o && ee != en
            if causesInversion(ee); return false; end
        end
    end

    # now perform the actual collapse...

    # ensure all the edges emanating from the source vertex
    # now emanate from the target vertex
    for ee = (cm,e)
        cm.edges[ee].src = tgt
    end

    # fix up the edge opps for the edges that remain
    cm.edges[epo].opp = eno;
    cm.edges[eno].opp = epo;
    cm.edges[opo].opp = ono;
    cm.edges[ono].opp = opo;

    # ensure the three remaining vertices point to edges that remain
    cm.vEdges[tgt] = opo
    cm.vEdges[vl] = eno
    cm.vEdges[vr] = ono

    # update the remaining vertex position
    cm.vPositions[tgt] = pos;

    # delete the vertex and edges
    cm.vEdges[src] = 0
    cm.edges[ep].nxt = 0
    cm.edges[en].nxt = 0
    cm.edges[e].nxt = 0
    cm.edges[op].nxt = 0
    cm.edges[on].nxt = 0
    cm.edges[o].nxt = 0

    true
end

###########################################################
#
# conversion between a vanilla mesh and a collapsible mesh
#

# construction from a vanilla mesh
function CollapsibleMesh(m::GeometricMesh)
    msh = mesh(m)
    vts = msh.vertices
    fcs = msh.faces

    nVts = length(vts)
    nFcs = length(fcs)

    # make edge, vEdge lists &
    # build edge dictionary
    vs = Array(Int64,nVts)
    es = Array(HalfEdge,3*nFcs)
    edgeDict = Dict{(Int64,Int64),Int64}()
    for i = 1:nFcs
        fc = fcs[i]

        # set vertex edges
        vs[fc.v1] = 3*i-2
        vs[fc.v2] = 3*i-1
        vs[fc.v3] = 3*i

        # set sources
        es[3*i-2] = HalfEdge(fc.v1,0,0)
        es[3*i-1] = HalfEdge(fc.v2,0,0)
        es[3*i]   = HalfEdge(fc.v3,0,0)

        # set nxts
        es[3*i-2].nxt = 3*i-1
        es[3*i-1].nxt = 3*i
        es[3*i].nxt   = 3*i-2

        # add edges to dictionary
        edgeDict[(fc.v1,fc.v2)] = 3*i-2
        edgeDict[(fc.v2,fc.v3)] = 3*i-1
        edgeDict[(fc.v3,fc.v1)] = 3*i
    end

    # fix up opps
    for i = 1:3*nFcs
        src = es[i].src
        tgt = es[es[i].nxt].src
        es[i].opp = get(edgeDict,(tgt,src),0)
    end

    CollapsibleMesh(vts,vs,es)
end

# conversion to a vanilla mesh
function mesh(cm::CollapsibleMesh)

    # collect vertex indices
    nVold = length(cm.vEdges)
    vs = IntSet()
    for v = 1:nVold
        if !isDeletedVertex(cm,v)
            push!(vs,v)
        end
    end

    # get vertex positions, create reverse map
    nV = length(vs)
    vts = Array(Vertex,nV)
    invV = zeros(Int64,nVold)
    ix = 1
    for v = vs
        vts[ix] = pos(cm,v)
        invV[v] = ix
        ix += 1
    end

    # collect faces
    fcs = Array(Face,0)
    nE = length(cm.edges)
    for e = 1:3:nE
        if !isDeletedEdge(cm,e)
            # make and push face
            v1 = invV[src(cm,e)]
            v2 = invV[src(cm,e+1)]
            v3 = invV[src(cm,e+2)]
            push!(fcs,Face(v1,v2,v3))
        end
    end

    Mesh(vts,fcs)
end


##########################################################
#
# mesh simplification based on vertex quadric error
#

typealias Plane Vector4{Float64}

# Given three vertices, determines coefficients of the
# corresponding plane equation
function plane(v1::Vertex,v2::Vertex,v3::Vertex)
    n = unit(cross(v1-v2,v3-v2))
    d = dot(n,v2)
    p = Plane(n.e1,n.e2,n.e3,-d)
end

# determines an error quadric associated with the given vertex
typealias Quadric Matrix4x4{Float64}
function quadric(cm::CollapsibleMesh, v::Int64)
    u = unit(Plane,4)
    q = 1.0e-3*column(u)*row(u) # start with a small constant
    
    if !isBoundaryVertex(cm,v)
        for e = (cm,edg(cm,v))
            # determine the plane associated with the current face
            v1 = pos(cm,src(cm,e))
            v2 = pos(cm,src(cm,nxt(cm,e)))
            v3 = pos(cm,src(cm,prv(cm,e)))
            p = plane(v1,v2,v3)

            # accumulate the outer product
            q += column(p)*row(p)
        end
    end
    q
end

homog(p) = Plane(p.e1,p.e2,p.e3,1.0)

function edgeCost(cm::CollapsibleMesh,qs::AbstractArray{Quadric,1},e::Int64)
    src = src(cm,e)
    tgt = tgt(cm,e)
    p1 = pos(cm,src)
    p2 = pos(cm,tgt)
    p  = 0.5*(p1+p2)
    hp = homog(p)
    q = qs[src]+qs[tgt]
    c = hp*q*hp
    (c,p)
end

# helper type for edge heap
immutable HeapNode
    cost     :: Float64
    edge     :: Int64
    position :: Vertex
    HeapNode(c,e,p) = new(c,e,p)
end
<(hn1::HeapNode,hn2::HeapNode) = hn1.cost < hn2.cost
using DataStructures

function simplify(msh::GeometricMesh,decimation::Float64)
    # to a collapsible mesh
    cm = CollapsibleMesh(msh)

    # calculate the initial vertex quadrics
    nV = length(cm.vPositions)
    qs = Array(Quadric,nV)
    for v = 1:nV
        qs[v] = quadric(cm,v)
    end

    # initialize the edge heap
    h = mutable_binary_minheap(HeapNode)
    nE = length(cm.edges)
    ks = zeros(Int,nE) # keys into the heap

    # a convenience closure : recalculate the cost
    # of the edge and update the heap
    function updateCost(e)
        if isCollapsibleEdge(cm,e)
            (c,p) = edgeCost(cm,qs,e)
            hn = HeapNode(c,e,p)
            if ks[e] != 0
                update!(h, ks[e], hn)
            else
                ks[e] = push!(h, hn)
            end
        end
    end

    # add all the appropriate edges to the heap
    for e = 1:nE
        updateCost(e)
    end

    # simplify
    nDeleted = 0
    nToDelete = int(nE*(1.0-decimation))
    while !isempty(h) && nDeleted < nToDelete
        hn = pop!(h)
        e = hn.edge
        p = hn.position
        ks[e] = 0

        if isDeletedEdge(cm,e)
            continue
        end
        
        src = src(cm,e)
        tgt = tgt(cm,e)

        if collapse!(cm,e,p)

            # update the quadric
            qs[tgt] += qs[src]

            # update neighbor edges in the heap
            for e = (cm,edg(cm,tgt))
                updateCost(e)
                nxt = nxt(cm,e)
                updateCost(nxt)
                updateCost(nxt(cm,nxt))
                if !isBoundaryEdge(cm,nxt)
                    updateCost(opp(cm,nxt))
                end
            end

            # increment the collapse counter
            nDeleted += 1
        end
    end
    
    # from a collapsible mesh
    mesh(cm)
end
export simplify
