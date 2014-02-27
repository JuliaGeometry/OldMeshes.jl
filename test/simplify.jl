using Meshes

# make a simple grid mesh
n = 10
vts = Array(Vertex,n*n)
k = 1
for i = 1:n, j = 1:n
    vts[k] = Vertex(float(i),float(j),0.0)
    k += 1
end
fcs = Array(Face,2*(n-1)^2)
k = 1
for i = 1:n-1, j = 1:n-1
    v1 = n*(i-1)+j
    v2 = v1 + 1
    v3 = v1 + n
    v4 = v3 + 1
    fcs[k]   = Face(v1,v3,v4)
    fcs[k+1] = Face(v1,v4,v2)
    k += 2
end
msh = Mesh(vts,fcs)

# simplify it
simplify(msh,0.1)

# write it out
exportToPly(msh,"grid.ply")

