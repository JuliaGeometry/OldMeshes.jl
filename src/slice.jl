# returns an array of SegmentedPolygons
function slice(mesh::PolygonMesh, heights::Array{Float64}; eps=0.00001, autoeps=true)
    slices = [LineSegment[] for i = 1:length(heights)]
    bounds = [Bounds2() for i = 1:length(heights)]

    for face in mesh.faces
        i = 1
        for height in heights
            if height > face.zmax
                break
            elseif face.zmin <= height
                seg = LineSegment(face, height)
                if seg != nothing
                    push!(slices[i], seg)
                    update!(bounds[i], seg)
                end
            end
            i = i + 1
        end
    end

    polys = SegmentedPolygon[]

    for i = 1:length(heights)
        push!(polys, SegmentedPolygon(slices[i], eps=eps, autoeps=autoeps))
    end

    return polys
end
