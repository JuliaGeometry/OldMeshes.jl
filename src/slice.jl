# TODO Return type channges based on pair value
function Base.slice(mesh::Mesh{Vector3{Float64}, Face{Int}}, heights::Vector{Float64}, pair=true; eps=0.0001)

    height_ct = length(heights)
    slices = [@compat Tuple{Vector2{Float64}, Vector2{Float64}}[] for i = 1:height_ct]

    for face in mesh.faces
        v1 = mesh.vertices[face.v1]
        v2 = mesh.vertices[face.v2]
        v3 = mesh.vertices[face.v3]
        zmax = max(v1[3], v2[3], v3[3])
        zmin = min(v1[3], v2[3], v3[3])

        for i = 1:height_ct
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

                push!(slices[i], (start, finish))
            end
        end
    end

    if !pair
        return slices
    end

    paired_slices = [Vector{@compat Tuple{Vector2{Float64}, Vector2{Float64}}}[] for i = 1:height_ct]

    for slice_num = 1:height_ct
        lines = slices[slice_num]
        line_ct = length(lines)
        if line_ct == 0
            continue
        end
        polys = Vector{@compat Tuple{Vector2{Float64}, Vector2{Float64}}}[]
        paired = fill(false, line_ct)
        start = 1
        paired[start] = true
        
        @inbounds while true
            #Start new polygon with seg
            poly = @compat Tuple{Vector2{Float64}, Vector2{Float64}}[]
            push!(poly, lines[start])

            #Pair slice until we get to start point
            while norm(poly[1][1] - poly[end][2]) >= eps
                min_dist = eps
                min_index = 0

                for i = 1:line_ct
                    if !paired[i]
                        dist = norm(poly[end][2] - lines[i][1])
                        if dist <= min_dist
                            min_dist = dist
                            min_index = i
                        end
                    end
                end

                if min_index == 0
                    break
                end
                push!(poly, lines[min_index])
                paired[min_index] = true
            end

            if length(poly) > 2
                closed = true
                if poly[1][1] != poly[end][2]
                    closed = false
                end
                for i = 1:length(poly)-2
                    if closed
                        break
                    end
                    for j = i+2:length(poly)
                        if poly[i][1] == poly[j][2]
                            poly = poly[i:j]
                            closed = true
                            break
                        end
                    end
                end
                push!(polys,poly)
            end
            finished_pairing = false
            #start new polygon
            for i = 1:length(lines)
                if !paired[i] #Find next unpaired seg
                    start = i
                    paired[i] = true
                    break
                elseif i == length(lines) #we have paired each segment
                    finished_pairing = true
                    break
                end
            end
            if finished_pairing
                paired_slices[slice_num] = polys
                break # move to next layer
            end
        end
    end
    paired_slices
end


function Base.slice(mesh::Mesh{Vector3{Int}, Face{Int}}, heights::Vector{Int})

    height_ct = length(heights)
    slices = Vector{@compat Tuple{Vector2{Int}, Vector2{Int}}}[@compat Tuple{Vector2{Int}, Vector2{Int}}[] for i = 1:height_ct]

    for face in mesh.faces
        v1 = mesh.vertices[face.v1]
        v2 = mesh.vertices[face.v2]
        v3 = mesh.vertices[face.v3]
        zmax = max(v1[3], v2[3], v3[3])
        zmin = min(v1[3], v2[3], v3[3])
        for i = 1:height_ct
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

                start = Vector2{Int}(round(Int, p1[1] + (p2[1] - p1[1]) * (height - p1[3]) / (p2[3] - p1[3])),
                                     round(Int, p1[2] + (p2[2] - p1[2]) * (height - p1[3]) / (p2[3] - p1[3])))
                finish = Vector2{Int}(round(Int, p1[1] + (p3[1] - p1[1]) * (height - p1[3]) / (p3[3] - p1[3])),
                                      round(Int, p1[2] + (p3[2] - p1[2]) * (height - p1[3]) / (p3[3] - p1[3])))

                push!(slices[i], (start, finish))
            end
        end
    end
    slices
end
