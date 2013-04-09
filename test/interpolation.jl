require("Meshes")
using Meshes
m = import2dm("./ex.2dm")
vInt = Vertex(0.1,0.1,0)
vExt = Vertex(5,5,0)
f = AFace(Vertex(0,0,5), Vertex(1,0,5), Vertex(0,1,5))
vs = Vertex[Vertex(50,50,1000), Vertex(60,60,1000)]
interpolate(vInt,f)
interpolate(vExt,f)
interpolate(vs,m)
