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
function getindex{ET}(q::Quad, T::Type{Point3{ET}})
	T[
        q.downleft,
        q.downleft + q.height,
        q.downleft + q.width + q.height,
        q.downleft + q.width
    ]
end
function getindex{ET}(q::Quad, T::Type{Triangle{ET}})
	T[T(0,1,2), T(2,3,0)]
end
function getindex{ET}(q::Quad, T::Type{UV{ET}})
	T[T(0,0), T(0,0), T(1,1), T(1,1)]
end
function getindex{ET}(q::Quad, T::Type{UVW{ET}})
	T[
        q.downleft,
        q.downleft + q.height,
        q.downleft + q.width + q.height,
        q.downleft + q.width
    ]
end

getindex{UVT}(r::Rectangle, T::Type{UV{UVT}}) = T[
    T(0, 0),
    T(0, 1),
    T(1, 1),
    T(1, 0)
]
getindex{FT}(r::Rectangle, T::Type{Triangle{FT}}) = T[
	T(0,1,2), T(2,3,0)
]

getindex{PT}(r::Rectangle, T::Type{Point2{PT}}) = T[
    T(r.x, r.y),
    T(r.x, r.y + r.h),
    T(r.x + r.w, r.y + r.h),
    T(r.x + r.w, r.y)
]
