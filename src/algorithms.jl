
function normals{VT, FT}(vertices::Vector{Point3{VT}}, faces::Vector{Triangle{FT}}, NT = Normal3{VT})
	normals_result = zeros(Point3{VT}, length(vertices)) # initilize with same type as verts but with 0
	for face in faces

		i1 = Int(face[1]+1) # convert to Int, to keep things homogenous for indexing
		i2 = Int(face[2]+1)
		i3 = Int(face[3]+1)

		v1 = vertices[i1]
		v2 = vertices[i2]
		v3 = vertices[i3]

		a = v2 - v1
		b = v3 - v1

		n = cross(a,b)

		normals_result[i1] = n+normals_result[i1]
		normals_result[i2] = n+normals_result[i2]
		normals_result[i3] = n+normals_result[i3]

	end
	map!(normalize, normals_result)
	normals_result = convert(NT, normals_result)
	println(typeof(normals_result))
	normals_result
end


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









