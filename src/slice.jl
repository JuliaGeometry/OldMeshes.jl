export slice

# returns an array of SegmentedPolygons
function slice(mesh::Mesh, heights::Array{Float64}; eps=0.00001, autoeps=true)

    n = length(heights)
    segments = [LineSegment[] for i = 1:n]

    for face in mesh.faces
        v1 = mesh.vertices[face.v1]
        v2 = mesh.vertices[face.v2]
        v3 = mesh.vertices[face.v3]
        zmax = max(v1[3], v2[3], v3[3])
        zmin = min(v1[3], v2[3], v3[3])
        for i = 1:n
            height = heights[i]
            if height > zmax
                break
            elseif zmin <= height
                seg = LineSegment(v1,v2,v3, height)
                if seg != nothing
                    push!(segments[i], seg)
                end
            end
        end
    end

    polys = [SegmentedPolygon[] for i = 1:n]

    for i = 1:n
        append!(polys[i], SegmentedPolygon(segments[i], eps=eps, autoeps=autoeps))
    end

    return polys
end
