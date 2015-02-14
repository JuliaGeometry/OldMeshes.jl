
function Base.slice(mesh::Mesh, heights::Array{Float64})

    n = length(heights)
    segments = [(Vector2{Float64}, Vector2{Float64})[] for i = 1:n]

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
                if v1[3] < height && v2[3] >= height && v3[3] >= height
                    p1 = v1
                    p2 = v3
                    p3 = v2
                elseif v1[3] > height && v2[3] < height && v3[3] < height
                    p1 = v1
                    p2 = v2
                    p3 = v3
                elseif v2[3] < height && v1[3] >= height && v3[3] >= height
                    p1 = v2
                    p2 = v1
                    p3 = v3
                elseif v2[3] > height && v1[3] < height && v3[3] < height
                    p1 = v2
                    p2 = v3
                    p3 = v1
                elseif v3[3] < height && v2[3] >= height && v1[3] >= height
                    p1 = v3
                    p2 = v2
                    p3 = v1
                elseif v3[3] > height && v2[3] < height && v1[3] < height
                    p1 = v3
                    p2 = v1
                    p3 = v2
                else
                    continue
                end

                start = Vector2{Float64}(p1[1] + (p2[1] - p1[1]) * (height - p1[3]) / (p2[3] - p1[3]),
                p1[2] + (p2[2] - p1[2]) * (height - p1[3]) / (p2[3] - p1[3]))
                finish = Vector2{Float64}(p1[1] + (p3[1] - p1[1]) * (height - p1[3]) / (p3[3] - p1[3]),
                p1[2] + (p3[2] - p1[2]) * (height - p1[3]) / (p3[3] - p1[3]))

                push!(segments[i], (start, finish))
            end
        end
    end

    return segments
end

