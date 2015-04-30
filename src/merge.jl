merge(m1::Mesh, rest::Mesh...) = merge(tuple(m1, rest...))
merge{M <: Mesh}(m::Vector{M}) = merge(tuple(m...))


#Merges an arbitrary mesh. This function probably doesn't work for all types of meshes
function merge{N, M <: Mesh}(meshes::NTuple{N, M})
	m1 = first(meshes)
    v = m1.vertices
    f = m1.faces
    attribs = attributes_noVF(m1)
    for mesh in meshes[2:end]
        append!(f, mesh.faces + length(v))
        append!(v, mesh.vertices)
       	map(append!, values(attribs), values(attributes_noVF(mesh)))
    end
    attribs[:vertices] 	= v
    attribs[:faces] 	= f
    return M(attribs)
end

# A mesh with one constant attribute can be merged as an attribute mesh. Possible attributes are FSArrays
function Base.merge{N, _1, _2, _3, _4, ConstAttrib <: Color, _5, _6}(meshes::NTuple{N, HMesh{_1, _2, _3, _4, ConstAttrib, _5, _6}})
    m1 = first(meshes)
    vertices = m1.vertices
    faces    = m1.faces
    attribs         = attributes_noVF(m1)
    color_attrib    = [RGBAU8(m1.color)]
    index           = Float32[length(color_attrib)-1 for i=1:length(m1.vertices)]
    delete!(attribs, :color)
    for mesh in meshes[2:end]
        append!(faces, mesh.faces + length(vertices))
        append!(vertices, mesh.vertices)
        attribsb = attributes_noVF(mesh)
        delete!(attribsb, :color)
        map(append!, values(attribs), values(attribsb))
        push!(color_attrib, mesh.color)
        append!(index, Float32[length(color_attrib)-1 for i=1:length(mesh.vertices)])
    end
    attribs[:vertices]      = vertices
    attribs[:faces]         = faces
    attribs[:attributes]    = color_attrib
    attribs[:attribute_id]  = index
    return HMesh(attribs)
end
