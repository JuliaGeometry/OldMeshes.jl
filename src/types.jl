abstract AbstractFixedVector{C}

immutable Vector3{T} <: AbstractFixedVector{3}
  x::T
  y::T
  z::T
end

immutable AABB{T}
    min::Vector3{T}
    max::Vector3{T}
end


immutable Face{T} <: AbstractFixedVector{3}
    i1::T
    i2::T
    i3::T
end
immutable Triangle{T} <: AbstractFixedVector{3}
    i1::T
    i2::T
    i3::T
end

immutable UV{T} <: AbstractFixedVector{2}
    u::T
    v::T
end
immutable UVW{T} <: AbstractFixedVector{3}
    u::T
    v::T
    w::T
end
immutable Vertex{T} <: AbstractFixedVector{3}
    x::T
    y::T
    z::T
end
immutable Normal{T} <: AbstractFixedVector{3}
    x::T
    y::T
    z::T
end

immutable Vector2{T} <: AbstractFixedVector{3}
  x::T
  y::T
end
# No fixedsizeArrays yet:
Base.getindex(a::AbstractFixedVector, i::Integer) = getfield(a,i)


immutable Material{T}
    diffuse::RGB{T}
    ambient::RGB{T}
    specular::RGB{T}
    specular_exponent::RGB{T}
end


immutable GLMesh{Attributes}
    data::Dict{Symbol, Any}
    material::Vector{Vector{RGBA{Float32}}}
    material_id::Vector{Uint32}
    textures::Dict{Symbol, Vector{Matrix}}
    model::Matrix4x4
end



Material() = RGBA{Float32}[rgba(0.99f0), rgba(0.99f0), rgba(0.99f0), rgba(90f0)]
const DEFAULT_TEX_MAP = Matrix{RGBAU8}[fill(rgbaU8(0,0,0,0), 1,1)]
function GLMesh(data...; material = Vector{RGBA{Float32}}[Material()], 
        material_id = Uint32[0],
        textures= @compat(Dict(
            :diffuse_texture  => DEFAULT_TEX_MAP, 
            :ambient_texture  => DEFAULT_TEX_MAP,
            :specular_texture => DEFAULT_TEX_MAP)), 
        model=eye(Mat4))

    
    result = (Symbol => DataType)[]
    meshattributes = Dict{Symbol, Any}()
    for elem in data
        typ                     = isa(elem, Vector) ? eltype(elem) : typeof(elem)
        keyname                 = symbol(lowercase(replace(string(typ.name.name), r"\d", "")))
        result[keyname]         = typ
        meshattributes[keyname] = elem
    end
    #sorting of parameters... Solution a little ugly for my taste
    result        = sort(map(x->x, result))
    mesh          = GLMesh{tuple(map(x->x[2], result)...)}(meshattributes, material, material_id, textures, model)
    mesh[:vertex] = unitGeometry(mesh[:vertex])
    mesh
end
Base.getindex(m::GLMesh, key::Symbol)       = m.data[key]
Base.setindex!(m::GLMesh, arr, key::Symbol) = m.data[key] = arr
function Base.show(io::IO, m::GLMesh)
    println(io, "Mesh:")
    maxnamelength = 0
    maxtypelength = 0
    names = map(m.data) do x
        n = string(x[1])
        t = string(eltype(x[2]).parameters...)
        namelength = length(n)
        typelength = length(t)
        maxnamelength = maxnamelength < namelength ? namelength : maxnamelength
        maxtypelength = maxtypelength < typelength ? typelength : maxtypelength

        return (n, t, length(x[2]))
    end

    for elem in names
        kname, tname, alength = elem
        namespaces = maxnamelength - length(kname)
        typespaces = maxtypelength - length(tname)
        println(io, "   ", kname, " "^namespaces, " : ", tname, " "^typespaces, ", length: ", alength)
    end
end

function Base.convert{T}(::Type{Face{T}}, face::Meshes.Face)
    Face{T}(
        face.v1,face.v2,face.v3
    )
end
function Base.convert{T}(::Type{Vertex{T}}, vertex::Vector3)
    Vertex{T}(
        vertex.(1),vertex.(2),vertex.(3)
    )
end
function Base.convert{T, TI}(::Type{GLMesh{( Face{TI}, Normal{T}, UV{Float32}, Vertex{T})}}, mesh::Meshes.Mesh)
    faces = map(mesh.faces) do face
        Face{TI}(face.v1-1, face.v2-1, face.v3-1) 
    end
    vertices = map(mesh.vertices) do vertex
        convert(Vertex{T}, vertex)
    end
    GLMesh(faces, vertices, gen_normals(faces, vertices), UV(-1f0, -1f0))
end

function Base.convert{T <: GLMesh}(::Type{T}, mesh::WavefrontObjFile)
    computeNormals!(mesh, smooth_normals = true, override = false)
    triangulate!(mesh)
    # center geometry
    mesh.vertices = unitGeometry(mesh.vertices)
    # load mtl files if present
    assets_path = mesh.root_folder
    materials = (map(mesh.mtllibs) do mtllib
        readMtlFile(assets_path*mtllib, colortype=Float32 )
    end)[1]
    textures    = Dict{Symbol, Any}()
    material    = Vector{RGBA{Float32}}[RGBA{Float32}[rgba(0,0,0,1) for i=1:4] for j=1:length(materials)]
    for (i, mtl) in enumerate(materials)
        for (j, tex_name) in [(1,:diffuse_texture), (2,:ambient_texture), (3,:specular_texture)]
            tex_path    = searchfile(getfield(mtl, tex_name), assets_path)
            mat_symbol  = symbol(split(string(tex_name), "_")[1])
            if tex_path != ""
                img        = imread(tex_path).data
                tex_arrays = get(textures, tex_name, typeof(img)[])
                push!(tex_arrays, img)
                textures[tex_name] = tex_arrays
                material[i][j]     = rgba(length(tex_arrays)-1, 0, 0,-1) # for loading indexes, -1 for 0 indexing
            else
                material[i][j]     = reinterpret(RGBA{Float32}, Float32[getfield(mtl, mat_symbol)..., 1f0])[1]
            end
        end
    end
    vs_compiled, nvs_compiled, uvs_compiled, material_id, fcs_compiled = compile(mesh)


    faces    = reinterpret(Face{Uint32}, fcs_compiled)
    vertices = reinterpret(Vertex{Float32}, vs_compiled)
    normals  = reinterpret(Normal{Float32}, nvs_compiled)
    uv       = UV{Float32}[UV{Float32}(_uv[1], _uv[2]) for _uv in uvs_compiled]
    GLMesh(faces, vertices, normals, uv, material_id=material_id, textures=textures, material=material)
end


function texturesused(mesh::GLMesh)
    usedtextures = fill(-1f0, length(names(TextureUsed)))
    for (i,attribute) in enumerate(names(TextureUsed))
        usedtextures[i] = haskey(mesh.textures, attribute) ? -1f0 : 1f0
    end
    usedtextures
end

function Base.show{T <: AbstractAlphaColorValue}(io::IO, m::T)
    print(io, "[")
    for i=1:3
        print(io, m.(1).(i),", ")
    end
    println(io, m.(2), "]")
end
function Base.show{T <: ColorValue}(io::IO, m::T)
    print(io, "[")
    for i=1:length(names(T))
        print(io, m.(i),", ")
    end
    println(io, "]")
end


function collect_for_gl(mesh::GLMesh)
    tused    = texturesused(mesh)
    material = RGBA{Float32}[mat[i] for mat in mesh.material, i=1:4]
    texures  = [k => Texture(convert(Vector{typeof(texture_array[1])}, texture_array)) for (k, texture_array) in mesh.textures]
    data = merge(
        [k => isa(v,Vector) ? (eltype(v) <: Face ? indexbuffer(v) : GLBuffer(v)) : v for (k,v) in mesh.data], 
        texures,
        @compat(Dict(
        #:material_id   => GLBuffer(uint32(mesh.material_id-one(Uint32)), 1),
        :material_map  => Texture(material),
        :model         => mesh.model,
    )))
    for (k,v) in data
        println(k, ": ", typeof(v))
    end
    data
end