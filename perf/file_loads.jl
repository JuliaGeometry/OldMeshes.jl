function stl_load_topology()
    mesh(data_dir*"cube.stl", topology=true);
end

function stl_load()
    mesh(data_dir*"cube.stl", topology=false);
end

function binary_stl_load_topology()
    mesh(data_dir*"cube_binary.stl", topology=true);
end

function binary_stl_load()
    mesh(data_dir*"cube_binary.stl", topology=false);
end
