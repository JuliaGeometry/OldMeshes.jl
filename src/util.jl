# Should probably go into base!?
foreach(func::Function, collection) = for elem in collection; func(elem); end


# Simple file wrapper, which encodes the type of the file in its parameter
# Usefull for file IO
immutable File{Ending}
	abspath::UTF8String
end
function File(file)
	@assert !isdir(file) "file string refers to a path, not a file. Path: $file"
	file 	= abspath(file)
	path 	= dirname(file)
	name 	= file[length(path):end]
	ending 	= rsearch(name, ".")
	ending  = isempty(ending) ? "" : name[first(ending)+1:end]
	File{symbol(ending)}(file)
end


function searchfile(file_name::String, root_folder::String)
    file_name == "" && return ""
    files_folders = readdir(root_folder)
    folders       = filter(x->isdir(joinpath(root_folder, x)), files_folders)
    files         = filter(x->!isdir(joinpath(root_folder, x)), files_folders)
    results = filter(x-> x == file_name, files)
    if !isempty(results)
        return joinpath(root_folder, first(results))
    elseif isempty(folders)
        return ""
    else
        for folder in folders
            result = searchfile(file_name, joinpath(root_folder, folder))
            result != "" && return result
        end
    end
    ""
end