# Meshes.jl

[![Build Status](https://travis-ci.org/twadleigh/Meshes.jl.png)](https://travis-ci.org/twadleigh/Meshes.jl)
[![Coverage Status](https://img.shields.io/coveralls/twadleigh/Meshes.jl.svg)](https://coveralls.io/r/twadleigh/Meshes.jl)

Generation and manipulation of triangular [polygon meshes](https://en.wikipedia.org/wiki/Polygon_mesh).

## Features
1. Isosurface extraction via [marching tetrahedra](https://en.wikipedia.org/wiki/Marching_tetrahedra).
2. Construction of volumes from primitive solids (sphere, box, cylinder).

### Import
Supported file formats:
* [Binary and ASCII STL](https://en.wikipedia.org/wiki/STL_%28file_format%29)
* [Aquaveo-SMS 2DM](http://www.xmswiki.com/xms/SMS:2D_Mesh_Files_*.2dm)
* [ASCII PLY](https://en.wikipedia.org/wiki/PLY)

Meshes can be imported with the following function.

```mesh(path::String; format=:autodetect, topology=false)```

By default the function autodetects the file format for you. You can specify a format manually by setting `format` to one of `:ply`, `:(2dm)`, `:binarystl`, or `:asciistl`.

By default we do not check topology for repeat vertices since it can be computationally expensive. If `topology` is set to `true`, repeat vertices are eliminated so the `Mesh` is a proper [face-vertex](https://en.wikipedia.org/wiki/Polygon_mesh#Face-vertex_meshes) polygon mesh.

### Export
Support export formats:
* [ASCII STL](https://en.wikipedia.org/wiki/STL_%28file_format%29)
* [Aquaveo-SMS 2DM](http://www.xmswiki.com/xms/SMS:2D_Mesh_Files_*.2dm)
* [ASCII PLY](https://en.wikipedia.org/wiki/PLY)
* [OFF](https://en.wikipedia.org/wiki/OFF_%28file_format%29)

## Coming soon, hopefully...

1. Basic mesh simplification.

## License
This package is available under the MIT "Expat" License. See [LICENSE.md](./LICENSE.md).
