# Low-dimensional geometry
# This or something like it should probably be its own package 
# at some point.

module Geometry

export Point3

immutable Point3{T<:Real}
    x::T
    y::T
    z::T
end

end
