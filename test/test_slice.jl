
println("Testing Slice..")

data_path = Pkg.dir("Meshes")*"/test/data/"

s = slice(mesh(data_path*"cube_binary.stl"), [1.0, 2.0])

let
    @test length(s) == 2
    @test length(s[1]) == length(s[2]) == 1
    exp1 = [([0.0,1.0],[0.0,0.0]),([0.0,0.0],[1.0,0.0]),
                      ([1.0,0.0],[10.0,0.0]),([10.0,0.0],[10.0,1.0]),
                      ([10.0,1.0],[10.0,10.0]),([10.0,10.0],[1.0,10.0]),
                      ([1.0,10.0],[0.0,10.0]),([0.0,10.0],[0.0,1.0])]
    exp2 = [([0.0,2.0],[0.0,0.0]),([0.0,0.0],[2.0,0.0]),
                      ([2.0,0.0],[10.0,0.0]),([10.0,0.0],[10.0,2.0]),
                      ([10.0,2.0],[10.0,10.0]),([10.0,10.0],[2.0,10.0]),
                      ([2.0,10.0],[0.0,10.0]),([0.0,10.0],[0.0,2.0])]
    @test length(s[1][1]) == length(exp1)
    @test length(s[2][1]) == length(exp2)
    for i = 1:length(exp1)
        @test s[1][1][i][1] == Point(exp1[i][1])
        @test s[1][1][i][2] == Point(exp1[i][2])
    end
    for i = 1:length(exp2)
        @test s[2][1][i][1] == Point(exp2[i][1])
        @test s[2][1][i][2] == Point(exp2[i][2])
    end
end
