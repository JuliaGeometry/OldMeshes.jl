using FactCheck
using Meshes, GeometryTypes

function testUnionNotInterection()
    # creates Union, Not, Intersection of cube and sphere
    # http://en.wikipedia.org/wiki/Constructive_solid_geometry

    # volume of interest
    x_min, x_max = -1, 15
    y_min, y_max = -1, 5
    z_min, z_max = -1, 5
    scale = 8

    b1(x,y,z) = box(   x,y,z, 0,0,0,3,3,3)
    s1(x,y,z) = sphere(x,y,z, 3,3,3,sqrt(3))
    f1(x,y,z) = min(b1(x,y,z), s1(x,y,z))  # UNION
    b2(x,y,z) = box(   x,y,z, 5,0,0,8,3,3)
    s2(x,y,z) = sphere(x,y,z, 8,3,3,sqrt(3))
    f2(x,y,z) = max(b2(x,y,z), -s2(x,y,z)) # NOT
    b3(x,y,z) = box(   x,y,z, 10,0,0,13,3,3)
    s3(x,y,z) = sphere(x,y,z, 13,3,3,sqrt(3))
    f3(x,y,z) = max(b3(x,y,z), s3(x,y,z))  # INTERSECTION
    f(x,y,z) = min(f1(x,y,z), f2(x,y,z), f3(x,y,z))

    vol = volume(f, x_min,y_min,z_min,x_max,y_max,z_max, scale)
    GLNormalMesh(vol, 0.0)
end
function testCylinders()
    c1(x,y,z) = cylinderX(x,y,z, 0,0,1,-2,4)
    c2(x,y,z) = cylinderY(x,y,z, 0,0,1,-2,4)
    c3(x,y,z) = cylinderZ(x,y,z, 0,0,1,-2,4)
    f(x,y,z) = min(c1(x,y,z), c2(x,y,z), c3(x,y,z))

    vol = volume(f, -3,-3,-3, 5,5,5, 2)
    msh = GLNormalMesh(vol, 0.0)
end


facts("Meshes") do 
	context("Volumes") do 
		msh = testUnionNotInterection()
		@fact typeof(msh) --> GLNormalMesh
		msh = testCylinders()
		@fact typeof(msh) --> GLNormalMesh

	end
	context("iso surfaces") do 
		N1 = 10
		volume1  = Float32[sin(x/14f0)*sin(y/14f0)*sin(z/14f0) for x=1:N1, y=1:N1, z=1:N1]
		msh = GLNormalMesh(volume1, 0.5f0, 0.001f0)
		@fact typeof(msh) --> GLNormalMesh
	end
end

#=
data_path = Pkg.dir("Meshes")*"/test/data/"

s = slice(mesh(data_path*"cube_binary.stl", topology=true), [1.0, 2.0])

context("cube slice")
    @fact length(s) --> 2
    @fact length(s[1]) == length(s[2]) --> 1
    @fact s[1][1] == [([0.0,1.0],[0.0,0.0]),([0.0,0.0],[1.0,0.0]),([1.0,0.0],[10.0,0.0]),([10.0,0.0],[10.0,1.0]),([10.0,1.0],[10.0,10.0]),([10.0,10.0],[1.0,10.0]),([1.0,10.0],[0.0,10.0]),([0.0,10.0],[0.0,1.0])]
    @fact s[2][1] == [([0.0,2.0],[0.0,0.0]),([0.0,0.0],[2.0,0.0]),([2.0,0.0],[10.0,0.0]),([10.0,0.0],[10.0,2.0]),([10.0,2.0],[10.0,10.0]),([10.0,10.0],[2.0,10.0]),([2.0,10.0],[0.0,10.0]),([0.0,10.0],[0.0,2.0])]
end


context("cube slice")
    m = mesh(data_path*"cube_binary.stl")
    int_m = convert(Mesh{Vector3{Int}, Face{Int}}, m, 1000)
    s = slice(int_m, [100, 200, 5000])
    @fact s[1] --> [([0,100],[0,0]),([0,10000],[0,100]),([100,0],[10000,0]),([0,0],[100,0]),([100,10000],[0,10000]),([10000,10000],[100,10000]),([10000,100],[10000,10000]),([10000,0],[10000,100])]
    @fact s[2] --> [([0,200],[0,0]),([0,10000],[0,200]),([200,0],[10000,0]),([0,0],[200,0]),([200,10000],[0,10000]),([10000,10000],[200,10000]),([10000,200],[10000,10000]),([10000,0],[10000,200])]
    @fact s[3] --> [([0,5000],[0,0]),([0,10000],[0,5000]),([5000,0],[10000,0]),([0,0],[5000,0]),([5000,10000],[0,10000]),([10000,10000],[5000,10000]),([10000,5000],[10000,10000]),([10000,0],[10000,5000])]
end
=#

# run lint if run with --lint
if "--lint" in ARGS
    using Lint
    println("Running Lint...")
    lintpkg("Meshes")
end

# make Travis fail when tests fail:
FactCheck.exitstatus()
