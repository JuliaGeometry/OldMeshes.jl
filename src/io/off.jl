export exportToOFF

function exportToOFF(msh::Mesh, fn::String, rgba)
    # writes an OFF geometry file, with colors
    #  see http://people.sc.fsu.edu/~jburkardt/data/off/off.html
    #  for format description
    vts = msh.vertices
    fcs = msh.faces
    nV = size(vts,1)
    nF = size(fcs,1)
    nE = nF*3

    str = open(fn,"w")

    # write the header
    write(str,"OFF\n")
    write(str,"$nV $nF $nE\n")

    # write the data
    for i = 1:nV
        v = vts[i]
        txt = @sprintf " %f %f %f\n" float32(v.e1) float32(v.e2) float32(v.e3)
        write(str,txt)
    end

    for i = 1:nF
        f = fcs[i]
        c = rgba[i,:]
        txt = @sprintf "  3 %i %i %i  %f %f %f %f\n" int32(f.v1-1) int32(f.v2-1) int32(f.v3-1)  float32(c[1]) float32(c[2]) float32(c[3]) float32(c[4])
        write(str,txt)
    end
    close(str)
end
