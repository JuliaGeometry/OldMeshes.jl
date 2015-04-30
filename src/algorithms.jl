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









