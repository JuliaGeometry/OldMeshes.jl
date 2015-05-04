convert{T <: HMesh}(meshtype::Type{T}, c::AABB) = T(Cube(c.min, c.max-c.min))
function convert{T <: HMesh}(meshtype::Type{T}, c::Cube)
    ET = Float32
    xdir = Vector3{ET}(c.width[1],0,0)
    ydir = Vector3{ET}(0,c.width[2],0)
    zdir = Vector3{ET}(0,0,c.width[3])
    quads = [
        Quad(c.origin + zdir,   xdir, ydir), # Top
        Quad(c.origin,          ydir, xdir), # Bottom
        Quad(c.origin + xdir,   ydir, zdir), # Right
        Quad(c.origin,          zdir, ydir), # Left
        Quad(c.origin,          xdir, zdir), # Back
        Quad(c.origin + ydir,   zdir, xdir) #Front    
    ]
    merge(map(meshtype, quads))
end


function getindex{NT}(q::Quad, T::Type{Normal3{NT}})
    normal = normalize(cross(q.width, q.height))
    T[normal for i=1:4]
end
getindex{ET}(q::Quad, T::Type{Point3{ET}}) = T[
    q.downleft,
    q.downleft + q.height,
    q.downleft + q.width + q.height,
    q.downleft + q.width
]

getindex{FT, IndexOffset}(q::Quad, T::Type{Face3{FT, IndexOffset}}) = T[
    T(1,2,3)+IndexOffset, T(3,4,1)+IndexOffset
]

getindex{ET}(q::Quad, T::Type{UV{ET}}) = T[
    T(0,0), T(0,0), T(1,1), T(1,1)
]

getindex{ET}(q::Quad, T::Type{UVW{ET}}) = T[
    q.downleft,
    q.downleft + q.height,
    q.downleft + q.width + q.height,
    q.downleft + q.width
]

getindex{UVT}(r::Rectangle, T::Type{UV{UVT}}) = T[
    T(0, 0),
    T(0, 1),
    T(1, 1),
    T(1, 0)
]

getindex{FT, IndexOffset}(r::Rectangle, T::Type{Face3{FT, IndexOffset}}) = T[
    T(1,2,3)+IndexOffset, T(3,4,1)+IndexOffset
]

getindex{PT}(r::Rectangle, T::Type{Point2{PT}}) = T[
    T(r.x, r.y),
    T(r.x, r.y + r.h),
    T(r.x + r.w, r.y + r.h),
    T(r.x + r.w, r.y)
]
