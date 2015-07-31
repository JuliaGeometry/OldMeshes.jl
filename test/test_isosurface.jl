using Meshes, GeometryTypes
function test()
  N1 = 10
  N2 = 200
  const volume1  = Float32[sin(x/14f0)*sin(y/14f0)*sin(z/14f0) for x=1:N1, y=1:N1, z=1:N1]

  @time isosurface(volume1, 0.5f0, 0.001f0)
  const volume2  = Float32[sin(x/14f0)*sin(y/14f0)*sin(z/14f0) for x=1:N2, y=1:N2, z=1:N2]
  max     = maximum(volume2)
  min     = minimum(volume2)
  volume2  = (volume2 .- min) ./ (max .- min)
  @time msh = GLNormalMesh(volume2, 0.5f0)
  @time vtx = isosurface(volume2, 0.5f0, 0.001f0)

end

GLUVWMesh(Cube(Vector3(0f0), Vector3(1f0)))
GLUVMesh2D(Rectangle{Float32}(0f0,0f0,10f0, 10f0))
GLNormalMesh(Cube(Vector3(0f0), Vector3(1f0)))

test()
#1.649335471
#N=200³
#1.26
#1.458748696 
#N=400³
#11 - 13 s
#14 - 18 s