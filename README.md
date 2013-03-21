# Meshes.jl

Generation and manipulation of triangular meshes.

## Features

* Isosurface extraction via marching tetrahedra.
* Import
    - Aquaveo-SMS .2dm 
* Export
    - Ply
    - Stl
    - Aquaveo-SMS .2dm 

## ToDo

* Simplification
    - Quadric Edge Decimation
* Slicing/Profiling (taking cross-section from planes)
* Boundary-extraction
* Interpolation from point-cloud
* Difference between arbitrary meshes
* New Types
    - `PointSet`
    - `HalfEdgeSet`
    - `Curve`
    - `Plane`
* Conversion `IndexedFaceSet` -> `HalfEdgeSet` (may make boundary-extraction and slicing easier)
* Triangulation of `PointSet`
    - Using [Triangle](http://www.cs.cmu.edu/~quake/triangle.html)
    - Using [QHull](http://qhull.org)
    - Using [GEOS](http://trac.osgeo.org/geos/)
