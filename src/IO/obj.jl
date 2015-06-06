##############################
#
# obj-Files
#
##############################



immutable WafeFrontCommand{Command} end

# type for obj file data
type WavefrontObjFile{T,V}
    vertices::Vector{Vector3{T}}
    normals::Vector{Vector3{T}}
    tex_coords::Vector{Vector3{T}}
    
    normal_faces::Vector{WavefrontObjFace{V}}
    vertex_faces::Vector{WavefrontObjFace{V}}
    texture_coordinate_faces::Vector{WavefrontObjFace{V}}

    groups::Dict{String, Array{Int}}
    smoothing_groups::Dict{Int, Array{Int}}

    mtllibs::Vector{String}
    materials::Dict{String, Array{Int}}
    root_folder::UTF8String
end 
function WaveFronObjFile(FloatType::DataType, IntegerType::DataType, root_folder::String)
    vertices    = Vector3{FloatType}[]
    normals     = Vector3{FloatType}[]
    tex_coords  = Vector3{FloatType}[]
    faces::Vector{WavefrontObjFace{V}}

    groups                  = ["default" => Int[]]
    current_groups          = ["default"]
    smoothing_groups        = Dict{Int, Vector{Int}}(0 => Int[])
    current_smoothing_group = 0

    mtllibs          = UTF8String[]
    materials        = Dict("" => Int[]) # map material names to array with indieces of faces
    current_material = ""

    groups::Dict{String, Array{Int}}
    smoothing_groups::Dict{Int, Array{Int}}

    mtllibs::Vector{String}
    materials::Dict{String, Array{Int}}
    root_folder::UTF8String
end


function import(fn::File{:obj}; vertextype=Float64, faceindextype=Int)
    str = open(fn.abspath, "r")
    mesh = importObjFile(str, dirname(abspath(fn)), vertextype=vertextype, faceindextype=faceindextype)
    close(str)
    return mesh
end
function importObjFile{VT <: FloatingPoint, FT <: Integer}(io::IO, root_path::String; vertextype::Type{VT}=Float64, faceindextype::Type{FT}=Int)
    lineNumber = 1
    for line in eachline(io)
        # read a line, remove newline and leading/trailing whitespaces
        line = strip(chomp(line))
        @assert is_valid_ascii(line) "non valid ascii in obj"

        if !startswith(line, "#") && !isempty(line) && !iscntrl(line) #ignore comments
            line_parts = split(line)
            command    = shift!(line_parts) #first is the command, rest the data
            command    = WafeFrontCommand{symbol(command)}()
            process(command, line_parts, wff, lineNumber)
        end
        # read next line
        lineNumber += 1
    end
    # remove the "default" group, the 0 smoothing group and the empty material "" if they don't refer to any faces
    return obj
end


# face indices are allowed to be negative, this methods handles this correctly
function handle_index{T <: Integer}(bufferlength::Integer, s::String, index_type::Type{T})
    i = parseint(T, s)
    i < 0 && return convert(T, bufferlength) + i + one(T) # account for negative indexes
    return i
end
function push_index!{T}(buffer::Vector{T}, s::String)
    push!(buffer, handle_index(length(buffer), s, eltype(T)))
end


#Unknown command -> just a warning for now
function process{S <: String}(::WafeFrontCommand, line_parts::Vector{S}, w::WavefrontObjFile, line::Int)
    println("WARNING: Unknown line while parsing wavefront obj: $(w.root_folder) (line $line)")
end

#Vertices
function process{S <: String}(::WafeFrontCommand{:v}, line_parts::Vector{S}, w::WavefrontObjFile, line::Int)
    push!(w.vertices, Vector3{vertextype}(map(readfloat, line_parts)...))
end
#Normals
function process{S <: String}(::WafeFrontCommand{:vn}, line_parts::Vector{S}, w::WavefrontObjFile, line::Int)
    push!(w.normals, Vector3{vertextype}(map(readfloat, line_parts)...))
end
#Texture coordinates
function process{S <: String}(::WafeFrontCommand{:vt}, line_parts::Vector{S}, w::WavefrontObjFile, line::Int)
    if length(line_parts) >= 2 &&  length(line_parts) <= 3
        push!(w.uvs, Vector3{vertextype}(map(readfloat, line_parts)...))
    else 
        error("unrecognized uv format")
    end
end
#Groups
function process{S <: String}(::WafeFrontCommand{:g}, line_parts::Vector{S}, w::WavefrontObjFile, line::Int)
    current_groups = String[]
    if length(line_parts) >= 2
        for i=2:length(line_parts)
            push!(current_groups, line_parts[i]) 
            if !haskey(groups, line_parts[i])
                groups[line_parts[i]] = Int[]
            end
        end
    else
        current_groups = ["default"]
    end
end
#Smoothing group
function process{S <: String}(::WafeFrontCommand{:s}, line_parts::Vector{S}, w::WavefrontObjFile, line::Int)
    #smoothing group, 0 and off have the same meaning
    if line_parts[1] == "off" 
        current_smoothing_group = 0
    else
        current_smoothing_group = int(line_parts[2])
    end
    if !haskey(smoothing_groups, current_smoothing_group)
        smoothing_groups[current_smoothing_group] = Int[]
    end
end
# material lib reference
function process{S <: String}(::WafeFrontCommand{:mtllib}, line_parts::Vector{S}, w::WavefrontObjFile, line::Int)
    for i=2:length(line_parts)
        push!(mtllibs, line_parts[i])
    end
end
# set a new material
function process{S <: String}(::WafeFrontCommand{:usemtl}, line_parts::Vector{S}, w::WavefrontObjFile, line::Int)
    current_material = line_parts[2]
    if !haskey(materials, current_material)
        materials[current_material] = Int[]
    end
end
# faces:
#Faces are looking like this: f v1/vt1 v2/vt2 v3/vt3 ... OR f v1/vt1/vn1 v2/vt2/vn2 v3/vt3/vn3 .... OR f v1//vn1 v2//vn2 v3//vn3 ...

# Triangles:
function process{Cardinality, S <: String}(::WafeFrontCommand{:f}, line_parts::AbstractFixedVector{Cardinality, S}, w::WavefrontObjFile, line::Int)
    # inside faceindex, the coordinates looke like this: #/# or #/#/# or #//#. The first entry determines the type for all following entries
    seperator = contains(line_parts, "//") ? "//" : contains(line_parts, "/") ? "/" : error("unknown face seperator")
    face      = map(part -> split(part, seperator), line_parts)
    lp        = length(first(face))
    @assert lp >= 1 && lp <= 3 "Obj's should only allow for three vertex attributes. Attributes found: $(length(v)) in line $line"

    lp >= 1 && push_index!(w.vertex_index,             face[1])
    lp >= 2 && push_index!(w.texture_coordinate_index, face[2])
    lp == 3 && push_index!(w.normal_index,             face[3])
    # add face to groups, smoothing_group,
    for group in current_groups
        push!(groups[group], length(fcs)+1) 
    end

    push!(materials[current_material], length(fcs)+1)

    push!(smoothing_groups[current_smoothing_group], length(fcs)+1)

    push!(fcs, face)
end

# smoothing groups: "off" goes to smoothing group 0, so each face has a unique smoothing group
# faces with no material go to the empty material "", so each face has a unique material
