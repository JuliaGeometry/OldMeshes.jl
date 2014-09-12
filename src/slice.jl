type LineSegment
    start::Vector2{Float64}
    finish::Vector2{Float64}
    normal::Vector3{Float64}
end

type Polygon
    bounds::Bounds2
    segments::Array{LineSegment}
end

type MeshSlice
    bounds::Bounds2
    polygons::Array{Polygon}
    layer::Float64
end

function LineSegment(f::Face, z::Float64)
    p0 = f.vertices[1]
    p1 = f.vertices[2]
    p2 = f.vertices[3]

    if p0.e3 < z && p1.e3 >= z && p2.e3 >= z
        return LineSegment(p0, p2, p1, z, f.normal)
    elseif p0.e3 > z && p1.e3 < z && p2.e3 < z
        return LineSegment(p0, p1, p2, z, f.normal)
    elseif p1.e3 < z && p0.e3 >= z && p2.e3 >= z
        return LineSegment(p1, p0, p2, z, f.normal)
    elseif p1.e3 > z && p0.e3 < z && p2.e3 < z
        return LineSegment(p1, p2, p0, z, f.normal)
    elseif p2.e3 < z && p1.e3 >= z && p0.e3 >= z
        return LineSegment(p2, p1, p0, z, f.normal)
    elseif p2.e3 > z && p1.e3 < z && p0.e3 < z
        return LineSegment(p2, p0, p1, z, f.normal)
    end

end

function LineSegment(p0::Vector3, p1::Vector3, p2::Vector3, z::Float64, normal::Vector3)
    start = Vector2(p0.e1 + (p1.e1 - p0.e1) * (z - p0.e3) / (p1.e3 - p0.e3),
                    p0.e2 + (p1.e2 - p0.e2) * (z - p0.e3) / (p1.e3 - p0.e3))
    finish = Vector2(p0.e1 + (p2.e1 - p0.e1) * (z - p0.e3) / (p2.e3 - p0.e3),
                     p0.e2 + (p2.e2 - p0.e2) * (z - p0.e3) / (p2.e3 - p0.e3))
    return LineSegment(start, finish, normal);
end

function ==(a::LineSegment, b::LineSegment)
    return (a.start == b.start &&
            a.finish == b.finish)
end


function Polygon(lines::Array{LineSegment}; eps=0.00001, autoeps=true)
    n = length(lines)
    if n == 0
        return [Polygon()]
    end
    polys = Polygon[]
    paired = [false for i = 1:n]
    start = 1
    seg = 1
    paired[seg] = true

    if autoeps
        for segment in lines
            eps = min(eps, norm(segment.start-segment.finish)/2)
        end
    end

    while true
        #Start new polygon with seg
        poly = Polygon()
        push!(poly, lines[seg])

        #Pair lines until we get to start point
        lastseg = seg
        while norm(lines[start].start - lines[seg].finish) >= eps
            lastseg = seg

            for i = 1:n
                if !paired[i]
                    if norm(lines[seg].finish - lines[i].start) <= eps
                        push!(poly, lines[i])
                        paired[i] = true
                        seg = i
                    end
                end
            end

            if (seg == start #We couldn't pair the segment
                || seg == lastseg) #The polygon can't be closed
                break
            end
        end

        if length(poly.segments) > 2
            closed = true
            if poly.segments[1].start != poly.segments[end].finish
                closed = false
            end
            for i = 1:length(poly.segments)-2
                if closed
                    break
                end
                for j = i+2:length(poly.segments)
                    if poly.segments[i].start == poly.segments[j].finish
                        poly.segments = poly.segments[i:j]
                        closed = true
                        break
                    end
                end
            end
            push!(polys,poly)
        end
        #start new polygon
        for i = 1:length(lines)
            if !paired[i] #Find next unpaired seg
                start = i
                paired[i] = true
                seg = start
                break
            elseif i == length(lines) #we have paired each segment
                return polys
            end
        end
    end
end

function MeshSlice(mesh::PolygonMesh, heights::Array{Float64}; eps=0.00001, autoeps=true)
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

    polys = MeshSlice[]

    for i = 1:length(heights)
        push!(polys, MeshSlice(bounds[i], Polygon(slices[i], eps=eps, autoeps=autoeps), heights[i]))
    end

    return polys
end
