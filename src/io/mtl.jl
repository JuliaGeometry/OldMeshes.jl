##############################
#
# mtl-Files
#
##############################

export WavefrontMtlMaterial, 
    readMtlFile

type WavefrontMtlMaterial{T}
    name::String
    ambient::Vector3{T}
    specular::Vector3{T}
    diffuse::Vector3{T}
    transmission_filter::Vector3{T}
    illum::Int
    dissolve::T
    specular_exponent::T
    ambient_texture::String
    specular_texture::String
    diffuse_texture::String
    bump_map::String
end

function WavefrontMtlMaterial(colortype=Float64)
    return WavefrontMtlMaterial{colortype}(
                "", 
                Vector3(zero(colortype)), 
                Vector3(zero(colortype)), 
                Vector3(zero(colortype)),
                Vector3(zero(colortype)), 
                0, 
                zero(colortype),
                zero(colortype),
                "",
                "",
                "",
                "" 
            )
end

function readMtlFile(fn::String; colortype=Float64)
    str = open(fn,"r")
    mesh = readMtlFile(str, colortype=colortype)
    close(str)
    return mesh
end

function parseMtlColor(s::String, colortype=Float64)
    colorconvfnc = colortype == Float64 ? float64 : (colortype == Float32 ? float32 : error("colortype: ", colortype, " not supported"))

    line_parts = split(s)

    if length(line_parts) == 3 # r b g
        return Vector3{colortype}(colorconvfnc(line_parts[1]), colorconvfnc(line_parts[2]), colorconvfnc(line_parts[3]))
    elseif line_parts[1] == "spectral" 
        println("WARNING Parsing Mtl-File: spectral color type not supported")
        return Vector3{colortype}(colorconvfnc(1.0), colorconvfnc(0.412), colorconvfnc(0.705))
    else
        println("WARNING Parsing Mtl-File: CIEXYZ color space or wrong color type. Not supported")
        return Vector3{colortype}(colorconvfnc(1.0), colorconvfnc(0.412), colorconvfnc(0.705))
    end
end

function parseMtlTextureMap(s::String)
    line_parts = split(s)

    if length(line_parts) == 1 # no options
        return line_parts[1]
    else
        println("WARNING Parsing Mtl-File: texture map options or invalid texutre map command. Not supported")
        return ""
    end
end

# supports the non-standard keywords: map_bump, map_refl
function readMtlFile(io::IO; colortype=Float64)
    colorconvfnc = colortype == Float64 ? float64 : (colortype == Float32 ? float32 : error("colortype: ", colortype, " not supported"))

    materials = WavefrontMtlMaterial{colortype}[]

    lineNumber = 1
    while !eof(io)
        # read a line, remove newline and leading/trailing whitespaces
        line = strip(chomp(readline(io)))
        @assert is_valid_ascii(line)

        if !startswith(line, "#") && !isempty(line) && !iscntrl(line) #ignore comments
            line_parts = split(line)
            command = line_parts[1]
            remainder = length(line_parts) > 1 ? line[searchindex(line, line_parts[2]):end] : ""

            # new material
            if command == "newmtl"
                push!(materials, WavefrontMtlMaterial(colortype))
                materials[end].name = line_parts[2]
            # abmient
            elseif command == "Ka"
                materials[end].ambient = parseMtlColor(remainder, colortype)
            # diffuse
            elseif command == "Kd"
                materials[end].diffuse = parseMtlColor(remainder, colortype)
            # specular
            elseif command == "Ks"
                materials[end].specular = parseMtlColor(remainder, colortype)
            # transmission filter
            elseif command == "Tf"
                materials[end].transmission_filter = parseMtlColor(remainder, colortype)
            # illumination model
            elseif command == "illum"
                materials[end].illum = parse(Int, line_parts[2])
            # dissolve
            elseif command == "d"
                if line_parts[2] == "-halo"
                    println("WARNING Parsing Mtl-File: d -halo not supported")
                else
                    materials[end].dissolve = colorconvfnc(line_parts[2])
                end
            # specular exponent
            elseif command == "Ns"
                materials[end].specular_exponent = colorconvfnc(line_parts[2])
            # sharpness
            elseif command == "sharpness"
                println("WARNING Parsing Mtl-File: sharpness not supported")
            # optical density
            elseif command == "Ni"
                println("WARNING Parsing Mtl-File: optical density not supported")
            # ambient texture map
            elseif command == "map_Ka"
                materials[end].ambient_texture = parseMtlTextureMap(remainder)
            # diffuse texture map
            elseif command == "map_Kd"
                materials[end].diffuse_texture = parseMtlTextureMap(remainder)
            # specular texture map
            elseif command == "map_Ks"
                materials[end].specular_texture = parseMtlTextureMap(remainder)
            # specular exponent texture map
            elseif command == "map_Ns"
                println("WARNING Parsing Mtl-File: map_Ns not supported")
            # dissolve texture map
            elseif command == "map_d"
                println("WARNING Parsing Mtl-File: map_d not supported")
            # ???
            elseif command == "disp"
                println("WARNING Parsing Mtl-File: disp not supported")
            # ???
            elseif command == "decal"
                println("WARNING Parsing Mtl-File: decal not supported")
            # bump map
            elseif command == "bump" || command == "map_bump"
                materials[end].bump_map = parseMtlTextureMap(remainder)   
            # ???
            elseif command == "refl" || command == "map_refl" 
                println("WARNING Parsing Mtl-File: refl not supported")
            # unknown line
            else 
                println("WARNING: Unknown line while parsing wavefront .mtl: '$line' (line $lineNumber)")
            end
        end

        # read next line
        lineNumber += 1
    end

    return materials
end
