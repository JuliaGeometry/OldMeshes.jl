function Base.unique(m::Mesh)
	vts = vertices(m)
	fcs = faces(m)
    uvts = unique(vts)
    for i = 1:length(fcs)
        #repoint indices to unique vertices
        v1 = findfirst(uvts, vts[fcs[i].v1])
        v2 = findfirst(uvts, vts[fcs[i].v2])
        v3 = findfirst(uvts, vts[fcs[i].v3])
        fcs[i] = Face{Int}(v1,v2,v3)
    end
    m.vertices[:] = uvts
end


import Base.(*)

immutable MeshMulFunctor{T} <: Base.Func{2}
    matrix::Matrix4x4{T}
end
Base.call{T}(m::MeshMulFunctor{T}, vert) = Vector3{T}(m.matrix*Vector4{T}(vert..., 1))
function *{T}(m::Matrix4x4{T}, mesh::Mesh)
    msh = deepcopy(mesh)
    map!(MeshMulFunctor(m), msh.vertices)
    msh
end








