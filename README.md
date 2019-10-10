Dear visitor:

This package is no longer maintained. Its usable contents have long ago migrated to
[Meshing](https://github.com/JuliaGeometry/Meshing.jl) and
[MeshIO](https://github.com/JuliaIO/MeshIO.jl). The remaining bit of code related to [mesh simplification](https://github.com/JuliaGeometry/OldMeshes.jl/blob/534cc58111636ddd837669ca156c44c1eb24a8a4/src/simplification.jl#L1)
had not yet found its way into another package at the time of this writing, but I don't believe it ever worked correctly, anyway. Still, it might serve as a starting point for a correct implementation. After all, I based it on a correct C++ implementation that I had created previously.

Sincerely,
[Tracy Wadleigh](https://github.com/twadleigh), original author.

# Meshes.jl

[![Build Status](https://travis-ci.org/JuliaGeometry/Meshes.jl.svg?branch=master)](https://travis-ci.org/JuliaGeometry/Meshes.jl)
[![Coverage Status](https://img.shields.io/coveralls/JuliaGeometry/Meshes.jl.svg)](https://coveralls.io/r/JuliaGeometry/Meshes.jl)

This package is designed to make it easy to work with [polygon mesh data](https://en.wikipedia.org/wiki/Polygon_mesh).
It is a primarily a meta-package for
[Meshing](https://github.com/JuliaGeometry/Meshing.jl),
[MeshIO](https://github.com/JuliaIO/MeshIO.jl),
and [GeometryTypes](https://github.com/JuliaGeometry/GeometryTypes.jl).
In addition, it is a great (and recommended) place for experimental
development that is not yet congruent with the GeometryTypes type heirarchy.

The current release series corresponds to `v0.2.x`. The pre-GeometryTypes, et. al.
version, [`v0.1.x`](https://github.com/JuliaGeometry/Meshes.jl/tree/v0.1.x),
is still supported by [@sjkelly](https://github.com/sjkelly/).

## Data Types

Meshes does not define many datatypes, but rather it uses those defined by
[GeometryTypes](https://github.com/JuliaGeometry/GeometryTypes.jl) where possible.

## Functionality

### Meshing

This functionality is derived from the
[Meshing](https://github.com/JuliaGeometry/Meshing.jl) package.
Full documentation is available there.
In combination with GeometryTypes it is easy to mesh implicit functions.

```
using Meshes
using GeometryTypes

s = SignedDistanceField(HyperRectangle(Vec(0,0,0.),Vec(1,1,1.))) do v
           sqrt(sum(dot(v,v))) - 1 # sphere
       end
m = HomogenousMesh(s) # uses Marching Tetrahedra from Meshing.jl
save("eighth_sphere.ply",m)
```

## Files

Meshes v0.2.0 and up depends on the Julia FileIO framework in order to load
files. This is re-exported from FileIO.

```
using Meshes
m = load("my3dmodel.obj")
save("my3dmodel_now_a.ply", m)
```

## History

This package started with an exclusive focus on Mesh geometry. For the first
year of existence it worked exclusively for computational geometry purposes. In
early 2015 an effort started to generalize for compatibilty with display
libraries such as OpenGL. This meant redesigning types and operations.
Ultimately it was broken up into other packages to facilitate collaboration.
Most notably
[Meshing](https://github.com/JuliaGeometry/Meshing.jl),
[MeshIO](https://github.com/JuliaIO/MeshIO.jl),
and [GeometryTypes](https://github.com/JuliaGeometry/GeometryTypes.jl)
contain a significant portion of the original code. We plan to support this
package as a meta-package for domain focused usability and extensions.

## License
This package is available under the MIT "Expat" License. See [LICENSE.md](./LICENSE.md).
