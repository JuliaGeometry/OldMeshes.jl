using ImmutableArrays
#unit{T}(geometry::Vector{Vertex{T}}) = reinterpret(Vertex{T}, unitGeometry(reinterpret(Vector3{T}, geometry)))


function AABB{T}(geometry::Vector{Vector3{T}}) 
    vmin = Vector3(typemax(T))
    vmax = Vector3(typemin(T))
    @inbounds for i=1:length(geometry)
         vmin = min(geometry[i], vmin)
         vmax = max(geometry[i], vmax)
    end
    AABB(vmin, vmax)
end

unit{T}( geometry::Vector{Vector3{T}})                = unit!(copy(geometry))
unit{T}( geometry::Vector{Vector3{T}}, aabb::AABB{T}) = unit!(copy(geometry), aabb)
unit!{T}(geometry::Vector{Vector3{T}})                = unit!(geometry, AABB(geometry))

function unit!{T}(geometry::Vector{Vector3{T}}, aabb::AABB{T})
    isempty(geometry) && return geometry
    const two = convert(T, 2)
    middle = aabb.min + (aabb.max-aabb.min) / two
    scale  = two / maximum(aabb.max-aabb.min)
    @simd for i = 1:length(geometry)
       @inbounds geometry[i] = (geometry[i] - middle) * scale
    end
    geometry
end

function normals(faces, verts)
  normals_result = fill(Vec3(0), length(verts))
  verts = reinterpret(Vec3, verts)
  for face in faces
    i1 = int(face[1]) +1
    i2 = int(face[2]) +1
    i3 = int(face[3]) +1

    v1 = verts[i1]
    v2 = verts[i2]
    v3 = verts[i3]
    a = v1 - v2
    b = v1 - v3
    n = cross(a,b)
    normals_result[i1] = unit(n+normals_result[i1])
    normals_result[i2] = unit(n+normals_result[i2])
    normals_result[i3] = unit(n+normals_result[i3])
  end
  reinterpret(Normal{Float32}, normals_result)
end



# copied from WavefrontObj.jl, not yet generalized
function triangulate!(faces, verts)
    for face in faces
        if length(face.ivertices) > 3
            # split a triangle
            triangle = WavefrontObjFace{faceindextype}(face.ivertices[1:3], [], [], face.material, copy(face.groups), copy(face.smoothing_group))
            splice!(face.ivertices, 2)

            if !isempty(face.itexture_coords)
                triangle.itexture_coords = face.itexture_coords[1:3]
                splice!(face.itexture_coords, 2)
            end
            if !isempty(face.inormals)
                triangle.inormals = face.inormals[1:3]
                splice!(face.inormals, 2)
            end

            # add new triangle to groups, smoothing_groups, material
            triangle_index = length(obj.faces)+1

            for group in triangle.groups
                push!(obj.groups[group], triangle_index) 
            end

            push!(obj.materials[triangle.material], triangle_index)

            push!(obj.smoothing_groups[triangle.smoothing_group], triangle_index)

            # done
            push!(obj.faces, triangle)
            continue
        end
    end
end
