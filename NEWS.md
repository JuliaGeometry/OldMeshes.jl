# Meshes.jl v0.1.0 Release Notes
This is a release introducing breaking changes over the v0.0.x series. It
supports Julia versions 0.3.

* `Mesh` is now parameterized by vertex type and face type.
* `Face` is also parameterized by field type. (#21)
* Improved marching tetrahedra code (#45)
* Support for ThreeJS files, and Jupyter rendering. (#27, #28)
* `unique` method to make sure Mesh vertices are unique.
* File API moved to the `Files` submodule.
