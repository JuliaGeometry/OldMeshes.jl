# https://en.wikipedia.org/wiki/Wavefront_.obj_file

function importOBJ(fn::String)
    str = open(fn,"r")
    mesh = importOBJ(str)
    close(str)
    return mesh
end


function importOBJ(io::IO)
    vts = Point{3,Float64}[]
    fcs = Face{3,Int,0}[]

    nV = 0
    nF = 0

    while !eof(io)
        txt = readline(io)
        line = split(txt)
        if line[1] == "v" #vertex
            push!(vts, Point{3,Float64}(parse(Float64, line[2]),
                              parse(Float64, line[3]),
                              parse(Float64, line[4])))
        elseif line[1] == "f" #face
            #get verts
            verts = [parse(Int, split(line[i], "/")[1]) for i = 2:length(line)]
            for i = 3:length(verts) #triangulate
                push!(fcs, Face{3,Int,0}(verts[1], verts[i-1], verts[i]))
            end
        end
    end

    return Mesh{Point{3,Float64}, Face{3,Int,0}}(vts, fcs)
end

